## MedDefense Health Systems – Cryptographic Posture Audit


Finding ID: CRYPTO‑001
Data Category: EHR Database (PostgreSQL)
Data State: At Rest
Current Protection: "None – plain‑text on disk"
Vulnerability Reference: FINDING 003 (Unrestricted PostgreSQL listening)
Risk Reference: RISK‑001 (Crimson Tide ransomware)
Algorithm Assessment: "AES‑128‑CBC with 1 × 256‑bit key inadequate; no TDE"
Recommended Protection: "AES‑256‑GCM with Transparent Data Encryption, 256‑bit keys, per‑column optional"
Encryption Level: Full (DB‑wide)
Key Management: "Central KMS + HSM, rotate quarterly, audit logs"
Implementation Priority: Immediate

Finding ID: CRYPTO‑002
Data Category: Billing System (MySQL)
Data State: At Rest
Current Protection: "None – unencrypted data files"
Vulnerability Reference: FINDING 006 (MySQL bind‑address on 3306)
Risk Reference: RISK‑003 (Unencrypted backups)
Algorithm Assessment: "AES‑128‑CBC with 1 × 256‑bit key inadequate"
Recommended Protection: "AES‑256‑GCM for backup archives & MySQL payloads, 256‑bit keys, built‑in TDE if orted"
Encryption Level: Full (App‑level)
Key Management: "Local HSM per server, rotate annually, key escrow"
Implementation Priority: Phase 1

Finding ID: CRYPTO‑003
Data Category: HR/Employee Records (AD DS)
Data State: At Rest
Current Protection: "None – plaintext attributes in AD"
Vulnerability Reference: none
Risk Reference: RISK‑004 (Kerberos RC4 & weak credentials)
Algorithm Assessment: "RSA‑1024 & Kerberos RC4 inadequate"
Recommended Protection: "AES‑256‑GCM for AD data, enforce AES‑256 only in Kerberos; disable RC4"
Encryption Level: Full (Domain)
Key Management: "AD KDC + HSM, rotate keys biannually"
Implementation Priority: Immediate

Finding ID: CRYPTO‑004
Data Category: Patient Portal (Web UI)
Data State: In Transit
Current Protection: TLS 1.0/1.1 enabled; no ECDHE or SHA‑256
Vulnerability Reference: none
Risk Reference: RISK‑001 (SSL‑VPN initial access)
Algorithm Assessment: "TLS < 1.2 inadequate; no forward secrecy"
Recommended Protection: "TLS 1.3, ECDHE_RSA + AES‑256‑GCM, SHA‑384 – 256‑bit keys, st‑lived certs (90 days)"
Encryption Level: Full (Transport)
Key Management: "X‑509 CA in HSM, enforce HTTPS via web server config"
Implementation Priority: Immediate

Finding ID: CRYPTO‑005
Data Category: Backup NAS (NAS‑01)
Data State: At Rest
Current Protection: "None – unencrypted, same LAN as prod"
Vulnerability Reference: none
Risk Reference: RISK‑002 (Unencrypted backups)
Algorithm Assessment: "AES‑128‑CBC with 1 × 256‑bit key inadequate"
Recommended Protection: "AES‑256‑GCM for all backup volumes + SHA‑512 hash of each archive, write‑once storage"
Encryption Level: Full (Physical)
Key Management: "HSM‑based KMS with quarterly rotation, separate NFS server"
Implementation Priority: Phase 1

Finding ID: CRYPTO‑006
Data Category: VPN / Remote Access (SSL‑VPN)
Data State: In Transit
Current Protection: FortiGate SSL‑VPN on unpatched firmware; TLS < 1.2
Vulnerability Reference: RISK‑NEW-001 (CVE‑2023‑27997)
Risk Reference: none
Algorithm Assessment: "TLS 1.0/1.1 with static keys inadequate"
Recommended Protection: "IPSec VPN + FortiGate updated to 7.4.x, enable MFA, enforce AES‑256‑GCM & ECDHE – 256‑bit keys"
Encryption Level: Full (Transport)
Key Management: "Central KMS, token‑based MFA provider, rotate session keys per connection"
Implementation Priority: Immediate

Finding ID: CRYPTO‑007
Data Category: Medical Device Data Exchange
Data State: In Use
Current Protection: Plain HTTP to HL7 endpoints
Vulnerability Reference: none
Risk Reference: RISK‑005 (Device‑level data exposure)
Algorithm Assessment: "Plain HTTP inadequate"
Recommended Protection: "TLS 1.3 on device endpoints, mutual cert auth, AES‑256‑GCM – 256‑bit keys per device"
Encryption Level: Full (Application)
Key Management: "Device HSMs with local key store, rotation quarterly"
Implementation Priority: Phase 2

## Posture Score

7 of the 9 identified weak/absent encryption points now have a clear remediation path 78 % of critical data flows are covered by a concrete mitigation strategy.

## Top 3 Crypto Risks (by combined impact)

| Rank | Finding ID | Associated Risk                                  | Estimated ALE Impact |
| ---- | ---------- | ------------------------------------------------ | -------------------- |
| 1    | CRYPTO‑001 | RISK‑001 – Crimson Tide ransomware on EHR data   | $20 M / yr           |
| 2    | CRYPTO‑004 | RISK‑001 – Initial access via weak TLS (SSL‑VPN) | $10 M / yr           |
| 3    | CRYPTO‑005 | RISK‑002 – Unencrypted backups (destruction)     | $6 M / yr            |

1. **Weak/Absent cells in T0:** The original data‑protection map listed **9** critical areas lacking adequate protection (EHR DB, Billing DB, AD DS, Patient Portal TLS, Backup NAS, VPN SSL‑VPN, Medical Device HL7, plus two additional vendor‑specific services that were already covered by controls).
2. **Remediation path:** For each of the 7 cells we mapped a specific cryptographic technology (AES‑256‑GCM, TLS 1.3, HSM‑based KMS, etc.) and an implementation priority.
3. **Posture score calculation:** `(Number with remediation / Total weak) * 100 = (7/9)*100 ≈ 78%`.

---

### Next Steps for the Board

| Priority      | Action                                                                          | Owner                 | Timeline         | Notes                                  |
| ------------- | ------------------------------------------------------------------------------- | --------------------- | ---------------- | -------------------------------------- |
| **Immediate** | Renew FortiGate support and upgrade to v7.4.x; enable TLS 1.3 & MFA on SSL‑VPN. | James / Sarah         | Night (0–12 hrs) | Budget $2,400, requires approval       |
| **Phase 1**   | Deploy AES‑256‑GCM TDE on PostgreSQL & MySQL; encrypt backup volumes.           | Security Analyst      | Day 1–3          | Test in staging first                  |
| **Phase 2**   | Install mutual‑auth TLS on medical device endpoints (Philips, BD Alaris).       | Vendor/IT             | Week 1–2         | Requires device firmware upgrade       |
| **Ongoing**   | Implement central KMS with HSM; rotate keys quarterly.                          | Security Architecture | Ongoing          | Align with HIPAA key‑management policy |

> By executing the above roadmap, MedDefense will move from a **78 %** cryptographic coverage to **≥ 95 %**, dramatically reducing exposure to the Crimson Tide ransomware and other credential‑based threats.

---
