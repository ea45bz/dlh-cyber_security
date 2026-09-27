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

## 3 Data and Services

## 4 Known Unknowns

Central: - name: ehr-srv-01
type_os: Ubuntu 20.04 LTS
function: EHR application server
technical_notes: "-" - name: ehr-db-01
type_os: Ubuntu 20.04 LTS
function: PostgreSQL database (EHR)
technical_notes: "-" - name: pacs-srv-01
type_os: Windows Server 2016
function: PACS imaging server
technical_notes: "-" - name: billing-srv-01
type_os: Ubuntu 18.04 LTS
function: Billing/claims processing
technical_notes: "Performance issues noted; restarted frequently" - name: ad-dc-01 / ad-dc-02
type_os: Windows Server 2019
function: Primary & secondary Domain Controllers
technical_notes: "-" - name: file-srv-01
type_os: Windows Server 2016
function: Department file shares
technical_notes: "-" - name: print-srv-01*
type_os: Windows Server 2012R2
function: Print server
technical_notes: "*UNVERIFIED – end of support (Oct 2023)" - name: backup-srv-01
type_os: Ubuntu 22.04 LTS
function: Backup server (Veeam agent)
technical_notes: "Veeam nightly backups to local NAS on same rack" - name: web-srv-01
type_os: Ubuntu 20.04 LTS
function: Public website + patient portal
technical_notes: "-" - name: network gear
type_os: - Cisco core switch (model unknown) - 2x Cisco access switches per floor - Fortinet FortiGate 100F firewall
function: Switching, routing, perimeter protection
technical_notes: "No VLANs configured; flat 10.10.0.0/16 broadcast domain" - name: Wi‑Fi
type_os: Ubiquiti UniFi APs (12 units)
function: Internal wireless access
technical_notes: "Guest SSID exists but isolation not verified"

Westside: - name: ws-srv-01
type_os: Windows Server 2016
function: Local file server + scheduling
technical_notes: "-" - name: additional server?
type_os: _Unknown_
function: Potentially another local server (not confirmed)
technical_notes: "–" - name: network gear
type_os: - 1x unmanaged switch - 1x Netgear Nighthawk consumer router (with VPN to Central)
function: No firewall; deemed “NOT acceptable” for medical facility
technical_notes: "-" - name: Wi‑Fi
type_os: _Unknown_
function: _
technical_notes: "-"

Corporate HQ: - name: None on‑prem
type_os: Cloud services only
function: AD, O365, etc. connect via site‑to‑site VPN
technical_notes: "Managed by building landlord; MedDefense VLAN exists"

Endpoints (all sites): - name: Windows 10/11 workstations
type_os: ~320 (Central) <br> ~45 (Westside) <br> ~120 (HQ)
function: Clinical & administrative staff
technical_notes: "Counts from AD report (8 months old)" - name: Thin clients
type_os: ~60 (Central, clinical areas)
function: _
technical_notes: "-" - name: Laptops
type_os: ~30 (HQ, remote‑capable)
function: _
technical_notes: "-" - name: iPads
type_os: ~25
function: Physician tablets; management status unclear
technical_notes: "-"

Medical Devices / IoT:
assets: - name: Philips IntelliVue patient monitors
type_os: ~80 (Central)
function: Network‑connected monitoring data
technical_notes: "-" - name: BD Alaris infusion pumps
type_os: ~120 (Central)
function: Dosage updates over network
technical_notes: "-" - name: Siemens MAGNETOM MRI scanner
type_os: 1 (Radiology, Central)
function: Runs Windows XP
technical_notes: "-" - name: GE Revolution CT scanner
type_os: 1 (Central)
function: OS unknown
technical_notes: "-" - name: Nurse call system
type_os: IP‑based
function: Integrated with phone system
technical_notes: "-" - name: HID Global badge/access system
type_os: -
function: Connected to AD for some doors
technical_notes: "-"

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
