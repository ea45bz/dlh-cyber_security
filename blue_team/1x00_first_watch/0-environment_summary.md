# Structured Environment Summary

## 1 Organization Overview

- **Locations & Purpose**

  | Site                                    | Type                   | Function                                                     | Approx. Staff               | Notes                                                                                                        |
  | --------------------------------------- | ---------------------- | ------------------------------------------------------------ | --------------------------- | ------------------------------------------------------------------------------------------------------------ |
  | MedDefense Central Hospital (downtown)  | Acute care facility    | Patient treatment, diagnostics, imaging, pharmacy, lab, etc. | ~1,400 (clinical + support) | 6‑floor building + basement mechanical/server room; underground staff parking                                |
  | Westside Clinic (suburban)              | Outpatient office      | Primary care, imaging (X‑ray/US), labs, minor procedures, PT | ~180                        | 2‑story medical office; shares some IT services with Central but has a local server closet for “basic needs” |
  | Corporate HQ (Greenfield Business Park) | Administrative offices | Finance, HR, Legal, Marketing, Executive leadership, IT      | ~220                        | 3rd floor of a leased commercial building; all staff rely on cloud services and site‑to‑site VPN to Central  |

- **Total Employees** – ≈ 2,000 across the organization.

- **Security‑Relevant Reporting Structure**
  - **CISO Position:** Vacant (acting Deputy CISO James Chen).
  - **James Chen, Deputy CISO** – reports to CEO in practice; manages security policy but not IT ops.
  - **Sarah Park, IT Director** – peers with James; leads 12‑person IT team.
    - System Administrators (3)
    - Network Technicians (2)
    - Database Administrator (1)
    - Helpdesk Analysts (2) – Mike Torres lead
    - Desktop Support Technicians (2)
    - IT Intern (vacant)

## 2 IT Infrastructure Identified

| Location                  | Asset                               | Type/OS                                                                                                         | Function                                                  | Technical Notes                                         |
| ------------------------- | ----------------------------------- | --------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- | ------------------------------------------------------- |
| **Central**               | ehr‑srv‑01                          | Ubuntu 20.04 LTS                                                                                                | EHR application server                                    | -                                                       |
|                           | ehr‑db‑01                           | Ubuntu 20.04 LTS                                                                                                | PostgreSQL database (EHR)                                 | -                                                       |
|                           | pacs‑srv‑01                         | Windows Server 2016                                                                                             | PACS imaging server                                       | -                                                       |
|                           | billing‑srv‑01                      | Ubuntu 18.04 LTS                                                                                                | Billing/claims processing                                 | Performance issues noted; restarted frequently          |
|                           | ad‑dc‑01 / ad‑dc‑02                 | Windows Server 2019                                                                                             | Primary & secondary Domain Controllers                    | -                                                       |
|                           | file‑srv‑01                         | Windows Server 2016                                                                                             | Department file shares                                    | -                                                       |
|                           | print‑srv‑01*                       | Windows Server 2012R2                                                                                           | Print server                                              | *UNVERIFIED – end of support (Oct 2023)                 |
|                           | backup‑srv‑01                       | Ubuntu 22.04 LTS                                                                                                | Backup server (Veeam agent)                               | Veeam nightly backups to local NAS on same rack         |
|                           | web‑srv‑01                          | Ubuntu 20.04 LTS                                                                                                | Public website + patient portal                           | -                                                       |
|                           | network gear                        | Cisco core switch (model unknown) <br> 2x Cisco access switches per floor <br> Fortinet FortiGate 100F firewall | Switching, routing, perimeter protection                  | No VLANs configured; flat 10.10.0.0/16 broadcast domain |
|                           | Wi‑Fi                               | Ubiquiti UniFi APs (12 units)                                                                                   | Internal wireless access                                  | Guest SSID exists but isolation not verified            |
| **Westside**              | ws‑srv‑01                           | Windows Server 2016                                                                                             | Local file server + scheduling                            | -                                                       |
|                           | additional server?                  | _Unknown_                                                                                                       | Potentially another local server (not confirmed)          | –                                                       |
|                           | network gear                        | 1x unmanaged switch <br> 1x Netgear Nighthawk consumer router (with VPN to Central)                             | No firewall; deemed “NOT acceptable” for medical facility |
|                           | Wi‑Fi                               | _Unknown_                                                                                                       | –                                                         |
| **Corporate HQ**          | None on‑prem                        | Cloud services only                                                                                             | AD, O365, etc. connect via site‑to‑site VPN               | Managed by building landlord; MedDefense VLAN exists    |
| **Endpoints (all sites)** | Windows 10/11 workstations          | ~320 (Central) <br> ~45 (Westside) <br> ~120 (HQ)                                                               | Clinical & administrative staff                           | Counts from AD report (8 months old)                    |
|                           | Thin clients                        | ~60 (Central, clinical areas)                                                                                   | -                                                         |
|                           | Laptops                             | ~30 (HQ, remote‑capable)                                                                                        | -                                                         |
|                           | iPads                               | ~25                                                                                                             | Physician tablets; management status unclear              |
| **Medical Devices / IoT** | Philips IntelliVue patient monitors | ~80 (Central)                                                                                                   | Network‑connected monitoring data                         |
|                           | BD Alaris infusion pumps            | ~120 (Central)                                                                                                  | Dosage updates over network                               |
|                           | Siemens MAGNETOM MRI scanner        | 1 (Radiology, Central)                                                                                          | Runs Windows XP                                           |
|                           | GE Revolution CT scanner            | 1 (Central)                                                                                                     | OS unknown                                                |
|                           | Nurse call system                   | IP‑based                                                                                                        | Integrated with phone system                              |
|                           | HID Global badge/access system      | -                                                                                                               | Connected to AD for some doors                            |

- **Backup & Storage** – Veeam backups stored on a local NAS in the same rack as backup‑srv‑01 (risk of ransomware wiping both).

## 3 Data and Services

| Category                                      | What is handled                                                               | Key IT services used                                                             | Primary users                                                  |
| --------------------------------------------- | ----------------------------------------------------------------------------- | -------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| **Patient Health Information (PHI)**          | EHR records, imaging files (PACS), lab results, pharmacy orders, billing data | ehr‑srv‑01 / ehr‑db‑01; pacs‑srv‑01; billing‑srv‑01; web‑srv‑01 (patient portal) | Physicians, nurses, pharmacists, labs, billing staff, patients |
| **Operational & Administrative Data**         | Finance records, HR personnel files, marketing content, legal documents       | file‑srv‑01; AD domain controllers; VPN connections                              | Executive leadership, finance/HR/legal teams                   |
| **Network and Infrastructure Configurations** | Network diagrams, firewall rules, VPN settings                                | FortiGate 100F; Core switches; site‑to‑site VPNs                                 | IT staff (Sarah Park team), security analysts                  |
| **Endpoint Security State**                   | Antivirus signatures, patch levels, MFA status                                | Sophos endpoint protection; Windows AD password policy                           | All workstations and mobile devices                            |

- **Critical services**:
  - EHR application & database – core clinical workflow.
  - PACS imaging – diagnostics.
  - Billing/claims – financial operations.
  - Domain controllers – authentication for all users.
  - Backup service – data protection.
  - Public website / patient portal – external access to health information.

## 4 Known Unknowns

| Gap                                                                                                                                                                     | Why it matters                                                        |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| **Server inventory completeness** – print‑srv‑01 is marked _UNVERIFIED_; existence of a second Westside server unconfirmed.                                             | Potential hidden attack surface; unknown patch status.                |
| **Operating system / patch status for medical devices** – MRI (Windows XP), CT (unknown OS), infusion pumps, monitors.                                                  | Devices may be vulnerable to known exploits.                          |
| **Guest Wi‑Fi isolation** – SSID exists but no confirmation that traffic is isolated from internal network.                                                             | Risk of lateral movement if compromised.                              |
| **MFA coverage** – only James’s personal account has MFA; others rely on password policy alone.                                                                         | Non‑compliant with many security frameworks.                          |
| **Physical security** – server room badge access uses generic badge; no cameras in IT corridor; Westside IT closet not locked.                                          | Vulnerable to insider or opportunistic theft/access.                  |
| **VPN ACLs** – not audited, especially for HQ and Westside connections.                                                                                                 | Possible over‑permissive rules exposing internal resources.           |
| **Endpoint counts & health** – last AD report 8 months old; Sophos update status unknown on all machines.                                                               | Inaccurate risk assessment of endpoint exposure.                      |
| **Cloud service inventory** – O365 is known, but departments may use other SaaS solutions (e.g., SharePoint, Teams, non‑Microsoft services).                            | Untracked data flows could violate compliance requirements.           |
| **Compliance evidence** – no formal HIPAA Security Rule assessment, incident response plan, business continuity/disaster recovery plan, or documented risk assessments. | Cannot prove regulatory compliance; high legal exposure.              |
| **Network segmentation / VLANs** – flat 10.10.0.0/16 broadcast domain with no VLANs.                                                                                    | Single point of failure for critical services; lateral movement risk. |
| **Backup strategy** – no off‑site or cloud backup; Veeam backups stored locally next to source data.                                                                    | Single point of failure in ransomware scenario.                       |
| **Firmware / patch status of network gear** – Cisco switches, FortiGate, Ubiquiti APs, Netgear router, consumer-grade equipment.                                        | Potential unpatched vulnerabilities on perimeter devices.             |
| **Firewall configuration details** – rulesets, IDS/IPS settings not provided.                                                                                           | Uncertain threat detection capability.                                |
| **Shared accounts** – radiology PACS shared login (“raduser / radiology1”) remains unresolved.                                                                          | Brute‑force and privilege escalation risk.                            |
| **Endpoint device management** – iPads used by physicians; unclear if MDM, OS patching, or antivirus applied.                                                           | Potential unpatched mobile devices exposing PHI.                      |

---

### Takeaway

The package gives a broad picture of MedDefense’s physical sites, core IT assets, and the security‑relevant reporting structure. However, several critical gaps—especially around network segmentation, device patch status, MFA coverage, backup strategy, and formal compliance documentation—must be addressed to form a complete risk assessment and to demonstrate HIPAA/IT governance readiness.
