
Gap Reference: "GAP-001"
description: "No corrective restoration test for the EHR application server."
vulnerability evidence:
  - "FINDING 001 (Apache mod_lua RCE)"
  - "FINDING 002 (privilege escalation on billing server)"
threat context: >-
  State‑sponsored APT or ransomware group → Initial Access →
  Execution → Privilege Escalation → potential data loss or
  compromise of PHI.
NIST CSF Function: Recover
CIS Control: "10 – Data Recovery"
recommended action: >-
  Build and run an automated nightly restore‑validation suite for `ehr‑srv‑01` (and its DB). 

Gap Reference: "GAP-002"
description: "No corrective restoration test for the EHR database."
vulnerability evidence:
  - "FINDING 001 (Apache mod_lua RCE)"
  - "FINDING 002 (privilege escalation on billing server)"
threat context: >-
  Insider or APT with local access → Execution → Privilege Escalation →
  Data Exfiltration → corrupted PHI.
NIST CSF Function: Recover
CIS Control: "10 – Data Recovery"
recommended action: >-
  Execute bi‑weekly full backup restore drills on `ehr‑db‑01` and audit the integrity of recovered data.

Gap Reference: "GAP-003"
description: "No asset‑specific firewall/IDS rules for PACS server."
vulnerability evidence:
  - "FINDING 005 (TLS weak protocols)"
  - "FINDING 012 (missing HTTP security headers)"
  - "FINDING 031 (Ghostcat AJP)"
threat context: >-
  Ransomware or APT exploiting imaging data → Initial Access →
  Execution → Data Theft → misdiagnosis.
NIST CSF Function: Protect
CIS Control: "12 – Network Infrastructure Management"
recommended action: >-
  Add a dedicated PACS segment with host‑based firewall and IDS/IPS rules; block all non‑essential ports.

Gap Reference: "GAP-004"
description: "No application‑level logs for the PACS server."
vulnerability evidence:
  - "FINDING 017 (Tomcat error page disclosure)"
  - "FINDING 031 (Ghostcat AJP)"
threat context: >-
  Insider or APT → Execution → Privilege Escalation →
  Credential Theft → undetected image tampering.
NIST CSF Function: Detect
CIS Control: "3 – Audit Log Management"
recommended action: >-
  Enable comprehensive Tomcat audit logs, forward them to a central SIEM, and enforce log‑retention.

Gap Reference: "GAP-006"
description: "No domain‑controller disaster‑recovery plan."
vulnerability evidence:
  - "FINDING 007 (LDAP signing disabled)"
  - "FINDING 008 (PrintNightmare on Windows 2012 R2)"
threat context: >-
  Insider or APT → Execution → Privilege Escalation →
  Lateral Movement → complete authentication failure.
NIST CSF Function: Recover
CIS Control: "10 – Data Recovery"
recommended action: >-
  Deploy a redundant DC with live replication, document the fail‑over procedure, and test quarterly.

Gap Reference: "GAP-007"
description: "No firmware hardening / device firewall for ICU monitor."
vulnerability evidence:
  - "FINDING 010 (BD Alaris DoS)"
  - "FINDING 011 (missing HTTP security headers on device)"
threat context: >-
  Ransomware or insider → Execution →
  System Compromise → altered vital‑sign readings,
  potential patient harm.
NIST CSF Function: Protect
CIS Control: "11 – Secure Configuration"
recommended action: >-
  Upgrade firmware to the latest version, enable secure boot/firmware signing, and configure a dedicated VLAN + host firewall.

Gap Reference: "GAP-009"
description: "No backup recovery test for NAS & backup server."
vulnerability evidence:
  - "FINDING 015 (DSM open web interface)"
  - "FINDING 018 (Kerberoasting on AD DC)"
threat_context: >-
  Insider or APT → Execution →
  Privilege Escalation → Data Exfiltration →
  loss of all backups.
NIST CSF Function: Recover
CIS Control: "10 – Data Recovery"
recommended action: >-
  Perform quarterly full‑restore tests on NAS and backup server, verify data integrity and file‑system integrity.

Gap Reference: "GAP-010"
description: "No privileged access monitoring on critical servers."
vulnerability evidence:
  - "FINDING 009 (SSH password authentication)"
  - "FINDING 014 (VPN terminator – Netgear router)"
threat context: >-
  Insider or APT → Execution →
  Privilege Escalation → Credential Abuse →
  undetected lateral movement.
NIST CSF Function: Detect
CIS Control: "13 – Account Monitoring and Control"
recommended action: >-
  Implement privileged session recording on EHR & billing servers; enforce MFA for privileged accouns