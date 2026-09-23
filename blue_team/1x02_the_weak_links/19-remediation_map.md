```yaml
remediation:
  - finding_id: FINDING 001 # Apache HTTP Server mod_lua Buffer Overflow (CVE‑2021‑44790)
    response_type: Patch
    patch_source: https://httpd.apache.org/security/vulnerabilities_24.html#CVE-2021-44790
    prerequisites:
      - Take a full backup of /etc/apache2 and the website directory.
      - Deploy the updated Apache 2.4.52 (or later) in a staging VM that mirrors billing‑srv‑01.
      - Verify that the billing application (mod_wsgi, PHP, etc.) starts without errors after restart.
      - Schedule maintenance during the nightly window (02:00–04:00) when fewer clinicians use the portal.
    rollback_plan:
      - Restore httpd.conf and modules from backup.
      - Re‑install previous Apache binary via package manager.
      - Restart the service and confirm that traffic resumes with old binaries.
    operational_risk:
      - Short outage (~30 min) while Apache restarts; possible loss of in‑flight billing transactions.
      - Custom mod_lua scripts may need re‑verification against new binary.
    timeline: 7 days
    owner: IT – Infrastructure & Security
    cost_estimate: $0–$1K (software already included in OS)

  - finding_id: FINDING 002 # Privilege Escalation on billing server (CVE‑2019‑0211)
    response_type: Patch
    patch_source: https://httpd.apache.org/security/vulnerabilities_24.html#CVE-2019-0211
    prerequisites:
      - Back up current Apache configuration and document mod_wsgi module status.
      - Test upgrade to Apache 2.4.39 (or later) in a sandbox that runs the billing application stack.
      - Confirm no breakage of mod_lua interactions or custom security modules.
      - Plan restart during low‑usage hours identified by usage telemetry.
    rollback_plan:
      - Re‑install previous Apache binary and restore configuration files from backup.
      - Verify service status; if upgrade fails, revert to old binaries immediately.
    operational_risk:
      - Potential service disruption while restarting the web server (~15 min).
      - If custom security policies rely on older module behavior, a regression could expose additional attack surface.
    timeline: 7 days
    owner: IT – Application Support & Security
    cost_estimate: $0–$1K

  - finding_id: FINDING 003 # PostgreSQL unrestricted network access (misconfiguration)
    response_type: Configuration Change
    change_description:
      - Edit /etc/postgresql/12/main/pg_hba.conf to allow connections only from the billing server IP (10.10.2.15) or a dedicated ACL.
      - Add a firewall rule on the database host that drops inbound traffic to port 5432 except for the allowed IP(s).
    impact_assessment:
      - Billing application will remain functional; only internal hosts with DB credentials can connect.
      - End‑users accessing the portal are unaffected.
    prerequisites:
      - Take current pg_hba.conf and firewall rule set as backup.
      - Verify that the billing server’s database connection string uses the new host/port configuration in a test environment.
    rollback_plan:
      - Restore original pg_hba.conf file and re‑enable inbound port 5432 for all internal hosts.
    operational_risk:
      - If the change is mis‑typed, the billing application may lose connectivity to the database.
      - Possible brief downtime of billing during service reload (~1–2 min).
    timeline: 7 days
    owner: IT – Database & Security
    cost_estimate: $0–$1K

  - finding_id: FINDING 004 # Windows XP MRI workstation (EternalBlue, BlueKeep, MS08‑067)
    response_type: Exception / Replacement
    justification:
      • Windows XP is end‑of‑life and cannot receive security updates for these CVEs.
      • The MRI workstation runs critical imaging equipment that must remain online during clinical shifts; patching would require an OS reinstall with a long validation cycle, risking downtime of imaging services.
    review_date: 2026-06-30
    monitoring:
      - Continuous network scans to confirm no SMBv1 or RDP traffic from the MRI host.
      - Monitor for any unusual outbound connections from the workstation.
    remediation_plan (alternative):
      • Migrate the imaging application to a newer Windows 10/11 workstation that is supported and can receive regular patches.
      • Immediately disable SMBv1 on the XP machine via registry key and close RDP port (3389) using local firewall rules; schedule removal of the device from the network if replacement not feasible.
    operational_risk:
      - Short‑term downtime during OS upgrade or migration (~4 hrs).
      - Potential clinical impact if imaging software fails to start on new hardware.
    timeline: 30 days
    owner: Clinical IT & Radiology
    cost_estimate: $10–$50K (hardware replacement, licensing)

  - finding_id: FINDING 007 # LDAP signing disabled & SMBv1 on AD DC
    response_type: Patch / Configuration Change
    patch_source:
      - Enable LDAP signing via GPO: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/domain-security-group-policy-settings#enforce-ldap-signing
      - Disable SMBv1 using PowerShell (Set-SmbServerConfiguration –EnableSMB1Protocol $false) and apply the Windows 2008 R2 SP3 cumulative update: https://support.microsoft.com/en-us/topic/update-to-fix-buggy-smbv1-support-in-windows-2008r2-7e58b5d2‑a0c4‑b6f9‑9bd6‑a6e3fa0c
    prerequisites:
      - Deploy GPO changes in a test OU and confirm that authentication continues to work for existing users.
      - Verify no services on DC require SMBv1 (e.g., legacy file shares).
      - Backup current AD domain state (system state backup) before disabling SMBv1.
    rollback_plan:
      - Re‑enable LDAP signing flag via GPO if authentication breaks.
      - Re‑enable SMBv1 and restore previous registry key if service failover occurs.
    operational_risk:
      • A brief authentication outage could affect logon for domain users during the change window (~10 min).
      • Some legacy applications may lose access to shared resources if SMBv1 is disabled; verify in staging first.
    timeline: 7 days
    owner: IT – Security & Domain Admins
    cost_estimate: $0–$1K

  - finding_id: FINDING 008 # PrintNightmare on Windows Server 2012 R2 (Print Spooler RCE)
    response_type: Patch
    patch_source:
      - Microsoft Security Update KB5006955 for Windows 8.1/Server 2012 R2: https://support.microsoft.com/kb/5006955
      - Additional cumulative update for 2012 R2 SP3 (KB4474414) to ensure complete coverage.
    prerequisites:
      - Backup the print server's configuration and spool directory.
      - Test installation of updates in a non‑production replica; verify that printers remain functional.
      - Schedule patch deployment during the overnight maintenance window (00:00–02:00).
    rollback_plan:
      - Restore print settings from backup if printers stop responding after update.
      - If critical services fail, roll back to previous OS image via VSS or imaging tool.
    operational_risk: • Print jobs in queue may be lost during restart (~5 min).
      • Users experiencing printing issues for a brief period; coordinate with clinical staff.
    timeline: 7 days
    owner: IT – Print Services & Security
    cost_estimate: $0–$1K

  - finding_id: FINDING 010 # BD Alaris infusion pump DoS (CVE‑2020‑25165)
    response_type: Patch / Compensating Control
    patch_source: https://support.bdlabs.com/releases/alx-2020-25165
    prerequisites:
      - Inventory all Alaris pumps and verify current firmware version.
      - Acquire latest firmware (12.2.3 or later) from BD support; test on a spare pump in a lab environment.
      - Backup existing configuration files via the device web interface or CLI.
      - Plan firmware upgrade during a scheduled maintenance window when patient flow is minimal.
    rollback_plan:
      - Re‑install previous firmware using backup configuration if upgrade fails.
      - If a newer firmware causes instability, revert to 12.1.2 and report back to BD for assistance.
    operational_risk:
      • Upgrading may temporarily suspend drug delivery; must coordinate with pharmacy/clinical staff to ensure backup infusion plan.
      • Firmware update requires device reboot; potential downtime of ~10 min per pump.
    timeline: 30 days
    owner: Clinical IT – Pharmacy & Device Management
    cost_estimate: $1–$10K (firmware licensing, support contract)

  - finding_id: FINDING 014 # Consumer‑grade Netgear router VPN terminator (Westside Clinic)
    response_type: Replacement / Configuration Change
    patch_source:
      - Replace the device with a business‑class firewall/router that supports centralized logging and proper ACLs.
      - If replacement is not immediately possible, enforce strict firmware updates: https://kb.netgear.com/… (link to Netgear's latest router firmware).
      - Configure ACL to allow VPN traffic only from authorized IP ranges and block all other inbound connections.
    prerequisites:
      - Document current routing table and VPN configuration for migration.
      - Test new device in a lab with the same VPN server and confirm connectivity.
      - Backup router config before making changes.
    rollback_plan:
      - Restore original Netgear configuration if new device fails to provide required performance.
      - Re‑enable all routes on the legacy device while troubleshooting.
    operational_risk:
      • Short outage (~15 min) during switch over, potentially affecting remote site connectivity.
      • VPN clients may experience reauthentication; plan user communication.
    timeline: 30 days
    owner: IT – Network & Security
    cost_estimate: $5–$10K (hardware purchase, support)
```
