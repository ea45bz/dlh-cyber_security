#!/bin/bash
# 8-suricata_setup.sh – install Suricata, load rules and perform an offline replay test

set -euo pipefail
IFS=$'\n\t'

SURICATA_PKG="suricata"
JQ_PKG="jq"

RULES_SRC="/home/analyst/MedDefense_Lab/suricata/rules/"
RULES_DST="/var/lib/suricata/rules/"
SMOKE_PCAPPATH="/home/analyst/MedDefense_Lab/PCAPs/smoke.pcap"
LOGDIR="/tmp/suricata-smoke"

OUTPUT_JSON="setup_verification.json"

# ---------------------------------------------------------------
# 1. Install packages idempotently
install_pkg() {
    local pkg=$1
    if ! dpkg -l | grep -q "^ii\s*$pkg"; then
        echo "Installing $pkg ..."
        sudo apt-get update >/dev/null
        sudo apt-get install -y "$pkg" >/dev/null
    fi
}

echo "[*] Ensuring required packages are installed..."
install_pkg "$SURICATA_PKG"
install_pkg "$JQ_PKG"

# ---------------------------------------------------------------
# 2. Copy rules and count them
sudo mkdir -p "$RULES_DST"
sudo cp -a "$RULES_SRC"* "$RULES_DST"
rule_count=$(sudo find "$RULES_DST" -type f | wc -l)

echo "[*] Copied $rule_count rule files."

# ---------------------------------------------------------------
# 3. Render minimal suricata.yaml
cat > suricata.yaml <<EOF
%YAML 1.1
---
af-packet: {}
default-rule-path: /var/lib/suricata/rules

rule-files:
$(sudo find "$RULES_DST" -type f | while read -r r; do echo "  - $(basename "$r")"; done)
  - meddefense.rules   # placeholder for future custom rules

default-log-dir: /var/log/suricata
outputs:
  - eve-log:
      enabled: yes
      filetype: regular
      filename: eve.json
      types:
        - alert
        - http
        - dns
        - tls
        - fileinfo

pcap-file:
  enabled: true

vars:
  address-groups:
    HOME_NET: "[10.10.0.0/16]"
    EXTERNAL_NET: "!\$HOME_NET"
EOF

# ---------------------------------------------------------------
# 4. Test configuration
config_test_exit=0
if ! suricata -T -c ./suricata.yaml -v; then
    config_test_exit=$?
fi

# ---------------------------------------------------------------
# 5. Smoke test (offline replay)
rm -rf "$LOGDIR"
mkdir -p "$LOGDIR"

echo "[*] Running smoke test on $SMOKE_PCAPPATH ..."
suricata -c ./suricata.yaml -r "$SMOKE_PCAPPATH" -l "$LOGDIR"

smoke_alerts=$(jq '. | select(.event_type=="alert")' "$LOGDIR/eve.json" | wc -l)

# ---------------------------------------------------------------
# 6. Emit verification JSON
installed_version=$(suricata --version | head -n1 | awk '{print $NF}')
cat > "$OUTPUT_JSON" <<EOF
{
  "installed_version": "$(echo $installed_version)",
  "rule_count": $rule_count,
  "config_test_exit": $config_test_exit,
  "smoke_alerts": $smoke_alerts
}
EOF

chmod 644 "$OUTPUT_JSON"
echo ""
echo "Setup verification written to $OUTPUT_JSON"
