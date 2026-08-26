## Policy Analysis

**Part A – Missing Components**

| **Missing Component**                | **Why It’s Important**                                                                        |
| ------------------------------------ | --------------------------------------------------------------------------------------------- |
| Version / Revision ID                | Enables tracking of changes and ensures everyone is referring to the same document.           |
| Effective Date & Expiration (if any) | Clarifies when the policy becomes binding and when it will be reviewed.                       |
| Owner/Author                         | Identifies who is accountable for maintaining the policy and for addressing questions.        |
| Purpose Statement                    | Provides context and explains why the policy exists, aligning with business goals.            |
| Scope Definition                     | Specifies which people, systems, locations, and data the policy applies to.                   |
| Specific Policy Statements (Rules)   | Translates high‑level intent into concrete, enforceable actions or constraints.               |
| Roles & Responsibilities             | Assigns clear duties to users, IT, security, HR, compliance, etc., reducing ambiguity.        |
| Enforcement / Discipline Section     | Describes how violations will be handled and what consequences apply.                         |
| Definitions                          | Clarifies terminology (e.g., “password”, “MFA”) so readers interpret the policy consistently. |
| Related Documents / References       | Links to standards, guidelines, or other policies that support or extend this one.            |
| Review & Revision History            | Records when and why changes were made, ensuring the document remains current.                |

---

**Part B – Weaknesses**

| **Weakness**                                             | **Problem**                                                                       | **Impact**                                                                     |
| -------------------------------------------------------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| _“All employees should use good passwords.”_             | Vague language—“good” is subjective; no metrics or controls defined.              | Users may choose weak passwords, increasing breach risk.                       |
| _“Don't share them.”_                                    | No clarification on acceptable sharing (e.g., with IT support) or secure methods. | Inconsistent practice; users might share insecurely or refuse legitimate help. |
| _“IT will handle security stuff.”_                       | Responsibilities are not clearly distributed between end‑users and IT staff.      | Ambiguity leads to gaps in enforcement and accountability.                     |
| _“Report problems to someone.”_                          | No named reporting channel, escalation path, or record‑keeping procedure.         | Delays remediation; incidents may go unlogged or unresolved.                   |
| _“Updated: Sometime last year”_                          | Date is imprecise, no version number, and no documented review cycle.             | Difficult to verify compliance; policy may be stale or ignored.                |
| No mention of password complexity, length, or expiration | Leaves open the possibility for very short or dictionary‑based passwords.         | Increases vulnerability to brute‑force and credential‑stuffing attacks.        |

---

**Part C – Rewritten Password Policy**

```
──────────────────────────────────────────────────────────────
                         PASSWORD POLICY
──────────────────────────────────────────────────────────────

Version: 1.2
Effective Date: 01 September 2026
Last Review Date: 15 March 2025
Owner: IT Security Manager (John Doe)

Purpose
-------
This policy establishes the minimum requirements for creating, managing,
and protecting passwords used to authenticate to all corporate systems.
It aligns with NIST SP 800‑63B and internal compliance obligations.

Scope
------
All employees, contractors, consultants, temporary staff, and any individual
who has access to an organization‑controlled account that uses a password.

Definitions
-----------
**Password:** A secret string of characters known only to the user, used
to authenticate to an information system.
**Multi‑Factor Authentication (MFA):** The requirement that authentication
involves two or more independent factors (something you know,
something you have, something you are).
**Compromise:** Unauthorized use or disclosure of a password.

Policy Statement
----------------

1. **Password Complexity & Length**
   * Minimum length: 12 characters.
   * Must contain at least one uppercase letter, one lowercase letter,
     one digit, and one non‑alphanumeric character.
   * Passwords may not be derived from the user’s name or common dictionary
     words; a list of prohibited passwords (e.g., “Password123”) will be maintained.

2. **Password Creation & Management**
   * Users must create unique passwords for each system; reuse is prohibited
     within the last 24 passwords.
   * Passwords are case‑sensitive and stored only in salted, hashed form by the
     authentication service (PBKDF2‑SHA256, 200 000 iterations).

3. **Password Expiration & Rotation**
   * Passwords must be changed at least every 90 days.
   * Users will receive reminders starting 10 days before expiration.
   * No password may be reused within the last 12 months.

4. **Account Lockout & Brute‑Force Protection**
   * After five consecutive failed login attempts, the account is locked
     for 15 minutes or until IT verifies legitimate access (whichever is later).
   * Lockout events are logged and reported to Security Operations Center
     (SOC) daily.

5. **Multi‑Factor Authentication (MFA)**
   * MFA is required for all remote access (VPN, cloud services, SaaS)
     and for privileged accounts (administrative, root, etc.).
   * Approved MFA methods: FIDO2 security keys or the organization’s
     one‑time password (OTP) application.

6. **Password Sharing & Delegation**
   * Passwords may never be shared verbally, in writing, or electronically.
   * If an account must be delegated temporarily, a “shared session” policy
     shall be used instead; the delegate’s credentials remain distinct.

7. **Reporting & Incident Response**
   * Suspected compromise of a password (forgotten login, unusual activity,
     phishing attempts) must be reported immediately to the IT Help Desk.
   * All incidents will be recorded in the Incident Management System
     and investigated according to the Incident Response Plan.

8. **Enforcement**
   * Violations may result in disciplinary action up to termination of employment,
     legal proceedings, or civil penalties as per company policy.
   * IT Security will conduct quarterly audits of password compliance
     and report findings to the Board.

Roles & Responsibilities
-------------------------
| Role | Responsibility |
|------|---------------|
| **End User** | Create, maintain, and protect passwords; comply with MFA; report incidents. |
| **IT Help Desk** | Verify identity for account resets; enforce lockout policy; forward incidents. |
| **Security Operations Center (SOC)** | Monitor lockout events; conduct audit reviews; support incident response. |
| **IT Security Manager** | Review and approve policy changes; oversee enforcement; report compliance status. |
| **HR & Legal** | Ensure disciplinary procedures align with employment law and data protection regulations. |

Related Documents
-----------------
* NIST SP 800‑63B Digital Identity Guidelines
* Company Incident Response Plan
* Acceptable Use Policy

Review Cycle
------------
This policy shall be reviewed annually or sooner if a significant security threat,
regulatory change, or technology update occurs.

Appendix A – Password Complexity Validator Code Snippet (Python)


---
```
