# MedDefense Health Systems – Security Strategy Document

## 1. Executive Summary

| Item                           | Details                                                                                                                                                                                                                                                                        |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Current risk posture**       | A flat, unsegmented network coupled with a FortiGate running vulnerable firmware exposes all critical assets to a known ransomware campaign (Crimson Tide). The top five ALEs total **$24.3 M/yr**, largely driven by EHR encryption, credential theft and backup destruction. |
| **Strategic approach**         | Adopt the NIST Cybersecurity Framework (CSF) as the foundation, layer CIS Controls 1–15 for operational mapping, and use a cost‑benefit model to prioritize investments that deliver > 80 % ALE reduction within an annual budget of $120 k.                                   |
| **Investment requested**       | **$120 k** – covers quick wins (EDR, segmentation, FortiGate patch, MFA) and core controls (SIEM). Remaining $21 k will be allocated to the 2nd‑year plan (medical‑device isolation, off‑site backup).                                                                         |
| **Top three priority actions** | 1. Deploy Sophos Intercept X on all endpoints.<br>2. Implement VLAN‑based network segmentation.<br>3. Upgrade FortiGate firmware to v7.4.x and enable MFA on VPN.                                                                                                              |

---

## 2. Governance Framework

### 2.1 Framework Selection Rationale (T0)

| Criteria                   | Reason                                                                        |
| -------------------------- | ----------------------------------------------------------------------------- |
| **Comprehensiveness**      | NIST CSF covers all core functions (Identify‑Protect‑Detect‑Respond‑Recover). |
| **Vendor‑neutral mapping** | CIS Controls map cleanly to NIST CSF, enabling audit alignment.               |
| **Maturity model**         | Enables current vs target profiling and transparent progress reporting.       |

### 2.2 NIST CSF Current vs Target Profile (T1)

| Function/Category      | Current Score (0–4) | Target Score | Gap |
| ---------------------- | ------------------- | ------------ | --- |
| Identify (ID.RA)       | 3                   | 4            | +1  |
| Protect (PR.AC, PR.PT) | 2                   | 4            | +2  |
| Detect (DE.CM)         | 1                   | 3            | +2  |
| Respond (RS.RP)        | 1                   | 3            | +2  |
| Recover (RC.RP)        | 2                   | 3            | +1  |

_Overall CSF score increases from **19/20** to **27/32** once the four core controls are in place._

### 2.3 CIS Controls Maturity Scorecard (T2)

| Control Group            | Current Level (0–5) | Target Level | Notes                            |
| ------------------------ | ------------------- | ------------ | -------------------------------- |
| Asset Management         | 3                   | 4            | Add dynamic asset discovery      |
| Vulnerability Management | 2                   | 4            | Automate patching & scanning     |
| Configuration Management | 3                   | 4            | Implement IaC templates          |
| Identity & Access        | 2                   | 5            | MFA, least‑privilege enforcement |
| Security Operations      | 1                   | 4            | SIEM + SOC services              |

### 2.4 Governance Structure and Roles (T4)

| Role                       | Responsibility                                     | Reporting Line |
| -------------------------- | -------------------------------------------------- | -------------- |
| CISO (Vacant) – James Chen | Strategic oversight, risk acceptance               | CEO            |
| Deputy CISO (James)        | Program delivery, controls implementation          | CISO / CEO     |
| IT Director (Sarah)        | Infrastructure & operations                        | Deputy CISO    |
| Security Analyst (You)     | Asset inventory, risk register updates, monitoring | Deputy CISO    |
| SOC Manager (External)     | 24/7 monitoring, incident response                 | Deputy CISO    |
| Finance Lead               | Budget approval, ROI tracking                      | CFO            |

---

## 3. Quantitative Risk Analysis

### 3.1 Top 5 Risks by ALE (T6)

| Rank | Risk ID                              | ALE /yr     | Control(s) Addressing              | Post‑Control ALE |
| ---- | ------------------------------------ | ----------- | ---------------------------------- | ---------------- |
| 1    | RISK‑001 – EHR ransomware            | $10,000,000 | EDR, Segmentation, FortiGate patch | $2,500,000       |
| 2    | RISK‑005 – Phishing credential theft | $6,240,000  | MFA, Security training             | $800,000         |
| 3    | RISK‑002 – VPN exploit               | $4,130,000  | FortiGate patch + MFA              | $650,000         |
| 4    | RISK‑004 – Kerberos RC4              | $2,437,500  | Kerberos policy update             | $200,000         |
| 5    | RISK‑007 – Endpoint malware          | $1,500,000  | EDR                                | $300,000         |

**Total ALE before controls:** **$24.3 M/yr**  
**Estimated ALE after core controls:** **$4.0 M/yr** (≈ 83 % reduction)

### 3.2 Risk Register Summary (T10)

(See full register in previous deliverable – top 10 risks shown; each entry includes owner, current ALE, treatment decision, and KRI.)

### 3.3 Risk Appetite Statement (T16)

_MedDefense will accept only residual risks that result in an annual loss ≤ $4 M, are easily detectable, and can be mitigated within the next two years._

---

## 4. Control Strategy

### 4.1 Cost‑Benefit Analysis Results (T7)

| Control                  | Annual Cost | ALE Reduction | Net Benefit |
| ------------------------ | ----------- | ------------- | ----------- |
| Sophos Intercept X       | $25,000     | $8,000,000    | $7,975,000  |
| VLAN Segmentation        | $10,000     | $4,130,000    | $4,120,000  |
| FortiGate Firmware + MFA | $28,000     | $4,480,000    | $4,452,000  |
| SIEM (Wazuh)             | $18,000     | $1,400,000    | $1,382,000  |
| **Subtotal**             | **$81,000** | –             | –           |

All controls yield a positive net benefit. The sum of ALE reductions (~$19 M) far exceeds the investment.

### 4.2 Budget Allocation with Justification (T8)

| Category                                                      | Allocated Cost | Rationale                                                   |
| ------------------------------------------------------------- | -------------- | ----------------------------------------------------------- |
| Core Controls (EDR, Segmentation, FortiGate patch, MFA, SIEM) | **$81 k**      | Covers the four controls that deliver > 80 % ALE reduction. |
| Year‑2 Controls (MD isolation, off‑site backup)               | **$21 k**      | Planned after initial ROI realization and budget renewal.   |
| Governance & Training                                         | **$5 k**       | Policy updates, staff training sessions.                    |

**Total Requested:** **$120 k**

### 4.3 Control Selection with Framework Mapping (T11)

(See Part 2 of the Network‑Segmentation Plan for mapping details; each selected control is linked to CIS and NIST CSF IDs.)

### 4.4 Quick Wins for Immediate Implementation (T13)

1. **Deploy Sophos Intercept X** – installs within 24 hrs on all endpoints.
2. **Upgrade FortiGate firmware** – one‑time upgrade with zero downtime if scheduled during low traffic window.
3. **Enable MFA on VPN** – leverages existing O365 E3 licenses; no extra cost.

These three actions can be rolled out in the first 48 hrs of Phase 1.

---

## 5. Architecture Recommendations

### 5.1 Network Segmentation Design (T14)

- Five VLAN zones: Server‑Zone, Clinical‑Workstation‑Zone, Medical‑Device‑Zone, Management‑Zone, Guest/IoT‑Zone.
- ACLs enforced on the FortiGate provide **strict ingress/egress** and micro‑segmentation.
- All critical servers sit behind a DMZ with least‑privilege RDP/SSH access.

### 5.2 Kill‑Chain Disruption Analysis

| Kill‑Chain Step      | Where Segmentation Intercepts                                     | Estimated Chain Disruption                               |
| -------------------- | ----------------------------------------------------------------- | -------------------------------------------------------- |
| Initial Access (CVE) | None – attacker still exploits FortiGate.                         | 0 %                                                      |
| Internal Recon       | Visibility only; no prevention.                                   | 0 %                                                      |
| Lateral Movement     | Blocks traffic between Server‑Zone → Clinical/Medical zones.      | **70 %** of similar ransomware attacks halted.           |
| Data Exfiltration    | Only HTTPS/Secure SMTP allowed; large SMB transfers blocked.      | Partial – reduces exfil speed and raises detection risk. |
| Backup Destruction   | No path from compromised zone to NAS; backup integrity preserved. | 100 % protection for this step.                          |

Overall, **≈ 70 %** of the top five ransomware kill chains would be stopped by the new architecture.

---

## 6. Policy Foundation

### 6.1 Acceptable Use Policy (AUP) Summary (T12)

- All users must use MFA for any remote or privileged access.
- Encryption is mandatory for all PHI at rest and in transit.
- USB & removable media are restricted to business‑justified cases only.

### 6.2 Policy Roadmap

| Month | Policy                                                           | Owner | Deadline    |
| ----- | ---------------------------------------------------------------- | ----- | ----------- |
| 1–2   | Updated AUP (MFA, encryption)                                    | Sarah | End Month 2 |
| 3     | Password & Account Management policy (enforce rotation, lockout) | James | End Month 3 |
| 4     | Incident Response Policy (roles, communication plan)             | James | End Month 4 |
| 5     | Data Classification & Handling policy                            | James | End Month 5 |
| 6     | Vendor Security & Contract Management policy                     | Sarah | End Month 6 |

---

## 7. Residual Risk Assessment

### 7.1 Red‑Team Findings (T15)

- **Device firmware** on several monitors still at EOL; risk mitigated by future patch plan in Year 2.
- **Patch compliance drift** on a handful of legacy workstations; will be resolved during the next update cycle.

### 7.2 Accepted Risks with Justification (T16)

| Risk                                   | Acceptance Reason                                                                                                           |
| -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Legacy medical device firmware < 5 yrs | Cost to replace exceeds ROI for now; planned for Year 2 budget.                                                             |
| Limited off‑site backup initially      | Backup encryption and offline snapshot will be introduced in Phase 3; interim risk acceptable due to segmentation barriers. |

### 7.3 Year‑2 Priorities

1. Deploy medical‑device isolation + mutual‑auth TLS.
2. Implement immutable, off‑site cloud backups.
3. Expand SOC to 24/7 outsourced managed service.

---

## 8. Implementation Roadmap

| Phase                                   | Months | Milestones                                                                                                               | Dependencies                           | Success Metrics                                                                                      |
| --------------------------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------ | -------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| **Phase 1 – Quick Wins**                | 1‑2    | • Deploy Sophos Intercept X on all endpoints.<br>• Upgrade FortiGate firmware & enable MFA.<br>• Publish updated AUP.    | None                                   | 100 % of endpoints protected; zero unpatched FortiGate devices.                                      |
| **Phase 2 – Core Controls**             | 3‑4    | • Implement VLAN segmentation and ACLs.<br>• Deploy SIEM (Wazuh).<br>• Conduct phishing simulation campaign.             | Phase 1 completed, network gear ready. | < 5 % of unauthorized cross‑zone traffic; SIEM alert volume > 100/day with 90 % triage time < 2 hrs. |
| **Phase 3 – Validation & Optimization** | 5‑6    | • Red‑team assessment of segmentation.<br>• Tune firewall rules and log correlation.<br>• Finalize policy documentation. | Phases 1‑2 finished; policy approvals. | Zero critical incidents in simulated penetration test; all policies signed by stakeholders.          |

---

## 9. Next Steps

1. **Finalize the $120 k budget** – CFO sign‑off.
2. **Kick‑off Phase 1** – assign tasks to Sarah and the security analyst, schedule procurement for FortiGate firmware & Sophos licenses.
3. **Link to Project 1x04 (Cryptographic Foundation)** – integrate TLS hardening, endpoint key management, and backup encryption plans into the 2nd‑year budget.
4. **Continuous Monitoring** – set up KPI dashboards in SIEM; automate risk register updates with quarterly reviews.

_The strategy above moves MedDefense from a reactive posture to a proactive, evidence‑based security program that aligns with regulatory expectations, protects patient data, and delivers measurable ROI._
