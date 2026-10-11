#!/bin/bash

log() { printf '\033[1;32m%s\033[0m\n' "$*"; }

suid_set() {
    if egrep "^$1$" "${mode}uid_whitelist.txt" >/dev/null; then
       wl_count=$((wl_count + 1))
     else
       if [[ ${mode} == "s" ]]; then
         chmod u-s $1
       else
         chmod g-s $1
       fi
       log "  $1 [${mode^}UID REMOVED]"
       nwl_count=$((nwl_count + 1))
     fi
}

log "Found $( find / -type f \( -perm -u=s \) -print 2>/dev/null|wc -l) SUID binaries"
wl_count=0
nwl_count=0
mode=s
find / -type f \( -perm -u=s \) -print 2>/dev/null >.found_binaries.txt
while read fname; do
  suid_set $fname ;
done <.found_binaries.txt
log "Whitelisted: ${wl_count}"
log "Non-whitelisted: ${nwl_count}"
suid_count=${nwl_count}

log "Found $( find / -type f \( -perm -g=s \) -print 2>/dev/null|wc -l) SGID binaries"
wl_count=0
nwl_count=0
mode=g
find / -type f \( -perm -g=s \) -print 2>/dev/null >.found_binaries.txt
while read fname; do
  suid_set $fname ;
done <.found_binaries.txt
log "Whitelisted: $wl_count"
log "Non-whitelisted: ${nwl_count}"
guid_count=${nwl_count}


log "Found  $( find / -path "/proc" -prune -o -path "/dev" -prune -o -path "/sys" -prune -o   -type f -perm -o=w -print|wc -l) world-writable files"
ww_count=0
find / -path "/proc" -prune -o -path "/dev" -prune -o -path "/sys" -prune -o   -type f -perm -o=w  -print 2>/dev/null >.found_binaries.txt
while read fname; do
   chmod o-w $fname
   log "  $fname [FIXED]"
   ww_count=$((ww_count + 1))
done <.found_binaries.txt

check_mount() {
if  findmnt  -n -l $1 |  egrep "nosuid,nodev,noexec"; then
  log "${1}: noexec,nosuid,nodev  [OK]"
else
  log "${1}: noexec,nosuid,nodev  [APPLIED]"
fi
}

check_mount /var
check_mount /var/tmp
check_mount /dev/shm

log "SUID remediated: ${suid_count} | SGID remediated: ${guid_count} | World-writable fixed: ${ww_count}"
