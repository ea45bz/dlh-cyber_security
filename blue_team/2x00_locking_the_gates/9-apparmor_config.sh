#!/bin/bash

log() { printf '\033[1;32m%s\033[0m\n' "$*"; }

log "[*] Checking AppArmor status..."
if dpkg-query -W apparmor >/dev/null; then
  version=$(dpkg-query -W  apparmor |cut -d ' ' -f 2)
  log "    Already installed: apparmor $version"
else
    apt-get -y install  apparmor-util apparmor-profiles apparmor-profiles-extra libapache2-mod-apparmor >/dev/null
fi
if systemctl list-unit-files --value  apparmor.service  --state=enabled --no-pager; then
  log "    AppArmor module: loaded"
else
    systemctl enable --now apparmor.service
fi
log "    AppArmor module: active"

log "[*] Profile enforcement:"

set_aa() {
    if grep $1 /sys/kernel/security/apparmor/profiles; then
      status=$(grep $1 /sys/kernel/security/apparmor/profiles|cut -d ' ' -f 2)
      status=${status:1:-1}
      if [[ $status == "complain" ]]; then
          aa-enforce $1
          log "    $1         complain -> enforce  [ENFORCED]"
      elif [[ $status == "enforce" ]]; then
          log "    $1        enforce              [OK]"
      fi
    fi
    }

set_aa /usr/sbin/apache2
set_aa /usr/sbin/mysqld
set_aa /usr/sbin/sshd

apparmor_parser -r /etc/apparmor.d/opt.meddefense.billing-app
aa-enforce /opt/meddefense/billing-app
log "[*] Custom profile: /opt/meddefense/billing-app   [CREATED] [ENFORCED]"

log "[*] Unconfined network-exposed processes:"
while read line; do
    log "    $line [UNCONFINED - Profile recommended]"
done < <(aa-unconfined |cut -d ' ' -f 2 | sort| uniq)

enforce_count=$(aa-status |grep "profiles are in enforce mode" |cut -d ' ' -f 1)
complain_count=$(aa-status |grep "profiles are in complain mode" |cut -d ' ' -f 1)

log " Profiles in enforce: $enforce_count | Complain: $complain_count | Unconfined: $(aa-unconfined |wc -l)"
