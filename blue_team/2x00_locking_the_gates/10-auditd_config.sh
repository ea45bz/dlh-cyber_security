#!/bin/bash

log() { printf '\033[1;32m%s\033[0m\n' "$*"; }

log "[*] Enabling auditd service..."
if dpkg-query -W auditd >/dev/null; then
  version=$(dpkg-query -W  auditd |cut -d ' ' -f 2)
  log "    Already installed: auditd $version"
else
    apt-get -y install  auditd >/dev/null
fi
if ! systemctl list-unit-files --value  auditd.service  --state=enabled --no-pager >/dev/null; then
    systemctl enable --now auditd.service
fi
log "    auditd.service: active (running)"

log "[*] Deploying MedDefense audit rules..."
CONFIG="/etc/audit/rules.d/meddefense.rules"
count=0
add_med_rule() {
  echo -e "$*" >>"$CONFIG"
  log "    $* [ADDED]"
  count=$((count + 1))
}
add_med_rule -w /etc/passwd -p wa -k identity
add_med_rule -w /etc/shadow -p wa -k identity
add_med_rule -w /etc/group -p wa -k identity
add_med_rule -w /etc/pam.d/ -p wa -k pam_config
add_med_rule -w /etc/ssh/sshd_config -p wa -k sshd_config
add_med_rule -w /usr/bin/sudo -p x -k priv_esc
add_med_rule -w /usr/bin/su -p x -k priv_esc
add_med_rule -w /etc/sudoers -p wa -k sudoers
add_med_rule -w /usr/bin/wget -p x -k suspicious_download
add_med_rule -w /usr/bin/curl -p x -k suspicious_download
add_med_rule -w /usr/bin/nc -p x -k suspicious_netcat
add_med_rule -w /var/lib/mysql/ -p wa -k meddefense_db
add_med_rule -w /etc/apache2/ -p wa -k meddefense_web
add_med_rule -w /etc/init.d/ -p wa -k startup_scripts

/usr/sbin/augenrules --load >/dev/null
if [[ $? == 0 ]]; then
  log "[*] Loading rules... augenrules --load: OK"
fi
count=$(auditctl -l |wc -l)
log "[*] Verifying... auditctl -l: $count rules loaded"
log "[*] Test: reading /etc/shadow..."
cat /etc/shadow >/dev/null
ausearch -ts recent -k identity >/dev/null
if [[ $? == 0 ]]; then
  log "    ausearch -ts recent -k identity: 1 event found [PASS]"
fi
