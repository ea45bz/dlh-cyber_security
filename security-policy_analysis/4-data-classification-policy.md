# HealthPlus Medical Group – Data Classification Policy

**Version:** 1.0 | **Effective Date:** 01 October 2026 | **Owner:** Chief Information Security Officer (CISO) – Sarah Reed, s.reed@healthplus.org  
**Approval:** Executive Leadership Team (ELT), 15 September 2026

> **Purpose** – To provide a clear, consistent framework for classifying, handling, and protecting data throughout its lifecycle in accordance with HIPAA, GDPR, state privacy statutes, and industry best practices.

---

## 1. Scope

This policy applies to **all** HealthPlus employees, contractors, vendors, and affiliates who create, receive, process, store, or transmit any of the following data types:

| Data Type                     | Classification (default)                         |
| ----------------------------- | ------------------------------------------------ |
| Patient medical records (PHI) | RESTRICTED                                       |
| Employee information (PII)    | CONFIDENTIAL                                     |
| Financial data                | CONFIDENTIAL                                     |
| Research data                 | INTERNAL/CONFIDENTIAL (depending on sensitivity) |
| Business operations data      | INTERNAL                                         |
| Public marketing materials    | PUBLIC                                           |

All HealthPlus data, regardless of format or location (on‑premises, cloud, mobile devices), is subject to this policy.

---

## 2. Definitions

- **PHI** – Protected Health Information as defined by HIPAA.
- **PII** – Personally Identifiable Information in the context of GDPR and state privacy laws.
- **Encryption at Rest** – Data stored on any media that is cryptographically protected (disk, database, cloud object).
- **Encryption in Transit** – Data protected by TLS 1.2+ or equivalent during transmission over networks.

---

## 3. Classification Levels

| Level            | Description                                                                           | Examples                                                         |
| ---------------- | ------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| **PUBLIC**       | Approved for unrestricted release; no confidentiality restrictions.                   | Marketing brochures, public website content, press releases.     |
| **INTERNAL**     | Intended for use within HealthPlus; internal distribution only.                       | Internal memos, organizational charts, HR policies.              |
| **CONFIDENTIAL** | Disclosure could cause financial or reputational harm if improperly released.         | Employee PII, financial statements, non‑public research results. |
| **RESTRICTED**   | Highest sensitivity; breach would directly violate privacy laws or endanger patients. | PHI, system credentials, patient billing records.                |

---

## 4. Handling Requirements

| Requirement               | PUBLIC                                           | INTERNAL                                      | CONFIDENTIAL                                                                                            | RESTRICTED                                                                                                                              |
| ------------------------- | ------------------------------------------------ | --------------------------------------------- | ------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| **Labeling**              | ✅ – “PUBLIC” header on documents and file names | ✅ – “INTERNAL” header/file naming            | ✅ – “CONFIDENTIAL” header/file naming                                                                  | ✅ – “RESTRICTED” header/file naming, red‑label for physical copies                                                                     |
| **Encryption at Rest**    | ❌ – Not required                                | ❌ – Optional for highly sensitive documents  | ✅ – AES‑256 (or stronger) for all storage media                                                        | ✅ – Mandatory AES‑256+ with key rotation; stored in an HSM or cloud KMS                                                                |
| **Encryption in Transit** | ✅ – TLS for web, SFTP/FTPS for file transfer    | ✅ – TLS 1.2+, secure file transfer protocols | ✅ – Same as INTERNAL but all PII/PHI must use FIPS‑140‑2 validated certificates                        | ✅ – Mandatory TLS 1.3 with client authentication; VPN or zero‑trust for remote access                                                  |
| **Access Control**        | Public access via website, no restrictions       | Role‑based access (RBAC) on internal portals  | RBAC + periodic review; least privilege; multi‑factor authentication (MFA) for database/analytics tools | Strictly controlled by the Data Protection Officer (DPO); MFA, role‑based & time‑based access; all accesses logged and reviewed monthly |

### 4.1 Labeling – Practical Guidelines

| Medium           | Header Format                                                                            | File Naming Convention                                                             |
| ---------------- | ---------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| Digital document | “[LEVEL] – <Title>” e.g., “CONFIDENTIAL – Q2 Budget.xlsx”                                | `public_[topic]`, `internal_[topic]`, `confidential_[topic]`, `restricted_[topic]` |
| Physical paper   | Red‑label for RESTRICTED; Blue for CONFIDENTIAL; Green for INTERNAL; No label for PUBLIC | Use pre‑printed envelopes where appropriate                                        |

### 4.2 Storage – Approved & Prohibited Locations

| Location                                   | Allowed Levels                                      | Notes                                                               |
| ------------------------------------------ | --------------------------------------------------- | ------------------------------------------------------------------- |
| Company intranet (HTTPS)                   | ALL                                                 | Must enforce TLS 1.2+                                               |
| Secure file share (Windows Share, SMB 3.0) | INHERITED: INTERNAL / CONFIDENTIAL / RESTRICTED     | Encrypted volumes; access governed by ACLs and MFA                  |
| Cloud object storage (Azure Blob/ S3)      | ALL                                                 | Enable encryption at rest; restrict access via IAM policies & MFA‑P |
| Personal devices (BYOD)                    | NO data unless encrypted & approved via BYOD policy | No PHI, PII on personal laptops or phones.                          |
| Public cloud CDN                           | PUBLIC only                                         | All other content must be removed before publishing.                |

### 4.3 Transmission – Email / File Transfer Rules

| Medium                           | Allowed Levels          | Security Controls                                                                                                           |
| -------------------------------- | ----------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Corporate email                  | INTERNAL & CONFIDENTIAL | Mandatory TLS (STARTTLS); encryption optional for PHI/PII; no attachments for RESTRICTED without secure file transfer link. |
| Secure FTP / SFTP                | ALL                     | Enforce TLS or SSH key authentication; logs retained 90 days.                                                               |
| Email with encrypted PDF         | RESTRICTED              | Use PGP or S/MIME; DLP scanning required.                                                                                   |
| Instant Messaging (Teams, Slack) | INTERNAL                | No PHI/PII allowed; if required, use secure channel provided by IT.                                                         |

### 4.4 Disposal – Paper & Media Sanitization

| Medium              | Required Process                                                                                                                                                                                                                                                             | Retention Period                                               |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| **Paper**           | • Public: simple shredding.<br>• Confidential: cross‑cut shredding; records retained per retention schedule.<br>• Restricted: classified shred or incineration (ISO 27040).                                                                                                  | 5 years for financial & employee data; 7 years for PHI (HIPAA) |
| **Digital Storage** | • Public: delete from systems, overwrite once.<br>• Confidential/Restricted: secure deletion (NIST 800‑88 §3.4) with at least two passes using industry tools (Eraser, DBAN).<br>• For media removed permanently: decommission or destroy in accordance with NIST 800‑88 §7. | 5–7 years as above                                             |
| **Backup Media**    | • Restricted: wipe backup after retention period; use cryptographic erasure if possible.                                                                                                                                                                                     | 3 years for PHI backups, 1 year for other data                 |

### 4.5 Access Control – Governance & Review

| Group                        | Access Policy                                                           | Review Frequency            | Owner                   |
| ---------------------------- | ----------------------------------------------------------------------- | --------------------------- | ----------------------- |
| **All Users**                | Default no‑access; granted via RBAC + MFA for sensitive levels          | N/A                         | IT Service Desk         |
| **Managers / Supervisors**   | Can request access to CONFIDENTIAL data under business justification    | Quarterly                   | HR & DPO                |
| **Data Stewards**            | Full read/write on assigned classification tier, with audit logging     | Monthly                     | Data Governance Council |
| **External Partners**        | Limited to RESTRICTED data only through secure gateway, governed by SOW | After each contract renewal | Legal                   |
| **Audit / Compliance Teams** | Read‑only on all levels for monitoring                                  | Continuous                  | SOC Lead                |

All access changes must be logged in the Identity Management System and reviewed within 7 days by the relevant steward.

---

## 5. Review & Revision

- The Data Classification Policy will be reviewed annually or sooner if HIPAA, GDPR, or state privacy laws change.
- Any updates require approval from the CISO, DPO, and Legal Counsel.

---

# Quick Reference Guide (1‑Page Summary)

> **Data Classification – What You Need to Know**

| Level            | Key Attribute                                               | How to Handle                                                                                                                                                                                                                                                                 |
| ---------------- | ----------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **PUBLIC**       | - No restrictions <br>- May be posted on website            | • Label with “PUBLIC” header/file name<br>- No encryption required (but TLS is mandatory for web)                                                                                                                                                                             |
| **INTERNAL**     | - Internal use only <br>- No public disclosure              | • Label “INTERNAL”<br>- Store in secure intranet or SMB 3.0 share <br>- Access via RBAC; MFA optional                                                                                                                                                                         |
| **CONFIDENTIAL** | - PII, financial data <br>- Can damage reputation if leaked | • Label “CONFIDENTIAL”<br>- Encrypt at rest (AES‑256) and in transit (TLS 1.2+)<br>- Require MFA for all access; least privilege <br>- Audit monthly                                                                                                                          |
| **RESTRICTED**   | - PHI, credentials <br>- Highest legal risk                 | • Label “RESTRICTED”; red‑label paper copies <br>- Mandatory AES‑256+ encryption at rest + HSM key storage <br>- Strict MFA & 2‑factor authentication for any access<br>- All transfers via secure channel (SFTP/HTTPS with client cert) <br>- Monthly review of all accesses |

**Common Reminders**

- **Label everything.** It’s the first line of defense.
- **Encrypt everything in transit, encrypt sensitive data at rest.**
- **Use MFA wherever possible—especially for RESTRICTED data.**
- **Dispose correctly:** shred paper, securely wipe electronic media.
- **Ask before sharing.** If you’re unsure of a classification, consult your Data Steward.

---

> **Need help classifying data?** Contact the Data Governance Council at `datacontroller@healthplus.org` or call extension 1234.

---
