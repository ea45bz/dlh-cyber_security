# Structured Environment Summary

## 1 Organization Overview

**Sites**

| Site                                    | Type                   | Function                                                     | Headcount |
| --------------------------------------- | ---------------------- | ------------------------------------------------------------ | --------- |
| MedDefense Central Hospital (downtown)  | Acute care facility    | Patient treatment, diagnostics, imaging, pharmacy, lab, etc. | ~1,400    |
| Westside Clinic (suburban)              | Outpatient office      | Primary care, imaging (X‑ray/US), labs, minor procedures, PT | ~180      |
| Corporate HQ (Greenfield Business Park) | Administrative offices | Finance, HR, Legal, Marketing, Executive leadership, IT      | ~220      |

**Departments**

- Emergency
- Surgery
- Cardiology
- Radiology
- Oncology
- Pediatrics
- Maternity
- Pharmacy
- Laboratory
- Administration
- Finance
- HR
- Legal
- Marketing
- Executive Leadership
- IT

**Security‑Relevant Reporting Structure**

- CISO Position: Vacant (acting Deputy CISO James Chen).
- James Chen, Deputy CISO – reports to CEO in practice; manages security policy but not IT ops.
- Sarah Park, IT Director – peers with James; leads 12‑person IT team.
  - System Administrators (3)
  - Network Technicians (2)
  - Database Administrator (1)
  - Helpdesk Analysts (2) – Mike Torres lead
  - Desktop Support Technicians (2)
  - IT Intern (vacant)

## 2 IT Infrastructure Identified

Central:

- ehr-srv-01, Central,Ubuntu 20.04 LTS, EHR application server
- ehr-db-01, Central, Ubuntu 20.04 LTS, PostgreSQL database (EHR)
- pacs-srv-01, Central, Windows Server 2016, PACS imaging server
- billing-srv-01, Central, Ubuntu 18.04 LTS, Billing/claims processing, Performance issues noted; restarted frequently
- ad-dc-01 / ad-dc-02, Central,Windows Server 2019, Primary & secondary Domain Controllers
- file-srv-01, Central, Windows Server 2016, Department file shares
- print-srv-01*, Central, Windows Server 2012R2, Print server, "*UNVERIFIED – end of support (Oct 2023)"
- backup-srv-01, Ubuntu 22.04 LTS, Backup server (Veeam agent), "Veeam nightly backups to local NAS on same rack"
- web-srv-01, Central, Ubuntu 20.04 LTS, Public website + patient portal
- network gear, Central, Cisco core switch (model unknown) - 2x Cisco access switches per floor -
- network gear, Central, Fortinet FortiGate 100F firewall, Switching, routing, perimeter protection, "No VLANs configured; flat 10.10.0.0/16 broadcast domain"
- Wi‑Fi, Central, Ubiquiti UniFi APs (12 units), Internal wireless access, "Guest SSID exists but isolation not verified"
- ws-srv-01, Westside, Windows Server 2016, Local file server + scheduling
- network gear, Westside, 1x unmanaged switch - 1x Netgear Nighthawk consumer router (with VPN to Central)

## 3 Data and Services

| Category                                  | What is handled                                                               | Key IT services used                                                             | Primary users                                                  |
| ----------------------------------------- | ----------------------------------------------------------------------------- | -------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| Patient Health Information                | EHR records, imaging files (PACS), lab results, pharmacy orders, billing data | ehr‑srv‑01 / ehr‑db‑01; pacs‑srv‑01; billing‑srv‑01; web‑srv‑01 (patient portal) | Physicians, nurses, pharmacists, labs, billing staff, patients |
| Operational & Administrative Data         | Finance records, HR personnel files, marketing content, legal documents       | file‑srv‑01; AD domain controllers; VPN connections                              | Executive leadership, finance/HR/legal teams                   |
| Network and Infrastructure Configurations | Network diagrams, firewall rules, VPN settings                                | FortiGate 100F; Core switches; site‑to‑site VPNs                                 | IT staff (Sarah Park team), security analysts                  |
| Endpoint Security State                   | Antivirus signatures, patch levels, MFA status                                | Sophos endpoint protection; Windows AD password policy                           | All workstations and mobile devices                            |

**Critical services**:

- EHR application & database – core clinical workflow.
- PACS imaging – diagnostics.
- Billing/claims – financial operations.
- Domain controllers – authentication for all users.
- Backup service – data protection.
- Public website / patient portal – external access to health information.

## 4 Known Unknowns

- Server inventory completeness** – print‑srv‑01 is marked, existence of a second Westside server unconfirmed.
- Operating system / patch status for medical devices** – MRI (Windows XP), CT (unknown OS), infusion pumps, monitors.
- Guest Wi‑Fi isolation** – SSID exists but no confirmation that traffic is isolated from internal network.
- MFA coverage – only James’s personal account has MFA; others rely on password policy alone.
- Physical security – server room badge access uses generic badge; no cameras in IT corridor; Westside IT closet not locked.
- VPN ACLs – not audited, especially for HQ and Westside connections.
- Endpoint counts & health – last AD report 8 months old; Sophos update status unknown on all machines.
- Cloud service inventory – O365 is known, but departments may use other SaaS solutions
- Network segmentation / VLANs – flat 10.10.0.0/16 broadcast domain with no VLANs.
- Backup strategy – no off‑site or cloud backup; Veeam backups stored locally next to source data.
- Firmware / patch status of network gear – Cisco switches, FortiGate, Ubiquiti APs, Netgear router, consumer-grade equipment.
- Firewall configuration details – rulesets, IDS/IPS settings not provided.
