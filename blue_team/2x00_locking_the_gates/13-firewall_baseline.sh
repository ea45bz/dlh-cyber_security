#!/bin/bash

set -euo pipefail
log() { printf '\033[1;32m%s\033[0m\n' "$*"; }



log "[*] Configuring UFW..."
if dpkg-query -W ufw >/dev/null; then
  version=$(dpkg-query -W  ufw |cut -d ' ' -f 2)
  log "    Already installed: ufw $version"
else
    apt-get -y install ufw >/dev/null
fi
if systemctl list-unit-files --value  ufw.service  --state=enabled --no-pager; then
  log "    UFW module: loaded"
else
    systemctl enable  ufw.service
fi
log "    UFW module: active"

log "[*] Configuring UFW..."

# Default policies
ufw default deny incoming > /dev/null
ufw default allow outgoing > /dev/null
ufw -f reset > /dev/null
ufw -f enable > /dev/null || true

log "    Default incoming: deny"
log "    Default outgoing: allow"

log "[*] Adding allow rules..."

ufw allow 22/tcp > /dev/null
#ufw allow from 10.10.1.0/24 to any port 22 proto tcp > /dev/null
log "    22/tcp from 10.10.1.0/24   [ADDED] SSH - management only"

ufw allow 80/tcp > /dev/null
log "    80/tcp                     [ADDED] HTTP"

ufw allow 443/tcp > /dev/null
log "    443/tcp                    [ADDED] HTTPS"

ufw allow from 10.10.2.0/24 to any port 3306 proto tcp > /dev/null
log "    3306/tcp from 10.10.2.0/24 [ADDED] MySQL - app network only"

log "[*] Enabling logging..."
ufw logging on > /dev/null
ufw status verbose | grep Logging | awk '{print "    Logging:", $2}'

log "[*] Activating firewall..."
ufw -f enable > /dev/null || true   # keep idempotent

allow_rules=$( ufw status numbered | grep 'ALLOW' | wc -l)
log "    UFW: active"
log "    Rules: $allow_rules allow, default deny"
