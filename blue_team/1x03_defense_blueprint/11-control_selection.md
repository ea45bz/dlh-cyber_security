
Risk: RISK-001
controls:
  - Selected Control: "Sophos Intercept X (EDR for all endpoints, including servers)"
    CIS Control Mapping: "Control 7 – Endpoint Protection – ID EPR‑01"
    NIST CSF Mapping: "DE.AE.01"
    Control Type: "Detective"
    Control Category: "Technical"
    Implementation Cost: 25000
    Expected Risk Reduction: "$8,000,000 ALE reduction (~80%)"
    dependencies: []

  - Selected Control: "Network Segmentation (VLANs for servers, workstations, medical devices & guest zone)"
    CIS Control Mapping: "Control 5 – Network Boundary Protection – ID NET‑02"
    NIST CSF Mapping: "PR.DS.01"
    Control Type: "Preventive"
    Control Category: "Technical"
    Implementation Cost: 10000
    Expected Risk Reduction: "$1,000,000 ALE reduction (~10%)"
    dependencies: []

Risk: RISK-002
controls:
  - Selected Control: "FortiGate Firmware Upgrade to FortiOS v7.4.x (includes CVE‑2023‑27997 patch)"
    CIS Control Mapping: "Control 5 – Network Boundary Protection – ID FW‑01"
    NIST CSF Mapping: "PR.DS.04"
    Control Type: "Preventive"
    Control Category: "Technical"
    Implementation Cost: 25000
    Expected Risk Reduction: "$4,130,000 ALE reduction (~100%)"
    dependencies: []

  - Selected Control: "MFA on VPN and administrative accounts (using O365 E3 licenses)"
    CIS Control Mapping: "Control 8 – Access Control – ID AC‑01"
    NIST CSF Mapping: "PR.AC.07"
    Control Type: "Preventive"
    Control Category: "Technical"
    Implementation Cost: 3000
    Expected Risk Reduction: "$4,130,000 ALE reduction (~100%)"
    dependencies: ["FortiGate Firmware Upgrade"]

Risk: RISK-003
controls:
  - Selected Control: "Off‑site immutable backup to AWS S3 Glacier (cloud replication & WORM)"
    CIS Control Mapping: "Control 9 – Data Recovery Management – ID DR‑01"
    NIST CSF Mapping: "PR.IP.09"
    Control Type: "Corrective"
    Control Category: "Technical"
    Implementation Cost: 60000
    Expected Risk Reduction: "$840,000 ALE reduction (~100%)"
    dependencies: []

Risk: RISK-004
controls:
  - Selected Control: "Enforce AES‑256 Kerberos tickets & encrypt AD attributes"
    CIS Control Mapping: "Control 5 – Network Boundary Protection – ID AD‑01; Control 8 – Access Control – ID AC‑02"
    NIST CSF Mapping: "PR.AC.04, PR.DS.06"
    Control Type: "Preventive"
    Control Category: "Technical"
    Implementation Cost: 4000
    Expected Risk Reduction: "$2,437,500 ALE reduction (~100%)"
    dependencies: []

Risk: RISK-005
controls:
  - Selected Control: "Revamp security awareness program (role‑specific phishing simulations)"
    CIS Control Mapping: "Control 12 – Awareness & Training – ID AT‑01"
    NIST CSF Mapping: "PR.AT.02"
    Control Type: "Administrative"
    Control Category: "Operational"
    Implementation Cost: 10000
    Expected Risk Reduction: "$6,240,000 ALE reduction (~100%)"
    dependencies: []

Risk: RISK-006
controls:
  - Selected Control: "Medical Device Network Isolation + dedicated monitoring (VLAN + IDS/IPS on device subnet)"
    CIS Control Mapping: "Control 5 – Network Boundary Protection – ID MD‑01"
    NIST CSF Mapping: "PR.DS.02"
    Control Type: "Preventive"
    Control Category: "Technical"
    Implementation Cost: 55000
    Expected Risk Reduction: "$2,000,000 ALE reduction (~100%)"
    dependencies: ["Network Segmentation"]

Risk: RISK-007
controls:
  - Selected Control: "Sophos Intercept X (EDR for all endpoints)"
    CIS Control Mapping: "Control 7 – Endpoint Protection – ID EPR‑01"
    NIST CSF Mapping: "DE.AE.01"
    Control Type: "Detective"
    Control Category: "Technical"
    Implementation Cost: 25000
    Expected Risk Reduction: "$1,500,000 ALE reduction (~100%)"
    dependencies: ["Patch Management"]

Risk: RISK-008
controls:
  - Selected Control: "Advanced VLAN segmentation (server zone, workstation zone, medical‑device zone, guest zone)"
    CIS Control Mapping: "Control 5 – Network Boundary Protection – ID NET‑02"
    NIST CSF Mapping: "PR.DS.01"
    Control Type: "Preventive"
    Control Category: "Technical"
    Implementation Cost: 10000
    Expected Risk Reduction: "$5,000,000 ALE reduction (~100%)"
    dependencies: []

Risk: RISK-009
controls:
  - Selected Control: "Off‑site immutable backup to AWS S3 Glacier (cloud replication & WORM)"
    CIS Control Mapping: "Control 9 – Data Recovery Management – ID DR‑01"
    NIST CSF Mapping: "PR.IP.09"
    Control Type: "Corrective"
    Control Category: "Technical"
    Implementation Cost: 60000
    Expected Risk Reduction: "$420,000 ALE reduction (~100%)"
    dependencies: []

Risk: RISK-010
controls:
  - Selected Control: "Enterprise SIEM deployment (Wazuh) + centralized log forwarding from all devices"
    CIS Control Mapping: "Control 15 – Continuous Monitoring – ID CM‑01"
    NIST CSF Mapping: "DE.CM.04"
    Control Type: "Detective"
    Control Category: "Technical"
    Implementation Cost: 18000
    Expected Risk Reduction: "$1,400,000 ALE reduction (~100%)"
    dependencies: ["Log Forwarding configured on all devices"]

Control Dependency Map:
  - "FortiGate Firmware Upgrade --> VPN MFA"
  - "Network Segmentation --> Medical Device Isolation"
  - "Patch Management --> Endpoint EDR"
  - "Log Forwarding --> SIEM deployment"


The diagram shows the required order of implementation: a critical control (e.g., firmware upgrade) must be in place before its dependent controls (MFA on VPN) can provide the intended protection. Similarly, network segmentation has to precede device‑level isolation, and basic patch management must exist before an EDR solution is effective; log forwarding is necessary for the SIEM to function properly.