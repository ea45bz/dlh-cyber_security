#!/bin/bash
# 1-service_deps.sh – build a service → package dependency map
#
# The script:
#   • lists every active systemd service,
#   • resolves the binary that is running for the service,
#   • finds all dynamic libraries used by that binary,
#   • maps every executable / library back to its owning Debian package,
#   • reads criticality from service_criticality.json,
#   • flags whether a patch of any linked package would require a restart.
#
# Requires:  systemd, dpkg, ldd, jq (≥1.5), apt

set -euo pipefail
IFS=$'\n\t'

CRIT_FILE="service_criticality.json"
OUT_FILE="service_dependency_map.json"

# --------------------------------------------------------------------
# Packages that have an upgradable version – used to determine if a
# service will need a restart when one of its libraries is patched.
declare -A UPGRADES
while read -r line; do
    pkg=${line%%/*}
    [[ $pkg ]] && UPGRADES[$pkg]=1
done < <(apt list --upgradable 2>/dev/null | tail -n +2)

# --------------------------------------------------------------------
# Helper – find the package that owns a file (first match)
file_pkg() {
    local file=$1
    dpkg -S "$file" 2>/dev/null | head -n1 | cut -d: -f1 || echo "unknown"
}

# --------------------------------------------------------------------
# Resolve ExecStart from unit file if service is not running.
unit_exec_start() {
    local svc=$1
    local path=$(systemctl show -p FragmentPath --value "$svc" 2>/dev/null)
    [ ! -s "$path" ] && return 1
    grep '^ExecStart=' "$path" | sed 's/^[^=]*=\([^ ;]\+\).*/\1/' || true
}

# --------------------------------------------------------------------
echo "Building dependency map…"

services=$(systemctl list-units --type=service --state=active \
          --no-legend | awk '{print $1}')

json_out="["

first=true
for svc in $services; do
    # Resolve executable path ------------------------------------------
    exec_path=""
    pid=$(systemctl show -p MainPID --value "$svc" 2>/dev/null || echo 0)
    if [[ $pid -ne 0 && -e /proc/$pid/exe ]]; then
        exec_path=$(readlink -f "/proc/$pid/exe")
    else
        # fallback to unit file
        exec_path=$(unit_exec_start "$svc") || exec_path=""
    fi

    if [[ -z $exec_path ]]; then
        echo "  * warning: could not resolve executable for $svc – skipping" >&2
        continue
    fi

    # Owning package of the service binary -----------------------------
    main_pkg=$(file_pkg "$exec_path")

    # Gather dynamic libs -----------------------------------------------
    mapfile -t libs < <(ldd "$exec_path" 2>/dev/null | awk '
        /=>/{
            sub(/^.*=>[[:space:]]*/, "", $0);
            if ($1 !~ /^linux-vdso$/) {print $1}
        }' | sort -u)

    # Resolve libraries to packages -------------------------------------
    declare -A pkgs
    pkgs[$main_pkg]=1          # include the executable itself

    for lib in "${libs[@]}"; do
        pkg=$(file_pkg "$lib")
        pkgs[$pkg]=1
    done

    linked_pkgs=()
    for p in "${!pkgs[@]}"; do
        [[ $p != "unknown" ]] && linked_pkgs+=("$p")
    done
    # Remove duplicates, keep order (original order of insertion)
    linked_pkgs=$(printf '%s\n' "${linked_pkgs[@]}" | awk '!seen[$0]++')

    # Criticality --------------------------------------------------------
    crit=$(jq -r --arg svc "$svc" '.[$svc] // "low"' "$CRIT_FILE")

    # Does any linked package have a pending upgrade? --------------------
    restart=false
    for p in $linked_pkgs; do
        if [[ ${UPGRADES[$p]+_} ]]; then
            restart=true
            break
        fi
    done

    # Build JSON entry -----------------------------------------------
    entry=$(jq -n \
        --arg svc "$svc" \
        --arg exec_path "$exec_path" \
        --arg pkg_main "$main_pkg" \
        --argjson linked "$(printf '%s\n' "${linked_pkgs[@]}" | jq -R . | jq -s .)" \
        --arg crit "$crit" \
        --argjson restart $restart \
        '{
            service: $svc,
            exec_path: $exec_path,
            owning_package: $pkg_main,
            linked_packages: $linked,
            criticality: $crit,
            restart_required_on_patch: $restart
         }')

    if ! $first; then json_out+=$'\n,'; fi
    json_out+=$entry
    first=false

done

json_out+="]"

echo "$json_out" > "$OUT_FILE"
chmod 644 "$OUT_FILE"

echo "Done – output written to $OUT_FILE"

# --------------------------------------------------------------------
