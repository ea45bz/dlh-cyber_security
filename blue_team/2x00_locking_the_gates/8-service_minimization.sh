#!/bin/bash

log() { printf '\033[1;32m%s\033[0m\n' "$*"; }

log "[*] Checking libpam-pwquality..."
if dpkg-query -W libpam-pwquality >/dev/null; then
  version=$(dpkg-query -W  libpam-pwquality |cut -d ' ' -f 2)
  log "    Already installed: libpam-pwquality $version"
else
    apt-get -y install  libpam-pwquality >/dev/null
fi
log "[*] Configuring password quality (/etc/security/pwquality.conf)..."
CONFIG="/etc/security/pwquality.conf"
BACKUP="${CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
cp "$CONFIG" "$BACKUP"

set_cfg() {
    local KEY="$1"
    local VALUE="$2"
    # Remove any existing instance of the key (ignore case)
    sed -ri "/^\s*${KEY}\b/d" "$CONFIG"
    echo -e "\n${KEY} ${VALUE}" >>"$CONFIG"
    log "    $KEY = $VALUE  [SET]"
}

set_cfg minlen  14
set_cfg dcredit -1
set_cfg ucredit -1
set_cfg lcredit -1
set_cfg ocredit -1
set_cfg maxrepeat 3

sed -i '/pam_pwquality.so/ s/$/ reject_username/' /etc/pam.d/common-password
log "    reject_username  [SET]"

log "[*] Configuring account lockout (pam_faillock)..."
CONFIG="/etc/security/faillock.conf"
set_cfg deny 5
set_cfg unlock_time 900
set_cfg fail_interval 900

log "[*] Configuring password history..."
CONFIG="/etc/security/pwhistory.conf"
set_cfg remember 12

length=14
attempts=5
attempt_min=15
history=12
log "Password minimum length: $length | Lockout: $attempts attempts / $attempt_min min | History: $history"
