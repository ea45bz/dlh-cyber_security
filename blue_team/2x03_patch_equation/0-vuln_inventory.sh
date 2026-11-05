#!/bin/bash
# 0-vuln_inventory.sh – inventory installed packages + pending security updates

set -euo pipefail

CVE_FEED="cve_feed.json"      # supplied snapshot
OUT_FILE="vulnerability_inventory.json"

# --------------------------------------------------------------------
echo "[*] Enumerating installed packages..."
mapfile -t INSTALLED < <(dpkg-query -W -f='${binary:Package} ${Version} ${Status}\n')

# --------------------------------------------------------------------
# Prepare list of upgradable packages
echo "[*] Checking for available upgrades..."
UPG_LIST=$(apt list --upgradable 2>/dev/null | tail -n +2)   # skip header

declare -A UPG_VERS       # pkg -> candidate version
declare -A UPG_POCKET     # pkg -> pocket

while read -r line; do
    pkg=${line%%/*}
    cand_ver=$(echo "$line" | awk '{print $3}')
    if [[ -z $cand_ver ]]; then continue; fi
    UPG_VERS[$pkg]=$cand_ver

    # Determine the source pocket (security, updates, backports, etc.)
    pocket=$(apt-cache policy "$pkg" 2>/dev/null |
             grep -E 'Candidate:' -A1 | tail -n1 | awk '{print $2}')
    UPG_POCKET[$pkg]=$pocket
done <<<"$UPG_LIST"

# --------------------------------------------------------------------
echo "[*] Parsing CVE feed..."
if [[ ! -f "$CVE_FEED" ]]; then
    echo "CVE feed not found: $CVE_FEED" >&2
    exit 1
fi

cve_data=$(jq '.' "$CVE_FEED")

# helper to get CVSS and severity for a CVE
get_cve_info() {
    local cve=$1
    jq -r --arg cve "$cve" '.[] | select(.id==$cve) | {cvss:$cvss_base_score, severity:$severity}' <<<"$cve_data"
}

# --------------------------------------------------------------------
echo "[*] Building inventory..."

json_out=$(jq -n --compact-output '{"packages": []}')

for pkg_line in "${INSTALLED[@]}"; do
    pkg=${pkg_line%%,*}
    ver_installed=${pkg_line##*,}
    ver_installed=${ver_installed%%,*}

    # skip if no upgrade candidate or not a security pocket
    cand_version=${UPG_VERS[$pkg]}
    pocket=${UPG_POCKET[$pkg]}

    if [[ -z $cand_version || $pocket != *security* ]]; then
        continue
    fi

    # gather CVEs from changelog (apt-get changelog may block; we ignore errors)
    cves=()
    if output=$(apt-get changelog "$pkg" 2>/dev/null | grep -iE '^-\s*CVE-\d{4}-\d+' 2>/dev/null); then
        while read -r line; do
            cv=$line
            cv=${cv##*-}   # remove leading '- '
            cves+=("$cv")
        done <<<"$output"
    fi

    # If no CVEs found in changelog, try USN mapping (Ubuntu Advantage)
    if [[ ${#cves[@]} -eq 0 && -d /usr/share/ubuntu-advantage-tools ]]; then
        for file in /usr/share/ubuntu-advantage-tools/*/*.txt; do
            if grep -q "$pkg" "$file"; then
                cve_line=$(grep "$pkg" "$file")
                cv=${cve_line##*CVE-}
                IFS=' ' read -ra parts <<<"$cv"
                for p in "${parts[@]}"; do
                    [[ $p =~ ^[0-9]{4}-[0-9]+$ ]] && cves+=("CVE-$p")
                done
            fi
        done
    fi

    # compute max CVSS, severity and CISA KEV flag
    max_cvss=0
    max_sev="unknown"
    in_cisa=false
    for cv in "${cves[@]}"; do
        read -r cvss sev <<<$(get_cve_info "$cv")
        if [[ $cvss && $(echo "$cvss > $max_cvss" | bc -l) == 1 ]]; then
            max_cvss=$cvss
            max_sev=$sev
        fi
        # check KEV list (kevs.json bundled with project)
        if grep -q "^$cv\$" kev_list.txt 2>/dev/null; then
            in_cisa=true
        fi
    done

    entry=$(jq -n --compact-output \
        --arg p "$pkg" \
        --arg iv "$ver_installed" \
        --arg cv "$cand_version" \
        --arg po "$pocket" \
        --argjson cve_list "$(printf '%s\n' "${cves[@]}" | jq -R . | jq -s .)" \
        --arg cs "$max_cvss" \
        --arg sev "$max_sev" \
        --argbool kev "$in_cisa" \
        '{
            package: $p,
            installed_version: $iv,
            candidate_version: $cv,
            source_pocket: $po,
            cves: $cve_list,
            max_cvss: ($cs|tonumber),
            severity: $sev,
            in_cisa_kev: $kev
        }')
    json_out=$(jq --argjson new "$entry" '.packages += [$new]' <<<"$json_out")
done

echo "$json_out" > "$OUT_FILE"
echo "Output written to $OUT_FILE"

# --------------------------------------------------------------------
