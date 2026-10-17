#!/bin/bash

log() { printf '\033[1;32m%s\033[0m\n' "$*"; }

log "[*] Running audit telemetry coverage tests..."

count=0
captured=0
missed=0

run_test() {
    local COMMAND="$1"
    local KEY="$2"
    local DESCRIPTION="$2"
    count=$((count + 1))
    $COMMAND 2>/dev/null >>audit_validation.json
    echo "checking: ausearch -i  -ts recent -k $KEY"  >>audit_validation.json
    ausearch -i -ts recent -k $KEY 2>/dev/null >>audit_validation.json
    if [[ $? == 0 ]]; then
        captured=$((captured + 1))
        log "[$count/6] $DESCRIPTION               [CAPTURED]"
    else
        missed=$((missed=0 + 1))
        log "[$count/6] $DESCRIPTION                    [MISSED]"
    fi
}

run_test "sudo ls" priv_esc \
  "sudo execution"

run_test "cat /etc/shadow" identity \
  "shadow acces"

run_test "curl -s -o /tmp/example.com.html https://example" suspicious_download \
  "suspicious download tool"

run_test "cat /etc/ssh/sshd_config" sshd_config \
  "sshd config read"

run_test "echo  \"test\" >/etc/apache2/temporty_test.txt" meddefense_web \
  "monitored test file write"

run_test "crontab -l" cron \
  "cron configuration check"

log "[*] Cleaning test artifacts..."
rm /etc/apache2/temporty_test.txt 2>/dev/null
rm /tmp/example.com.html  2>/dev/null
log "Tests executed: $count"
log "Captured: $captured"
log "Missed: $missed"
log "Report saved to: audit_validation.json"
