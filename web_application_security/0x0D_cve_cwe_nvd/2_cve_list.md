## Explain the process of assigning CVE IDs to vulnerabilities.

### How a Vulnerability Gets a **CVE** Identifier

| Step                                | What Happens                                                                                                                                   | Who’s Involved                                 |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| **1️⃣ Discovery**                    | A researcher, vendor, or user finds an exploitable weakness in software/hardware.                                                              | Security researchers / product teams           |
| **2️⃣ CVE Request (or “Reporting”)** | The discoverer submits the details to a _CVE Numbering Authority_ (CNA) with a request for a new ID.                                           | Discoverer + CNA (often a vendor or CERT team) |
| **3️⃣ Verification & Validation**    | The CNA checks: is it a real vulnerability? Does it meet the CVE criteria (publicly known, potentially exploitable, distinct from other CVEs)? | CNA’s vetting process                          |
| **4️⃣ ID Assignment**                | If approved, the CNA assigns a unique identifier `CVE‑YYYY‑NNNN` and creates the record.                                                       | CNA                                            |
| **5️⃣ Publication & Distribution**   | The CVE record is posted to the MITRE NVD (National Vulnerability Database) and pushed out via feeds (JSON, XML).                              | MITRE/NVD + CNAs                               |
| **6️⃣ Follow‑up**                    | Vendor issues patches/advisories; researchers may publish proof‑of‑concepts. The CVE remains in the public registry forever.                   | Vendor / researcher                            |

## Who manages the CVE List, and what role do CVE Numbering Authorities (CNAs) play in this process?

MITRE Corporation owns and operates the _CVE Registry_ (the official source of all CVE IDs).

**CVE Numbering Authorities (CNAs)**

- **Definition**: Authorized entities (typically vendors, CERTs, or large organizations) that can create CVE IDs for vulnerabilities in products they own or support.
- **Role**:
  - Serve as the _first point of contact_ for new vulnerability reports.
  - Vet the vulnerability against the CVE criteria and assign a unique ID.
  - Supply the initial record to MITRE, which then makes it publicly available.
- **Examples**: Microsoft (CVE‑Microsoft), Red Hat, Cisco, OpenSSL project, US-CERT, many Linux distributions.
