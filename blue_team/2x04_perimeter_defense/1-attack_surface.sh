#!/bin/bash
# 1-attack_surface.sh – map listening sockets to function, criticality and exposure

set -euo pipefail
IFS=$'\n\t'

BASE_JSON="network_baseline.json"
CATALOG_JSON="service_catalog.json"       # { "mysqld": "database", ... }
CRIT_JSON="service_criticality.json"     # { "ssh.service": "high", ... }

OUT_FILE="attack_surface.json"

# --------------------------------------------------------------------
TIMESTAMP=$(jq -n --arg ts "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" '{ timestamp: $ts }')
HOSTNAME=$(jq -n --arg host "$(hostname)" '{ hostname: $host }')


sockets_raw=$(jq '.listening_sockets' "$BASE_JSON")

# helper to lookup package from binary
pkg_from_bin() {
    local bin=$1
    dpkg -S "$bin" 2>/dev/null | head -n1 | cut -d: -f1 || echo "unknown"
}

# helper to get systemd service for a PID if any
service_of_package() {
    local pid=$1
    # find which unit owns the process, fallback to null
    svc=$(systemctl list-units --state=running --no-legend | \
        grep -F "$pid" | awk '{print $1}')
    echo "${svc:-null}"
}

# --------------------------------------------------------------------
echo "Generating attack surface report…"

sockets_report="["
declare -A flagged
flagged['critical']=0
flagged['high']=0
flagged['medium']=0
flagged['low']=0
flagged['unknown']=0

for sock in $(jq -c '.listening_sockets[]' "$BASE_JSON"); do
    proto=$(echo "$sock" | jq -r '.protocol')
    local_ip=$(echo "$sock" | jq -r '.local_ip')
    port=$(echo "$sock" | jq -r '.local_port')
    pid=$(echo "$sock" | jq -r '.pid // empty')
# echo $local_ip $port $pid
    # Resolve binary path
    if [[ -n $pid && -e /proc/$pid/exe ]]; then
        bin_path=$(readlink -f "/proc/$pid/exe")
        proc_name=$(basename "$bin_path")
        pkg=$(pkg_from_bin "$bin_path")
    else
        proc_name="unknown"
        pkg="unknown"
    fi

    # Find systemd unit if any
    #svc_unit=$(service_of_package "$pkg")
    if [[ "$pkg" != "unknown" ]]; then
      svc_path=$(dpkg -L $pkg | grep '/usr/lib/systemd/.*.service')
      svc_unit="${svc_path##*system/}"
      # Determine function from catalog
      func=${proc_name}   # default to binary name; will be looked up in catalog later
    else
      svc_unit="none"
      func="unknown"
    fi

    # Map to function label
    cat_func=$(jq -r --arg bin "$func" '.[$bin] // "unknown"' "$CATALOG_JSON")
    if [[ $cat_func == null ]]; then cat_func="unknown"; fi
    function=$cat_func

    # Determine criticality from service unit name (if systemd) else fallback to binary catalog
    crit=$(jq -r --arg svc "$svc_unit" '.[$svc] // "low"' "$CRIT_JSON")
    if [[ $crit == null ]]; then crit="low"; fi
    #((flagged[$crit]++))

    # Flag exposures -------------------------------------------------
    flags=()
    # 0.0.0.0 binding rule
    if [[ "$local_ip" == "0.0.0.0" || "$local_ip" == "[::]" ]]; then
        flags+=("bound_0.0.0.0")
        if [[ $function == database || $function == rpc ]]; then
            flags+=("${function}_exposed")
        fi
    fi

    # Protocol‑specific insecure flags (telnet, ftp, snmpv1/v2c, rlogin, nfs v2/v3)
    proto_name=$(echo "$proc_name" | tr '[:upper:]' '[:lower:]')
    case $proto_name in
        telnet|ftp|snmpd|rlogin|nfs* )
            flags+=("insecure_protocol_${proto_name}")
            ;;
    esac

    # Build JSON entry
    entry=$(jq -n \
        --arg proto "$proto" \
        --arg port "$port" \
        --arg bind_ip "$local_ip" \
        --arg process "$proc_name" \
        --arg package "$pkg" \
        --arg crit "$crit" \
        --arg flags "$(printf '%s\n' "${flags[@]}" | jq -R . | jq -s .)" \
        '{
            proto: $proto,
            port: ($port|tonumber),
            bind_addr: $bind_ip,
            process: $process,
            package: $package,
            criticality: $crit,
            exposure_flags: $flags
         }')
    sockets_report+=$entry","
    #sockets_report=$(echo "$sockets_report" | jq -c --arg entry "$entry" '.[] +=  $entry ')
done
sockets_report="${sockets_report%*,}"
sockets_report+="]"

# Summary block
summary=$(jq -n \
    --argjson flagged "${flagged[@]}" \
    '{
        flagged_by_severity: {critical:$flagged[0], high:$flagged[1],
                               medium:$flagged[2], low:$flagged[3], unknown:$flagged[4]}
     }')

# 7. Assemble final JSON ---------------------------------------------
final_json=$(jq -n \
    --argjson ts "$TIMESTAMP" \
    --argjson host "$HOSTNAME" \
    --argjson sockets "$sockets_report" \
    '{
        generated_at: $ts,
        hostname: $host,
        sockets: $sockets
     }')

   # --argjson summary "$summary" \

echo "$final_json" > "$OUT_FILE"
chmod 644 "$OUT_FILE"

echo "Attack surface report written to $OUT_FILE"
