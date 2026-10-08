# The 72-Hour Plan Emergency Response Plan

```yaml
Tier 1 Tonight(0‑12h):
  - Action: "Disable the FortiGate SSL‑VPN service (or block port 443/port 10443) until patch is applied."
    Phase Blocked: "Phase 1 – Initial Access"
    Owner: "Sarah Park (IT Director)"
    Prerequisites:
      - Verify that no critical remote users depend on SSL‑VPN (temporary outage will affect staff at Westside and Corporate HQ).
      - Confirm a backup of the current FortiGate config exists.
    Risk of Action:
      - Disruption to all remote employees; possible loss of critical patient data access during the outage.
    Risk of Inaction:
      - Attackers can immediately exploit CVE‑2023‑27997, gain full control over the firewall and launch further lateral movement (Phase 2–3).

  - Action: "Physically disconnect NAS‑01 from the internal network."
    Phase Blocked: "Phase 5 – Backup Destruction"
    Owner: "Sarah Park + 2 IT staff"
    Prerequisites:
      - Identify the physical cabling/patch panel for NAS‑01.
      - Ensure that backup jobs are paused or redirected to a temporary storage location.
    Risk of Action:
      - Loss of backup availability for the next few hours; risk of data loss if a production system crashes during the outage.
    Risk of Inaction:
      - Attackers can delete or corrupt all backups before the ransomware is deployed (Phase 5).

  - Action: "Enable and review FortiGate logs, forward them to a centralized syslog server."
    Phase Blocked: "Phases 1‑3 – Early Detection"
    Owner: "You (Security Analyst)"
    Prerequisites:
      - Configure remote log forwarding in the FortiGate.
      - Verify that the syslog collector is reachable and has sufficient storage.
    Risk of Action:
      - Minimal operational impact; may temporarily increase CPU load on the FortiGate.
    Risk of Inaction:
      - No early warning of attacker activity, delaying containment.

Tier 2 Tomorrow(12‑36h):
  - Action: "Renew the FortiGate support contract ($2400) and download the latest firmware (7.4.x or newer)."
    Phase Blocked: "Phase 1 – Initial Access"
    Owner: "James Chen (Deputy CISO – Budget approval)"
    Prerequisites:
      - Board sign‑off on $2400 expense at tomorrow’s meeting.
      - Confirmation that the current firmware version is 7.0.x or 7.2.x.
    Risk of Action:
      - Short maintenance window may require reboot of the FortiGate, briefly cutting all VPN traffic.
    Risk of Inaction:
      - The CVE remains exploitable; attackers can continue to use it for initial access and lateral movement.

  - Action: "Change AD Kerberos policy to enforce AES‑256 only (disable RC4) in a short 30 min maintenance window."
    Phase Blocked: "Phase 3 – Lateral Movement"
    Owner: "Sarah Park (Domain Admins) with oversight from James"
    Prerequisites:
      - Identify all client OS versions; ensure they support AES‑256.
      - Document potential authentication failures in a test environment.
    Risk of Action:
      - Some legacy workstations or applications may fail to authenticate, causing service interruptions.
    Risk of Inaction:
      - Attackers can harvest cached credentials and perform Kerberoasting (Phase 3).

  - Action: "Configure MFA for all VPN users and critical administrative accounts."
    Phase Blocked: "Phases 1‑6 – Access Control"
    Owner: "James Chen (CISO) – procurement of MFA solution if needed"
    Prerequisites:
      - Verify that the existing VPN solution supports MFA or plan to upgrade the authentication provider.
      - Ensure backup authentication methods are in place for emergency access.
    Risk of Action:
      - Possible temporary loss of remote admin access until MFA is provisioned; may delay response.
    Risk of Inaction:
      - Attackers can use stolen credentials with no additional friction (Phase 3 & 6).

  - Action: "Implement temporary firewall rule to block outbound connections from the FortiGate to known malicious IP ranges (e.g., 185.220.101.xxx, mega.nz)."
    Phase Blocked: "Phases 4‑5 – Data Exfiltration / Backup Destruction"
    Owner: "You (Security Analyst)"
    Prerequisites:
      - Obtain current threat intel feed; ensure rule does not block legitimate outbound traffic.
    Risk of Action:
      - May inadvertently block legitimate data synchronization services if IPs overlap.
    Risk of Inaction:
      - Attackers can exfiltrate data and delete backups before containment.

Tier 3 This Week(36‑72h):
  - Action: "Begin network segmentation project – configure new VLANs for servers, workstations, medical devices, and backup storage."
    Phase_Blocked: "Phase 3 – Lateral Movement"
    Owner: "Sarah Park (Network Team) + External vendor (Switch Config)"
    Prerequisites:
      - Schedule a 2‑3 day maintenance window.
      - Draft new VLAN topology; coordinate with application owners to avoid breaking services.
    Risk of Action:
      - Misconfigured VLANs could isolate critical services or cause downtime during re‑boot of switches.
    Risk of Inaction:
      - Flat network remains; attackers can move freely between assets (Phase 3).

  - Action: "Install and configure an Endpoint Detection & Response (EDR) solution on all servers and workstations."
    Phase Blocked: "Phases 6‑7 – Ransomware Deployment & Extortion"
    Owner: "You (Security Analyst) – vendor procurement"
    Prerequisites:
      - Procure licensing; test deployment in a lab.
      - Define alerting thresholds for unusual outbound traffic and privilege escalation attempts.
    Risk of Action:
      - Deployment may temporarily reduce system performance; some services might need to be restarted.
    Risk of Inaction:
      - Attackers can execute ransomware payloads undetected (Phase 6) and rely on unmonitored exfiltration channels.

  - Action: "Fully update all FortiGate firmware after contract renewal, conduct full regression testing."
    Phase Blocked: "Phase 1 – Initial Access"
    Owner: "Sarah Park + James Chen (oversee)"
    Prerequisites:
      - Completed Tier 2 patch download and backup.
      - Schedule 4‑6 h maintenance window during low activity.
    Risk of Action:
      - Firmware upgrade may fail, potentially leaving the device in an inconsistent state; could temporarily disable VPN.
    Risk of Inaction:
      - Vulnerability remains exploitable until patched.

  - Action: "Review and harden all privileged account usage – restrict or remove unused service accounts."
    Phase Blocked: "Phases 3 & 6"
    Owner: "James Chen (Security Team)"
    Prerequisites:
      - Generate inventory of service accounts; assess necessity.
      - Coordinate with application owners to re‑authenticate services if needed.
    Risk of Action:
      - Removing or disabling an account may break a critical business process.
    Risk of Inaction:
      - Attackers can abuse over‑privileged accounts for lateral movement and persistence.
```

## Resource Conflict Assessment

### Conflicts

- "Sarah Park is required for both disabling the FortiGate VPN (Tier 1) and configuring AD Kerberos changes (Tier 2)."
- "The same FortiGate device requires a maintenance window for both disabling SSL‑VPN and later applying firmware updates."
- "You must enable log forwarding, install EDR, and monitor logs simultaneously in Tier 3."

### Resolutions

1. Stagger Tasks on the FortiGate:  
   Disable the VPN first (Tier 1) without rebooting; keep the device online.  
   Schedule the firmware upgrade later in the day after the AD Kerberos change, allowing Sarah to attend both tasks sequentially within a single maintenance window.
2. Leverage IT Staff for Dual Roles:  
   The two IT staff available tonight can handle the physical disconnection of NAS‑01 while Sarah focuses on disabling VPN; this frees Sarah to later perform Kerberos configuration with James’s oversight.
3. Use Temporary Remote Access:  
   Enable remote management via SSH (pre‑configured) so that AD changes and EDR deployment can be done without physically visiting the server room, reducing the risk of overlapping resource needs.

Overall, by scheduling the FortiGate downtime in a single window after the initial disabling of SSL‑VPN and before the full firmware update, and by delegating the NAS disconnection to on‑site IT staff, no critical tasks will compete for the same person or system simultaneously. The plan maintains minimal disruption while delivering maximum risk reduction within 72 hours.
