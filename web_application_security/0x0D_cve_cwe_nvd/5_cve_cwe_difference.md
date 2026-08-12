## What is CWE, and how does it differ from CVE?

CWE is a _classification system_ for software/hardware weaknesses – the “root cause” of a flaw. Each CWE is an **abstract weakness type** such as _“SQL Injection”_, _“Buffer Overflow”_, _“Improper Input Validation”_.

| Feature                  | CWE                                                                           | CVE                                                                                                      |
| ------------------------ | ----------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| **Purpose**              | Catalogs _weakness patterns_ that can lead to exploitable vulnerabilities.    | Catalogs _exploitable vulnerability instances_.                                                          |
| **Granularity**          | Abstract; e.g., “Cross‑Site Scripting (XSS)”.                                 | Concrete; e.g., “CVE‑2024‑12345 – XSS in ExampleCMS 5.3”.                                                |
| **Scope**                | Covers code, configuration, hardware, and even process weaknesses.            | Focused on publicly known exploits that can be mitigated with a patch or configuration change.           |
| **Assignment Authority** | Managed by MITRE; no single “issuer” – any CWE can be added by the community. | Issued by CVE Numbering Authorities (CNAs) such as vendors, CERTs, and Microsoft; vetted before release. |
| **Use in Tools**         | Used for static‑analysis rules, code‑review checklists, and threat‑modeling.  | Used by scanners, patch‑management systems, compliance reports, and threat‑intelligence feeds.           |

## Why Both Are Important

| Role of CWE                         | What It Enables                                                                                                        |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| Defines the **“why”** a flaw exists | Developers can design secure code patterns; static analysers flag _CWE‑79_ (XSS) before an exploit is ever discovered. |
| Helps in **threat modeling**        | Security architects map business assets to CWE classes to estimate potential attack surface.                           |

| Role of CVE                                                   | What It Enables                                                                                                              |
| ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Provides a **single reference point** for every known exploit | Vulnerability scanners return `CVE‑2024‑12345`, you can instantly pull patch notes, severity scores, and vendor advisories.  |
| Drives **patch management & compliance**                      | Auditors require evidence that all “critical” CVEs have been remediated within a given SLA.                                  |
| Enables **incident response**                                 | A security team can quickly see if an observed exploit matches a known CVE and look up the official fix or mitigation steps. |
