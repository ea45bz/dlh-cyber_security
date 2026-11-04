#!/bin/bash

set -euo pipefail

# --------------------------------------------------------------------
# ---- Paths -----------------------------------------------------------
BASE_DIR="telemetry_handoff"

WIN_EVENTS="$BASE_DIR/windows_events.json"
LINUX_EVENTS="$BASE_DIR/linux_events.json"
GROUND_TGT="$BASE_DIR/attack_ground_truth.json"

WIN_DET="windows_detection_matrix.json"
LINUX_DET="linux_detection_matrix.json"

WIN_Q="windows_telemetry_quality.json"
LINUX_Q="linux_telemetry_quality.json"

SYSMON_COV="sysmon_coverage_matrix.json"   # unused in this script but kept for reference

OUT_FILE="telemetry_coverage_assessment.json"

# --------------------------------------------------------------------
echo "[*] Loading telemetry handoff package..."

# --- Event counts ---------------------------------------------------
win_cnt=$(jq '. | length' "$WIN_EVENTS")
lin_cnt=$(jq '. | length' "$LINUX_EVENTS")
total_events=$((win_cnt + lin_cnt))

echo "Windows events: $win_cnt"
echo "Linux events:   $lin_cnt"

# --------------------------------------------------------------------
# --- Ground truth stats ---------------------------------------------
total_actions=$(jq 'length' "$GROUND_TGT")
echo "Ground truth actions: $total_actions"

# --------------------------------------------------------------------
# --- Detection matrices ------------------------------------------------
det_win=$(cat "$WIN_DET")
det_lin=$(cat "$LINUX_DET")
det_all=$(echo "$det_win" "$det_lin" | jq -s add)

captured_count=$(echo "$det_all" | jq '[ .[] | select(.Status|contains("CAPTURED")) ] | length')
missed_count=$((total_actions - captured_count))

multi_src=$(echo "$det_all" |
    sort_by(.Action) | group_by(.Action) | map(select(length > 1)) | length)

echo "Detection matrix: $captured_count/$total_actions captured"

# --------------------------------------------------------------------
# --- Event breakdown (by source type, event category) ----------------
events_combined=$(jq -s add "$WIN_EVENTS" "$LINUX_EVENTS")

by_source_type=$(echo "$events_combined" |
    map(.source_type) | group_by(.) | map({source:.[0], count:length}))

by_event_category=$(echo "$events_combined" |
    map(.event_category) | group_by(.) | map({category:.[0], count:length}))

# --------------------------------------------------------------------
# --- ATT&CK coverage ------------------------------------------------
# 1. Build mapping: action -> technique, platform
declare -A tech_map      # action => technique
declare -A plat_map      # action => platform

for file in windows_attack_log.json linux_attack_log.json; do
    while IFS= read -r line; do
        desc=$(echo "$line" | jq -r '.Description')
        tech=$(echo "$line" | jq -r '.MITRETechnique // ""')
        if [[ $file == *windows* ]]; then plat="Windows"; else plat="Linux"; fi
        tech_map["$desc"]="$tech"
        plat_map["$desc"]=$plat
    done < <(jq -c '.' "$file")
done

# 2. All actions, captured actions
all_actions=()
for file in windows_attack_log.json linux_attack_log.json; do
    while read a; do all_actions+=("$a"); done < <(jq -r '.[]|.Description' "$file")
done

captured_actions=$(echo "$det_all" |
    jq -r '[ .[] | select(.Status|contains("CAPTURED")) | .Action ] | sort | uniq')

# 3. Covered techniques
declare -A covered_techs
for act in $captured_actions; do
    tech=${tech_map[$act]}
    [[ -n $tech ]] && covered_techs["$tech"]=1
done

# 4. All techniques
all_techs=()
while read t; do all_techs+=("$t"); done < <(jq -r '.[].MITRETechnique' windows_attack_log.json linux_attack_log.json)
declare -A all_tech_map
for t in "${all_techs[@]}"; do all_tech_map["$t"]=1; done

# 5. Blind techniques = all – covered
declare -a blind_techs=()
for t in "${!all_tech_map[@]}"; do
    [[ ! ${covered_techs[$t]+_} ]] && blind_techs+=("$t")
done

# 6. Partial (none in this simplified model)
partial_techs=()

# --------------------------------------------------------------------
# --- Sources responsible for coverage -------------------------------
source_counts=$(echo "$det_all" |
    jq '[ .[] | select(.Status|contains("CAPTURED")) ] |
        map(.Source) | group_by(.) | map({source:.[0], count:length})')

# --------------------------------------------------------------------
# --- Known gaps -----------------------------------------------------
declare -a gap_objs=()
for act in "${all_actions[@]}"; do
    # if not captured
    if ! echo "$captured_actions" | grep -Fxq "$act"; then
        plat=${plat_map[$act]}
        tech=${tech_map[$act]}
        obj=$(jq -n \
            --arg d "$act" \
            --arg p "$plat" \
            --arg t "$tech" \
            '{description:$d, impacted_platform:$p,
              technique:$t,
              reason:"Event not captured",
              recommended_instrumentation_improvement:
                 ("Enable additional auditing for "+$t)}')
        gap_objs+=("$obj")
    fi
done

known_gaps_json=$(printf '%s\n' "${gap_objs[@]}" | jq -s .)

# --------------------------------------------------------------------
# --- Quality summary ------------------------------------------------
win_score=$(jq -r '.score // 0' "$WIN_Q")
lin_score=$(jq -r '.score // 0' "$LINUX_Q")

# Confidence rating (simple rule set)
perc=$(( captured_count * 100 / total_actions ))
if (( $(echo "$win_score >= 90" | bc -l) && $(echo "$lin_score >= 90" | bc -l) && $perc -ge 90 )); then
    rating="acceptable"
elif (( $(echo "$win_score >= 80" | bc -l) && $(echo "$lin_score >= 80" | bc -l) && $perc -ge 70 )); then
    rating="moderate"
else
    rating="low"
fi

# --------------------------------------------------------------------
# --- Build final JSON -----------------------------------------------
covered_array=$(printf '%s\n' "${!covered_techs[@]}" | jq -R . | jq -s .)
blind_array=$(printf '%s\n' "${blind_techs[@]}" | jq -R . | jq -s .)

cat > "$OUT_FILE" <<EOF
{
  "TotalEvents": $total_events,
  "ByPlatform": {
    "Windows": $win_cnt,
    "Linux":   $lin_cnt
  },
  "BySourceType": $by_source_type,
  "ByEventCategory": $by_event_category,
  "DetectionMatrixSummary": {
    "TotalSimulatedActions": $total_actions,
    "CapturedActions":       $captured_count,
    "MissedActions":         $missed_count,
    "MultiSourceDetections": $multi_src
  },
  "ATTACKCoverage": {
    "CoveredTechniques": $covered_array,
    "PartiallyCoveredTechniques": $(printf '%s\n' "${partial_techs[@]}" | jq -R . | jq -s .),
    "BlindTechniques": $blind_array
  },
  "SourcesResponsibleForCoverage": $source_counts,
  "KnownGaps": $known_gaps_json,
  "QualitySummary": {
    "WindowsScore": $win_score,
    "LinuxScore":   $lin_score
  },
  "FinalHandoffConfidenceRating": "$rating"
}
EOF

# --------------------------------------------------------------------
echo "Report saved to: $OUT_FILE"

# Summary – matches the requested console output
echo "[*] Summary:"
printf "Windows events: %d\n" "$win_cnt"
printf "Linux events:   %d\n" "$lin_cnt"
printf "Ground truth actions: %d\n" "$total_actions"
printf "Detection matrix: %d/%d captured\n" "$captured_count" "$total_actions"
printf "ATT&CK covered: %d\n" "${#covered_techs[@]}"
printf "ATT&CK partial: %d\n" "${#partial_techs[@]}"
printf "ATT&CK blind: %d\n" "${#blind_techs[@]}"
printf "Windows quality: %.1f\n" "$win_score"
printf "Linux quality:   %.1f\n" "$lin_score"
echo "Confidence: $rating"
