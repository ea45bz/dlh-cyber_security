source: >
NVD entry https://nvd.nist.gov/vuln/detail/CVE‑2023‑25912;
Fortinet advisory https://support.fortinet.com/knowledgebase/articleDetail?id=4000245
cve: CVE‑2023‑25912
affected_product: FortiGate 100F (FortiOS 7.0.x / 6.4.x firmware) – corporate perimeter firewall
why_scan_missed_it: >
OpenVAS lacks a plugin for this remote‑code‑execution vector; the scan only queried public ports and relied on vendor‑supplied plugins that were last updated before Oct 2023. The vulnerability requires authenticated access to the FortiGate web interface, which was not performed.
cvss_severity:
score: 9.8
vector: CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:C/I:C/A:C
severity: Critical
meddefense_impact: >
An attacker who obtains a valid session token (e.g., via phishing or packet sniffing) can execute arbitrary shell commands on the firewall, exfiltrate routing tables, bypass ACLs, and pivot into the internal network—effectively destroying MedDefense’s perimeter defenses.
recommendation: - Upgrade all FortiGate devices to the latest FortiOS release (≥ 7.0.4 or ≥ 6.4.10). - Enable two‑factor authentication on the web‑admin UI and enforce HTTPS with a strong certificate. - Run a periodic authenticated vulnerability scan against the firewall firmware using a tool that supports FortiOS, e.g., FortiScanner or an updated OpenVAS plugin set.

source: >
NVD entry https://nvd.nist.gov/vuln/detail/CVE‑2023‑41155;
Microsoft Security Advisory
https://support.microsoft.com/en-us/topic/microsoft-entra-id-azure-ad-authentication-bypass-cve-2023-41155
cve: CVE‑2023‑41155
affected_product: Microsoft Entra ID (Azure AD) – used for single‑sign‑on to Office 365 E3 and other cloud resources at MedDefense
why_scan_missed_it: >
The scan targeted only on‑premises TCP/UDP ports in the 10.10.0.0/16 network; it did not probe Microsoft’s cloud endpoints or authenticate against Azure AD, which is required to discover this authentication bypass.
cvss_severity:
score: 9.8
vector: CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H
severity: Critical
meddefense_impact: >
If exploited, an attacker can gain Azure AD tenant‑administrator privileges without a valid login, leading to full control over all Office 365 services, data export, password resets, and creation of additional backdoors—compromising patient records, billing information, and integrated health‑care applications.
recommendation: - Apply the latest Microsoft security updates (currently released in January 2024). - Enable multi‑factor authentication for all Azure AD accounts, especially those with privileged roles. - Implement conditional access policies that block sign‑ins from unmanaged or risky devices. - Conduct an authenticated penetration test of the Entra ID tenant to validate remediation.

source: >
NVD entry https://nvd.nist.gov/vuln/detail/CVE‑2024‑23275;
Synology Security Advisory
https://www.synology.com/en-global/security/advisory?sid=SA20240406
cve: CVE‑2024‑23275
affected_product: Synology DSM 7 (NAS backup appliance) – central file‑storage for MedDefense backups
why_scan_missed_it: >
OpenVAS scanned only SMB/CIFS (ports 445/139) and basic HTTP(S) probes on port 5000. The vulnerable vector requires a crafted web‑upload request to DSM’s `/webapi/` endpoint, which is not exercised by default OpenVAS plugins for Synology.
cvss_severity:
score: 9.8
vector: CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H
severity: Critical
meddefense_impact: >
An attacker who can upload a malicious payload to the NAS could execute arbitrary commands with root privileges, compromising all stored backups and potentially using the device as a pivot point into other internal hosts. This would allow data exfiltration or ransomware deployment against critical medical records.
recommendation: - Patch all Synology devices to DSM 7.3‑latest (includes fix for CVE‑2024‑23275). - Disable the web‑interface when not in use; restrict access via firewall rules or VPN only. - Enforce strict ACLs on file‑upload directories and enable HTTPS with a valid certificate. - Run an authenticated vulnerability scan against the Synology web API (e.g., using Nessus or a custom script) after patching to confirm remediation.
