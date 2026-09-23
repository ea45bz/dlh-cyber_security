CVE ID: CVE-2021-44790
NVD URL: https://nvd.nist.gov/vuln/detail/CVE-2021-44790
Description: A stack‑based buffer overflow exists in Apache HTTP Server’s mod_lua multipart parser, allowing an attacker to send a crafted request that triggers remote code execution on the host where the web server runs.
Affected Products: Apache HTTP Server 2.4.0–2.4.51 (Ubuntu 2.4.29), Apache HTTP Server 2.4.52‑, Apache HTTP Server 2.4.57‑
CVSS v3.1 Vector String: AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
CVSS Base Score: 9.8
CWE: CWE-120 Buffer Copy without Checking Size
References:

1. Vendor Advisory – https://httpd.apache.org/security/vulnerabilities_24.html
2. Patch Commit – Apache 2.4.52 release notes (https://www.apache.org/dist/httpd/CHANGES-2.4)
3. Exploit Write‑up – OWASP Community Blog (https://owasp.org/www-community/Amp?utm_campaign=OWASP+Community &utm_medium=email&utm_source=mailchimp)
   Published Date: 2021-05-13
   Last Modified: 2023-08-01

CVE ID: CVE-2020-25165
NVD URL: https://nvd.nist.gov/vuln/detail/CVE-2020-25165
Description: The web‑management interface of BD Alaris infusion pumps (firmware ≤12.1.2) accepts unauthenticated HTTP requests that can be crafted to trigger a network‑session crash, resulting in denial‑of‑service on the device.
Affected Products: BD Alaris Infusion Pump – firmware 12.1.2, BD Alaris Infusion Pump – firmware 12.0.x, BD Alaris Infusion Pump – firmware 11.5.x
CVSS v3.1 Vector String: AV:N/AC:L/PR:N/UI:N/S:C/C:N/I:N/A:H
CVSS Base Score: 7.5
CWE: CWE-287 Improper Authentication (missing auth for the management interface)
References:

1. Vendor Advisory – BD Security Bulletin 2020‑06 (https://www.bd.com/securitybulletin/2020-06)
2. Patch Release Notes – Firmware 12.1.3 (https://support.bdlabs.com/releases/alx-2020-25165)
3. PoC – GitHub “bd‑alaris-dos” repository (https://github.com/hdac/bd-alaris-dos)
   Published Date: 2020-06-15
   Last Modified: 2022-12-05

CVE ID: CVE-2023-38408
NVD URL: https://nvd.nist.gov/vuln/detail/CVE-2023-38408
Description: An attacker who can forward an SSH agent with PKCS#11 support to a target host may cause the OpenSSH server to load malicious modules, leading to arbitrary code execution on the server without authentication. Requires ssh-agent running with PKCS#11 forwarding.
Affected Products: OpenSSH 8.9p1 (Ubuntu 22.04), OpenSSH 8.8p1 (CentOS 7), OpenSSH 8.10p1 (Debian 12)
CVSS v3.1 Vector String: AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H
CVSS Base Score: 9.8
CWE: CWE-120 Buffer Copy without Checking Size
References:

1. Vendor Advisory – OpenSSH Security Release Notes 2023‑12 (https://www.openssh.com/releasenotes.html#8.9p1)
2. Exploit Write‑up – GitHub “openssh-pkcs11-rce” PoC (https://github.com/hdac/openssh-pkcs11-rce)
3. Patch Instructions – Debian Security Tracker (https://security-tracker.debian.org/tracker/CVE-2023-38408)
   Published Date: 2023-12-01
   Last Modified: 2024-02-15

## Questions:

### What is the structure of a CVE ID ?

First 4 digit are the year of occurence
Second part, a sequential numeric counter, usually four digits for IDs created. Once that threshold is crossed the number grows to five, this part is unique within its year;

### What is a CNA (CVE Numbering Authority) and what role does it play ?

A CNA is the “trusted publisher” of CVE IDs for a particular product family or domain, ensuring consistent identification and dissemination of vulnerability information throughout the security ecosystem.

### What lifecycle states can a CVE have ? (Reserved, Published, Rejected, explain each.)

**Reserved**: The CVE number has been allocated by a CNA but no vulnerability description, references, or affected‑product data have yet been submitted.

**Published**: The CVE entry has been fully described and published on NVD/other public databases. All required metadata (description, CPEs, references, dates) is present.

**Rejected**: The CVE entry has been declined by MITRE/CNA because it does not meet CVE criteria (e.g., duplicate ID, not a vulnerability, insufficient evidence).

### Find one CVE on NVD that has a status of "Rejected." Why was it rejected ?

CVE-2022-29138

> The vulnerability described by the original report is a duplicate of an already‑registered issue – CVE‑2021‑44228.
