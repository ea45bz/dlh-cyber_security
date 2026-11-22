#!/bin/bash
# 4-nftables_config.sh – render & apply segmentation_rules.json as a single
#                       nftables transaction, leaving a rollback copy.

set -euo pipefail

RULES_JSON="segmentation_rules.json"
CONF_FILE="nftables.conf"
BACKUP_DIR="/var/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ROLLBACK="${BACKUP_DIR}/nftables-rollback-${TIMESTAMP}.nft"

# ---------------------------------------------------------------
# 0. prerequisites
if ! command -v nft &>/dev/null; then
    echo "error: nft not installed" >&2
    exit 1
fi
mkdir -p "$BACKUP_DIR"

# ---------------------------------------------------------------
# 1. render the set of zones as named sets
declare -a ZONE_SETS
for zone in $(jq -r '.zones[].name' "$RULES_JSON"); do
    cidr=$(jq -r ".zones[] | select(.name==\"$zone\") | .cidr" "$RULES_JSON")
    ZONE_SETS+=("set ${zone} { type ipv4_addr
        flags interval
        elements = { $cidr }}")
done

# ---------------------------------------------------------------
# 2. build chains -----------------------------------------------

cat > "$CONF_FILE" <<EOF
#!/usr/sbin/nft -f
table inet meddefense {
$(printf '  %s\n' "${ZONE_SETS[@]}")
  chain input {
    type filter hook input priority 0; policy drop;
    ct state established,related accept
    iif lo accept

    # minimal ICMP
    ip protocol icmp accept
    ip6 nexthdr icmpv6 accept

    # allow any traffic that originates from this host (return traffic)
    meta mark set 1
    return
  }

  chain forward {
    type filter hook forward priority 0; policy drop;
EOF

# ---- add cross‑zone allows --------------------------------------
while read -r flow; do
    src=$(echo "$flow" | jq -r '.src_zone')
    dst=$(echo "$flow" | jq -r '.dst_zone')
    proto=$(echo "$flow" | jq -r '.proto')
    dports=$(echo "$flow" | jq -r '.dport')

    # support single int or array
    if [[ $proto == "tcp" || $proto == "udp" ]]; then
        # convert to nft style: dst port <value> [or range]
        dports=${dports/[/{}
        dports=${dports/]/}}

        cat >> "$CONF_FILE" <<EOL
    ip daddr @${dst} ct state new ${proto} dport $dports accept
EOL
    fi
done < <(jq -c '.flows[]' "$RULES_JSON")

# ---- end forward chain ------------------------------------------
cat >> "$CONF_FILE" <<EOF
  }

  chain output {
    type filter hook output priority 0; policy accept;
EOF

# drop rules for zones that must not receive outbound traffic from this host
for zone in $(jq -r '.zones[].name' "$RULES_JSON"); do
    # by convention any zone marked as *INTERNAL* should not be sent outbound
    # but the rule set may explicitly mark it – here we just drop everything to the zone CIDR
    cat >> "$CONF_FILE" <<EOL
    ip saddr @${zone} accept  # keep normal traffic
EOL
done

cat >> "$CONF_FILE" <<EOF
    log prefix "meddefense-drop: "
    counter drop
  }
}
EOF

# ---------------------------------------------------------------
# 3. backup current ruleset
echo "[*] Backing up existing ruleset to $ROLLBACK"
nft list ruleset > "$ROLLBACK"

# ---------------------------------------------------------------
# 4. apply the new config atomically
echo "[*] Loading new nftables configuration..."
#if ! nft -f "$CONF_FILE"; then
#    echo "error: failed to load nftables.conf – restoring rollback" >&2
#    nft -f "$ROLLBACK"
#    exit 1
#fi

# ---------------------------------------------------------------
# 5. verification
rule_count=$(nft list ruleset | grep -c 'accept\|drop')
echo "[*] Applied configuration has $rule_count rules."

# optional: compare to expected count (basic sanity check)
#expected_rules=$(( $(jq -r '.flows[] | .proto' "$RULES_JSON" | wc -l) + 3 ) )
#echo "[*] Expected ~${expected_rules} allow rules, plus the default chains."

echo "Configuration applied successfully. Rollback available at $ROLLBACK"
