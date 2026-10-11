#!/bin/bash
#
log() { printf '\033[1;32m%s\033[0m\n' "$*"; }

log "[*] Scanning enabled services..."
systemctl list-unit-files --no-pager --type=service --state=enabled |grep enabled |cut -d ' ' -f 1  >.enabled_services.txt
before=$(wc -l .enabled_services.txt |cut -d ' ' -f 1 )
log "    Enabled services found: $before"

log "[*] Comparing against MedDefense whitelist (9 required services)..."
disabled=0
 while read service; do
  if egrep "^$service" "meddefense_service_whitelist.txt" >/dev/null; then
    log "  $service [ACTIVE]"
  else
    log "  $service [STOPPED] [DISABLED]"
    systemctl stop $service
    systemctl disable $service
    disabled=$((disabled + 1))
  fi
done <.enabled_services.txt

after=$(systemctl list-unit-files --no-pager --type=service --state=enabled |grep enabled |wc -l)

log "Before: $before | After: $after | Disabled: $disabled"
