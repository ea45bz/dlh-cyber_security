# SecureBank Financial Services – Password Policy

| Item                | Details                                                                         |
| ------------------- | ------------------------------------------------------------------------------- |
| **Policy Title**    | Password Policy                                                                 |
| **Company**         | SecureBank Financial Services (SBF)                                             |
| **Version**         | 1.0                                                                             |
| **Effective Date**  | 01 October 2026                                                                 |
| **Owner / Contact** | Chief Information Security Officer (CISO) – James Patel, j.patel@securebank.com |
| **Approval**        | Executive Leadership Team (ELT), 20 September 2026                              |

---

## 1. Purpose

The Password Policy establishes the minimum security requirements for creating, managing, storing, and protecting passwords used to access all SecureBank information systems. It supports compliance with PCI‑DSS v4.0, SOX, FFIEC, and industry‑best practices (NIST SP 800‑63B).

---

## 2. Scope

This policy applies to:

| Category      | Covered Entities                                                                                                                                                                                                     |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Users**     | All employees, contractors, consultants, temporary staff, and vendors who authenticate to SBF systems.                                                                                                               |
| **Locations** | Headquarters, regional offices, branch networks, remote workstations.                                                                                                                                                |
| **Systems**   | • Core banking system (critical)<br>• Customer portal<br>• Employee workstations (Windows/Linux/Mac)<br>• Administrative & privileged systems (HR, ITSM, DevOps)<br>• Development environment (GitLab, Azure DevOps) |
| **Devices**   | Any device used to authenticate – laptops, desktops, mobile phones, tablets.                                                                                                                                         |

---

## 3. Definitions

| Term                                   | Definition                                                                                                                                                   |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Password**                           | Secret string known only to the user; used with MFA for authentication.                                                                                      |
| **MFA (Multi‑Factor Authentication)**  | A combination of at least two independent factors: something you know (password), something you have (token, smart card), or something you are (biometrics). |
| **PAM (Privileged Access Management)** | Framework that controls, logs, and monitors privileged account usage.                                                                                        |
| **Hash**                               | Cryptographic transformation producing a fixed‑size output; irreversible.                                                                                    |

---

## 4. Policy Statements

### 4.1 Password Requirements

| Requirement               | Description                                                                                                                                                                                                                                                                  | Rationale                                                                      |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| **Minimum Length**        | ≥ 12 characters for all user accounts.                                                                                                                                                                                                                                       | Increases entropy and mitigates brute‑force attacks.                           |
| **Passphrase Acceptance** | Passwords may use dictionary words as long as they are at least 12 chars or include a mix of upper/lowercase, digits, and symbols.                                                                                                                                           | Encourages memorability while maintaining security.                            |
| **Disallowed Content**    | Password must not contain: <br>• The user’s full name or parts thereof (≥ 3 characters). <br>• Account or system identifiers. <br>• Consecutive sequences such as “1234”, “abcd”. <br>• Common dictionary words, reversible patterns, or trivial substitutions (“p@ssw0rd”). | Prevents predictable passwords that can be cracked by dictionary attacks.      |
| **Password Expiration**   | No mandatory periodic change unless a breach is suspected.                                                                                                                                                                                                                   | NIST 800‑63B advises against arbitrary rotations that do not improve security. |
| **Compromise Response**   | Upon detection of compromise or suspicious activity, the user must reset immediately; IT will force an immediate password reset.                                                                                                                                             | Minimizes risk window.                                                         |

### 4.2 Password Management

| Process             | Description                                                                                                                                                                                  | Controls                                      |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| **Change / Reset**  | • Users may change passwords via Self‑Service portal (no admin assistance). <br>• After lockout or suspected compromise, admins can reset; the user must set a new password upon next login. | All resets logged in SIEM with event ID 1001. |
| **Account Lockout** | • 10 consecutive failed attempts → account locked for 15 minutes. <br>• Locked accounts may be unlocked only by a Tier‑2 or higher security staff using the IAM portal.                      | Protects against credential stuffing.         |
| **Session Timeout** | Idle sessions on all systems automatically terminate after 15 minutes of inactivity.                                                                                                         | Limits opportunistic access.                  |

### 4.3 Multi‑Factor Authentication (MFA)

| System / Account Type                                                              | MFA Requirement                                                                   | Approved Methods                                                                                                                                                                                                               |
| ---------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Core banking system, administrative & privileged accounts, development environment | **Mandatory**                                                                     | • FIPS‑140‑2/3 certified hardware token (YubiKey, RSA SecurID). <br>• TOTP app (Google Authenticator, Microsoft Authenticator) over HTTPS. <br>• Biometric MFA for mobile devices compliant with Apple/Android Secure Enclave. |
| Customer portal                                                                    | **Optional** but highly encouraged for credit‑card or personal data transactions. | Same as above.                                                                                                                                                                                                                 |
| Employee workstations (non‑privileged)                                             | **Recommended** for remote access and VPN connections.                            | Hardware token or TOTP app.                                                                                                                                                                                                    |

_All MFA implementations must satisfy the CISA Multi‑Factor Authentication Guide and maintain a backup second factor._

### 4.4 Password Storage & Hashing

| Item                        | Requirement                                                                                                                                                                                                                                                                                    |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Hash Algorithm**          | Argon2id (preferred) with at least 32 MB memory cost, 3 iterations; if legacy systems require PBKDF2‑SHA256, use ≥ 200 000 iterations.                                                                                                                                                         |
| **Salt**                    | Unique per password, 16‑byte cryptographically random value.                                                                                                                                                                                                                                   |
| **Pepper**                  | Single system‑wide secret stored in a Hardware Security Module (HSM).                                                                                                                                                                                                                          |
| **Password Manager Policy** | • End‑users may store passwords locally using an approved password manager (e.g., LastPass Enterprise, Dashlane Business) that encrypts data end‑to‑end. <br>• Privileged accounts must be stored exclusively within the enterprise PAM system; no local storage or personal managers allowed. |
| **Audit**                   | Quarterly cryptographic review of hash parameters; any deviations trigger immediate remediation.                                                                                                                                                                                               |

### 4.5 Privileged Accounts & PAM

| Requirement             | Description                                                                                                                              | Controls |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| **Account Naming**      | Use descriptive names (e.g., `svc_jenkins_admin`).                                                                                       |
| **Least Privilege**     | Grant only the minimum permissions required for the job role.                                                                            |
| **Just‑in‑Time Access** | PAM solutions must enforce temporary elevation; session timeouts of 30 minutes unless overridden by an administrator with justification. |
| **Session Recording**   | All privileged sessions are recorded and stored securely for 90 days.                                                                    |
| **MFA**                 | Mandatory MFA for all privileged accounts, as listed in Section 4.3.                                                                     |
| **Periodic Review**     | Quarterly audit of privileged account list; any unused or orphaned accounts must be disabled immediately.                                |

---

## 5. Enforcement & Consequences

| Violation Type                         | Description                                                                | Disciplinary Action                                                     |
| -------------------------------------- | -------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| **Non‑compliance with password rules** | Using weak, reused, or disallowed passwords.                               | Verbal warning → Written warning → Suspension → Termination.            |
| **Unauthorized MFA bypass**            | Circumventing MFA controls (e.g., sharing tokens).                         | Immediate suspension; potential legal action under SOX/PCI regulations. |
| **Improper password storage**          | Storing passwords in plain text or insecure locations.                     | Immediate remediation; repeat offenders subject to termination.         |
| **Privileged account misuse**          | Unauthorized use of privileged accounts or failure to follow PAM controls. | Disciplinary review per SOX; potential regulatory reporting.            |

All incidents will be investigated by the Information Security Team and, where applicable, reported to external regulators (PCI DSS Incident Response).

---

## 6. Review & Revision Cycle

The Password Policy is reviewed annually or after any significant security incident, system upgrade, or regulation change. All revisions require ELT approval.

---

## 7. Employee Acknowledgment

I, **[Employee Name]**, have read and understood the SecureBank Password Policy. I agree to comply with all its provisions and understand that non‑compliance may result in disciplinary action up to termination of employment.

| Signature                | Date         |
| ------------------------ | ------------ |
| ________________________ | ____________ |

_The signed acknowledgment is stored electronically in the HRIS._

---

## 8. Technical Standards Reference

A separate **Technical Standards Document** [docs/Technical-Standards-Password.md](docs/Technical-Standards-Password.md) contains detailed implementation guidance, including:

1. NIST SP 800‑63B alignment – password creation, storage, and MFA.
2. PCI‑DSS v4.0 Requirement 8 – encryption of stored passwords.
3. SOX & FFIEC data protection requirements for employee credentials.
4. OWASP Authentication Cheat Sheet – session management and lockout parameters.
5. CISA MFA Guide – approved token types and backup procedures.

The Technical Standards document is the authoritative source for any system‑specific configuration beyond this policy framework.

---
