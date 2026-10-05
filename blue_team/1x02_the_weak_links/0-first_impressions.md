# First Impressions Summary – MedDefense Vulnerability Scan

_(OpenVAS 22.x, Full & Deep policy – authenticated where possible)_

## 1. Scan Metadata

| Item             | Details                                                                                                                                                                                          |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Scan Target**  | `10.10.0.0/16` (all internal subnets)                                                                                                                                                            |
| **Scan Date**    | Current – 5 days ago                                                                                                                                                                             |
| **Requested by** | James Chen, Deputy CISO                                                                                                                                                                          |
| **Executed by**  | SecurePoint Consulting (third‑party)                                                                                                                                                             |
| **Policy**       | Full and Deep – authenticated where credentials were supplied                                                                                                                                    |
| **Scope Notes**  | Cloud services (O365), mobile devices, and any asset offline during the scan window are _outside_ of scope. Medical devices were scanned unauthenticated; active exploitation was not performed. |

---

## 2. Finding Distribution

| Severity          | Count | % of total (31) |
| ----------------- | ----- | --------------- |
| **Critical**      | 4     | 13 %            |
| **High**          | 8*    | 26 %            |
| **Medium**        | 11    | 35 %            |
| **Low**           | 5     | 16 %            |
| **Informational** | 4     | 13 %            |

\*The manual finding (AJP Ghostcat) is counted as high, bringing the High total to eight.

**Most common severity:** _Medium_ (11 findings).

---

## 3. Asset Heat Map

| Rank | Host / IP    | Hostname              | # Findings | Primary Role (Asset Registry 1x00 T7)          |
| ---- | ------------ | --------------------- | ---------- | ---------------------------------------------- |
| 1    | `10.10.2.15` | **billing‑srv-01**    | **7**      | Billing Application Server (Web + DB services) |
| 2    | `10.10.2.50` | **web-srv-01**        | 4          | Patient Portal Web Server (HTTPS/HTTP)         |
| 3    | `10.10.2.20` | **ad-dc-01**          | 3          | Active Directory Domain Controller #1          |
| 4    | `10.10.3.40` | **bd-alaris-pump‑01** | 1*         | BD Alaris Infusion Pump (Device)               |
| 5    | `10.10.3.10` | **intellivue‑mon‑01** | 1*         | Philips IntelliVue Patient Monitor (Device)    |

\*The BD Alaris pumps and IntelliVue monitors each host has a single finding in the report, but are listed separately because they represent distinct device classes.

> **Note:** The remaining hosts with findings (e.g., `10.10.2.11` ehr‑db-01, `10.10.1.70` WS‑RAD‑01, etc.) each have 1–3 findings and fall outside the top five.

---

## 4. First Observations

| Observation                          | Details                                                                                                                                                                                                                                                               |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Critical findings are clustered**  | Two of four criticals (Apache buffer overflow & privilege escalation) are on _billing‑srv-01_; the other two affect the EHR database and a Windows XP MRI workstation. No single system carries all criticals, but billing‑srv‑01 is the most heavily impacted asset. |
| **Chainable exploits**               | Findings 001 (mod_lua RCE) + 002 (privilege escalation) on _billing‑srv-01_ create a remote→local code‑execution chain that could grant root without authentication.                                                                                                  |
| **Device exposure**                  | Multiple medical devices (BD Alaris pumps, Philips IntelliVue monitors, Netgear router at Westside Clinic) expose web interfaces or legacy protocols with no credentials or encryption, increasing risk of unauthorized access.                                       |
| **Unpatched OS & services**          | `billing‑srv-01` runs Ubuntu 18.04 LTS without ESM; Windows XP MRI workstation is end‑of‑life; Windows Server 2012 R2 at print‑srv‑01 lacks patches for PrintNightmare.                                                                                               |
| **Network isolation gaps**           | The flat internal network allows unrestricted traffic to many exposed services (e.g., PostgreSQL on `ehr-db-01`, MySQL on `billing-srv-01`, LDAP signing disabled). Devices such as the BD pumps and IntelliVue monitors are reachable from any host.                 |
| **Credential management weaknesses** | Default admin credentials on BD Alaris devices, open SSH password auth on `billing‑srv-01`, and inactive Sophos agents on many workstations reduce security posture.                                                                                                  |
| **Surprises**                        | An unknown Linux host (`10.10.2.99`) with a Jupyter notebook service was discovered—likely shadow IT or an unregistered asset.                                                                                                                                        |

---

## 5. Scan Limitations

- **Cloud & SaaS Services** – O365, Azure AD, etc., were not part of the scan.
- **Mobile / BYOD Devices** – iPads, smartphones, and other endpoints outside the internal IP range are unscanned.
- **Offline Assets** – Any host that was down during 02:00‑06:00 scan window is omitted.
- **Unauthenticated Device Scans** – Medical devices were scanned without credentials; some findings may be false positives or missed due to lack of authentication.
- **No Exploitation** – Findings are based on configuration and version detection only; no live exploitation was performed.
- **False‑Positive Rate** – OpenVAS has an estimated 5–10 % FP rate; manual verification is strongly recommended for high‑value findings (e.g., Ghostcat, privilege escalation).
