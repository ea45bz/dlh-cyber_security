**Data Protection Map – MedDefense

**Data Protection Map – MedDefense**

| Data Category                                        | **At Rest**                                                              | **In Transit**                                                                                 | **In Use**                                                                               |
| ---------------------------------------------------- | ------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| **Patient medical records (EHR, PostgreSQL 14)**     | NONE – data directory on unencrypted ext4                                | PARTIAL – SSL enabled but `hostnossl` lines allow plain‑text connections; actual usage unknown | NONE – decrypted into memory on ehr‑srv‑01 and sent over HTTP to browsers                |
| **Financial / billing data (MySQL, billing‑srv‑01)** | NONE – MySQL files on unencrypted ext4                                   | WEAK – no SSL enforced; traffic in cleartext on flat network                                   | NONE – application reads data directly from disk into memory (no additional protection)  |
| **Medical images (DICOM, PACS‑srv‑01)**              | NONE – files stored unencrypted on local disks                           | NONE – DICOM protocol not configured for TLS; cleartext across 4242/11112 ports                | NONE – images displayed directly in workstations; no session‑level encryption            |
| **Credentials (Active Directory, app passwords)**    | WEAK – NT‑Hash (MD4) stored on DCs; DES/RC4 enabled                      | WEAK – LDAP unencrypted; Kerberos optional but legacy types still active                       | MIXED – AES‑256/Kerberos available but not forced; many services may use weak algorithms |
| **Backup data (NAS‑01)**                             | NONE – RAID‑5 array no encryption; NAS interface exposed on flat network | NONE – backup files copied to NAS without encryption                                           | N/A — backups are archived, not actively processed in the same session                   |
| **Email (O365)**                                     | ENCRYPTED – Microsoft uses BitLocker + per‑mailbox keys                  | SECURE – TLS 1.2 enforced by Exchange Online                                                   | NONE – PHI sometimes sent unencrypted; S/MIME/OME not configured                         |
| **VPN traffic (site‑to‑site tunnels)**               | N/A                                                                      | ENCRYPTED – AES‑256+SHA‑256, IKEv2 DH Group 14                                                 | N/A                                                                                      |

| Data Category                                        | State      | Protection                                                         | Evidence                                                            | Status       |
| ---------------------------------------------------- | ---------- | ------------------------------------------------------------------ | ------------------------------------------------------------------- | ------------ |
| **Patient medical records (EHR, PostgreSQL 14)**     | At Rest    | `None`                                                             | “Encryption at rest: NONE.” – audit note                            | **Absent**   |
|                                                      | In Transit | SSL enabled but _hostnossl_ lines exist → _Partial_                | “Encryption in transit: PARTIAL.” – audit note                      | **Weak**     |
|                                                      | In Use     | `None`                                                             | “Encryption in use: NONE.” – audit note                             | **Absent**   |
| **Financial / billing data (MySQL, billing‑srv‑01)** | At Rest    | `None`                                                             | “Encryption at rest: NONE.” – audit note                            | **Absent**   |
|                                                      | In Transit | No SSL enforced → _Weak_                                           | “Encryption in transit: WEAK.” – audit note                         | **Weak**     |
|                                                      | In Use     | `None`                                                             | No additional protection during processing (audit note)             | **Absent**   |
| **Medical images (DICOM, PACS‑srv‑01)**              | At Rest    | `None`                                                             | “Storage: NONE.” – audit note                                       | **Absent**   |
|                                                      | In Transit | DICOM protocol not TLS‑enabled → _None_                            | “DICOM traffic: NONE.” – audit note                                 | **Absent**   |
|                                                      | In Use     | `None`                                                             | Images displayed directly (audit note)                              | **Absent**   |
| **Credentials (Active Directory, app passwords)**    | At Rest    | NT‑Hash (MD4), DES/RC4 enabled → _Weak_                            | “Finding 018…DES and RC4 are still enabled.” – audit note           | **Weak**     |
|                                                      | In Transit | LDAP unencrypted; Kerberos optional → _Weak_                       | “LDAP: Not encrypted by default.” & “Finding 007” – audit note      | **Weak**     |
|                                                      | In Use     | Kerberos AES‑256 available but legacy types still enabled → _Weak_ | “Domain controllers support … AES‑256, DES, RC4, etc.” – audit note | **Weak**     |
| **Backup data (NAS‑01)**                             | At Rest    | `None`                                                             | “Encryption: NONE.” – audit note                                    | **Absent**   |
|                                                      | In Transit | Backups transferred over flat network without encryption → _None_  | NAS management interface exposed on flat network (audit note)       | **Absent**   |
|                                                      | In Use     | Not applicable (archive only)                                      | N/A                                                                 | **N/A**      |
| **Email (O365)**                                     | At Rest    | Microsoft‑managed keys + BitLocker → _Adequate_                    | “BitLocker … + per‑mailbox encryption.” – audit note                | **Adequate** |
|                                                      | In Transit | TLS 1.2 enforced by Exchange Online → _Adequate_                   | “TLS 1.2 for all Exchange Online connections.” – audit note         | **Adequate** |
|                                                      | In Use     | No S/MIME/OME configured → _None_                                  | “S/MIME or OME: Not configured.” – audit note                       | **Absent**   |
| **VPN traffic (site‑to‑site tunnels)**               | At Rest    | N/A (no persistence)                                               | N/A                                                                 | **N/A**      |
|                                                      | In Transit | IPSec AES‑256+SHA‑256, IKEv2 DH Group 14 → _Adequate_              | “AES‑256 with SHA‑256 … IKEv2 with DH Group 14.” – audit note       | **Adequate** |
|                                                      | In Use     | N/A (network layer only)                                           | N/A                                                                 | **N/A**      |

## Gap Summary

How many of the 21 cells (7 × 3) have adequate protection ?
3 cells

How many are weak ?
5 cells

How many are absent ?
13 cells

What is the overall crypto coverage percentage ?
approx 14 %
