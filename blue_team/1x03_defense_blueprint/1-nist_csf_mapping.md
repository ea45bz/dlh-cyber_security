Function: Govern
Current Level: Partial
Evidence:
CISO position vacant; James Chen is acting Deputy CISO (1x00 environment summary).
"No formal security policy or risk‑management process documented (Marcus notes in 1x02).
No governance charter or defined ownership for cybersecurity functions.
Key Gaps: Absence of a comprehensive governance framework and documented risk‑management program.
Target Level: Managed

Fuction: Identify
Current Level: Partial
Evidence:
Network scan summary (1x00) shows flat network, no segmentation, unknown host 10.10.2.99 not in inventory.
Asset registry (7-asset_registry.md) missing several critical devices; no formal risk assessment performed (1x02).
No documented list of data classification or business impact for assets.
Key Gaps: Incomplete asset discovery and lack of a structured risk‑assessment process.
Target Level: Managed

Fuction: Protect
Current Level: Managed
Evidence:
Firewall deny‑all rule and key‑only SSH configuration (1x00 artifacts).
Password complexity, rotation, lockout policy in place (Artifact 3).
Weekly backup schedule and nightly full backup job exist (Artifact 5).
Endpoint antivirus coverage for ~387 workstations (Artifact 4), but no server‑side protection or patch management.
Key Gaps: Missing technical safeguards on critical servers (patching, server‑level anti‑virus) and inconsistent application of policies.
Target Level: Managed

Function: Detect
Current Level: Not Implemented
Evidence:
Log management summary (1x00) states no centralization; firewall logs not forwarded (Artifact 1).
No IDS/IPS, SIEM, or automated alerting in place (1x02).
Findings from vulnerability scan show no detection controls.
Key Gaps: Complete absence of any detective capability.
Target Level: Managed

Function: Respond
Current Level: Not Implemented
Evidence:
Marcus notes that no incident‑response plan exists (1x00 artifact 6).
No documented IR playbooks, ownership, or testing procedures.
Key Gaps: Lack of an established incident‑response strategy and execution capability.
Target Level: Managed

Function: Recover
Current Level: Partial
Evidence:
Backup schedule exists but last full restore test performed 8 months ago and took 6 hours (Artifact 5).
No off‑site or cloud backup; recovery testing is limited to file‑srv‑01 only (1x00).
NAS backup server resides on the same rack and network as source data.
Key Gaps: Insufficient recovery validation and lack of off‑site replication.
Target Level: Managed
