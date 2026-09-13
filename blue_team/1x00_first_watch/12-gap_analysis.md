**Prioritized Gap Analysis**
Gap ID: GAP-001
Title: "No corrective restoration test for EHR server"
Affected Asset(s): "ASSET014 – EHR‑SRV‑01 (EHR System – Critical)"
Data at Risk: "PHI, billing data – Confidential"
Current Control Status: "C-005 “Scheduled nightly full backup” is preventive only"
What is Missing: "Corrective: periodic restore test & integrity check of EHR database and files"
Risk Level: "Critical"
Risk Justification: "Asset is critical + no detective/corrective → highest risk"
Potential Impact: "Full downtime or undetected corruption could lead to incorrect orders, regulatory fines and patient harm."

Gap ID: GAP-002
Title: "No corrective restoration test for EHR database"
Affected Asset(s): "ASSET015 – EHR‑DB‑01 (PostgreSQL DB – Critical)"
Data at Risk: "PHI – Confidential"
Current Control Status: "C-005 “Scheduled nightly full backup” is preventive only"
What is Missing: "Corrective: recovery testing & validation of database backups"
Risk Level: "Critical"
Risk Justification: "Same as GAP‑001 but for the data layer, with identical high consequence"
Potential Impact: "Loss of database integrity causes cascading failures in all downstream systems."

Gap ID: GAP-003
Title: "No asset‑specific firewall/IDS rules for PACS"
Affected Asset(s): "ASSET016 – PACS‑SRV‑01 (Imaging – Critical)"
Data at Risk: "PHI (images) – Confidential"
Current Control Status: "C-001 “Network perimeter ‘Deny‑All’ rule” applies to all devices but no internal segmentation or specific rules"
What is Missing: "Preventive: PACS‑specific IDS/IPS + segmentation from other servers"
Risk Level: "High"
Risk Justification: "Asset critical & protection only at generic network level → high likelihood of lateral compromise"
Potential Impact: "Unauthorized imaging access could mislead diagnosis and expose PHI."

Gap ID: GAP-004
Title: "No application‑level logs for PACS server"
Affected Asset(s): "ASSET016 – PACS‑SRV‑01 (Imaging – Critical)"
Data at Risk: "PHI – Confidential"
Current Control Status: "C-006 “Firewall traffic logging” is network‑level only"
What is Missing: "Detective: server‑ and application‑level audit logs & monitoring"
Risk Level: "High"
Risk Justification: "Without detection, malicious modifications to images go unnoticed"
Potential Impact: "Image tampering could result in misdiagnosis or patient safety incidents."

Gap ID: GAP-005
Title: "No backup recovery test for imaging data"
Affected Asset(s): "ASSET016 – PACS‑SRV‑01 (Imaging – Critical)"
Data at Risk: "PHI – Confidential"
Current Control Status: "C-005 “Scheduled nightly full backup” is preventive only"
What is Missing: "Corrective: restore & validation of PACS image archives"
Risk Level: "High"
Risk Justification: "Imaging is critical; lack of recovery testing undermines availability"
Potential Impact: "Data loss could halt treatment plans and violate HIPAA."

Gap ID: GAP-006
Title: "No domain‑controller disaster‑recovery plan"
Affected Asset(s): "ASSET018 – AD‑DC‑01 (Network Core – Critical)"
Data at Risk: "Credentials, group policy data – Confidential"
Current Control Status: "C-001 “Network perimeter ‘Deny‑All’ rule” & C-006 logging only"
What is Missing: "Corrective: DC backup, restoration testing and failover strategy"
Risk Level: "Critical"
Risk Justification: "Loss of DC → entire network compromised; no corrective test"
Potential Impact: "Rapid lateral movement, credential theft, ransomware spread."

Gap ID: GAP-007
Title: "No firmware hardening / device firewall for ICU monitor"
Affected Asset(s): "ASSET024 – MON‑ICU‑01 (Medical IoT – Critical)"
Data at Risk: "PHI & patient vitals – Confidential"
Current Control Status: "None identified in matrix"
What is Missing: "Preventive: device firewall, secure boot, updated firmware only"
Risk Level: "Critical"
Risk Justification: "Device is critical; no technical protection → high chance of exploitation"
Potential Impact: "Tampered readings can directly cause patient harm or death."

Gap ID: GAP-008
Title: "No logging/monitoring on ICU monitor web UI"
Affected Asset(s): "ASSET024 – MON‑ICU‑01 (Medical IoT – Critical)"
Data at Risk: "PHI – Confidential"
Current Control Status: "None identified"
What is Missing: "Detective: application logs, intrusion detection for device interface"
Risk Level: "High"
Risk Justification: "Without detection malicious changes may persist undetected"
Potential Impact: "Undiscovered compromised device can be used to exfiltrate data or manipulate therapy."

Gap ID: GAP-009
Title: "No backup recovery test for backup infrastructure (NAS/Backup‑SRV)"
Affected Asset(s): "BACKUP‑SRV‑01 / NAS‑01 (Backup & Storage – Critical)"
Data at Risk: "All PHI, imaging, EHR, billing – Confidential"
Current Control Status: "C-014 “Backup recovery testing” exists but is weak"
What is Missing: "Corrective: periodic full restore test for backup assets themselves"
Risk Level: "Critical"
Risk Justification: "Failure to recover means all data could be lost permanently"
Potential Impact: "Loss of disaster‑recovery capability; non‑compliance with HIPAA."

Gap ID: GAP-010
Title: "No privileged access monitoring on sensitive servers (EHR/DB)"
Affected Asset(s): "ASSET014, ASSET015 (EHR & DB – Critical)"
Data at Risk: "PHI – Confidential"
Current Control Status: "C-002 “Disable SSH root login” + password policy exist but no audit of privileged sessions"
What is Missing: "Detective: privileged account activity monitoring, session recording"
Risk Level: "High"
Risk Justification: "Lack of visibility into admin actions increases risk of undetected insider threats"
Potential Impact: "Unnoticed privilege abuse could lead to data theft or sabotage."

---

### Gap Distribution Summary

| Risk Level | # Gaps                              |
| ---------- | ----------------------------------- |
| Critical   | 5 (GAP‑001, ‑002, ‑006, ‑007, ‑009) |
| High       | 4 (GAP‑003, ‑004, ‑005, ‑008, ‑010) |
| Medium     | –                                   |
| Low        | –                                   |

**Asset Categories with the Most Gaps**

1. **Critical (EHR / DB / Imaging / Backup / IoT)** – 10 gaps total
2. **Administrative / Physical** – none of the top 10 gaps; existing controls insufficient but not categorized as gaps in this list.

**Control Category / Function Concentration**

| Category       | Function   | # Gaps                        |
| -------------- | ---------- | ----------------------------- |
| Technical      | Preventive | 3 (GAP‑003, ‑007, ‑009)       |
| Technical      | Detective  | 3 (GAP‑004, ‑008, ‑010)       |
| Administrative | Corrective | 4 (GAP‑001, ‑002, ‑005, ‑009) |
