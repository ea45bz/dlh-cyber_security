**MedDefense – Vulnerability Remediation Timeline (Executive Summary)**  
_(Prepared for the IT Director – Monday morning)_

| Horizon                   | Time Frame  | Findings & One‑Line Description                                                                                         | Primary Remediation Action                                                                                       | Owner                                | Estimated Cost |
| ------------------------- | ----------- | ----------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- | ------------------------------------ | -------------- |
| **Immediate** (24–48 h)   | 0–2 days    | **001** – Apache mod_lua RCE (CVE‑2021‑44790). Remote code execution on billing‑srv‑01.                                 | Apply Apache 2.4.52+ patch & restart web server in the nightly window.                                           | IT – Infrastructure & Security       | <$1k           |
|                           |             | **002** – Local privilege escalation (CVE‑2019‑0211) on billing‑srv‑01.                                                 | Upgrade to Apache 2.4.39+; verify mod_lua compatibility.                                                         | IT – Application Support             | <$1k           |
|                           |             | **003** – PostgreSQL unrestricted network access.                                                                       | Modify pg_hba.conf and firewall rule to allow only the billing server IP.                                        | IT – Database & Security             | <$1k           |
|                           |             | **008** – PrintNightmare (CVE‑2023‑38408) on print‑srv‑01.                                                              | Install KB5006955 + KB4474414 on Windows 2012 R2; restart spooler.                                               | IT – Print Services & Security       | <$1k           |
|                           |             | **014** – Consumer Netgear router is VPN terminator.                                                                    | Replace with a business‑grade firewall or flash latest firmware and lock down all ports except VPN.              | IT – Network & Security              | $5–$10 k       |
|                           |             | **017/031** – AJP Ghostcat (CVE‑2020‑1938) on ehr‑srv‑01.                                                               | Disable AJP listener or bind it to loopback; upgrade Tomcat to ≥9.0.39.                                          | IT – Security & Application Ops      | <$1k           |
|                           |             | **018** – Weak Kerberos/LDAP signing (AD DC).                                                                           | Enable LDAP signing via GPO and disable SMBv1; validate logon flow.                                              | IT – Domain Admins                   | <$1k           |
|                           |             | **010** – BD Alaris infusion pump DoS (CVE‑2020‑25165).                                                                 | Upgrade firmware to ≥12.2.3 on all pumps; apply ACL on port 5020.                                                | Clinical IT – Pharmacy & Device Mgmt | $5–$10 k       |
|                           |             | **028** – Shadow Linux host with default creds (10.10.2.99).                                                            | Isolate from network or decommission; remove default credentials.                                                | IT – Security & Network              | <$2k           |
|                           |             | **029** – Grafana path traversal (CVE‑2021‑43798) on Westside.                                                          | Upgrade to latest Grafana (≥8.3); patch OS.                                                                      | IT – Infrastructure                  | <$1k           |
| **Short‑Term** (7 days)   | 2–9 days    | **005** – TLS 1.0/1.1 enabled on web‑srv‑01.                                                                            | Reconfigure Apache to enforce TLS 1.2+ and disable older protocols; install HSTS header.                         | IT – Web Ops                         | <$500          |
|                           |             | **012** – Missing HTTP security headers on patient portal.                                                              | Add X‑Content‑Type‑Options, X‑Frame‑Options, CSP, HSTS, X‑XSS‑Protection in Apache config.                       | IT – Security & Web Ops              | <$1k           |
|                           |             | **013** – Let’s Encrypt cert expiring (23 days).                                                                        | Renew certificate via auto‑renew script; update server chain.                                                    | IT – Ops                             | <$200          |
|                           |             | **019** – RDP enabled on multiple workstations.                                                                         | Enforce Network‑Level Authentication & enable MFA via AD policy.                                                 | IT – Domain Admins                   | $2–$3k         |
|                           |             | **021** – HTTP TRACE method enabled.                                                                                    | Disable TRACE verb in Apache config; restart service.                                                            | IT – Security                        | <$1k           |
|                           |             | **025** – DNS zone transfer enabled on DC.                                                                              | Remove AXFR permission for all zones except localhost.                                                           | IT – Domain Admins                   | <$500          |
| **Medium‑Term** (30 days) | 10–40 days  | **006** – MySQL bound to all interfaces.                                                                                | Set bind-address=127.0.0.1; update firewall rules accordingly.                                                   | IT – Database & Security             | <$1k           |
|                           |             | **009** – SSH password authentication on billing‑srv‑01.                                                                | Migrate to key‑only auth, disable PasswordAuth in sshd_config, and enforce account lockout.                      | IT – Infrastructure                  | $2–$3k         |
|                           |             | **015** – Synology DSM web interface open to all.                                                                       | Restrict DSM access to specific IPs via firewall; disable unused services.                                       | IT – Network & Security              | $1–$2k         |
|                           |             | **016** – Philips IntelliVue HL7/Web UI exposed.                                                                        | Move devices onto a dedicated VLAN, apply ACL on port 80/443 and 2575/tcp; enable authentication if possible.    | Clinical IT – Device Mgmt            | $3–$4k         |
|                           |             | **023** – USB mass‑storage unrestricted on workstations.                                                                | Deploy GPO to block removable storage unless explicitly allowed.                                                 | IT – Endpoint Security               | $2–$3k         |
|                           |             | **024** – Unencrypted DICOM traffic (pacs‑srv‑01).                                                                      | Enforce TLS/SSL at the application layer or use VPN for PACS traffic; reconfigure NICs accordingly.              | IT – Network & Security              | $4–$5k         |
|                           |             | **026** – Kernel 4.15 outdated on billing‑srv‑01.                                                                       | Upgrade to Ubuntu 20.04 LTS with ESM enabled (or enable ESM on current).                                         | IT – Infrastructure                  | $3–$4k         |
| **Long‑Term** (90 days)   | 40–120 days | **004** – Windows XP MRI workstation (EternalBlue, BlueKeep, MS08‑067).                                                 | Replace with a supported Windows 10/11 imaging system; migrate imaging software and data.                        | Clinical IT – Radiology              | $30–$50k       |
|                           |             | **28‑31** – Any remaining legacy or shadow devices (e.g., unknown Linux host, other medical devices not covered above). | Perform inventory audit, decommission or replace all non‑supported hardware; move to enterprise‑grade equipment. | IT – Asset Management                | $10–$20k       |

---

### Budget Summary

| Horizon     | Approx. Cost         |
| ----------- | -------------------- |
| Immediate   | ~$15 k               |
| Short‑Term  | ~$7 k                |
| Medium‑Term | ~$23 k               |
| Long‑Term   | ~$30 k               |
| **Total**   | **≈ $75 k per year** |

The **annual security budget** for MedDefense, as stated in _16‑security_posture_assessment.md_, is **$120 k**.

| Category                   | Allocation | Remaining Budget |
| -------------------------- | ---------- | ---------------- |
| Remediation (all horizons) | $75 k      | $45 k            |

#### What Must Be Deferred and Why

1. **Full EOL Device Replacement Beyond MRI Workstation** – While the MRI replacement is critical, other legacy devices (e.g., certain older imaging workstations or printers that are not mission‑critical) would also require upgrade or decommissioning. Those items fall outside the top‑priority list and will be addressed in subsequent fiscal periods because of limited hardware budget and clinical workflow constraints.

2. **Extended Network Segmentation / Zero‑Trust Architecture** – Implementing a comprehensive VLAN/ACL redesign across the entire campus, along with advanced micro‑segmentation for all medical devices, would exceed the $120 k cap for this year. It will be scheduled as part of the next strategic security roadmap (FY 2027).

3. **Continuous Security Monitoring & SIEM Expansion** – While basic logging is already in place, a full‑scale SIEM with advanced correlation rules is currently outside budgetary limits. These capabilities will be revisited once core vulnerabilities are mitigated and remaining funds are available.
