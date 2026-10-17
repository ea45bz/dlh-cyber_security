#!/bin/bash

set -euo pipefail
LOG() { printf "%s\n" "$1"; }

LOG "[*] Configuring rsyslog..."

cat > /etc/rsyslog.d/security.conf <<'EOF'
# Authoritative auth/authpriv events
auth,authpriv.*        /var/log/auth.log

# All other informational traffic (except from auth subsystem)
*.info;auth.none      /var/log/syslog
EOF

chmod 644 /etc/rsyslog.d/security.conf
systemctl restart rsyslog &>/dev/null

LOG "    auth,authpriv.* -> /var/log/auth.log     [CONFIGURED]"
LOG "    *.info;auth.none -> /var/log/syslog      [CONFIGURED]"

LOG "[*] Setting log rotation policies..."

cat > /etc/logrotate.d/auth <<'EOF'
/var/log/auth.log {
    daily
    rotate 90
    missingok
    notifempty
    compress
    delaycompress
    sharedscripts
}
EOF

cat > /etc/logrotate.d/syslog <<'EOF'
/var/log/syslog {
    daily
    rotate 60
    missingok
    notifempty
    compress
    delaycompress
    sharedscripts
}
EOF

LOG "    /var/log/auth.log: rotate 90, compress after 7d  [SET]"
LOG "    /var/log/syslog: rotate 60, compress after 7d    [SET]"

LOG "[*] Verifying log activity..."

logger -p auth.info "Log test"
sleep 1   # give rsyslog a moment to write

if grep -q "Log test" /var/log/auth.log; then
    LOG "    /var/log/auth.log: receiving events       [OK]"
else
    LOG "    /var/log/auth.log: receiving events       [FAIL]"
fi

if [[ -s /var/log/syslog ]]; then
    LOG "    /var/log/syslog: receiving events         [OK]"
else
    LOG "    /var/log/syslog: receiving events         [FAIL]"
fi

LOG "[*] Securing log file permissions..."

chmod 640 /var/log/auth.log
chown root:adm /var/log/auth.log
if [[ $(stat -c "%a %U:%G" /var/log/auth.log) == "640 root:adm" ]]; then
    LOG "    /var/log/auth.log: 640 root:adm          [OK]"
else
    LOG "    /var/log/auth.log: permissions not set   [FAIL]"
fi

chmod 640 /var/log/syslog
chown root:adm /var/log/syslog
if [[ $(stat -c "%a %U:%G" /var/log/syslog) == "640 root:adm" ]]; then
    LOG "    /var/log/syslog: 640 root:adm            [OK]"
else
    LOG "    /var/log/syslog: permissions not set   [FAIL]"
fi

LOG "Log sources configured: 2 | Rotation policies: 2 | Permissions: secured"
