# TechSecure Solutions Inc. – Acceptable Use Policy (AUP)

| Item                | Details                                                                               |
| ------------------- | ------------------------------------------------------------------------------------- |
| **Policy Title**    | Acceptable Use Policy                                                                 |
| **Company**         | TechSecure Solutions Inc.                                                             |
| **Version**         | 1.0                                                                                   |
| **Effective Date**  | 01 _September 2026                                                                    |
| **Owner / Contact** | Chief Information Security Officer (CISO) – Sofia Chandler, s.chandler@techsecure.com |
| **Approval**        | Executive Leadership Team (ELT), 15 August 2026                                       |

---

## 1. Purpose

The Acceptable Use Policy establishes the boundaries of lawful and responsible use of all TechSecure Solutions corporate information technology resources. The policy safeguards our intellectual property, protects customer data, maintains compliance with applicable regulations, and preserves the company’s reputation.

## 2. Scope

This AUP applies to:

| Category               | Covered Entities                                                                                                                                                                                    |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Employees**          | Full‑time, part‑time, contract staff (≈ 500)                                                                                                                                                        |
| **Locations**          | All three corporate offices and remote workers                                                                                                                                                      |
| **Systems & Services** | • Cloud‑based dev environment<br>• Corporate email (Exchange Online)<br>• VPN (OpenVPN 2.5+)<br>• Collaboration tools (Microsoft Teams)<br>• Any other IT service under the IT Department’s control |
| **Devices**            | All devices used to access corporate resources, including desktops, laptops, tablets, smartphones, and IoT peripherals                                                                              |

---

## 3. Definitions

| Term                             | Definition                                                                                                                  |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **Corporate Network**            | All LAN/Wi‑Fi segments, VPN tunnels, and cloud services that are part of TechSecure’s infrastructure.                       |
| **Personal Use**                 | Non‑business activity conducted by an employee during working hours or on company‑provided equipment.                       |
| **BYOD (Bring Your Own Device)** | Any device owned or personally maintained by an employee that connects to corporate resources.                              |
| **Confidential Information**     | Proprietary code, designs, trade secrets, customer data, and any information marked as “Internal” or higher classification. |

---

## 4. Policy Statements

### 4.1 Internet Usage

| Rule                      | Requirement                                                                                                                                                                                                              | Rationale                                                          |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------ |
| **Browsing Restrictions** | • Allowed sites: company‑approved web services (development tools, documentation, learning portals).<br>• Prohibited: gambling, pornographic content, extremist material, non‑secure sites (HTTP) for business purposes. | Prevents malware exposure and preserves bandwidth.                 |
| **Personal Use**          | • Limited to 5 % of total internet usage per employee per month.<br>• Personal browsing must occur during non‑productive periods (e.g., lunch breaks).                                                                   | Ensures network resources remain available for business.           |
| **Monitoring & Logging**  | The IT Department will log all HTTP(S) traffic and can audit usage as needed to enforce this policy or investigate incidents.                                                                                            | Enables accountability and compliance with regulatory obligations. |

### 4.2 Email Usage

| Rule                      | Requirement                                                                                                                                                                                                                                                          | Rationale                                          |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| **Acceptable Use**        | • Emails must be sent for business purposes only.<br>• No mass mailing of unsolicited promotional material.<br>• Personal attachments or large media files should use cloud sharing services (OneDrive/SharePoint).                                                  | Reduces spam, phishing risk, and storage abuse.    |
| **Retention & Archiving** | • All corporate email is retained per the Data Retention Schedule: 7 years for transactional records, 3 years for general correspondence.<br>• Archived mail cannot be deleted by users; only the Legal/Compliance team can request deletion for compliance reasons. | Supports legal discovery and regulatory reporting. |

### 4.3 Software & Applications

| Rule                        | Requirement                                                                                                                                                                                                           | Rationale                                                           |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| **Approved Software List**  | • All software must appear on the approved list maintained by IT.<br>• Requests for new software go through the Software Request Form (SRF).                                                                          | Prevents unlicensed or insecure tools.                              |
| **Installation Procedures** | • End‑users cannot install software directly; installations are performed by IT support using a signed script and controlled elevation.<br>• Remote installation via Ansible/Chef is allowed only after SRF approval. | Ensures consistent patching, licensing, and security configuration. |

### 4.4 Social Media & Public Representation

| Rule                       | Requirement                                                                                                                                                                                                  | Rationale                                         |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------- |
| **Confidentiality**        | • No sharing of proprietary code, architecture diagrams, or internal discussions.<br>• Do not post sensitive client data or upcoming releases without explicit authorization from the Marketing/Legal teams. | Protects IP and maintains competitive advantage.  |
| **Company Representation** | • All public posts that reference TechSecure must include a disclaimer: “I am an employee of TechSecure Solutions Inc.”<br>• Personal opinions do not reflect company positions unless approved by PR.       | Prevents misrepresentation and reputational risk. |

### 4.5 Bring Your Own Device (BYOD)

| Rule                      | Requirement                                                                                                                                                                              | Rationale                                      |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| **Registration**          | • Every BYOD must be registered in the Mobile Device Management (MDM) system.<br>• Registration includes device type, OS version, and owner contact information.                         | Enables remote management and troubleshooting. |
| **Security Requirements** | • Minimum password complexity: 12 characters, alphanumeric + special char.<br>• Encryption: Full‑disk encryption must be enabled.<br>• Mandatory MDM compliance (antivirus, OS patches). | Safeguards corporate data on personal devices. |
| **Separation of Data**    | • Company data resides in a sandboxed container; personal files are isolated.<br>• No corporate credentials or applications stored in personal storage spaces.                           | Limits accidental leakage.                     |

### 4.6 Data Handling

| Rule         | Requirement                                                                                                                                                                                                                                        | Rationale                                            |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| **Storage**  | • Confidential data must be stored on encrypted drives within the cloud environment (Azure Disk Encryption) or local devices meeting encryption standards.<br>• Unclassified data may reside on non‑encrypted storage only if it is non‑sensitive. | Prevents unauthorized access in case of device loss. |
| **Sharing**  | • Share through secure channels (Teams/SharePoint) with least privilege.<br>• External sharing must be vetted and approved by the Data Owner.                                                                                                      | Controls data dissemination.                         |
| **Disposal** | • All removable media used for corporate data must be securely wiped (DEFLATE or SDELETE) before disposal.<br>• Decommissioned devices are subject to a hardware destruction audit.                                                                | Ensures no residual data remains.                    |

---

## 5. Enforcement & Consequences

- Violations will trigger an investigation by IT Security and the Human Resources department.
- Disciplinary action ranges from verbal warning (first offense) to suspension or termination (repeat offenses).
- Depending on severity, legal action may be pursued for breaches of confidentiality, data theft, or regulatory non‑compliance.

---

## 6. Review & Revision Cycle

The AUP will be reviewed annually and after any major security incident, technology shift, or regulatory change. All revisions must be approved by the ELT.

---

## 7. Employee Acknowledgment

I, **[Employee Name]**, have read and understood the TechSecure Solutions Inc. Acceptable Use Policy. I agree to comply with all its provisions and understand that non‑compliance may result in disciplinary action up to termination of employment.

| Signature                | Date         |
| ------------------------ | ------------ |
| ________________________ | ____________ |

_Note: The signed acknowledgment will be stored electronically in the Human Resources Information System._

---

**Appendix A – Contact Points**

| Function      | Contact                     |
| ------------- | --------------------------- |
| IT Security   | s.chandler@techsecure.com   |
| HR Compliance | hrcompliance@techsecure.com |
| Legal Counsel | legal@techsecure.com        |

---
