# Part 1 – RACI Matrix

| Activity                    | CEO | Deputy CISO (James) | IT Director (Sarah) | Dept Heads | Security Analyst (You) |
| --------------------------- | --- | ------------------- | ------------------- | ---------- | ---------------------- |
| Security budget approval    | A   | R                   | C                   | I          | C                      |
| Vulnerability remediation   | I   | R                   | A                   | C          | C                      |
| Incident response execution | I   | A                   | R                   | C          | C                      |
| Security policy approval    | I   | R                   | C                   | A          | C                      |
| Risk acceptance decisions   | I   | R                   | C                   | A          | C                      |
| Security awareness training | I   | R                   | C                   | A          | C                      |
| Vendor risk assessment      | I   | R                   | C                   | C          | A                      |
| Audit coordination          | I   | R                   | C                   | C          | A                      |

# Part 2 – Role Definitions role-definition

Data Owner:
Description: >
The individual or position that has final authority and accountability for a specific data set,
responsible for determining its classification, retention policy and who may access it.
Assigned_To: "Chief Medical Officer (Dr. Patel) – owns all PHI in the Clinical domain."
Rationale: >
As the steward of patient medical information, Dr. Patel has clinical and regulatory
authority over data use and must sign off on any processing that impacts care or privacy.

Data Controller:
Description: >
The entity (organization or sub‑organisation) that determines purposes and means
of processing personal data, establishing policies for access, retention, and deletion.
Assigned_To: "IT Director – Sarah Park."
Rationale: >
Sarah controls the technical platforms (EHR, PACS, billing servers) and decides how data is stored,
transmitted and protected; she enforces the organization‑wide data handling procedures.

Data Processor:
Description: >
Third‑party or internal entities that process personal data on behalf of the controller
following its instructions and only for agreed purposes.
Assigned_To: "MedTech Solutions – EHR maintenance vendor."
Rationale: >
MedTech performs software updates, patches and provides remote access to the EHR platform;
they are bound by a contract and cannot use PHI beyond their service scope.

Data Custodian/Steward:
Description: >
The role that manages day‑to‑day technical stewardship of data assets,
ensuring integrity, availability, and security controls are in place.
Assigned_To: "Security Analyst (You)."
Rationale: >
As the operational guardrail, the analyst applies patches, monitors logs,
validates backup tests and enforces encryption – effectively safeguarding the data that
the controller owns.

# Part 3 – Consequences of a vacant CISO & Recommendation

CISO position is vacant:
Consequences: >
• Lack of clear accountability for security strategy leads to ad‑hoc decisions
• Incident response coordination suffers; escalation paths are unclear.  
• No formal risk‑management framework – budgeting and compliance gaps widen.  
• Audit readiness is impaired, increasing likelihood of non‑compliance penalties.

Recommendation:
MedDefense should hire a full‑time CISO, hiring an in‑house CISO (salary ~$110–$130 k) will be fully funded and provides permanent ownership of policy, governance, audit preparation and incident management.  
A vCISO can complement the role during the transition period but cannot replace the need for a dedicated security officer.
