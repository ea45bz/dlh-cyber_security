**Triage of MedDefense Scan Findings**

| Finding | CVSS / Severity                                            | Host                                       | Category | Reason                                                                                |
| ------- | ---------------------------------------------------------- | ------------------------------------------ | -------- | ------------------------------------------------------------------------------------- |
| 001     | 9.8 (Critical)                                             | `10.10.2.15 (billing‑srv‑01)`              | **AC**   | Remote RCE with no auth on production billing system – must be fixed now.             |
| 002     | 7.8 (High, but flagged Critical in report)                 | `10.10.2.15 (billing‑srv‑01)`              | **AC**   | Local privilege escalation after exploit of Finding 001; critical impact.             |
| 003     | N/A (misconfiguration, score _Critical_ by policy)         | `10.10.2.11 (ehr‑db‑01)`                   | **AC**   | Unrestricted access to PHI database from any internal host – immediate action.        |
| 004     | 9.8 (Critical)                                             | `10.10.1.70 (WS‑RAD‑01)`                   | **AC**   | Windows XP with multiple exploitable RCEs; device critical for patient imaging.       |
| 005     | 7.5 (High)                                                 | `10.10.2.50 (web‑srv‑01 – Patient Portal)` | **AS**   | TLS 1.0/1.1 enabled on internet‑facing portal – patch in the next remediation window. |
| 006     | N/A (misconfiguration, score _High_)                       | `10.10.2.15 (billing‑srv‑01)`              | **AS**   | MySQL bound to all interfaces; schedule port restriction/policy update.               |
| 007     | N/A (misconfig, score _High_)                              | `10.10.2.20 (ad‑dc‑01)`                    | **AC**   | LDAP signing not required + SMBv1 on DC – high risk lateral movement.                 |
| 008     | 8.8 / 9.8 (PrintNightmare)                                 | `10.10.2.31 (print‑srv‑01)`                | **AC**   | Print spooler RCE on end‑of‑life Windows Server; must be patched now.                 |
| 009     | N/A (misconfig, score _High_)                              | `10.10.2.15 (billing‑srv‑01)`              | **AS**   | Password‑based SSH still allowed – plan key‑only migration.                           |
| 010     | 7.5 / CVE‑2020-25165 (DoS)                                 | `10.10.2.* (BD Alaris pumps)`              | **AC**   | Medical device DoS can stop lifesaving drug delivery; urgent patching required.       |
| 011     | N/A (ESM not enabled, score _Medium_)                      | `10.10.2.15 (billing‑srv‑01)`              | **AS**   | Ubuntu 18.04 lacking ESM – plan to enable or upgrade.                                 |
| 012     | N/A (headers missing, score _Medium_)                      | `10.10.2.50 (web‑srv‑01)`                  | **AS**   | Missing security headers on patient portal; quick configuration fix.                  |
| 013     | N/A (cert expiring, score _Medium_)                        | `10.10.2.50 (web‑srv‑01)`                  | **AS**   | Let’s Encrypt cert due in 23 days – schedule renewal before expiry.                   |
| 014     | N/A (misconfig, score _Medium_)                            | `10.10.10.1 (Westside Clinic router)`      | **AC**   | Consumer‑grade router is VPN terminator; immediate hardening or replacement needed.   |
| 015     | N/A (DSM web interface open, score _Medium_)               | `10.10.2.41 (NAS‑01)`                      | **AS**   | Unrestricted DSM access can steal or delete backups – restrict ACLs.                  |
| 016     | N/A (unauthenticated HL7 & web UI, score _Medium_)         | `10.10.2.* (Philips IntelliVue)`           | **AS**   | PHI visible on flat network; limit exposure via VLAN/ACLs.                            |
| 017     | 9.8 / CVE‑2020-1938 (Ghostcat)                             | `10.10.2.10 (ehr‑srv‑01)`                  | **AC**   | AJP exposed on internal subnet – allows file read, high risk.                         |
| 018     | N/A (weak Kerberos, score _High_)                          | `10.10.2.20/21 (ad‑dc‑01 / ad‑dc‑02)`      | **AC**   | Allows Kerberoasting; critical for domain integrity.                                  |
| 019     | N/A (RDP enabled, score _Medium_)                          | multiple internal hosts                    | **AS**   | Brute‑force risk – schedule MFA/enforcement.                                          |
| 020     | N/A (OpenSSH PKCS11 FP)                                    | `10.10.2.40 (backup‑srv‑01)`               | **I**    | Flagged as possible false positive; verify before action.                             |
| 021     | N/A (TRACE enabled, score _Medium_)                        | `10.10.2.50 (web‑srv‑01)`                  | **AS**   | Allows XST if combined with XSS – enable disable TRACE.                               |
| 022     | N/A (clock skew, score _Low_)                              | `10.10.2.10`                               | **I**    | Monitor and sync NTP; low impact.                                                     |
| 023     | N/A (USB unrestricted, score _Low_)                        | workstations                               | **AS**   | Risk of data exfiltration – apply GPO restriction.                                    |
| 024     | N/A (unencrypted DICOM, score _Low_)                       | `10.10.2.12 (pacs‑srv‑01)`                 | **AS**   | PHI could be intercepted if network compromised; restrict traffic.                    |
| 025     | N/A (zone transfer enabled, score _Low_)                   | `10.10.2.20`                               | **AS**   | Enables internal reconnaissance – disable or limit zone transfers.                    |
| 026     | N/A (kernel 4.15 outdated, score _Low_)                    | `10.10.2.15`                               | **AS**   | Plan upgrade or enable ESM.                                                           |
| 027     | N/A (Sophos status, score _Informational_)                 | workstations                               | **I**    | Review endpoint policy; no immediate action.                                          |
| 028     | N/A (unknown Linux host with default creds, score _High?)_ | `10.10.2.99`                               | **AC**   | Shadow device could pivot internally – isolate or decommission.                       |
| 029     | 7.5 / CVE‑2021-43798 (Path Traversal)                      | `10.10.9.200`                              | **AC**   | Grafana 8.2.0 vulnerable; patch immediately.                                          |
| 030     | N/A (CN mismatch, score _Low_)                             | `10.10.2.10 (ehr‑srv‑01)`                  | **I**    | Operational issue – note for future certificate management.                           |
| 031     | 9.8 / CVE‑2020-1938 (Ghostcat)                             | `10.10.2.10 (ehr‑srv‑01)`                  | **AC**   | Active AJP service; high‑impact file read.                                            |

---

## Triage Summary

| Category                     | Count |
| ---------------------------- | ----- |
| Actionable Critical (**AC**) | 13    |
| Actionable Standard (**AS**) | 14    |
| Informational (**I**)        | 4     |

---

## Actionable Findings List (Sorted by Priority)

**Actionable Critical (Immediate 24–48 h)**

1. Finding 001 – RCE on billing‑srv‑01
2. Finding 002 – Privilege escalation on billing‑srv‑01
3. Finding 003 – Unrestricted PostgreSQL access (ehr‑db‑01)
4. Finding 004 – Windows XP MRI workstation vulnerabilities
5. Finding 007 – LDAP signing & SMBv1 on domain controller
6. Finding 008 – PrintNightmare on print server
7. Finding 010 – BD Alaris infusion pump DoS
8. Finding 014 – Consumer router VPN terminator (Westside)
9. Finding 017 – AJP Ghostcat on EHR server
10. Finding 018 – Weak Kerberos on DCs
11. Finding 028 – Shadow Linux host with default creds
12. Finding 029 – Grafana path‑traversal (unidentified Westside host)
13. Finding 031 – Active AJP connector (Ghostcat)

**Actionable Standard (Scheduled 7–30 days)**

1. Finding 005 – TLS 1.0/1.1 on patient portal
2. Finding 006 – MySQL unrestricted binding on billing‑srv‑01
3. Finding 009 – Password‑based SSH on billing‑srv‑01
4. Finding 011 – Ubuntu 18.04 ESM not enabled (billing‑srv‑01)
5. Finding 012 – Missing HTTP security headers (patient portal)
6. Finding 013 – Expiring Let's Encrypt cert (patient portal)
7. Finding 015 – Synology DSM accessible from internal network
8. Finding 016 – Philips IntelliVue web & HL7 interfaces exposed
9. Finding 019 – RDP enabled on multiple internal hosts
10. Finding 021 – HTTP TRACE method enabled (patient portal)
11. Finding 023 – USB mass storage unrestricted on workstations
12. Finding 024 – Unencrypted DICOM traffic on PACS server
13. Finding 025 – DNS zone transfer enabled on DC
14. Finding 026 – Outdated kernel 4.15 on billing‑srv‑01

---

**Next Steps**

1. **Immediate Remediation (AC)** – Patch or harden the assets listed above.
2. **Schedule Fixes (AS)** – Plan configuration changes, upgrades, and vendor updates.
3. **Monitor & Document (I)** – Continue to log, monitor, and review informational findings for any change in risk profile.
