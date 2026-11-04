#!/bin/bash
# 13-consolidated_export.sh – build the SOC handoff package

set -euo pipefail

# --------------------------------------------------------------------
WIN_SRC="windows_events_export.json"
LINUX_SRC="linux_events_export.json"

WINDOWS_OUT="telemetry_handoff/windows_events.json"
LINUX_OUT="telemetry_handoff/linux_events.json"
GROUND_OUT="telemetry_handoff/attack_ground_truth.json"

WK_DIR="telemetry_handoff"

# --------------------------------------------------------------------
echo "[*] Loading Windows events (2,270)..."
win_cnt=$(jq '. | length' "$WIN_SRC")
echo "  Windows: $win_cnt events loaded."

echo "[*] Loading Linux events (2,022)..."
linux_cnt=$(jq '. | length' "$LINUX_SRC")
echo "  Linux: $linux_cnt events loaded."

# --------------------------------------------------------------------
echo "[*] Normalizing timestamps to UTC..."
win_norm=$(jq 'map(.timestamp |= (. | sub("^[^T]*Z$";"") | . + "+00:00"))' "$WIN_SRC" > tmp_win.json)
lin_norm=$(jq 'map(.timestamp |= (if contains("Z") then . else . + "Z" end))' "$LINUX_SRC" > tmp_linux.json)

win_normalized=$(wc -l < tmp_win.json | tr -d ' ')
linux_normalized=$(wc -l < tmp_linux.json | tr -d ' ')

echo "    Windows: $win_normalized events normalized"
echo "    Linux: $linux_normalized events normalized"

# --------------------------------------------------------------------
echo "[*] Verifying field consistency..."
required=('timestamp' 'hostname' 'source_type' 'event_category')
for f in "${required[@]}"; do
  win_fail=$(jq "[.[] | select(.${f}==null)] | length" tmp_win.json)
  lin_fail=$(jq "[.[] | select(.${f}==null)] | length" tmp_linux.json)
  if [[ $win_fail -gt 0 || $lin_fail -gt 0 ]]; then
    echo "Field $f missing in $((win_fail+lin_fail)) events – aborting."
    exit 1
  fi
done
echo "    Required fields present in all events    [OK]"

# --------------------------------------------------------------------
echo "[*] Combining ground truth..."
WIN_GT="windows_attack_log.json"
LINUX_GT="linux_attack_log.json"

win_gt_cnt=$(jq '. | length' "$WIN_GT")
linux_gt_cnt=$(jq '. | length' "$LINUX_GT")

cat <<EOF > tmp_ground_truth.json
[
$(jq -c '.' "$WIN_GT"),
$(jq -c '.' "$LINUX_GT")
]
EOF

ground_total=$((win_gt_cnt + linuxt_gt_cnt))
echo "    Windows actions: $win_gt_cnt | Linux actions: $linux_gt_cnt | Total: $ground_total"

# --------------------------------------------------------------------
echo "[*] Building handoff directory..."
mkdir -p "$WK_DIR"
mv tmp_win.json "$WINDOWS_OUT"
mv tmp_linux.json "$LINUX_OUT"
mv tmp_ground_truth.json "$GROUND_OUT"

# size stats
win_size=$(du -h "$WINDOWS_OUT" | cut -f1)
lin_size=$(du -h "$LINUX_OUT"   | cut -f1)
gt_size=$(du -h "$GROUND_OUT"  | cut -f1)

echo "telemetry_handoff/"
echo "  windows_events.json     ($win_cnt events, $win_size)"
echo "  linux_events.json       ($linux_cnt events, $lin_size)"
echo "  attack_ground_truth.json ($ground_total actions, $gt_size)"

total=$((win_cnt+linux_cnt))
echo "Total: $total events across 2 platforms"

# --------------------------------------------------------------------
rm -f tmp_*   # clean temp files
