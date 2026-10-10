#!/bin/bash

set -euo pipefail

CONFIG="/etc/ssh/sshd_config"
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

# 3. Helper: set or append a key/value pair
count=0
set_cfg() {
local KEY="$1"
    local VALUE="$2"
local COMMENT="$3"
count=$((count + 1))
    # Remove any existing instance of the key (ignore case)
    sed -ri "/^\s*${KEY}\b/d" "$CONFIG"

    # Append the comment + new setting at the end
    echo -e "\n# $COMMENT\n${KEY} ${VALUE}" >>"$CONFIG"

}

log "[*] Applying SSH hardening settings..."

set_cfg PermitRootLogin no \
"Disable root log‑ins – prevents brute‑force attacks that target the privileged account."
log "    PermitRootLogin no"

set_cfg PasswordAuthentication no \
"Disallow password auth – mitigates credential stuffing and dictionary attacks."
log "    PasswordAuthentication no"

set_cfg PermitEmptyPasswords no \
"Reject empty passwords – stops attackers from exploiting misconfigured accounts."
log "    PermitEmptyPasswords no"
set_cfg X11Forwarding no \
"Disable X11 forwarding – prevents potential X11 remote‑code execution or session hijacking."
log "    X11Forwarding no"

set_cfg MaxAuthTries 3 \
"Limit authentication attempts per connection – limits brute‑force time window."
log "    MaxAuthTries 3"

set_cfg ClientAliveInterval 300 \
"Enforce idle‑timeout (5 min)."
log "    ClientAliveInterval 300"

set_cfg ClientAliveCountMax 2 \
"Send keep‑alive packets twice before disconnecting – total timeout ≈10 min. Helps reclaim idle SSH sessions."
log "    ClientAliveCountMax 2"

set_cfg AllowUsers medadmin sysadmin \
"Whitelist only trusted administrators – reduces attack surface to known accounts."
log "    AllowUsers medadmin sysadmin"

set_cfg Protocol 2 \
"Use SSHv2 exclusively – eliminates all legacy protocol vulnerabilities."
log "    Protocol 2"

set_cfg LoginGraceTime 60 \
"Short login grace period (1 min) – limits the window for credential attacks."
log "    LoginGraceTime 60"

echo "restricted access" >/etc/issue.net
if [[ -f /etc/issue.net ]]; then
set_cfg Banner /etc/issue.net \
"Show a pre‑login banner – reminds users of legal compliance and can deter unauthorized logins."
log "    Banner /etc/issue.net"
fi

log "[*] Validating SSH configuration..."
if sshd -t; then
    log "    sshd -t: ok"
fi

log "[*] Restarting SSH service..."
systemctl restart sshd
if [[ $? == 0 ]]; then
    log "    ssh.service: active (running)"
fi

log "Settings applied: $count"

exit 0
