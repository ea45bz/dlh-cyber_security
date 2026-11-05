#!/bin/bash
# 4-patch_execute.sh – execute a patch plan safely and log everything

set -euo pipefail

# ---------------------------------------------------------------
# 0.  Constants & helpers ---------------------------------------
LOCKFILE="/var/lock/meddefense-patch.lock"
PLAN_FILE="patch_plan.json"
LOG_FILE="patch_execution_log.json"

# helper: get installed version
inst_ver() { apt-cache policy "$1" | awk '/Installed:/ {print $2}'; }

# helper: service state (ActiveState,SubState,MainPID)
svc_state() {
    local svc=$1
    if ! systemctl list-units --type=service --state=running | grep -q "^${svc}\."; then
        echo "{}"
        return
    fi
    local a s p
    read -r a s p < <(systemctl show -p ActiveState,SubState,MainPID --value "$svc" | tr '\n' ',')
    jq -n \
        --arg svc "$svc" \
        --arg active "${a%?}" \
        --arg sub "${s%?}" \
        --arg pid "$p" \
        '{service:$svc,active_state:$active,sub_state:$sub,main_pid:($pid|tonumber)}'
}

# helper: get state of many services → array
svc_states() {
    local svc_list=("$@")
    local jsons=()
    for s in "${svc_list[@]}"; do
        jsons+=("$(svc_state "$s")")
    done
    printf '%s\n' "${jsons[@]}" | jq -s .
}

# ---------------------------------------------------------------
# 1. Acquire advisory lock ----------------------------------------
exec 200>"$LOCKFILE"
if ! flock -n 200; then
    echo "Unable to acquire lock $LOCKFILE" >&2
    exit 2
fi

trap 'flock -u 200' EXIT INT TERM

echo "[*] Acquiring lock $LOCKFILE... OK"

# ---------------------------------------------------------------
# 2. Load plan ----------------------------------------
if [[ ! -f "$PLAN_FILE" ]]; then
    echo "Plan file not found: $PLAN_FILE" >&2
    exit 1
fi

total_entries=$(jq '.plan | length' "$PLAN_FILE")
echo "[*] Loading plan: $PLAN_FILE ($total_entries entries)"

started_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
hostname=$(hostname)
plan_hash=$(sha256sum "$PLAN_FILE" | awk '{print $1}')

# ---------------------------------------------------------------
# 3. Main loop ------------------------------------------
entries_file=$(mktemp /tmp/pathexec_entries_XXXXXX.json)
touch "$entries_file"

any_fail=0

for i in $(seq 0 $((total_entries-1))); do
    entry_json=$(jq -c ".plan[$i]" "$PLAN_FILE")
    pkg=$(echo "$entry_json" | jq -r '.package')
    bucket=$(echo "$entry_json" | jq -r '.bucket')
    requires_restart=$(echo "$entry_json" | jq -r '.requires_restart')
    requires_reboot=$(echo "$entry_json" | jq -r '.requires_reboot')

    affected_services=($(echo "$entry_json" | jq -r '.affected_services[]' 2>/dev/null))

    # ---- pre block -------------------------------------------------
    pre_installed=$(inst_ver "$pkg")
    pre_svc_state=$(svc_states "${affected_services[@]}")
    pre_block=$(jq -n \
        --arg ver "$pre_installed" \
        --argjson svc "$pre_svc_state" \
        '{installed_version:$ver,service_states:$svc}')

    # ---- run apt-get with retry ------------------------------------
    start_ts=$(date +%s)
    wait=1
    tries=0
    stdout=""
    stderr=""
    exit_code=1

    while true; do
        out=$(DEBIAN_FRONTEND=noninteractive apt-get install --only-upgrade -y "$pkg" 2>&1 | tee /dev/stderr)
        exit_code=$?
        if [[ $exit_code -eq 0 ]]; then
            stdout="$out"
            break
        fi

        if echo "$out" | grep -q "Could not get lock"; then
            ((tries++))
            if (( wait >= 120)); then
                echo "[!] Too many dpkg lock attempts for $pkg – aborting entry."
                exit_code=1
                stdout="$out"
                break
            fi
            sleep "$wait"
            wait=$((wait*2))
        else
            # other failure – stop trying
            stdout="$out"
            break
        fi
    done

    duration=$(( $(date +%s) - start_ts ))

    # ---- post block -----------------------------------------------
    post_installed=$(inst_ver "$pkg")
    post_svc_state=$(svc_states "${affected_services[@]}")
    post_block=$(jq -n \
        --arg ver "$post_installed" \
        --argjson svc "$post_svc_state" \
        '{installed_version:$ver,service_states:$svc}')

    # ---- restart affected services if needed ------------------------
    if [[ "$requires_restart" == "true" && "$requires_reboot" != "true" ]]; then
        for svc in "${affected_services[@]}"; do
            if [[ "$svc" == "(kernel-wide)" ]]; then continue; fi
            systemctl try-restart "$svc"
            rc=$?
            echo "      try-restart $svc $( [[ $rc -eq 0 ]] && echo OK || echo FAIL )"
        done
    fi

    # ---- log entry -----------------------------------------------
    stdout_tail=$(printf '%s' "$stdout" | tail -n 200)
    stderr_tail=$(printf '%s' "$stderr" | tail -n 200)

    status="succeeded"
    if (( exit_code != 0 )); then
        status="failed"
        any_fail=1
    fi

    entry_log=$(jq -n \
        --arg pkg "$pkg" \
        --arg status "$status" \
        --argjson pre "$pre_block" \
        --argjson post "$post_block" \
        --arg stdout_tail "$stdout_tail" \
        --arg stderr_tail "$stderr_tail" \
        --arg duration "$(printf "%.1f" $duration)" \
        '{package:$pkg,status:$status,pre:$pre,post:$post,\
           stdout_tail:$stdout_tail,stderr_tail:$stderr_tail,\
           duration_seconds:($duration|tonumber)}')

    echo "[$((i+1))/$total_entries] $pkg $bucket apt-get ... $( [[ $exit_code -eq 0 ]] && printf 'OK (%s)' "$(printf "%.1f" $duration)" || printf 'FAILED')"

    # write to temporary file – one entry per line
    echo "$entry_log" >> "$entries_file"

    if (( exit_code != 0 )); then
        break   # stop processing further entries
    fi
done

finished_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# ---------------------------------------------------------------
# 4. Build final JSON -----------------------------------------
final_json=$(jq -n \
    --arg started "$started_at" \
    --arg finished "$finished_at" \
    --arg host "$hostname" \
    --arg hash "$plan_hash" \
    --slurpfile entries "$entries_file" \
    '{
        started_at:$started,
        finished_at:$finished,
        hostname:$host,
        plan_source_hash:$hash,
        entries: $entries[]
     }')

echo "$final_json" > "$LOG_FILE"
chmod 644 "$LOG_FILE"

rm -f "$entries_file"

# ---------------------------------------------------------------
# 5. Exit status ----------------------------------------------
if (( any_fail )); then
    echo "Succeeded: $(($total_entries-1))  Failed: 1"
    exit 1
else
    echo "Succeeded: $total_entries  Failed: 0"
    exit 0
fi
