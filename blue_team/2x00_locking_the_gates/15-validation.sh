#!/bin/bash

log() { printf '\033[1;32m%s\033[0m\n' "$*"; }

if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config; then
    log "[PASS] PermitRootLogin = no"
else
    log "[FAIL] PermitRootLogin = no"
fi

if grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then
    log "[PASS] PasswordAuthentication = no"
else
    log "[FAIL] PasswordAuthentication = no"
fi

if grep -q "^MaxAuthTries 3" /etc/ssh/sshd_config; then
    log "[PASS] MaxAuthTries = 3"
else
    log "[FAIL] MaxAuthTries = 3"
fi

if [[  $(< /proc/sys/net/ipv4/ip_forward |xargs)  -eq 0 ]]; then
    log "[PASS] net.ipv4.ip_forward = 0"
else
    log "[FAIL] net.ipv4.ip_forward = 0"
fi

if [[  $(< /proc/sys/net/ipv4/tcp_syncookies |xargs)  -eq 1 ]]; then
    log "[PASS] net.ipv4.tcp_syncookies = 1"
else
    log "[FAIL] net.ipv4.tcp_syncookies = 1"
fi

if [[  $(< /proc/sys/kernel/randomize_va_space |xargs)  -eq 2 ]]; then
    log "[PASS] kernel.randomize_va_space = 2"
else
    log "[FAIL] kernel.randomize_va_space = 2"
fi

if [[  $(< /proc/sys/net/ipv4/conf/all/log_martians |xargs)  -eq 1 ]]; then
    log "[PASS] net.ipv4.conf.all.log_martians = 1"
else
    log "[FAIL] net.ipv4.conf.all.log_martians = 0 (expected: 1)"
fi


if systemctl is-active auditd.service >/dev/null; then
   log "[PASS] auditd.service = active"
else
    log "[FAIL] auditd.service = active"
fi

if systemctl is-active apparmor.service >/dev/null; then
   log "[PASS] apparmor.service = active"
else
    log "[FAIL] apparmor.service = active"
fi

if  [[ $(ufw status |grep ^Status | awk '{print $2}') == 'active' ]] ; then
   log "[PASS] UFW status = active"
else
    log "[FAIL] UFW status = active"
fi

if  [[ $(ufw status verbose |grep ^Default | awk '{print $2}') == 'deny' ]] ; then
   log "[PASS] Default incoming = deny"
else
    log "[FAIL] Default incoming = deny"
fi
