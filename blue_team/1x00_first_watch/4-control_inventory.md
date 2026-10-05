**Security Controls Identified (12+ distinct)**

```yaml
controls:
  - id: C-001
    name: "Network perimeter ‘Deny‑All’ rule"
    description: >
      Default deny of all inbound/outbound traffic unless explicitly allowed.
      Prevents unauthorized network access at the edge.
    category: Technical
    function: Preventive
    assets_protected:
      - All devices connected to the network (servers, workstations, endpoints)
    source: Artifact 1

  - id: C-002
    name: "Disable SSH root login"
    description: >
      `PermitRootLogin no` on ehr‑srv‑01 blocks direct root logins over SSH,
      reducing privileged‑access risk.
    category: Technical
    function: Preventive
    assets_protected:
      - Linux servers
    source: Artifact 2

  - id: C-003
    name: "Key‑only SSH authentication"
    description: >
      `PubkeyAuthentication yes` & `PasswordAuthentication no` force public‑key login only.
    category: Technical
    function: Preventive
    assets_protected:
      - Linux servers
    source: Artifact 2

  - id: C-004
    name: "Endpoint antivirus coverage"
    description: >
      Sophos Endpoint Protection is deployed to all Windows workstations (≈387 devices).
      Provides malware protection and detection.
    category: Technical
    function: Preventive
    assets_protected:
      - Workstation endpoints
    source: Artifact 4

  - id: C-005
    name: "Scheduled nightly full backup"
    description: >
      “Nightly‑Full” job captures a full snapshot of the VMware cluster at 02:00 AM every day.
    category: Technical
    function: Preventive
    assets_protected:
      - EHR application, database, billing system, domain controller, file shares, web portal VMs
    source: Artifact 5

  - id: C-006
    name: "Firewall traffic logging"
    description: >
      `set logtraffic all/utm` logs every rule evaluation for auditability and threat detection.
    category: Technical
    function: Detective
    assets_protected:
      - Firewall event logs
    source: Artifact 1

  - id: C-007
    name: "Sophos malware detection & action"
    description: >
      Automated quarantine/block of detected threats (Adware, PUA.CryptoMiner, Phish.URL).
    category: Technical
    function: Detective
    assets_protected:
      - Endpoint workloads
    source: Artifact 4

  - id: C-008
    name: "Web‑server log rotation"
    description: >
      Apache logs on web‑srv‑01 / billing‑srv‑01 rotated weekly, keeping 4 weeks of history.
    category: Technical
    function: Detective
    assets_protected:
      - Web server audit trails
    source: Artifact 8

  - id: C-009
    name: "Password complexity & length policy"
    description: >
      Minimum 8 chars with upper/lower/number/special character enforcement.
    category: Administrative
    function: Preventive
    assets_protected:
      - User accounts (Windows/Linux)
    source: Artifact 3

  - id: C-010
    name: "Password rotation policy"
    description: >
      Users must change passwords every 90 days.
    category: Administrative
    function: Preventive
    assets_protected:
      - User accounts
    source: Artifact 3

  - id: C-011
    name: "Account lockout policy"
    description: >
      Lock account after 5 failed logins for 30 min.
    category: Administrative
    function: Preventive
    assets_protected:
      - User accounts
    source: Artifact 3

  - id: C-012
    name: "Mandatory security awareness training"
    description: >
      “CyberSafe Basics” online module, annual mandatory for all staff.
    category: Administrative
    function: Preventive
    assets_protected:
      - Human factor (employees)
    source: Artifact 7

  - id: C-013
    name: "Training completion monitoring"
    description: >
      HR tracks and reports percentage of staff who completed the program each year.
    category: Administrative
    function: Detective
    assets_protected:
      - Staff training compliance
    source: Artifact 7

  - id: C-014
    name: "Backup recovery testing"
    description: >
      Last full restore test performed 8 months ago on file‑srv‑01 (6‑hour restore).
    category: Administrative
    function: Corrective
    assets_protected:
      - Restorability of backed‑up data
    source: Artifact 5

  - id: C-015
    name: "On‑site security guard"
    description: >
      Uniformed guard at the main entrance Monday‑Friday 07:00‑19:00.
    category: Physical
    function: Preventive
    assets_protected:
      - Main lobby & building perimeter
    source: Artifact 6

  - id: C-016
    name: "Visitor registration & badge verification"
    description: >
      Guard verifies visitor badges and records sign‑ins at the front desk.
    category: Physical
    function: Preventive
    assets_protected:
      - Unauthorized personnel
    source: Artifact 6

  - id: C-017
    name: "Analog camera monitoring with DVR"
    description: >
      4 cameras (entrances, parking) feed to a local DVR that retains 30 days of footage.
    category: Physical
    function: Detective
    assets_protected:
      - Building ingress points
    source: Artifact 6
```

## Control Summary Matrix

|                    | Preventive                                                    | Detective           | Corrective | Compensating | Deterrent |
| ------------------ | ------------------------------------------------------------- | ------------------- | ---------- | ------------ | --------- |
| **Technical**      | C‑001, C‑002, C‑003, C‑004, C‑005, C‑009, C‑010, C‑011, C‑012 | C‑006, C‑007, C‑008 |            |              |           |
| **Administrative** |                                                               | C‑013               | C‑014      |              |           |
| **Physical**       | C‑015, C‑016                                                  | C‑017               |            |              |           |

_Empty cells indicate no identified control of that function in the provided artifacts._
