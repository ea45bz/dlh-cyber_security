#!/bin/bash
set -euo pipefail

LOGDIR="/var/log"
OUTFILE="linux_events.json"

# Determine hostname
HOSTNAME=$(hostname -f)

# Counters
declare -A COUNT_AUTH=()
declare -A COUNT_AUDIT=()
declare -A COUNT_SYSLOG=()

echo "[" >"$OUTFILE"
FIRST=1

function add_json() {
    local json=$1
    if [ $FIRST -eq 0 ]; then echo "," >>"$OUTFILE"; fi
    echo "$json" >>"$OUTFILE"
    FIRST=0
}




# parse syslog
SYSLOG="$LOGDIR/syslog"
if [[ -f "$SYSLOG" ]]; then
    echo ""
    echo "Parsing syslog..."
    while IFS= read -r line; do
        ((COUNT_SYSLOG[total]++))
        set -- $line
        month=$1 day=$2 time=$3 rest="$4 ${@:5}"
        dt=$(date -u -d "$month $day $time $(date +%Y)" +"%FT%TZ")
        if [[ $rest == *"Started"* || $rest == *"Stopped"* ]]; then
            srv=$(echo "$rest" | awk -F'[ :]' '{print $4}')
            add_json "$(printf '{\"timestamp\":\"%s\",\"hostname\":\"%s\",\"source_type\":\"syslog\",\"event_category\":\"service_%s\",\"service\":\"%s\"}' "$dt" "$HOSTNAME" "${srv,,}" "$srv")"
            ((COUNT_SYSLOG[service]++))
        elif [[ $rest == *error* || $rest == *failed* ]]; then
            add_json "$(printf '{\"timestamp\":\"%s\",\"hostname\":\"%s\",\"source_type\":\"syslog\",\"event_category\":\"error\",\"message\":\"%s\"}' "$dt" "$HOSTNAME" "${rest//\"/\\\"}")"
            ((COUNT_SYSLOG[error]++))
        else
            add_json "$(printf '{\"timestamp\":\"%s\",\"hostname\":\"%s\",\"source_type\":\"syslog\",\"event_category\":\"other_syslog\"}' "$dt" "$HOSTNAME")"
            ((COUNT_SYSLOG[other]++))
        fi
    done <"$SYSLOG"
else
    echo "syslog not found."
fi

echo ""
echo "Syslog parsing finished. Total events: ${COUNT_SYSLOG[total]}"
echo "  service: ${COUNT_SYSLOG[service]} | error: ${COUNT_SYSLOG[error]} | other: ${COUNT_SYSLOG[other]}"

# finalize JSON
echo "]" >>"$OUTFILE"

# overall totals
TOTAL_EVENTS=$(( COUNT_AUTH[total] + COUNT_AUDIT[total] + COUNT_SYSLOG[total] ))
FIRST_DAY=$(date -u +"%Y-%m-%dT00:00:00Z")
LAST_DAY=$(date -u +"%Y-%m-%dT23:59:59Z")

echo ""
echo "Total events: $TOTAL_EVENTS"
echo "Time range: $FIRST_DAY to $LAST_DAY"
