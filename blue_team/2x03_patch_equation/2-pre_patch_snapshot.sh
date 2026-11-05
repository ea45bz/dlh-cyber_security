#!/bin/bash
# 2-pre_patch_snapshot.sh – capture a full system snapshot before any patch

set -euo pipefail
IFS=$'\n\t'

OUT_FILE="pre_patch_state.json"

# --------------------------------------------------------------------
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
hostname=$(hostname)
kernel=$(uname -r)

# check for reboot required flag file
reboot_flag="/var/run/reboot-required"
if [[ -f $reboot_flag ]]; then
    reboot_required=true
else
    reboot_required=false
fi

# --------------------------------------------------------------------
echo "Collecting package list..."
packages=$(dpkg-query -W -f='${binary:Package}\t${Version}\n')
# convert to JSON array of objects {name, version}
pkg_json=$(printf '%s\n' "$packages" | awk -F'\t' '{print "{ \"name\": \""$1"\", \"version\": \""$2"\" }"}' | jq -cs .)

# --------------------------------------------------------------------
echo "Collecting service state..."
services=$(systemctl list-units --type=service --state=running --no-legend)
svc_json="["

first=true
while read -r line; do
    line="${line#"${line%%[![:space:]]*}"}" # left trim
    svc=${line%% *}
    # get state details
    active=$(systemctl show -p ActiveState --value "$svc")
    sub=$(( systemctl show -p SubState --value "$svc") )
    pid=$(systemctl show -p MainPID --value "$svc")
    json=$(jq -n \
        --arg s "$svc" \
        --arg a "$active" \
        --arg sub "$sub" \
        --arg p "$pid" \
        '{service: $s, active_state: $a, sub_state: $sub, main_pid: ($p|tonumber)}')
    [[ ! $first ]] && svc_json+=$'\n,'
    svc_json+=$json
    first=false
done <<<"$services"
svc_json+="]"

# --------------------------------------------------------------------
echo "Collecting listening sockets..."
listening=$(ss -tulnp 2>/dev/null | awk 'NR>1{print $5}' | sed 's/.*://;s/#.*//' | sort -u)
listen_json="["$(printf '%s\n' "$listening" | jq -R . | jq -s .)""

# --------------------------------------------------------------------
echo "Hashing configuration files in /etc that belong to packages..."
conf_hashes_json="["
while read -r pkg _; do
    # list all files owned by the package inside /etc
    dpkg-query -L "$pkg" 2>/dev/null | grep '^/etc/' | while read -r file; do
        if [[ -f $file && ! -h $file ]]; then
            hash=$(sha256sum "$file" | awk '{print $1}')
            json=$(jq -n \
                --arg f "$file" \
                --arg h "$hash" \
                '{file: $f, sha256: $h}')
            conf_hashes_json+=$json
        fi
    done
done < <(dpkg-query -W -f='${binary:Package}\t${Version}\n')
conf_hashes_json+="]"


# --------------------------------------------------------------------
echo "Building JSON payload…"
json=$(jq -n \
    --arg ts "$timestamp" \
    --arg hn "$hostname" \
    --arg kr "$kernel" \
    --argjson pkgs $pkg_json \
    --argjson sers $svc_json \
    --argjson lis $listen_json \
    --argjson conf $conf_hashes_json \
    --arg re "$reboot_required" \
    '{
        timestamp: $ts,
        hostname: $hn,
        kernel: $kr,
        packages: $pkgs,
        services: $sers,
        listening_sockets: $lis,
        conffile_hashes: $conf,
        reboot_required: ($re | fromjson)
     }')

echo "$json" > "$OUT_FILE"

size_kb=$(du -k "$OUT_FILE" | cut -f1)
svc_count=$(jq '.services|length' "$OUT_FILE")
pkg_count=$(jq '.packages|length' "$OUT_FILE")

cat <<EOF
Snapshot: $OUT_FILE
Size: ${size_kb} KB
Kernel: $kernel
Reboot required: $reboot_required

$(
  jq -n \
    --arg hn "$hostname" \
    --arg kr "$kernel" \
    --arg pkgs "$pkg_count" \
    --arg sers "$svc_count" \
    '{
        hostname: $hn,
        kernel: $kr,
        packages: ($pkgs|tonumber),
        services: ($sers|tonumber)
     }' | jq .
)
EOF
