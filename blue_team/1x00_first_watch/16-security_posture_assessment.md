# MedDefense Health Systems – Security Posture Assessment

_Prepared for the Board of Directors – 13 Sept 2026_

---

## 1. Executive Summary

MedDefense’s current security posture is **moderately resilient but has critical gaps that could jeopardise patient safety, regulatory compliance and revenue streams**.

- **Overall verdict:** The organisation satisfies baseline technical controls (firewall perimeter, password policy, backups) but lacks _corrective_ testing for several core assets and fails to secure critical medical devices.
- **Single most critical finding:** Absence of a **domain‑controller disaster‑recovery plan** (GAP‑006). A compromised or lost AD DC would bring the entire network to a halt and expose all PHI.
- **Top three recommended actions:**
  1. Deploy a _secondary_ Active Directory domain controller with fail‑over testing.
  2. Implement asset‑specific corrective restoration tests for EHR/DB, PACS, and backup infrastructure.
  3. Harden ICU monitoring devices with secure boot, firmware updates and host‑based firewalls.

**Budget implication:** The five highest‑priority fixes cost ≈ $93 k per annum – comfortably below the allocated $120 k budget.

---

## 2. Scope & Methodology

| What was assessed | Where                                                                             |
| ----------------- | --------------------------------------------------------------------------------- |
| **Sites**         | Central Hospital (core network) and Westside Clinic (VPN gateway).                |
| **Systems**       | EHR server / database, PACS, billing, AD‑DC, backup servers, ICU medical devices. |
| **Data**          | PHI (patient records, imaging), billing information, credentials, audit logs.     |

### Sources of Information

- **Documentation:**
  - `0-environment_summary.md` – infrastructure overview.
  - `1-incident_classification.md` – real incidents illustrating gaps.
  - `3-physical_assessment.md` – physical vulnerabilities.
  - `4-control_inventory.md` & `10-complete_control_matrix.md` – current controls.
  - `7-asset_registry.md` – asset list (32 assets).
  - `8-criticality_assessment.md` – criticality matrix for each asset.
  - `12-gap_analysis.md` – gap inventory (10 gaps, 5 critical).
- **Evidence:** Each recommendation is tied to a specific Gap ID and Control ID where applicable.

### Limitations & Assumptions

- The assessment covers only the assets documented; any undiscovered “shadow‑IT” devices are outside scope.
- Controls identified in the inventory are assumed to be correctly configured unless otherwise noted (e.g., backup recovery testing flagged as _weak_).
- Budget calculations assume current vendor pricing and that no additional licensing costs arise during implementation.

---

## 3. Asset Landscape

### Total Inventory

| Category                    | Count  |
| --------------------------- | ------ |
| Servers                     | 10     |
| Workstations / Thin Clients | 16     |
| Network Devices             | 5      |
| IoT Medical Devices         | 4      |
| Backup & Storage            | 2      |
| **Total**                   | **32** |

### Top‑5 Critical Assets

| Asset ID | Name        | Why It’s Critical (brief)                                                  |
| -------- | ----------- | -------------------------------------------------------------------------- |
| ASSET014 | EHR‑SRV‑01  | Primary clinical application; stores all PHI and billing data.             |
| ASSET015 | EHR‑DB‑01   | Back‑end database for the EHR; loss of integrity cascades across services. |
| ASSET016 | PACS‑SRV‑01 | Holds diagnostic imaging; errors can alter patient care decisions.         |
| ASSET018 | AD‑DC‑01    | Single authentication hub for all network assets.                          |
| ASSET024 | MON‑ICU‑01  | Real‑time ICU monitor; data feeds into EHR and influences treatment.       |

### Data Classification Summary

- **PHI** – All patient records, imaging, lab results.
- **Billing Information** – Credit card details, insurance claims.
- **Credentials & Group Policy Data** – AD domain controls.  
  All classified as _Confidential_ or _Critical_ per HIPAA and internal policy.

---

## 4. Current Security Controls

| Category       | Function   | Count / Avg Effectiveness                          |
| -------------- | ---------- | -------------------------------------------------- |
| Technical      | Preventive | **5 / Strong** (C‑001, C‑002, C‑003, C‑004, C‑005) |
| Technical      | Detective  | **3 / Strong** (C‑006, C‑007, C‑008)               |
| Administrative | Preventive | **4 / Adequate** (C‑009, C‑010, C‑011, C‑012)      |
| Administrative | Detective  | **1 / Adequate** (C‑013)                           |
| Administrative | Corrective | **1 / Weak** (C‑014 – backup recovery testing)     |
| Physical       | Preventive | **2 / Adequate** (C‑015, C‑016)                    |
| Physical       | Detective  | **1 / Strong** (C‑017)                             |

### Strengths

- Strong perimeter firewall and SSH hardening protect most servers.
- Comprehensive antivirus coverage on endpoints.

### Weaknesses

- _Corrective_ testing is limited to a weak backup recovery test; no asset‑specific restore validation.
- Critical assets lack **application‑level logs** or **device‑firmware hardening** (e.g., ICU monitors).
- No _privileged access monitoring_ for core servers.

---

## 5. Gap Analysis

| Risk Level | # Gaps                              |
| ---------- | ----------------------------------- |
| Critical   | 5 (GAP‑001, ‑002, ‑006, ‑007, ‑009) |
| High       | 4 (GAP‑003, ‑004, ‑005, ‑008, ‑010) |

### Detailed Gap View

| Gap ID  | Asset(s)               | Impact                                         | Recommended Treatment                                                 |
| ------- | ---------------------- | ---------------------------------------------- | --------------------------------------------------------------------- |
| GAP‑001 | EHR‑SRV‑01             | Data loss → regulatory fines, patient harm     | **Mitigate** – implement corrective restoration test (see section 6). |
| GAP‑002 | EHR‑DB‑01              | Database corruption → downstream failures      | **Mitigate** – database restore testing.                              |
| GAP‑003 | PACS‑SRV‑01            | Imaging tampering → misdiagnosis               | **Mitigate** – create asset‑specific IDS/IPS rules.                   |
| GAP‑004 | PACS‑SRV‑01            | No application logs → undetected changes       | **Mitigate** – enable server‑level audit logging.                     |
| GAP‑005 | PACS‑SRV‑01            | No backup recovery test → loss of imaging data | **Mitigate** – restore validation for PACS archives.                  |
| GAP‑006 | AD‑DC‑01               | DC loss → network collapse                     | **Mitigate** – deploy secondary DC and fail‑over testing.             |
| GAP‑007 | MON‑ICU‑01             | Device firmware exposure → patient harm        | **Mitigate** – secure boot, firmware hardening, host firewall.        |
| GAP‑008 | MON‑ICU‑01             | No UI monitoring → undetected compromise       | **Mitigate** – enable application logs and intrusion detection.       |
| GAP‑009 | BACKUP‑SRV / NAS‑01    | Backup recovery weak → data loss               | **Mitigate** – full restore tests for backup infrastructure.          |
| GAP‑010 | EHR‑SRV‑01 / EHR‑DB‑01 | No privileged access monitoring                | **Mitigate** – implement privileged session recording.                |

### Gap Distribution

- _Critical_ gaps predominantly involve **corrective controls** (backup, restoration) and **device hardening**.
- _High_ gaps center on **preventive segmentation** (PACS firewall rules) and **detective logging** for imaging and ICU devices.

---

## 6. Risk Treatment Recommendations

| Gap     | Treatment Strategy                                           | Cost Estimate                       | Timeline             |
| ------- | ------------------------------------------------------------ | ----------------------------------- | -------------------- |
| GAP‑001 | Mitigate – automated corrective restore test for EHR server  | $10–50 k (shared tooling)           | Short‑term < 1 month |
| GAP‑002 | Mitigate – database restore validation                       | $10–50 k (shared tooling)           | Short‑term < 1 month |
| GAP‑006 | Mitigate – secondary AD‑DC + fail‑over testing               | $10–50 k ($25 k hardware+licensing) | Long‑term > 1 month  |
| GAP‑007 | Mitigate – firmware hardening & host firewall on ICU monitor | $1–10 k (vendor licensing)          | Short‑term < 1 month |
| GAP‑009 | Mitigate – full restore tests for backup infrastructure      | $5–20 k                             | Short‑term < 1 month |
| GAP‑003 | Mitigate – PACS‑specific IDS/IPS & segmentation              | $5–20 k                             | Short‑term < 1 month |
| GAP‑004 | Mitigate – enable application logs on PACS                   | $1–10 k                             | Quick win < 1 week   |

### Budget Allocation (per year)

| Item                  | Cost      |
| --------------------- | --------- |
| Gaps 001/002 (shared) | $20 k     |
| Gap 006               | $25 k     |
| Gap 007               | $8 k      |
| Gap 009               | $12 k     |
| Gap 003               | $18 k     |
| Gap 004               | $10 k     |
| **Total**             | **$93 k** |

_Remaining Budget:_ $27 k – can be reserved for contingency, SIEM tuning or additional training.

#### Quick Wins

- Implement application logs on PACS (GAP‑004) – deploy in < 1 week, <$10 k.
- Harden ICU monitor firmware (GAP‑007) – deploy within a month, ~$8 k.

#### Short‑Term Priorities (< 1 month)

- Restore testing for EHR server & database (GAP‑001/002).
- PACS IDS/IPS rule creation (GAP‑003).
- Full restore tests on backup servers (GAP‑009).

#### Long‑Term Roadmap (> 1 month)

- Deploy secondary AD domain controller with fail‑over (GAP‑006).
- Continuous monitoring of privileged sessions (GAP‑010) – to be addressed in the next fiscal cycle.

---

## 7. Conclusion & Next Steps

### Summary

MedDefense’s current posture meets basic technical thresholds but is **incomplete where it matters most**: critical data recovery, device hardening, and privilege visibility. The five highlighted gaps represent _mission‑critical_ risks that could directly harm patients or trigger regulatory sanctions.

### Consequence of Inaction

If the recommended controls are not implemented:

- A single compromised domain controller would disable authentication for all staff.
- Unvalidated backups could lead to irreversible data loss in a disaster scenario, violating HIPAA and exposing the hospital to $5 M+ penalties.
- Unsecured ICU monitors present an immediate patient‑safety hazard.

### Transition to Next Phase

The next logical step is a **Threat Landscape Assessment** (see Marcus’s unfinished work). By mapping external threat actors and attack vectors against the assets identified here, we can refine our defense-in-depth strategy and allocate resources for proactive hunting and red‑team exercises.

---
