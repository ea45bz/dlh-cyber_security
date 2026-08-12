## The Three Pillars of Vulnerability Management

| Term                                           | What It Is                                                                             | Who Provides It                                                    | Key Output                                                                |
| ---------------------------------------------- | -------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------- |
| **CWE (Common Weakness Enumeration)**          | A taxonomy of _software weakness patterns_ (e.g., “SQL Injection”, “Buffer Overflow”). | MITRE (maintains the public list).                                 | Abstract weakness IDs.                                                    |
| **CVE (Common Vulnerabilities and Exposures)** | Unique identifiers for every publicly disclosed vulnerability instance.                | CVE Numbering Authorities (CNAs: vendors, CERTs, Microsoft, etc.). | Concrete vulnerability records (affected product + version + patch).      |
| **CVSS (Common Vulnerability Scoring System)** | A mathematical formula that assigns a _numeric severity_ to a vulnerability.           | MITRE (specifies the algorithm).                                   | Base score (0–10) and vectors (Attack Vector, Privileges Required, etc.). |

---

## How They Connect

```
CWE  →  CVE  →  CVSS
  (weakness)   (instance)      (severity)
```

- **CWE** tells _what kind of weakness_ you’re dealing with.
- **CVE** gives you the _specific vulnerability instance_ (product, version).
- **CVSS** quantifies how severe that instance is.

Using them together turns raw scan data into a structured, risk‑centric workflow: from detection → scoring → context → prioritization → remediation → verification. This synergy dramatically improves the speed and accuracy of an organization’s vulnerability management program.
