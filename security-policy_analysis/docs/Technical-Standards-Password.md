> This document provides the technical implementation guidance that underpins SecureBank’s **Password Policy** (Policy ID: SB‑PASS‑001). It is intended for the Information Security Team, application architects, system administrators, and developers. The standards herein are aligned with NIST SP 800‑63B, OWASP Authentication Cheat Sheet, PCI‑DSS v4.0 Req. 8, CISA MFA Guide, and other relevant regulatory documents.

---

## 1. Overview

| Aspect                                | Standard / Source                                                        |
| ------------------------------------- | ------------------------------------------------------------------------ |
| **Password Complexity & Life Cycle**  | NIST SP 800‑63B §5.1.2 (Authentication – Passwords)                      |
| **Hashing / Storage**                 | NIST SP 800‑63B §5.1.4, ISO 27001 Annex A.9.2.3                          |
| **Multi‑Factor Authentication (MFA)** | CISA MFA Guide, NIST IR 8259C, PCI‑DSS Req. 8.3.6                        |
| **Password Managers**                 | NIST SP 800‑63B §5.1.7, OWASP Auth Cheat Sheet “Strong Password Storage” |
| **Recovery / Reset**                  | ISO 27001 A.11.2.1, PCI‑DSS 9.4.3                                        |
| **Auditing & Logging**                | NIST SP 800‑92, PCI‑DSS Req. 10.7.1                                      |

---

## 2. Password Complexity Rules

| Requirement                 | Specification                                                                                                                                                  | Reference                                                              |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| **Minimum Length**          | ≥ 12 characters for all accounts                                                                                                                               | NIST SP 800‑63B §5.1.2.2                                               |
| **Character Set**           | At least **3** of the 4 categories: <br>• Uppercase letters (A–Z) <br>• Lowercase letters (a–z) <br>• Digits (0–9) <br>• Special characters (!@#$%^&*()-_=+[]) | NIST SP 800‑63B §5.1.2.3                                               |
| **Prohibited Content**      | • Personal data (name, DOB, SSN).<br>• Dictionary words or reversible patterns.<br>• Password reuse across accounts for any user.                              | OWASP Auth Cheat Sheet – “Avoid Reuse and Known Compromised Passwords” |
| **Password Strength Meter** | Front‑end validation must use zxcvbn algorithm to give real‑time feedback.                                                                                     | OWASP Auth Cheat Sheet – “Client‑Side Validation”                      |

---

## 3. Storage & Hashing

| Item                             | Requirement                                                         | Implementation Guidance                                                               |
| -------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| **Hash Algorithm**               | Argon2id (preferred) or PBKDF2‑SHA256 if Argon2 unavailable         | _Argon2id:_ memory cost ≥ 32 MiB, iterations ≥ 3. <br>_PBKDF2:_ ≥ 200 000 iterations. |
| **Salt**                         | Unique 16‑byte random salt per password.                            | Generated via a CSPRNG (e.g., `os.urandom`).                                          |
| **Pepper**                       | Single system‑wide secret stored in HSM (Hardware Security Module). | Pepper length ≥ 32 bytes, rotate annually.                                            |
| **Password Hash Storage Format** | `$argon2id$v=19$m=32768,t=3,p=1$<salt>$<hash>`                      | Follows RFC 9106.                                                                     |
| **Database Field Size**          | At least 256 bits (32 bytes) for hash; store base64 or hex encoded. | Avoid truncation.                                                                     |

---

## 4. Multi‑Factor Authentication (MFA)

| Layer                   | Policy                                                                 | Technical Controls                                                                                        |
| ----------------------- | ---------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| **High‑Risk Systems**   | Mandatory MFA for all users.                                           | Hardware token (YubiKey U2F), TOTP (Google Authenticator) via FIDO2 protocol, or Windows Hello with TPM.  |
| **Remote Access / VPN** | 2FA required for any remote session.                                   | Deploy OpenVPN with LDAP and HSM‑backed certificates; fallback to Duo Push if hardware token unavailable. |
| **Privileged Accounts** | MFA + time‑bounded access tokens (max 60 min).                         | PAM module `pam_oath` or Azure AD Conditional Access.                                                     |
| **Backup / Recovery**   | Secondary factor must be distinct from primary (e.g., device vs. app). | Store backup codes in HSM; enforce single use per code.                                                   |

_All MFA mechanisms must support FIPS‑140‑2/3 validation for cryptographic components._

---

## 5. Password Managers

| Requirement            | Guideline                                                                                                                     |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **Enterprise Manager** | Only approved solutions (e.g., LastPass Enterprise, 1Password Business). <br>Encrypted vaults with zero‑knowledge encryption. |
| **Local Storage**      | No plain‑text passwords on endpoint devices.                                                                                  |
| **Credential Sharing** | Use secure “share” feature; audit shared credentials weekly.                                                                  |

---

## 6. Password Reset & Recovery

| Step                   | Action                                                                                          | Tool / Service                                            |
| ---------------------- | ----------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| **Self‑Service Reset** | User submits via SecureBank Self‑Reset portal; verifies identity via MFA or security questions. | Identity Management (Okta, Azure AD).                     |
| **Admin Reset**        | IT Security must approve reset request; record RACI in ticketing system.                        | ServiceNow with custom SLA for password resets (< 4 hrs). |
| **Post‑Reset**         | Force immediate password change on next login.                                                  | Enforced via session policy (no persistent tokens).       |

---

## 7. Auditing & Logging

| Log Item                                    | Requirement                                              | Retention Period                                                    |
| ------------------------------------------- | -------------------------------------------------------- | ------------------------------------------------------------------- |
| Successful logins                           | Capture IP, device, MFA factor used.                     | 90 days for general logs; 180 days for privileged account activity. |
| Failed login attempts                       | Record username, IP, timestamp, reason.                  | 365 days.                                                           |
| Password changes / resets                   | Who changed what and when.                               | 365 days.                                                           |
| System alerts (e.g., brute‑force detection) | Trigger automated blocks; log event IDs per SIEM schema. | 90 days.                                                            |

All logs must be write‑once, signed, and forwarded to the SOC’s SIEM platform (QRadar/ArcSight).

---

## 8. Patch & Configuration Management

| Item                        | Guideline                                                                                  |
| --------------------------- | ------------------------------------------------------------------------------------------ |
| **Hashing Library Updates** | Use up‑to‑date Argon2 implementation; patch any vulnerabilities within 30 days of release. |
| **MFA Firmware**            | Keep token firmware updated via vendor OTA process.                                        |
| **Server OS/Platform**      | Apply critical security patches within 10 business days.                                   |

---

## 9. Documentation & Training

- All developers must review the Password Storage section of the OWASP Cheat Sheet before committing code that handles passwords.
- End‑users receive an annual password hygiene training module; completion tracked in LMS.

---

## 10. References

1. **NIST Special Publication 800‑63B** – Digital Identity Guidelines, Authentication: §5.1 (Passwords).
2. **PCI DSS v4.0** – Requirement 8 (Protection of stored cardholder data) & Appendix A.3 (Password Storage).
3. **OWASP Authentication Cheat Sheet** – “Strong Password Storage” & “Client‑Side Validation”.
4. **CISA Multi‑Factor Authentication Guide** – Implementation Checklist.
5. **ISO/IEC 27001:2018 Annex A.9.2.3** – Password Management.

---

_Prepared by:_  
Information Security Team, SecureBank  
**Date:** 1 Oct 2026
