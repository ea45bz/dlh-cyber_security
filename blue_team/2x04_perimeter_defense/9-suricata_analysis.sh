#!/bin/bash
# 9-suricata_analysis.sh – replay a PCAP with Suricata,
#                          aggregate alerts, classify by severity & category

set -euo pipefail
IFS=$'\n\t'

PCAP_PATH=${1:-/home/analyst/MedDefense_Lab/PCAPs/mixed_traffic.pcap}
CFG_FILE="./suricata.yaml"
LOG_DIR="/tmp/suricata_replay_${RANDOM}"
SIG_CATS="signature_categories.json"
OUT_JSON="suricata_alerts.json"

# --------------------------------------------------------------------
if [[ ! -f "$PCAP_PATH" ]]; then
    echo "PCAP not found: $PCAP_PATH" >&2
    exit 1
fi

rm -rf "$LOG_DIR"
mkdir -p "$LOG_DIR"

STARTED=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "[*] Running Suricata replay…"

suricata -c "$CFG_FILE" -r "$PCAP_PATH" -l "$LOG_DIR"
if [[ $? -ne 0 ]]; then
    echo "Suricata failed to process the PCAP" >&2
    exit 1
fi

FINISHED=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EVE_FILE="$LOG_DIR/eve.json"

# --------------------------------------------------------------------
echo "[*] Parsing eve.json…"
if [[ ! -f "$EVE_FILE" ]]; then
    echo "eve.json not found – Suricata likely produced no output" >&2
    exit 1
fi

alerts_json=$(jq -c 'select(.event_type=="alert")' "$EVE_FILE")

total_alerts=$(echo "$alerts_json" | jq 'length')
unique_sigs=$(echo "$alerts_json" | jq '[ .signature_id ] | unique | length')

# aggregate severity
severity_dist=$(echo "$alerts_json" |
    jq -r '.severity' |
    sort | uniq -c |
    awk '{print $2 ":" $1}')

# map signatures to category
declare -A cat_map
if [[ -f "$SIG_CATS" ]]; then
    while IFS= read -r line; do
        id=$(echo "$line" | cut -d: -f1)
        cat=$(echo "$line" | cut -d: -f2-)
        cat_map["$id"]="$cat"
    done < <(jq -r 'to_entries[]|"\(.key):\(.value)"' "$SIG_CATS")
fi

by_category=$(echo "$alerts_json" |
    jq -c '.signature_id as $sid | [$sid, ($sid | tostring)] |
           {sig:$sid} |
           .category = (env.cat_map[$sid] // "other")' |
    sort -t: -k2 |
    awk -F':' '{print $2 ":"}' | \
    awk '{
        gsub(/:$/, "", $0);
        if ($1=="") next;
        c[$1]++;
    } END{ for (c in c) print c ":" c[c] }')

# top sources & destinations
top_src=$(echo "$alerts_json" |
    jq -r '.src_ip' |
    sort | uniq -c |
    sort -nr | head -n5)

top_dst=$(echo "$alerts_json" |
    jq -r '.dst_ip' |
    sort | uniq -c |
    sort -nr | head -n5)

# --------------------------------------------------------------------
echo "[*] Building final JSON…"

cat >"$OUT_JSON" <<EOF
{
  "pcap":          "$PCAP_PATH",
  "started_at":    "$STARTED",
  "finished_at":   "$FINISHED",
  "total_alerts":  $total_alerts,
  "unique_signatures": $unique_sigs,
  "severity_distribution": {
$(echo "$severity_dist" | sed 's/^[ \t]*//; s/[ \t]*$//')
  },
  "by_category": {
$(echo "$by_category" | sed 's/^ *//; s/:/\": /' | paste -sd, -)
  },
  "top_sources": [
$(echo "$top_src" |
    awk '{printf "    {\"ip\":\"%s\",\"count\":%s},\n",$2,$1}' |
    sed '$ s/,$//' )
  ],
  "top_destinations": [
$(echo "$top_dst" |
    awk '{printf "    {\"ip\":\"%s\",\"count\":%s},\n",$2,$1}' |
    sed '$ s/,$//' )
  ],
  "alerts": $(jq '.' <<<"$alerts_json")
}
EOF

chmod 644 "$OUT_JSON"
echo ""
echo "Analysis complete – results written to $OUT_JSON"
