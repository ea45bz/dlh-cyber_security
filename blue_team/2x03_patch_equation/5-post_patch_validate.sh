#!/bin/bash
# 5-post_patch_validate.sh – compare live state with pre‑patch baseline

set -euo pipefail

PRE_JSON="pre_patch_state.json"
MAP_JSON="service_dependency_map.json"
PROBES_JSON="service_probes.json"
OUT_FILE="post_patch_validation.json"

# --------------------------------------------------------------------
echo "Service state checks:   "
services_pre=$(jq '.services | length' "$PRE_JSON")
passed=0; total=$services_pre
for svc in $(jq -r '.services[] | .service' "$MAP_JSON"); do
    # Current active state
    act=$(systemctl show -p ActiveState --value "$svc" 2>/dev/null || echo "unknown")
    if [[ $act == "active" ]]; then
        ((passed++))
        status="pass"
    else
        status="regression"
    fi
    detail+=("{\"check_type\":\"service_state\",\"service\":\"$svc\", \"expected\":\"active\",\"actual\":\"$act\",\"status\": \"$status\"}")
done
echo "$passed/$total   PASS"

# --------------------------------------------------------------------
echo "Listening socket checks: "
sockets_pre=$(jq '.listening_sockets | length' "$PRE_JSON")
passed_sock=0; total=$sockets_pre

for port in $(jq -r '.listening_sockets[]' "$PRE_JSON"); do
    # check if this TCP/UDP port is still listening
    if ss -tuln 2>/dev/null | grep -q ":$port "; then
        ((passed_sock++))
        status="pass"
    else
        status="regression"
    fi
    detail+=("{\"check_type\":\"socket\",\"port\": \"$port\", \"status\":\"$status\"}")
done
echo "$passed_sock/$total   PASS"

# --------------------------------------------------------------------
echo "Critical liveness probes: "
crit_services=$(jq -r '.[] | select(.criticality=="critical") | .service' "$MAP_JSON")
passed_probe=0; total_probe=$(( crit_services==""?0:$crit_services | wc -w ))
for svc in $crit_services; do
    # find probe for this service
    probe_type=$(jq -r --arg s "$svc" \
        '.[] | select(.service==$s) | .probe.type' "$PROBES_JSON")
    probe_cmd=$(jq -r --arg s "$svc" \
        '.[] | select(.service==$s) | .probe.command' "$PROBES_JSON")

    if [[ $probe_type == "curl" ]]; then
        out=$(eval "$probe_cmd" 2>&1)
        rc=$?
        ((rc==0?passed_probe++:0))
        status=$([[ $rc -eq 0 ]] && echo pass || echo probe_failed)
    elif [[ $probe_type == "mysqladmin" ]]; then
        out=$(eval "$probe_cmd" 2>&1)
        rc=$?
        ((rc==0?passed_probe++:0))
        status=$([[ $rc -eq 0 ]] && echo pass || echo probe_failed)
    elif [[ $probe_type == "ssh" ]]; then
        out=$(eval "$probe_cmd" 2>&1)
        rc=$?
        ((rc==0?passed_probe++:0))
        status=$([[ $rc -eq 0 ]] && echo pass || echo probe_failed)
    else
        status="unknown_probe"
    fi

    detail+=("{\"check_type\":\"liveness\",\"service\":\"$svc\", \"probe_cmd\":\"$probe_cmd\", \"status\":\"$status\"}")
done
echo "$passed_probe/$total_probe   PASS"

# --------------------------------------------------------------------
# Build final JSON report
details_json=$(printf '%s\n' "${detail[@]}" | jq -s .)
summary_json=$(jq -n \
    --arg total "$(($services_pre+$sockets_pre+$crit_services))" \
    --arg pass "$(($(echo "$detail" | grep -c '\"status\":\"pass\"')))" \
    '{total_checks: ($total|tonumber), passed: ($pass|tonumber), failed: (($total-$pass)|tonumber)}')

final_json=$(jq -n \
    --argjson summary "$summary_json" \
    --argjson details "$details_json" \
    '{
        verdict: ($summary.failed==0?"PASS":"FAIL"),
        summary: $summary,
        details: $details
     }')

echo "$final_json" > "$OUT_FILE"
chmod 644 "$OUT_FILE"

# Exit status
if [[ $(jq -r '.verdict' "$OUT_FILE") == "PASS" ]]; then
    exit 0
else
    exit 1
fi
