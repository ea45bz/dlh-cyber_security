## What is the purpose of CVE (Common Vulnerabilities and Exposures) in cybersecurity?

A publicly‑maintained identifier assigned to every known software or hardware vulnerability, providing a _single, unambiguous reference_ that everyone—vendors, researchers, security tools, auditors—can use when talking about the same flaw.

## How does it contribute to vulnerability management and information sharing?

| Activity                             | How CVE Helps                                                                                                                                     |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Asset Inventory & Patch Tracking** | Scan results report `CVE‑xxxx`, letting you map findings directly to the affected component and its patch status.                                 |
| **Risk Prioritization**              | CVSS scores in the CVE record give a quick severity metric; combined with business impact, you can rank which fixes are urgent.                   |
| **Automated Workflows**              | CI/CD pipelines or patch‑management platforms ingest CVE IDs to trigger alerts, ticket creation, or deployment of security updates automatically. |
| **Metrics & Reporting**              | MTTR (Mean Time To Remediate) and coverage dashboards often aggregate “CVE counts” to show progress over time.                                    |
