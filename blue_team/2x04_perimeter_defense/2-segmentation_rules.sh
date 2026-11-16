#!/bin/bash
# 2-segmentation_rules.sh – create a JSON rule set describing MedDefense zones and allowed cross‑zone flows

set -euo pipefail
IFS=$'\n\t'

OUT_FILE="segmentation_rules.json"

cat > "$OUT_FILE" <<'EOF'
{
  "zones": [
    {
      "name": "MGMT",
      "cidr": "10.10.0.0/24",
      "purpose": "Administration",
      "default_inbound": "drop",
      "default_outbound": "accept"
    },
    {
      "name": "INTERNAL",
      "cidr": "10.10.1.0/24",
      "purpose": "Clinical applications & databases",
      "default_inbound": "drop",
      "default_outbound": "accept"
    },
    {
      "name": "DMZ",
      "cidr": "10.10.2.0/24",
      "purpose": "Public‑facing services (web, API)",
      "default_inbound": "drop",
      "default_outbound": "accept"
    },
    {
      "name": "MEDDEV",
      "cidr": "10.10.3.0/24",
      "purpose": "Medical device VLAN",
      "default_inbound": "drop",
      "default_outbound": "accept"
    }
  ],
  "flows": [
    # MGMT → INTERNAL
    {
      "src_zone": "MGMT",
      "dst_zone": "INTERNAL",
      "proto": "tcp",
      "dport": [22],
      "justification": "SSH to clinical servers",
      "exception_for": null
    },
    # MGMT → DMZ
    {
      "src_zone": "MGMT",
      "dst_zone": "DMZ",
      "proto": "tcp",
      "dport": [22],
      "justification": "SSH to web and API hosts",
      "exception_for": null
    },
    # INTERNAL workstations → INTERNAL servers
    {
      "src_zone": "INTERNAL",
      "dst_zone": "INTERNAL",
      "proto": "tcp",
      "dport": [443, 3306],
      "justification": "EHR/DB traffic within clinical network",
      "exception_for": null
    },
    # DMZ application hosts → INTERNAL databases
    {
      "src_zone": "DMZ",
      "dst_zone": "INTERNAL",
      "proto": "tcp",
      "dport": [3306],
      "justification": "Database access from public APIs",
      "exception_for": null,
      "app_hosts_only": true
    },
    # MEDDEV → INTERNAL (DICOM + EHR)
    {
      "src_zone": "MEDDEV",
      "dst_zone": "INTERNAL",
      "proto": "tcp",
      "dport": [4242, 443],
      "justification": "Medical devices talking to PACS & EHR web",
      "exception_for": null
    },
    # Any zone → MGMT DNS resolver
    {
      "src_zone": "*",
      "dst_zone": "MGMT",
      "proto": ["udp", "tcp"],
      "dport": [53],
      "justification": "Domain name resolution for all zones",
      "exception_for": null
    }
  ],
  "deny_all": [
    # explicit deny when no flow is defined between zone pairs
    {
      "src_zone": "*",
      "dst_zone": "MEDDEV",
      "reason": "No outbound from MEDDEV or Internet"
    },
    {
      "src_zone": "MEDDEV",
      "dst_zone": ["DMZ", "*"],
      "reason": "Medical devices are isolated from public and DMZ networks"
    }
  ],
  "summary": {
    "flow_count": 7,
    "allow_count": 7,
    "deny_count": 2,
    "cross_zone_pairs": [
      {"src":"MGMT","dst":"INTERNAL"},
      {"src":"MGMT","dst":"DMZ"},
      {"src":"INTERNAL","dst":"INTERNAL"},
      {"src":"DMZ","dst":"INTERNAL"},
      {"src":"MEDDEV","dst":"INTERNAL"},
      {"src":"*","dst":"MGMT"}
    ]
  }
}
EOF

chmod 644 "$OUT_FILE"
echo "Segmentation rule set written to $OUT_FILE"
