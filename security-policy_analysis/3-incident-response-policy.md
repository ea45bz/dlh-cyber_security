# GlobalTech Manufacturing – Incident Response Policy

**Version:** 1.0 | **Effective Date:** 01 October 2026 | **Owner:** Chief Information Security Officer (CISO) – Leila Bennett, l.bennett@globaltech.com  
**Approval:** Executive Leadership Team (ELT), 15 September 2026

**Purpose** – This policy establishes a repeatable, NIST‑aligned incident‑response process that protects GlobalTech’s assets, ensures regulatory compliance (ISO 27001, GDPR, industry regulations) and preserves the integrity of our manufacturing IoT/OT environments.

---

## 1. Incident Classification

| Severity     | Description                                                                                                                                           | Response Time                          | Examples                                                                                                                                           |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Critical** | Disruption to mission‑critical production lines or safety‑related OT systems; loss of customer data; large‑scale ransomware affecting multiple sites. |  ≤ 30 minutes (initial acknowledgment) | • Unauthorized takeover of PLC controlling a hazardous process.<br>• Ransomware encryption of the master control database.                         |
| **High**     | Significant operational impact, substantial financial loss, or potential regulatory breach; partial compromise of OT or IT systems.                   |  ≤ 4 hours                             | • Malware detected on a manufacturing workstation that could affect product quality.<br>• Unauthorized access to confidential engineering designs. |
| **Medium**   | Limited disruption, minimal data exposure; internal reconnaissance activity.                                                                          |  ≤ 24 hours                            | • Phishing campaign targeting several employees.<br>• Vulnerability scanning of the factory network.                                               |
| **Low**      | Minor incidents with negligible impact; non‑confidential data exfiltration or accidental disclosure.                                                  |  ≤ 72 hours                            | • Stolen USB drive containing internal documents.<br>• Incorrectly configured public cloud bucket.                                                 |

_Response Time refers to the initial containment step (e.g., isolating affected assets)._

---

## 2. Incident Response Team

| Role                                             | Primary Responsibilities                                                                                                      |
| ------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| **Incident Response Manager**                    | Leads the IR process; coordinates all teams; maintains incident log; escalates to Executive Sponsor when needed.              |
| **Security Analysts (Tier‑1 / Tier‑2)**          | Conduct triage, forensic analysis, threat hunting; manage SIEM alerts; document evidence and actions.                         |
| **IT Support / OT Engineers**                    | Implement containment, eradication, and recovery on production systems; apply patches to PLC/SCADA devices; maintain backups. |
| **Legal Counsel**                                | Advises on regulatory obligations (GDPR 33, ISO 27001 controls), data‑breach notification timelines, third‑party contracts.   |
| **Communications / PR**                          | Prepares internal/external communications; manages media queries; coordinates with Legal on disclosure statements.            |
| **Executive Sponsor** (Chief Operations Officer) | Provides executive oversight; authorizes high‑level decisions; ensures business continuity is maintained.                     |

All team members receive annual IR training and quarterly tabletop exercises.

---

## 3. Detection & Reporting

### 3.1 Detection Methods

- SIEM/UEBA alerts from IDS/IPS, endpoint protection, and OT‑specific anomaly detection.
- Automated notifications from SCADA monitoring (e.g., DCS alarms).
- User‑reported incidents via the GlobalTech “Security Portal” or direct email to `security@globaltech.com`.

### 3.2 Reporting Process

1. **Submit** incident ticket through the Security Portal (`ticket.globaltech.com`) or send an encrypted email with subject **[INCIDENT]**.
2. **Ticket fields**: system affected, description, timestamp, urgency level (auto‑assigned by the portal based on keyword detection).
3. **Automated acknowledgment** within 5 minutes; if manual, within 30 minutes.

### 3.3 Information to Collect

- Asset identifiers (IP, hostname, MAC, OT device ID).
- Logs and screenshots.
- Email headers or phishing URLs.
- User notes/observations.
- Forensic evidence (memory dumps, disk images).

### 3.4 Initial Assessment

1. **Triage**: Security Analyst validates severity, checks for duplicate tickets, assigns priority.
2. **Escalation**: If classified as High/Critical, notify Incident Response Manager and Executive Sponsor via secure channel (encrypted instant messaging or phone).
3. **Containment Decision**: Decide whether to isolate assets immediately.

---

## 4. Response Procedures

| Phase                        | Key Actions                                                                                                                                                                                                      |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Containment – Short‑Term** | • Isolate affected device(s) from network (e.g., switch port shutdown, PLC disconnection).<br>• Apply network segmentation rules.<br>• Preserve volatile memory where possible.                                  |
| **Evidence Preservation**    | • Take live memory capture and disk images using forensically sound tools (FTK Imager, EnCase).<br>• Store evidence on write‑once media; record hash values (SHA‑256).                                           |
| **Containment – Long‑Term**  | • Apply security patches/firmware updates to OT devices.<br>• Revoke compromised credentials.<br>• Update firewall rules and access controls.                                                                    |
| **Eradication**              | • Remove malware artifacts, delete malicious scripts.<br>• Conduct root cause analysis (e.g., vulnerability exploitation path).<br>• Harden vulnerable configurations per ISO 27001 control A.6.2.5.             |
| **Validation**               | • Re‑scan affected assets with updated AV signatures.<br>• Verify no persistence mechanisms remain.                                                                                                              |
| **Recovery**                 | • Restore systems from verified backups (for IT) or rebuild compromised OT firmware.<br>• Run regression tests on production lines to confirm normal operation.<br>• Monitor for recurrence via SIEM dashboards. |

---

## 5. Communication Plan

| Stakeholder                  | When to Notify                                                                                            | Method                                                     |
| ---------------------------- | --------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| **Executive Management**     | Within **15 minutes** of confirmation (Critical) / **4 hours** (High).                                    | Secure phone call + encrypted email summary.               |
| **Legal Counsel**            | Immediately upon detection of any personal data exposure or regulatory risk.                              | Encrypted email and real‑time meeting if needed.           |
| **Regulators**               | Within **72 hours** for GDPR Article 33 breaches; as required by ISO 27001 controls.                      | Official notification via regulator portal / secure email. |
| **Affected Users / Clients** | As soon as a solution is in place, within **48 hours** of public disclosure if the incident impacts them. | Email + dedicated support line.                            |
| **Media/Press**              | Only after Legal and PR confirm that it is appropriate to release information.                            | Press briefing or official statement.                      |
| **Supply Chain Partners**    | If the incident affects shared OT infrastructure.                                                         | Secure collaboration platform with partner’s CISO.         |

All communications are logged in the Incident Log and signed off by the Incident Response Manager.

---

## 6. Evidence Handling

1. **Chain‑of‑Custody Form (CoC)** – completed for every evidence item; records: collector name, date/time, actions taken.
2. **Evidence Preservation** – images captured with write‑once media; stored in a tamper‑evident vault; digital signatures created and verified.
3. **Documentation Requirements** – forensic report detailing acquisition process, integrity checks (hash verification), analysis results, and findings.
4. **Retention** – Evidence retained for at least 7 years or as required by regulatory bodies.

---

## 7. Post‑Incident Activities

| Activity                       | Deliverable                                                          |
| ------------------------------ | -------------------------------------------------------------------- |
| **Lessons Learned Meeting**    | Minutes with action items, owners, due dates.                        |
| **Root‑Cause Analysis Report** | Detailed technical explanation, impact assessment, mitigation steps. |
| **Policy / Process Update**    | Documented changes to IR procedures or controls if needed.           |
| **Executive Summary**          | High‑level overview for board reporting.                             |
| **Continuous Improvement**     | Updated threat intelligence feeds, training refreshes.               |

All reports are archived in the Incident Response Knowledge Base and reviewed by the CISO before the next quarterly audit.

---

# Deliverables

## A. Incident Classification Matrix

_(Table above – copyable into policy document.)_

## B. Communication Plan Table

_(Table above – ready for use during an incident.)_

## C. Incident Report Template

```
Incident ID: ___________________
Date/Time Detected: ____________
Reported By: _________________
Severity Level: ______________

1. Executive Summary
   - Brief description of the event.
   - Key impact areas (production, data, reputation).

2. Timeline of Events
   | Timestamp | Event | Action Taken |
   |-----------|-------|--------------|
   | 2026‑10‑01 08:15 | Alert from SIEM ... | Triage conducted |

3. Technical Details
   - Affected systems
   - Vulnerability / exploit used
   - Malware/Threat ID

4. Response Actions
   - Containment steps
   - Eradication measures
   - Recovery activities

5. Impact Assessment
   - Production downtime (hrs)
   - Data loss or exposure
   - Regulatory implications

6. Lessons Learned
   - What worked / didn’t work
   - Root cause and corrective actions

7. Recommendations
   - Process improvements
   - Control enhancements
   - Training needs

Prepared By: ______________________  Date: ____________
Approved By (IR Manager): ___________  Date: ____________
```

> All incident reports must be reviewed within 48 hours by the Incident Response Manager and forwarded to Legal for regulatory assessment.

---

**End of Policy**  
All employees, contractors, and partners are required to read, understand, and comply with this Incident Response Policy. Failure to do so may result in disciplinary action up to termination.
