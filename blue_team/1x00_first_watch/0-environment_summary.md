# Structured Environment Summary

## 1 Organization Overview

- **Sites**

  | Site                                    | Type                   | Function                                                     | Headcount |
  | --------------------------------------- | ---------------------- | ------------------------------------------------------------ | --------- |
  | MedDefense Central Hospital (downtown)  | Acute care facility    | Patient treatment, diagnostics, imaging, pharmacy, lab, etc. | ~1,400    |
  | Westside Clinic (suburban)              | Outpatient office      | Primary care, imaging (X‑ray/US), labs, minor procedures, PT | ~180      |
  | Corporate HQ (Greenfield Business Park) | Administrative offices | Finance, HR, Legal, Marketing, Executive leadership, IT      | ~220      |

- **Departments**
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

- **Security‑Relevant Reporting Structure**
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

| Location              | Asset                               | Type/OS                                                                                                         | Function                                                  | Technical Notes                                         |
| --------------------- | ----------------------------------- | --------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- | ------------------------------------------------------- |
| Central               | ehr‑srv‑01                          | Ubuntu 20.04 LTS                                                                                                | EHR application server                                    | -                                                       |
|                       | ehr‑db‑01                           | Ubuntu 20.04 LTS                                                                                                | PostgreSQL database (EHR)                                 | -                                                       |
|                       | pacs‑srv‑01                         | Windows Server 2016                                                                                             | PACS imaging server                                       | -                                                       |
|                       | billing‑srv‑01                      | Ubuntu 18.04 LTS                                                                                                | Billing/claims processing                                 | Performance issues noted; restarted frequently          |
|                       | ad‑dc‑01 / ad‑dc‑02                 | Windows Server 2019                                                                                             | Primary & secondary Domain Controllers                    | -                                                       |
|                       | file‑srv‑01                         | Windows Server 2016                                                                                             | Department file shares                                    | -                                                       |
|                       | print‑srv‑01*                       | Windows Server 2012R2                                                                                           | Print server                                              | *UNVERIFIED – end of support (Oct 2023)                 |
|                       | backup‑srv‑01                       | Ubuntu 22.04 LTS                                                                                                | Backup server (Veeam agent)                               | Veeam nightly backups to local NAS on same rack         |
|                       | web‑srv‑01                          | Ubuntu 20.04 LTS                                                                                                | Public website + patient portal                           | -                                                       |
|                       | network gear                        | Cisco core switch (model unknown) <br> 2x Cisco access switches per floor <br> Fortinet FortiGate 100F firewall | Switching, routing, perimeter protection                  | No VLANs configured; flat 10.10.0.0/16 broadcast domain |
|                       | Wi‑Fi                               | Ubiquiti UniFi APs (12 units)                                                                                   | Internal wireless access                                  | Guest SSID exists but isolation not verified            |
| Westside              | ws‑srv‑01                           | Windows Server 2016                                                                                             | Local file server + scheduling                            | -                                                       |
|                       | additional server?                  | _Unknown_                                                                                                       | Potentially another local server (not confirmed)          | –                                                       |
|                       | network gear                        | 1x unmanaged switch <br> 1x Netgear Nighthawk consumer router (with VPN to Central)                             | No firewall; deemed “NOT acceptable” for medical facility |
|                       | Wi‑Fi                               | _Unknown_                                                                                                       | –                                                         |
| Corporate HQ          | None on‑prem                        | Cloud services only                                                                                             | AD, O365, etc. connect via site‑to‑site VPN               | Managed by building landlord; MedDefense VLAN exists    |
| Endpoints (all sites) | Windows 10/11 workstations          | ~320 (Central) <br> ~45 (Westside) <br> ~120 (HQ)                                                               | Clinical & administrative staff                           | Counts from AD report (8 months old)                    |
|                       | Thin clients                        | ~60 (Central, clinical areas)                                                                                   | -                                                         |
|                       | Laptops                             | ~30 (HQ, remote‑capable)                                                                                        | -                                                         |
|                       | iPads                               | ~25                                                                                                             | Physician tablets; management status unclear              |
| Medical Devices / IoT | Philips IntelliVue patient monitors | ~80 (Central)                                                                                                   | Network‑connected monitoring data                         |
|                       | BD Alaris infusion pumps            | ~120 (Central)                                                                                                  | Dosage updates over network                               |
|                       | Siemens MAGNETOM MRI scanner        | 1 (Radiology, Central)                                                                                          | Runs Windows XP                                           |
|                       | GE Revolution CT scanner            | 1 (Central)                                                                                                     | OS unknown                                                |
|                       | Nurse call system                   | IP‑based                                                                                                        | Integrated with phone system                              |
|                       | HID Global badge/access system      | -                                                                                                               | Connected to AD for some doors                            |

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
