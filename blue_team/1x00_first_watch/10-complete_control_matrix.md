# Control Registry (updated)

| Control ID | Control Name                              | Category       | Function   | Asset(s) Protected                                                                        | Effectiveness | Evidence / Source |
| ---------- | ----------------------------------------- | -------------- | ---------- | ----------------------------------------------------------------------------------------- | ------------- | ----------------- |
| C‑001      | Network perimeter ‘Deny‑All’ rule         | Technical      | Preventive | All devices connected to the network (servers, workstations, endpoints)                   | Strong        | Artifact 1        |
| C‑002      | Disable SSH root login                    | Technical      | Preventive | Linux servers                                                                             | Strong        | Artifact 2        |
| C‑003      | Key‑only SSH authentication               | Technical      | Preventive | Linux servers                                                                             | Strong        | Artifact 2        |
| C‑004      | Endpoint antivirus coverage               | Technical      | Preventive | Workstation endpoints (≈387 devices)                                                      | Adequate      | Artifact 4        |
| C‑005      | Scheduled nightly full backup             | Technical      | Preventive | EHR application, database, billing system, domain controller, file shares, web portal VMs | Adequate      | Artifact 5        |
| C‑006      | Firewall traffic logging                  | Technical      | Detective  | Firewall event logs                                                                       | Strong        | Artifact 1        |
| C‑007      | Sophos malware detection & action         | Technical      | Detective  | Endpoint workloads                                                                        | Strong        | Artifact 4        |
| C‑008      | Web‑server log rotation                   | Technical      | Detective  | Web server audit trails (Apache logs)                                                     | Adequate      | Artifact 8        |
| C‑009      | Password complexity & length policy       | Administrative | Preventive | User accounts (Windows/Linux)                                                             | Adequate      | Artifact 3        |
| C‑010      | Password rotation policy                  | Administrative | Preventive | User accounts                                                                             | Weak          | Artifact 3        |
| C‑011      | Account lockout policy                    | Administrative | Preventive | User accounts                                                                             | Adequate      | Artifact 3        |
| C‑012      | Mandatory security awareness training     | Administrative | Preventive | Human factor (employees)                                                                  | Adequate      | Artifact 7        |
| C‑013      | Training completion monitoring            | Administrative | Detective  | Staff training compliance                                                                 | Adequate      | Artifact 7        |
| C‑014      | Backup recovery testing                   | Administrative | Corrective | Restorability of backed‑up data                                                           | Weak          | Artifact 5        |
| C‑015      | On‑site security guard                    | Physical       | Preventive | Main lobby & building perimeter                                                           | Adequate      | Artifact 6        |
| C‑016      | Visitor registration & badge verification | Physical       | Preventive | Unauthorized personnel                                                                    | Adequate      | Artifact 6        |
| C‑017      | Analog camera monitoring with DVR         | Physical       | Detective  | Building ingress points                                                                   | Strong        | Artifact 6        |

# Updated Control Summary Matrix

Below is the **Category × Function** matrix built from all controls recorded in

- **[4‑control_inventory.md]**
- **[3‑physical_assessment.md]** – (no new controls, but provides context for gaps)
- **[7‑asset_registry.md]**

The values shown are:

| Category       | Preventive (count / avg effectiveness) | Detective (count / avg effectiveness) | Corrective (count / avg effectiveness) | Compensating | Deterrent |
| -------------- | -------------------------------------- | ------------------------------------- | -------------------------------------- | ------------ | --------- |
| Technical      | 5 / 2.6 (**Strong**)                   | 3 / 2.7 (**Strong**)                  | 0 / N/A                                | 0 / N/A      | 0 / N/A   |
| Administrative | 4 / 1.8 (**Adequate**)                 | 1 / 2.0 (**Adequate**)                | 1 / 1.0 (**Weak**)                     | 0 / N/A      | 0 / N/A   |
| Physical       | 2 / 2.0 (**Adequate**)                 | 1 / 3.0 (**Strong**)                  | 0 / N/A                                | 0 / N/A      | 0 / N/A   |

### How the averages were computed

| Rating   | Numeric value |
| -------- | ------------- |
| Weak     | 1             |
| Adequate | 2             |
| Strong   | 3             |

For each cell, the numeric average was rounded to one decimal place.  
If the average lies:

- >  2.5 → **Strong**
- 1.5–2.5 → **Adequate**
- ≤ 1.5 → **Weak**

Cells with no controls are marked `0 / N/A`.

# Control Coverage Map

**Top 5 Critical Assets – Control Mapping & Gaps**

| Asset ID                                                          | Controls that Protect It _(Control ID – Name)_                                                                                                                                                                                                                                                        | Missing Control **Categories / Functions**                                                                                                                                                                                                    | Coverage Assessment                                                                                                                                              |
| ----------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ASSET014 – EHR‑SRV‑01 (EHR Server)                                | <ul><li>C‑001 “Network perimeter ‘Deny‑All’ rule” (Preventive)</li><li>C‑002 “Disable SSH root login” (Preventive)</li><li>C‑003 “Key‑only SSH authentication” (Preventive)</li><li>C‑005 “Scheduled nightly full backup” (Preventive)</li><li>C‑006 “Firewall traffic logging” (Detective)</li></ul> | **Corrective** – no asset‑specific restore test<br>**Compensating** – none<br>**Deterrent** – none                                                                                                                                            | _Partially Protected_ – strong preventive & detective coverage, but lacks a corrective control that verifies the integrity/availability of this critical server. |
| ASSET015 – EHR‑DB‑01 (PostgreSQL Database)                        | <ul><li>C‑001 “Network perimeter ‘Deny‑All’ rule” (Preventive)</li><li>C‑005 “Scheduled nightly full backup” (Preventive)</li><li>C‑006 “Firewall traffic logging” (Detective)</li></ul>                                                                                                              | **Corrective** – no database‑specific restore test<br>**Compensating** – none<br>**Deterrent** – none                                                                                                                                         | _Partially Protected_ – similar to the EHR server; backup exists but there is no evidence of periodic restoration or testing.                                    |
| ASSET016 – PACS‑SRV‑01 (Picture Archiving & Communication System) | <ul><li>C‑001 “Network perimeter ‘Deny‑All’ rule” (Preventive)</li><li>C‑006 “Firewall traffic logging” (Detective)</li></ul>                                                                                                                                                                         | **Preventive** – no PACS‑specific firewall/IDS rules<br>**Detective** – no application or server‑level logs<br>**Corrective** – no backup/recovery test for imaging data<br>**Compensating** – none<br>**Deterrent** – none                   | _Under‑Protected_ – only generic network controls; the asset lacks dedicated preventive, detective and corrective measures.                                      |
| ASSET018 – AD‑DC‑01 (Active Directory Domain Controller)          | <ul><li>C‑001 “Network perimeter ‘Deny‑All’ rule” (Preventive)</li><li>C‑006 “Firewall traffic logging” (Detective)</li></ul>                                                                                                                                                                         | **Corrective** – no domain‑controller backup/recovery test<br>**Compensating** – none<br>**Deterrent** – none                                                                                                                                 | _Under‑Protected_ – while the DC benefits from perimeter protection, it is missing internal corrective testing and compensatory controls.                        |
| ASSET024 – MON‑ICU‑01 (Philips IntelliVue ICU Monitor)            | _No direct technical or administrative control identified in the inventory._<br>Physical guard at the main entrance covers building access but not device‑level security.                                                                                                                             | **Preventive** – no device firewall/firmware hardening<br>**Detective** – no logging or monitoring of the monitor’s web UI<br>**Corrective** – no restore/test for device firmware or data<br>**Compensating** – none<br>**Deterrent** – none | _Unprotected_ – the ICU monitor has no documented technical, administrative, or physical controls that secure its integrity, availability, or detect tampering.  |

### Key Take‑aways

1. **Preventive coverage is strongest for network perimeter and server access (C‑001, C‑002, C‑003).**
2. **Detective controls are limited to firewall traffic logs; no application‑level monitoring exists for critical servers or IoT devices.**
3. **Corrective testing is only present at the general backup level (C‑014) and does not target the individual critical assets.**
4. **Physical and compensatory controls remain largely generic and do not directly protect the top‑5 assets.**

> **Recommendation:** Prioritize adding asset‑specific preventive, detective, and corrective measures for PACS‑SRV‑01, AD‑DC‑01, and MON‑ICU‑01. This will move them from “Under‑Protected” or “Unprotected” toward a _Well‑Protected_ posture.
