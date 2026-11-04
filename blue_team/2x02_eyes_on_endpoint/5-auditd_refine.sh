#!/bin/bash

log() { printf '\033[1;32m%s\033[0m\n' "$*"; }

log "[*] Current auditd rules:  $(auditctl -l |wc -l)"

CONFIG="/etc/audit/rules.d/meddefense_refine.rules"
count=0

add_rule() {
  echo -e "$*" >>"$CONFIG"
  #log "    $* [ADDED]"
  count=$((count + 1))
}

captured=0
missed=0

run_test() {
    local COMMAND="$1"
    local KEY="$2"
    local DESCRIPTION="$3"
    $COMMAND 2>/dev/null >/dev/null
    ausearch -i -ts recent -k $KEY 2>/dev/null >/dev/null
    if [[ $? == 0 ]]; then
        captured=$((captured + 1))
        log "    $DESCRIPTION               [CAPTURED]"
    else
        missed=$((missed=0 + 1))
        log "    $DESCRIPTION                    [MISSED]"
    fi
}

log "[*] Adding detection-focused rules..."
add_rule -a always,exit -F arch=b64 -S execve -k process_exec
log "    execve syscall tracking               [ADDED]"
add_rule -a always,exit -F arch=b64 -S socket -S connect -k network_connect
log "    socket/connect syscall tracking       [ADDED]"
add_rule -w /home/*/.ssh/ -p rwa -k ssh_keys
log "    SSH key file monitoring               [ADDED]"
add_rule -w /etc/cron.d/ -p wa -k cron_persist
add_rule -w /var/spool/cron/ -p wa -k cron_persist
log "    Cron directory monitoring             [ADDED]"
add_rule -w /etc/sudoers.d/ -p wa -k sudoers
log "    sudoers.d monitoring                  [ADDED]"
/usr/sbin/augenrules --load >/dev/null
if [[ $? == 0 ]]; then
  log "[*] Loading rules... augenrules --load: OK"
fi

run_test "ran /usr/bin/id" process_exec \
  "execve: ran /usr/bin/id -> ausearch -k process_exec"
run_test "curl localhost" network_connect \
  "socket: curl localhost -> ausearch -k network_connect"
run_test "touch ~/.ssh/test" ssh_keys \
  "ssh_keys: touch ~/.ssh/test -> ausearch -k ssh_keys"
run_test "touch /etc/cron.d/test" cron_persist \
  "cron: touch /etc/cron.d/test -> ausearch -k cron_persist"
run_test "touch /etc/sudoers.d/test" sudoers \
  "sudoers: touch /etc/sudoers.d/test -> ausearch -k sudoers"

rm ~/.ssh/test
rm /etc/cron.d/test
rm /etc/sudoers.d/test

log "Rules added: $count | Validation: $captured/5 PASS"
