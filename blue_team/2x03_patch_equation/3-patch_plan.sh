#!/bin/bash
# 3-patch_plan.sh – priority‑based patch plan
#
#   * Reads vulnerability_inventory.json (T0)
#   * Reads service_dependency_map.json (T1)
#   * Computes a deterministic score for each vulnerable package
#   * Orders the packages and emits patch_plan.json

set -euo pipefail
IFS=$'\n\t'

VULN_JSON="vulnerability_inventory.json"
SERVICES_JSON="service_dependency_map.json"

OUT_FILE="patch_plan.json"

# -------------------------  weights ----------------------------------
CVSS_WEIGHT=1.5          # weight for CVSS score
KEV_WEIGHT=0.8           # weight if in CISA KEV list
CRIT_WEIGHT=2.0          # weight for highest service criticality (low=1, medium=2, high=3, critical=4)
EXPWEIGHT=0.5            # exposure rank weight

# -------------------------  mapping of criticality to number ----------
declare -A CRIT_MAP=( ["low"]=1 ["medium"]=2 ["high"]=3 ["critical"]=4 )

# read all vulnerability entries into array
mapfile -t VULNS < <(jq -c '.packages[]' "$VULN_JSON")
# read service dependency map
services=$(jq -c '.[]' "$SERVICES_JSON")

# helper: find all services that depend on a given package
find_services() {
    local pkg=$1
    jq --arg p "$pkg" \
       '[ .[] | select(.linked_packages[] == $p) | .service ]'
}

# helper: get highest criticality among list of services
max_crit_of_services() {
    local arr="$1"
    local max=0
    for svc in $(echo "$arr" | jq -r '.[]'); do
        crit=$(jq -r --arg svc "$svc" \
            '. | select(.service== $svc) | .criticality' <<<"$SERVICES_JSON")
        val=${CRIT_MAP[$crit]:-1}
        [[ $val -gt $max ]] && max=$val
    done
    echo "$max"
}

# helper: exposure rank – simply the CVSS divided by 10 (higher CVSS → higher exposure)
exposure_rank() {
    local cvss=$1
    echo "scale=2; ($cvss / 10.0)" | bc
}

declare -A plan_entries

for vuln in "${VULNS[@]}"; do
    pkg=$(jq -r '.package' <<<"$vuln")
    max_cvss=$(jq -r '.max_cvss // 0' <<<"$vuln")
    kev=$([ "$(jq -r '.in_cisa_kev' <<<"$vuln")" == "true" ] && echo 1 || echo 0)

    # find affected services
    svc_arr=$(find_services "$pkg")
    affected_services=($(echo "$svc_arr" | jq -c 'tonumber? // .'))

    # determine if patch requires a restart (any linked service needs it)
    restart=false
    for svc in $(jq -r '.[]' <<<"$svc_arr"); do
        if [[ "$(jq --arg s "$svc" \
                '. | select(.service== $s) | .restart_required_on_patch' <<<"$SERVICES_JSON")" == "true" ]]; then
            restart=true; break
        fi
    done

    # special case for kernel or systemd – reboot required if present in affected list
    requires_reboot=false
    for svc in "${affected_services[@]}"; do
        if [[ "$svc" == "(kernel-wide)" || "$svc" == "systemd.service" ]]; then
            requires_reboot=true; break
        fi
    done

    # criticality weight: highest of linked services
    crit_val=$(max_crit_of_services "$(echo "${affected_services[@]}" | jq -s .)")

    exposure=$(exposure_rank "$max_cvss")
    score=$(awk "BEGIN{printf \"%.2f\", $CVSS_WEIGHT*$max_cvss + $KEV_WEIGHT*$kev + $CRIT_WEIGHT*$crit_val + $EXPWEIGHT*$exposure}")

    # classify bucket
    if (( $(echo "$score >= 7" | bc -l) )); then bucket="emergency"
    elif (( $(echo "$score >= 4" | bc -l) )); then bucket="urgent"
    else bucket="scheduled"; fi

    plan_entries["$pkg"]=$(
        jq -n \
            --arg pkg "$pkg" \
            --argjson score "$(printf '%s' "$score")" \
            --arg bucket "$bucket" \
            --argjson services "$(echo "${affected_services[@]}" | jq -s .)" \
            --arg restart "$restart" \
            --arg reboot "$requires_reboot" \
            '{
                package: $pkg,
                score: ($score|tonumber),
                bucket: $bucket,
                affected_services: $services,
                requires_restart: ($restart=="true"),
                requires_reboot: ($reboot=="true")
             }')
done

# sort entries by descending score
sorted_keys=$(printf '%s\n' "${!plan_entries[@]}" |
    xargs -I{} sh -c "echo '{}' $(jq '.score' <<<\"${plan_entries[{}]}\")" |
    sort -k2nr | awk '{print $1}')

# build final JSON
json="{"
first=true; rank=1
for pkg in $sorted_keys; do
    entry=$(echo "${plan_entries[$pkg]}" | jq --argjson rank "$rank" '. + {rank: ($rank|tonumber)}')
    [[ ! $first ]] && json+=$'\n,'; first=false
    json+="$entry"
    ((rank++))
done
json+="}"

# add meta data
meta=$(jq -n \
    --arg generated "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    --argjson weights "$(jq -n \
          --arg cvss "$CVSS_WEIGHT" \
          --arg kev  "$KEV_WEIGHT" \
          --arg crit "$CRIT_WEIGHT" \
          --arg exp  "$EXPWEIGHT" \
          '{cvss_weight: ($cvss|tonumber),kev_weight:($kev|tonumber),
           criticality_weight:($crit|tonumber),
           exposure_weight:($exp|tonumber)})' \
    --argjson plan "$json" \
    '{
        generated_at: $generated,
        weights: $weights,
        plan: $plan
     }')

echo "$meta" > "$OUT_FILE"

# summary for console
emergency=$(jq '[ .plan[] | select(.bucket=="emergency") ] | length' <<<"$meta")
urgent=$(jq '[ .plan[] | select(.bucket=="urgent") ] | length' <<<"$meta")
scheduled=$(jq '[ .plan[] | select(.bucket=="scheduled") ] | length' <<<"$meta")

reboot_needed=$(jq -r 'any(.plan[].requires_reboot; .)' <<<"$meta" && echo "yes" || echo "no")

echo
echo "$emergency   $urgent   $scheduled"
echo "Reboot required by plan: $reboot_needed (kernel update present)"
echo "Report saved to: $OUT_FILE"
