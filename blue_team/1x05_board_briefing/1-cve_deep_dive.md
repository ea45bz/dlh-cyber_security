# Part 1 - NVD Research

```yaml
CVE_2023_27997:
  Full Description: >
    A heap‑based buffer overflow exists in the FortiOS SSL‑VPN pre‑authentication
    processing code (remote “/remote/logincheck” handler).  
    An attacker sends a crafted HTTP request to the SSL‑VPN portal, causing
    stack corruption and remote code execution on the FortiGate appliance itself,
    prior to any authentication.  The vulnerability is present in all FortiOS
    releases 7.0.x (7.0.0‑7.0.11), 7.2.x (7.2.0‑7.2.4) and earlier 6.4.x
    firmware versions.
  CVSS v3.1:
    Vector: "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H"
    Base Score: 9.8
    Severity: Critical
  CWE: "CWE‑122 – Heap‑Based Buffer Overflow"
  Affected Products and Versions:
    - Fortinet FortiGate, FortiOS 7.2.0 – 7.2.4
    - Fortinet FortiGate, FortiOS 7.0.0 – 7.0.11
    - (Older FortiOS 6.4.x releases are also affected but less relevant to MedDefense)
  References:
    - Vendor Advisory: https://support.fortinet.com/knowledgebase/articleDetail?id=4000245
    - Patch Security Notice: https://support.fortinet.com/securitybulletins/FortiOS/2023-06.html
    - CVE Details Page: https://nvd.nist.gov/vuln/detail/CVE‑2023‑27997
```

# Part 2 - Exploit Assessment

Is there a public exploit ?
True

Is this CVE in the CISA KEV catalog ?
Listed in CISA KEV – advisory explicitly states CVE‑2023‑27997 is listed

What is your Exploitability Score?
5 # Active exploitation observed; PoC exists and the attack is widely deployed against hospitals.

# Part 3 - MedDefense CVSS Contextualization

Adjusted Base Score:
Score: 9.8
Description: >
Because the environment does not provide any reduction to the impact or exploitability
metrics (the FortiGate is singular and cannot be patched immediately), the
environmental CVSS reduces to the same as the base score.  
Thus the adjusted score remains 9.8– Critical.

Is_Adjusted_Score_Higher_than_Base?
False # The environmental assessment yields an identical score (critical).
