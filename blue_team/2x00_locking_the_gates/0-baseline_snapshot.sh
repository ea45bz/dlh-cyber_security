#!/bin/bash

echo "Hostname: $(hostname)"
echo "OS: $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d \")"
echo "Running services: $(systemctl list-units --type=service --state=active --no-pager |grep "loaded active" |wc -l)"
echo "Open ports: $(ss -antp |grep ^LISTEN|wc -l)"
echo "SUID binaries: $( find / -type f \( -perm -u=s \) -print 2>/dev/null|wc -l)"
echo "SGID binaries: $( find / -type f \( -perm -g=s \) -print 2>/dev/null|wc -l)"
echo "World-writable files: $( find / -path "/proc" -prune -o -path "/dev" -prune -o -path "/sys" -prune -o   -type f -perm -o=w -print|wc -l)"
