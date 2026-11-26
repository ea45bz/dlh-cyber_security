#!/bin/bash
# 0-source_inventory.sh – walk evidence pack and create a manifest

set -euo pipefail
IFS=$'\n\t'

ROOT="~/evidence_pack_primary"
OUT_FILE="source_inventory.json"

declare -A counts   # category -> file count
counts["windows"]=0
counts["linux"]=0
counts["network"]=0
declare -A sizes    # category -> bytes
sizes["windows"]=0
sizes["linux"]=0
sizes["network"]=0

# helper to compute SHA‑256, size, line/record count & first/last timestamps
process_file() {
    local relpath=$1
    local category=$2
    local abs="$ROOT/$relpath"
    local type
    case "$abs" in
        *.json)   type="${category}_json"  ;;
        *.log)    type="${category}_text"  ;;
        *.csv)    type="${category}_csv" ;;
        *.ndjson) type="windows_json" ;;
        *)        type="linux_text"     ;;
    esac

    size=$(stat -c %s "$abs")
    sha256=$(sha256sum "$abs" | awk '{print $1}')

    # line or record count
    if [[ ${type} == "network_csv" ]]; then
        line_count=$(wc -l <"$abs")
    else
        line_count=$(wc -l <"$abs")
    fi

    # first/last event time – best effort: look for ISO‑8601 in the file
    times=($(grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}[T ]+[0-9]{2}:[0-9]{2}:[0-9]{2}' "$abs" | sort -u))
    if [[ ${#times[@]} -gt 0 ]]; then
        first_time=${times[0]}
        last_time=${times[-1]}
    else
        first_time=""
        last_time=""
    fi

    cat <<EOF
{
  "path": "$(echo "$relpath" )",
  "source_type": "$type",
  "size_bytes": $size,
  "sha256": "$sha256",
  "line_count": $line_count,
  "first_event_time": "${first_time}",
  "last_event_time": "${last_time}"
}
EOF
}

# walk directories
declare -a json_entries

for category in windows linux network; do
    dir="$ROOT/$category"
    if [[ ! -d "$dir" ]]; then continue; fi
    while IFS= read -r -d '' file; do
        rel=$(realpath --relative-to="$ROOT" "$file")
        json_entries+=("$(process_file "$rel" "$category")")
        # update counters
        ext="${rel##*.}"
        if [[ $category == "windows" ]]; then
            key="windows"
        elif [[ $category == "linux" ]]; then
            key="linux"
        else
            key="network"
        fi
        counts[$key]=$((counts[$key]+1))
        sizes[$key]=$((sizes[$key]+$(stat -c %s "$file")))
    done < <(find "$dir" -type f -print0)
done

# write JSON array
cat > "$OUT_FILE" <<EOF
{
  "files": [
$(printf "%s\n" "${json_entries[@]}" )
  ]
}
EOF

chmod 644 "$OUT_FILE"

# human‑readable summary
total_files=0; total_bytes=0
for key in windows linux network; do
    cnt=${counts[$key]:-0}
    sz=${sizes[$key]:-0}
    total_files=$((total_files+cnt))
    total_bytes=$((total_bytes+sz))
    printf "%s : %d files | %.1f MB\n" "$key" $cnt "$(awk "BEGIN{printf \"%.1f\", ($sz)/1024/1024}")"
done
printf "total   : %d files | %.1f MB\n" $total_files "$(awk "BEGIN{printf \"%.1f\", ($total_bytes)/1024/1024}")"

echo "manifest written to $OUT_FILE"
