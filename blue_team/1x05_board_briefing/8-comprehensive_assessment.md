# **MedDefense Health Systems – Comprehensive Security Assessment**

_Prepared for Dr. Patricia Morales and the Board of Directors – 24 Sept 2026_

---

## Executive Summary _(≈1 page)_

MedDefense has evolved into a complex, flat‑network healthcare delivery system serving ~2,400 staff across three sites (Central Hospital, Westside Clinic, Corporate HQ). The organization hosts critical medical data—EHR, PACS, billing and financial records—and is the target of multiple ransomware campaigns.

**Key findings:**

- **FortiGate SSL‑VPN CVE‑2023‑27997** remains unpatched; the single perimeter device is a critical kill‑chain entry point exploited by the _Crimson Tide_ RaaS campaign.
- A flat, unsegmented network exposes servers, workstations and medical devices to lateral movement.
- Active directory authentication controls are weak (RC4 Kerberos, no MFA).
- Backups reside on the same LAN as production data, are unencrypted, and lack restoration validation.

The **72‑hour emergency plan** has been executed: VPN service disabled, NAS physically isolated, AD Kerberos policy hardened, and a support contract for FortiGate renewed. Remaining priorities include network segmentation, patching, MFA rollout, and endpoint detection.

MedDefense remains **exposed to immediate ransomware risk**, but the rapid response mitigates the most direct attack vectors. The full implementation of the remaining controls will bring the overall risk below an acceptable level (ALE < $5M/yr) while preserving clinical operations.

---

## Emergency Status – Crimson Tide Threat

| Item                                   | Detail                                                                                                                                                                                                                                                                                                     |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **What is happening?**                 | The _Crimson Tide_ ransomware‑as‑a‑service network is actively exploiting CVE‑2023‑27997 on FortiGate firewalls, gaining control of the perimeter device, and then moving laterally across a flat internal network to exfiltrate patient, financial and employee data.                                     |
| **Is MedDefense in the blast radius?** | Yes – our single FortiGate 100F runs an affected firmware (7.2.x), all sites connect via SSL‑VPN, no MFA is enforced on VPN or AD logons, and backups are co‑located with production servers.                                                                                                              |
| **72‑hour action plan summary**        | • Disable SSL‑VPN until patch; physically disconnect NAS; renew FortiGate support contract ($2 400) and download the latest firmware. <br>• Harden AD Kerberos (disable RC4, enable AES). <br>• Implement MFA for all remote users. <br>• Forward FortiGate logs to SIEM; block known malicious IP ranges. |

---

## Security Posture Overview

| Category            | Asset Summary                                              |
| ------------------- | ---------------------------------------------------------- |
| **Servers**         | 10 (EHR, Billing, AD DCs, PACS, backups).                  |
| **Workstations**    | ~380 (clinical & admin), all Windows 10/11.                |
| **Medical Devices** | 120 Philips IntelliVue + 120 BD Alaris pumps.              |
| **Network**         | Flat 10.10.0.0/16, no VLANs, single FortiGate firewall.    |
| **Backups**         | NAS‑01 & Veeam backup server on the same LAN, unencrypted. |

### Control Maturity (NIST CSF 2.0)

| Function | Status                                          | Notes                                                                                                                       |
| -------- | ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Govern   | Managed (Policy exists)                         | Gap: No formal risk‑management charter.                                                                                     |
| Identify | Managed (Inventory & asset registry maintained) | Gap: Incomplete coverage of shadow IT devices.                                                                              |
| Protect  | Partially Managed                               | 5 critical gaps: FortiGate vulnerability, flat network, weak AD controls, unencrypted backups, missing endpoint protection. |
| Detect   | Not Implemented                                 | No SIEM or centralized logs.                                                                                                |
| Respond  | Not Implemented                                 | No IR playbook; incident response relies on ad‑hoc actions.                                                                 |
| Recover  | Managed (Nightly backup)                        | Gap: No recovery testing; no off‑site copy.                                                                                 |

**Top Gaps:**

1. **FortiGate CVE‑2023‑27997** – single perimeter device, unpatched.
2. **Network segmentation** – flat LAN allows lateral movement.
3. **AD authentication** – RC4 Kerberos, no MFA.
4. **Backup isolation & encryption** – same LAN, unencrypted.
5. **Endpoint detection** – no EDR or SIEM.

---

## Threat Landscape _(from 1x01)_

| Rank | Threat Actor                          | Current Status                                                       | Impact                                   |
| ---- | ------------------------------------- | -------------------------------------------------------------------- | ---------------------------------------- |
| 1    | Crimson Tide (RaaS)                   | Active; exploiting FortiGate CVE, targeting hospitals in our region. | Ransom + data breach (double extortion). |
| 2    | Nation‑state actors (APT28, APT29)    | Infiltration attempts via unpatched Windows & VPN.                   | Data exfiltration, sabotage.             |
| 3    | Cybercriminal groups (FIN7, Carbanak) | Opportunistic attacks on legacy medical devices.                     | Ransomware, device tampering.            |

### Crimson Tide in Original Threat Model

The campaign aligns with the _Initial Access → Lateral Movement → Data Exfiltration_ chain identified in our baseline threat model. The new intelligence confirms that MedDefense's current perimeter and authentication controls directly map to their exploited vectors.

---

## Vulnerability Status _(from 1x02)_

| #   | Finding                                    | Severity | Key Impact                                          | Remediation                                             |
| --- | ------------------------------------------ | -------- | --------------------------------------------------- | ------------------------------------------------------- |
| 1   | **CVE‑2023‑27997** – FortiGate SSL‑VPN RCE | Critical | Full firewall takeover, enabling lateral movement.  | Patched (contract renewal) – _Completed_                |
| 2   | **PostgreSQL unrestricted access**         | Critical | Direct read/write of EHR data by any internal host. | Port restriction + `pg_hba.conf` update – _In Progress_ |
| 3   | **SSH password auth on billing‑srv-01**    | High     | Privilege escalation potential.                     | Migrated to key‑only – _Completed_                      |
| 4   | **Unencrypted backups (NAS‑01)**           | Critical | Backup deletion, data loss.                         | Physical isolation – _Completed_                        |
| 5   | **AD Kerberos RC4 enabled**                | High     | Credential theft via Kerberoasting.                 | AES‑256 enforced – _In Progress_                        |

Remediation has progressed: 2 of the 5 critical findings are fully closed; 3 remain in transition (segmentation, AD hardening, backup encryption).

---

## Risk Quantification _(from 1x03)_

| Rank | Risk ID                            | Threat Source       | ARO (per year) | SLE ($)   | ALE ($/yr)     |
| ---- | ---------------------------------- | ------------------- | -------------- | --------- | -------------- |
| 1    | RISK‑001 (Crimson Tide ransomware) | Crimson Tide        | 5              | 4,000,000 | **20,000,000** |
| 2    | RISK‑NEW-001 (CVE‑2023‑27997)      | CT + CVE exploit    | 2              | 5,000,000 | **10,000,000** |
| 3    | RISK‑002 (Unencrypted backups)     | Internal / external | 4              | 1,500,000 | 6,000,000      |
| 4    | RISK‑003 (AD Kerberos RC4)         | CT & other APTs     | 3              | 800,000   | 2,400,000      |
| 5    | RISK‑004 (PostgreSQL unrestricted) | Insider / external  | 2              | 1,200,000 | 2,400,000      |

**Total ALE (pre‑remediation): $40M/yr.**  
With the 72‑hour actions applied, ALE drops to **$12M/yr** (the top two risks mitigated).

---

## Budget Allocation Status

| Category                             | Planned Cost | Current Spend    | Variance |
| ------------------------------------ | ------------ | ---------------- | -------- |
| Emergency Patch & Support            | $2,400       | $2,400           | 0%       |
| MFA Roll‑out                         | $8,000       | $4,500 (partial) | –50%     |
| Network Segmentation (switch config) | $12,000      | $0               | –100%    |
| EDR deployment                       | $15,000      | $0               | –100%    |
| Backup encryption & off‑site copy    | $20,000      | $0               | –100%    |
| **Total**                            | **$57,400**  | **$6,900**       | –88%     |

_Board‑approved emergency budget: $12,000. The remaining $45k is earmarked for the next 90‑day accelerated roadmap._

---

## ROI of Implemented vs Planned Controls

| Control               | Cost          | ALE Reduction | Payback   |
| --------------------- | ------------- | ------------- | --------- |
| FortiGate patch       | $2,400        | $10M          | < 30 days |
| NAS isolation         | $0 (physical) | $6M           | < 24 h    |
| MFA rollout (partial) | $4,500        | $1.5M         | < 90 days |
| Kerberos hardening    | $2,000        | $2.4M         | ~180 days |

All implemented controls deliver a **>10x ROI** relative to cost and are in the top‑tier risk mitigations.

---

## Cryptographic Posture _(from 1x04)_

- **Data at Rest:**
  - EHR database: **0% encryption** (critical).
  - Backup NAS: **0% encryption**.
  - Windows logs & AD: **AES‑256 in transit, but not all data encrypted**.

- **Data in Transit:**
  - VPN traffic: **Unencrypted SSL V1/SSL V2** before patching; now upgraded to TLS 1.2+.
  - RDP and SSH: **Strong encryption (TLS 1.3 / AES‑256).**

- **Critical Crypto Gaps Exposed by Crimson Tide:**
  - Unencrypted backups (CVE‑2023‑27997 enabled attacker to copy data pre‑encryption).
  - RC4 Kerberos in AD – vulnerable to offline brute force.

**Action:** Encrypt EHR DB using Transparent Data Encryption (TDE) and enable AES‑256 only for Kerberos; deploy full‑disk encryption on all servers.

---

## Compliance Status – HIPAA

| Control                  | Status                               |
| ------------------------ | ------------------------------------ |
| PHI protection policy    | In place but lacks audit of backups. |
| Breach notification plan | Exists, but not tested.              |
| Encryption at rest       | **Non‑compliant** for EHR & backups. |
| Access controls          | MFA pending; AD credentials weak.    |

MedDefense is **currently in breach risk** due to unencrypted data and inadequate authentication.

---

## Recommendations

1. **Immediate (72 h):**
   - Complete FortiGate patching.
   - Disable SSL‑VPN until all endpoints re‑authenticate via MFA.
   - Finish NAS isolation; schedule backup migration off‑site.
2. **30‑Day Accelerated Roadmap:**
   - Deploy network segmentation (VLANs, ACLs) – 3‑day switch config.
   - Harden AD: enforce AES‑256, disable RC4, enable MFA for all admins.
   - Implement EDR and SIEM; forward logs from FortiGate and endpoints.
   - Encrypt EHR database and backup media (TDE & encrypted VMs).
3. **Year‑1 Strategic Priorities:**
   - Complete zero‑trust architecture across all sites.
   - Deploy continuous monitoring, anomaly detection, and automated patch management.
   - Conduct quarterly penetration tests and tabletop exercises for ransomware response.
4. **Budget Request (next 30 days):**
   - $40,000 for segmentation, EDR, MFA licensing, backup off‑site storage, and encryption tools.

---

## Residual Risk Disclosure

| Risk                                                              | Current ALE | Post‑implementation ALE | Acceptance                                  |
| ----------------------------------------------------------------- | ----------- | ----------------------- | ------------------------------------------- |
| Unpatched legacy medical device firmware (e.g., BD Alaris 12.1.2) | $2M         | $800k                   | Acceptable pending vendor patch.            |
| Insider threat via privileged accounts (non‑admin)                | $1M         | $200k                   | Acceptable with role‑based access controls. |
| Supply‑chain compromise of third‑party firmware updates           | $500k       | $100k                   | Acceptable after supplier audit.            |

**MedDefense accepts these residual risks** because they represent lower‑impact vectors relative to the mitigated ransomware threat, and remediation would impose disproportionate operational costs or downtime.

---

## Next Module Preview

- **Endpoint Hardening:** Zero‑trust device posture for all workstations and medical devices.
- **Infrastructure Defense Layering:** Multi‑layered segmentation (application, network, data).
- **Automation & Orchestration:** SIEM + SOAR integration for rapid incident response.

---
