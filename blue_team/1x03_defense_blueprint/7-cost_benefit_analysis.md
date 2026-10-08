
Control 1: "Endpoint Detection and Response Upgrade (Sophos Intercept X)"
CIS Control Reference: "Control 7 – Endpoint Protection"
Annual Cost:
  license: 20000
  labor_and_support: 5000
  total: 25000
Risk(s) Addressed:
  - Ransomware encrypts the EHR system
  - Phishing / social engineering leads to credential compromise
ALE Reduction: 8000000   # 10 M ALE before – ~2 M after (post‑detection mitigation)
Net Value: 7975000       # 8,000,000 – 25,000
Verdict: "Justified"
Recommendation: "Implement immediately; provides the highest risk reduction per dollar spent."

Control 2: "Network Segmentation (VLAN implementation for servers, workstations, medical devices and guest zones)"
CIS Control Reference: "Control 5 – Network Boundary Protection"
Annual Cost:
  labor_and_config: 10000
  total: 10000
Risk(s) Addressed:
  - Unencrypted VPN grants remote attackers a foothold
  - Backup data destruction on the on‑prem NAS
ALE Reduction: 4970000   # 4,130,000 + 840,000 (separate mitigation)
Net Value: 4960000
Verdict: "Justified"
Recommendation: "Implement; it delivers a huge cost‑benefit by preventing multiple high‑impact attacks."

Control 3: "Outsourced 24/7 Security Operations Center (Managed SOC)"
CIS Control Reference: "Control 15 – Continuous Monitoring"
Annual Cost:
  vendor_contract: 100000
  total: 100000
Risk(s) Addressed:
  - Ransomware encrypts the EHR system
  - Unencrypted VPN grants remote attackers a foothold
  - Phishing / social engineering leads to credential compromise
  - Backup data destruction on the on‑prem NAS
ALE Reduction: 3000000   # Broad detection & response reduces all high ALE risks by ~30%
Net Value: 2900000
Verdict: "Justified"
Recommendation: "Implement; provides comprehensive coverage and high ROI, though it consumes a large portion of the budget."

Control 4: "Multi‑Factor Authentication on VPN and Administrative Accounts (O365 E3 licenses)"
CIS Control Reference: "Control 8 – Access Control"
Annual Cost:
  existing_licenses: 0
  labor_and_config: 3000
  total: 3000
Risk(s) Addressed:
  - Unencrypted VPN grants remote attackers a foothold
  - Credential theft via weak Kerberos (RC4) and AD authentication
ALE Reduction: 2065000   # ~50% reduction of 4,130,000 + 50% of 2,437,500
Net Value: 2062000
Verdict: "Justified"
Recommendation: "Implement; low cost with substantial risk mitigation."

Control 5: "Medical Device Network Isolation and Dedicated Monitoring"
CIS Control Reference: "Control 5 – Network Boundary Protection"
Annual Cost:
  hardware_and_setup: 55000
  total: 55000
Risk(s) Addressed:
  - Ransomware encrypts the EHR system (via device compromise)
  - Backup data destruction on the on‑prem NAS (indirect protection)
ALE Reduction: 2000000   # Estimated 1 M reduction from ransomware + 1 M indirect
Net Value: 1945000
Verdict: "Justified"
Recommendation: "Implement; protects critical medical devices and strengthens overall posture."

Control 6: "Enterprise SIEM Deployment (Wazuh – open‑source, labor only)"
CIS Control Reference: "Control 15 – Continuous Monitoring"
Annual Cost:
  labor_and_config: 18000
  total: 18000
Risk(s) Addressed:
  - Ransomware encrypts the EHR system
  - Backup data destruction on the on‑prem NAS
  - Unencrypted VPN grants remote attackers a foothold
ALE Reduction: 1500000   # Early detection cuts ALE by ~15%
Net Value: 1482000
Verdict: "Justified"
Recommendation: "Implement; adds valuable visibility at modest cost."

Control 7: "Dedicated Firewall for Westside Clinic (replacing consumer router)"
CIS Control Reference: "Control 5 – Network Boundary Protection"
Annual Cost:
  hardware_and_license: 28000
  total: 28000
Risk(s) Addressed:
  - Unencrypted VPN grants remote attackers a foothold
  - Credential theft via weak Kerberos (RC4) and AD authentication
ALE Reduction: 1240000   # ~30% of 4,130,000
Net Value: 1212000
Verdict: "Justified"
Recommendation: "Implement; improves network security for the remote site with a clear ROI."

Control 8: "Off‑Site Backup Replication to AWS S3 Glacier (Immutable Storage)"
CIS Control Reference: "Control 7 – Endpoint Protection / Control 9 – Data Recovery"
Annual Cost:
  storage_and_bandwidth: 60000
  total: 60000
Risk(s) Addressed:
  - Backup data destruction on the on‑prem NAS
ALE Reduction: 588000   # 70% reduction of 840k ALE
Net Value: -72000        # 588,000 – 60,000 = -72,000
Verdict: "Not Justified"
Recommendation: "Reject; cost exceeds the risk reduction benefit."

Cost-Benefit Summary Table:
  ranked_by_Net Value:
    - control_1: 7975000
    - control_2: 4960000
    - control_3: 2900000
    - control_4: 2062000
    - control_5: 1945000
    - control_6: 1482000
    - control_7: 1212000
    - control_8: -72000
  
within budget of 120k:
    - Endpoint Detection and Response Upgrade (Control 1): 25000
    - Network Segmentation (Control 2): 10000
    - MFA on VPN (Control 4): 3000
    - SIEM Deployment (Control 6): 18000
    - Dedicated Firewall for Westside Clinic (Control 7): 28000
    - Total Cost: 88000   # < 120k, leaving room for other initiatives

