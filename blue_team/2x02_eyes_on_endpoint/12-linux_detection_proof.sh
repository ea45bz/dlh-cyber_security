#!/bin/bash
# 12-linux_detection_proof.sh – Correlate Linux attack log vs auditd/auth.log/syslog

set -euo pipefail

LOG_GROUND="linux_attack_log.json"
OUT_JSON="linux_detection_matrix.json"

# --------------------------------------------------------------------
echo "[*] Loading ground truth (6 actions)..."

# ---------- Helpers ------------------------------------------------
timestamp_to_epoch() {   # “2026-03-25T14:35:01Z” → epoch
    date -u -d "$1" +%s
}

epoch_range() {          # $ts ± 30 sec
    local ts=$1; shift
    echo $(($ts-30)) $(($ts+30))
}

# ---------- Key maps ------------------------------------------------
declare -A AUDIT_KEY   # mapping: action -> audit key
AUDIT_KEY["Create user"]="identity"
AUDIT_KEY["Modify sudoers"]="sudoers"
AUDIT_KEY["Execute from /tmp"]="process_exec"
AUDIT_KEY["Reverse shell"]="network_connect"
AUDIT_KEY["Cron persistence"]="cron_persist"
AUDIT_KEY["Access /etc/shadow"]="identity"

declare -A AUTH_KW   # mapping: action -> grep pattern in auth.log
AUTH_KW["Create user"]="useradd"
AUTH_KW["Modify sudoers"]="sudoers"
AUTH_KW["Execute from /tmp"]="sudosh"
AUTH_KW["Reverse shell"]="ssh"
AUTH_KW["Cron persistence"]="cron"
AUTH_KW["Access /etc/shadow"]="passwd"

declare -A SYSLOG_KW   # not used in this demo but kept for completeness
SYSLOG_KW["Create user"]="useradd"
SYSLOG_KW["Modify sudoers"]="sudoers"
# … etc.

# ---------- Detail templates --------------------------------------
# (which fields must exist to consider “Full”)
declare -A DETAIL_FIELDS
DETAIL_FIELDS["identity"]="auid uid gid euid ses"
DETAIL_FIELDS["sudoers"]="exe subj"
DETAIL_FIELDS["process_exec"]="pid exe comm"
DETAIL_FIELDS["network_connect"]="pid src_ip dest_ip dest_port proto"
DETAIL_FIELDS["cron_persist"]="cmd jobtype"
# For shadow we reuse identity

# --------------------------------------------------------------------
echo "[*] Searching telemetry..."

RESULTS=()

# read ground truth
jq -c '.[]' "$LOG_GROUND" | while IFS= read -r action_json; do
    desc=$(echo "$action_json" | jq -r '.Description')
    ts=$(echo "$action_json" | jq -r '.Timestamp')


    # compute epoch window
    epoch_ts=$(timestamp_to_epoch "$ts")
    start_end=$(epoch_range "$epoch_ts")
    read start end <<<"$start_end"

    # ----------------------------------------------------------------
    # 1. auditd
    key=${AUDIT_KEY[$desc]}
    if [[ -n $key ]]; then
        audit_output=$(ausearch -ts recent -k  "$key" 2>/dev/null )
        if [[ -n $audit_output ]]; then
            # check presence of all required fields
            needed=${DETAIL_FIELDS[$key]}
            full=true
            for f in $needed; do
                if ! echo "$audit_output" | grep -q "\b$f\b"; then
                    full=false; break
                fi
            done
            detail=$([ "$full" = true ] && echo "Full" || echo "Partial")
            status="CAPTURED"
        else
            detail="Missed"
            status="MISSING"
        fi
        RESULTS+=("{\"Action\":\"$desc\",\"Source\":\"auditd\",\"Key\":\"$key\",\"Detail\":\"$detail\",\"Status\":\"[$status]\"}")
    fi

    # ----------------------------------------------------------------
    # 2. auth.log (simple grep, ignoring the time window for demo)
    kw=${AUTH_KW[$desc]}
    if [[ -n $kw ]]; then
        if grep -q "$kw" /var/log/auth.log; then
            RESULTS+=("{\"Action\":\"$desc\",\"Source\":\"auth.log\",\"Key\":\"$kw\",\"Detail\":\"Full\",\"Status\":\"[CAPTURED]\"}")
        else
            RESULTS+=("{\"Action\":\"$desc\",\"Source\":\"auth.log\",\"Key\":\"$kw\",\"Detail\":\"Missed\",\"Status\":\"[MISSING]\"}")
        fi
    fi

    # ----------------------------------------------------------------
    # 3. syslog (demo – same as auth.log)
    kw=${SYSLOG_KW[$desc]}
    if [[ -n $kw ]]; then
        if grep -q "$kw" /var/log/syslog; then
            RESULTS+=("{\"Action\":\"$desc\",\"Source\":\"syslog\",\"Key\":\"$kw\",\"Detail\":\"Full\",\"Status\":\"[CAPTURED]\"}")
        else
            RESULTS+=("{\"Action\":\"$desc\",\"Source\":\"syslog\",\"Key\":\"$kw\",\"Detail\":\"Missed\",\"Status\":\"[MISSING]\"}")
        fi
    fi

done

# --------------------------------------------------------------------
# Print table
printf "\n%-25s %-15s %-10s %-8s %-8s\n" \
    "Action" "Source" "Key" "Detail" "Status"
printf "\n%-25s %-15s %-10s %-8s %-8s\n" \
    "-------" "-------" "-------" "-------" "-------"


for r in "${RESULTS[@]}"; do
    # simple parsing – this is just for pretty printing, not needed for JSON
    act=$(echo "$r" | jq -r '.Action')
    src=$(echo "$r" | jq -r '.Source')
    key=$(echo "$r" | jq -r '.Key')
    det=$(echo "$r" | jq -r '.Detail')
    stat=$(echo "$r" | jq -r '.Status')
    printf "%-25s %-15s %-10s %-8s %s\n" "$act" "$src" "$key" "$det" "$stat"
done

# --------------------------------------------------------------------
# Count stats
captured=$(printf '%s\n' "${RESULTS[@]}" | grep -c '\[CAPTURED\]')
total=${#RESULTS[@]}
multi=$(printf '%s\n' "${RESULTS[@]}" | cut -d',' -f2 | sort | uniq -c | awk '$1>1{print $0}' | wc -l)

echo ""
echo "Actions: $total | Captured: $captured/$total ($(printf '%.1f%%' "$(awk "BEGIN{printf \"%.2f\", ($captured/$total)*100}") )) | Multi-source: $multi"

# --------------------------------------------------------------------
# Save JSON report
printf '%s\n' "${RESULTS[@]}" | paste -sd, - > "$OUT_JSON"
sed -i '1s/^/[/' "$OUT_JSON"
sed -i '$s/$/\]/' "$OUT_JSON"

echo "Report saved to: $OUT_JSON"
