#!/bin/bash
# 10-rule_validation.sh – run Suricata on each labeled PCAP and confirm that
# the custom rule fires.

set -euo pipefail

RULES="meddefense.rules"
SURICATA_CFG="./suricata.yaml"

# helper to run a single test
run_test() {
    local pcap=$1
    local sid=$2
    local description=$3

    echo "sid $sid $description"
    echo "  target: $(basename "$pcap")"

    # create temp dir for output
    tmp=$(mktemp -d)
    suricata -c "$SURICATA_CFG" -r "$pcap" -l "$tmp" -k none
    if [[ ! -f $tmp/eve.json ]]; then
        echo "  expected: fire"
        echo "  observed: no eve.json – FAIL"
        return 1
    fi

    hits=$(jq --arg sid "$sid" '. | select(.event_type=="alert") |
                            select(.alert.signature_id== ($sid|tonumber))' \
             "$tmp/eve.json" | wc -l)

    if [[ $hits -gt 0 ]]; then
        echo "  expected: fire"
        echo "  observed: fire ($hits hit$([ $hits -ne 1 ] && echo 's'))                PASS"
        return 0
    else
        echo "  expected: fire"
        echo "  observed: none                                      FAIL"
        return 1
    fi
}

echo "[*] Loading meddefense.rules... 6 rules"

failed=0
total=0

# mapping of PCAP file -> SID & description
declare -A tests
tests["meddev_egress.pcap"]="9000001 MEDDEV to Internet"
tests["guest_smb.pcap"]="9000002 Guest to SMB"
tests["large_outbound.pcap"]="9000003 Large Outbound From Server"
tests["dns_tunnel.pcap"]="9000004 DNS Tunneling Long Label"
tests["clinical_wrong_db.pcap"]="9000005 Clinical to Unauthorized DB"
tests["telnet_meddev.pcap"]="9000006 Telnet to MEDDEV"

echo "[*] Running validation against labeled PCAPs..."

for pcap in "${!tests[@]}"; do
    sid_desc=${tests[$pcap]}
    IFS=' ' read -r sid desc <<<"$sid_desc"
    if ! run_test "/home/analyst/MedDefense_Lab/PCAPs/labels/$pcap" "$sid" "$desc"; then
        failed=$((failed+1))
    fi
    total=$((total+1))
done

echo ""
echo "Rules:  $total"
echo "Passed: $((total-failed))"
echo "Failed: $failed"

exit $failed
