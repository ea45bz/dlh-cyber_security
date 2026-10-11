#!/bin/bash
#
# set -euo pipefail

CONFIG="/etc/sysctl.conf"
BACKUP="${CONFIG}.bak.$(date +%Y%m%d%H%M%S)"

log() { printf '\033[1;32m%s\033[0m\n' "$*"; }

# 1. Verify root privileges

if [[ "$(id -u)" -ne 0 ]]; then
echo "ERROR: This script must be run as root (or via sudo)." >&2
exit 1
fi

# 2. Backup the current sshd_config

log "[*] Backing up $CONFIG to $BACKUP"
cp "$CONFIG" "$BACKUP"

count=0
fail=0
pass=0
sysctl_check() {
    SYSCFG_PARAM=${line%%=*}
    SYSCFG_VALUE=${line#*= }
    PROC_FILE="/proc/sys/${SYSCFG_PARAM//.//}"
    VALUE="$(echo -e "${SYSCFG_VALUE}" | tr -d '[:space:]')"
    count=$((count + 1))
    if [[  $(< $PROC_FILE |xargs)  -eq $VALUE ]]; then
       log "$SYSCFG_PARAM = $SYSCFG_VALUE [PASS]"
       pass=$((pass + 1))
    else
        log "$SYSCFG_PARAM = $SYSCFG_VALUE [FAIL]"
        fail=$((fail + 1))
    fi
}

log "[*] Applying kernel hardening parameters..."

echo "net.ipv4.ip_forward = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
kernel.randomize_va_space = 2
fs.suid_dumpable = 0
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2" >$CONFIG

sysctl -p $CONFIG >/dev/null

while read line; do
    sysctl_check $line ;
done < $CONFIG

log "Parameters applied: $pass"
log "Verified PASS: $pass"
log "Verified FAIL: $fail"
