#!/bin/bash
#
# 0-network_baseline.sh – capture a host‑level network baseline

set -euo pipefail

OUT_FILE="network_baseline.json"
TIMESTAMP=$(jq -n --arg ts "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" '{ timestamp: $ts }')
HOSTNAME=$(jq -n --arg host "$(hostname)" '{ hostname: $host }')

# --------------------------------------------------------------------
# 1. Interfaces -------------------------------------------------------
interfaces_json=$(ip -j addr show | jq -r 'map({ name: .ifname,
    operstate: .operstate,
    mac: .address, addr: .addr_info }) ')
    #' |.[]| { ip: .local } }')

# --------------------------------------------------------------------
# 2. Routes ----------------------------------------------------------
routes_json=$(ip -j route show | jq '
    map({
        dst: (.dst // "default"),
        gateway: .gateway,
        iface: .oif_name,
        mtu: .mtu
    })')

# --------------------------------------------------------------------
# 3. ARP neighbors ----------------------------------------------------
neighbors_json=$(ip -j neigh show | jq '
    map({
        ip: .ip_address,
        mac: .lladdr,
        state: .state,
        iface: .iface
    })')

# --------------------------------------------------------------------
# 4. Listening sockets -----------------------------------------------
listening_json=$(ss -tulnpH |python3  -c '
import json,sys
text=sys.stdin.read()
rows=[]
for line in text.splitlines():
    fields = line.split(maxsplit=6)
    if len(fields) >= 6:
        rows.append({
            "netid": fields[0],
            "state": fields[1],
            "local_address": fields[4],
            "peer_address": fields[5],
            "process": fields[6] if len(fields) > 6 else None,
        })
print(json.dumps(rows, indent=2))
')
# --------------------------------------------------------------------
# 5. Established connections -----------------------------------------
established_json=$(ss -tnpH state established |python3  -c '
import json,sys
text=sys.stdin.read()
rows=[]
for line in text.splitlines():
    fields = line.split(maxsplit=6)
    if len(fields) >= 5:
        rows.append({
            "local_address": fields[2],
            "peer_address": fields[3],
            "process": fields[4] if len(fields) > 4 else None,
        })
print(json.dumps(rows, indent=2))
')

# --------------------------------------------------------------------
# 6. DNS resolvers ----------------------------------------------------
dns_resolvers=""
resolv_conf=$(sed '/^#/d' /etc/resolv.conf | awk '{print "{\"search\": \""$2"\"}"}' | jq -s .)
dns_resolvers=$(echo "[" $resolv_conf "]" | jq -s add )

# --------------------------------------------------------------------
# 7. Assemble final JSON ---------------------------------------------
final_json=$(jq -n \
    --argjson ts "$TIMESTAMP" \
    --argjson host "$HOSTNAME" \
    --argjson interfaces "$interfaces_json" \
    --argjson routes "$routes_json" \
    --argjson neighbors "$neighbors_json" \
    --argjson listeners "$listening_json" \
    --argjson established "$established_json" \
    --argjson dns "$dns_resolvers" \
    '{
        timestamp: $ts,
        hostname: $host,
        interfaces: $interfaces,
        routes: $routes,
        neighbors: $neighbors,
        listening_sockets: $listeners,
        established_connections: $established,
        dns_resolvers: $dns
     }')

echo "$final_json" > "$OUT_FILE"
chmod 644 "$OUT_FILE"

# --------------------------------------------------------------------
# quick summary for console
listener_count=$(echo "$listening_json" | jq 'length')
echo "Network baseline created: $OUT_FILE"
echo "Timestamp: $TIMESTAMP"
echo "Hostname: $HOSTNAME"
echo "Active interfaces: $(echo "$interfaces_json" | jq -r '.[] | .name' | tr '\n' ', ')"
echo "Listeners: $listener_count"
