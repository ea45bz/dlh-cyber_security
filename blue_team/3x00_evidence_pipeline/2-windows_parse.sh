#!/bin/bash
# 2-windows_parse.sh – merge evidence‑pack Windows logs and student telemetry

set -euo pipefail
IFS=$'\n\t'

ROOT="~/evidence_pack_primary"
OUT_FILE="windows_events.json"

declare -A file_counts
records=()

add_records() {
    local src=$1   # path to source file
    local origin=$2  # evidence_pack or student_telemetry
    #echo "reading $(basename "$src") ..."
    while IFS= read -r line; do
        [[ -z $line ]] && continue
        json=$(jq -c --arg src "$origin" '
            . + {
                timestamp_raw: (.timestamp_raw // empty),
                hostname:      (.hostname     // empty),
                event_id:      (.event_id    // empty),
                channel:       (.channel     // empty),
                provider:      (.provider    // empty),
                raw_message:   (.raw_message // empty),
                event_data:    (.event_data  // empty),
                source_origin: $src
            }' <<<"$line")
        records+=("$json")
    done < "$src"

    #file_counts[$(basename "$src")]=${#records[@]}
    echo "reading $(basename "$src") ... ${#records[@]} records"
}

# evidence‑pack files
add_records "$ROOT/windows/security.json" "evidence_pack"
add_records "$ROOT/windows/sysmon.json"   "evidence_pack"
add_records "$ROOT/windows/powershell.json" "evidence_pack"
# student telemetry
telemetry_file="$ROOT/student_telemetry/windows_events.json"
count=0
if [[ -f $telemetry_file ]]; then
    while IFS= read -r line; do
        [[ -z $line ]] && continue
        json=$(jq -c '
            . + {
                timestamp: (.timestamp // empty),
                hostname:      (.hostname     // empty),
                event_id:      (.event_id    // empty),
                source_type:   (.source_type // empty),
                event_category: (.event_category // empty),
                channel:       (.user     // empty),
                raw_message:   (.raw_message // empty),
                source_origin: "student_telemetry"
            }' <<<"$line")
        records+=("$json")
        count=$((count + 1))
    done < "$telemetry_file"
    echo "appending student telemetry ... $count records"
fi


# write output
printf "%s\n" "${records[@]}" > "$OUT_FILE"

echo "$OUT_FILE: ${#records[@]} records"
