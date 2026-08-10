# Windows Essentials – Quick Reference Guide

---

## 1️⃣ What is **Windows** & How It Differs from Other OSes

- **Commercial, proprietary** OS developed by Microsoft.
- Uses a _hybrid kernel_ (NT kernel) with a micro‑kernel‑like architecture but includes many driver layers in the kernel.
- **Unified GUI + CLI**: Windows Explorer + PowerShell / CMD.
- Strong integration with **Active Directory**, **Microsoft‑centric cloud** services, and enterprise management tools (Group Policy, SCCM).

---

## 2️⃣ **Windows Architecture** – Kernel Mode vs User Mode

- **Kernel Mode**: Full CPU privilege. Runs core OS services and drivers (`ntoskrnl.exe`). Handles memory management, scheduling, I/O.
- **User Mode**: Application sandbox. All user‑space programs run here; they must make system calls (via `syscalls` or `Nt*` functions) to request kernel services.

---

## 3️⃣ **NTFS File System** – How It Works

Journaling, Metadata structures, Permissions & ACLs

## 4️⃣ **Windows Registry**

- Hierarchical key‑value store: `HKEY_LOCAL_MACHINE`, `HKEY_CURRENT_USER`, etc.
- Stores system & application configuration, device settings, user profiles.
- **Registry Editor (`regedit.exe`)**, PowerShell cmdlets (`Get-ItemProperty`), and APIs (`RegOpenKeyEx`) interact with it.

---

## 5️⃣ **User, Group, Access Control Management**

- **Local Users & Groups**
- **Active Directory (AD)** – centralized user/group management in domains.

---

## 6️⃣ **Navigating Windows & Built‑in Administrative Tools**

| Tool                                     | Typical Use                                |
| ---------------------------------------- | ------------------------------------------ |
| **File Explorer**                        | File/folder management, shortcuts.         |
| **Control Panel / Settings**             | System settings, hardware.                 |
| **Task Scheduler (`taskschd.msc`)**      | Automate tasks.                            |
| **Services (`services.msc`)**            | Start/stop services.                       |
| **Event Viewer (`eventvwr.msc`)**        | View logs.                                 |
| **Computer Management (`compmgmt.msc`)** | Disk management, users/groups, event logs. |

---

## 7️⃣ **Windows Processes & Services**

- **Processes**: Instances of `*.exe`. Managed by Task Manager or PowerShell (`Get-Process`).
- **Services**: Persistent background processes controlled via Service Control Manager.

## 8️⃣ **Command Prompt (`cmd.exe`) – Basic System Administration**

```bat
:: View system info
systeminfo

:: Network config
ipconfig /all

:: Check active connections
netstat -anb
```

---

## 9️⃣ **Windows Event Logs**

- **Event Viewer** displays logs in categories: _Application_, _System_, _Security_, _Setup_, _Forwarded Events_.
- **Common event IDs**:
  - 4624/4625 – Logon success/failure.
  - 1100–1110 – Application crashes.
  - 7040/7042 – Service start/stop.
- **Reading via PowerShell**:

## 🔟 Built‑in Security Features

| Feature                                       | Description                                                             |
| --------------------------------------------- | ----------------------------------------------------------------------- |
| **User Account Control (UAC)**                | Elevates privilege on demand; prompts when admin actions are requested. |
| **Windows Defender**                          | Real‑time antivirus, anti‑malware protection.                           |
| **BitLocker**                                 | Full‑disk encryption using TPM or password.                             |
| **AppLocker / Software Restriction Policies** | Whitelist/blacklist of executables.                                     |
| **Credential Guard**                          | Isolates credentials via VMs.                                           |
| **Windows Firewall + Advanced Security**      | Stateful packet filtering; inbound/outbound rules.                      |

---

## 1️⃣1️⃣ Network Configuration & Connectivity

- **Network Connections (`ncpa.cpl`)** – set IP, DNS, adapter properties.
- **`netsh`** – CLI for interface configuration, firewall, port mapping.
- **DHCP / static IP**: assign via `netsh interface ip set address`.
- **DNS resolution**: `/etc/hosts` style in `C:\Windows\System32\drivers\etc\hosts`.

---

## 1️⃣2️⃣ Common Attack Surfaces & Mitigation

| Surface                                     | Typical Threat                   | Mitigation                                                                      |
| ------------------------------------------- | -------------------------------- | ------------------------------------------------------------------------------- |
| **Unpatched OS / Applications**             | Exploits like EternalBlue (SMB). | Enable automatic updates, use WSUS.                                             |
| **Weak Passwords / LLMNR/NBT‑NS spoofing**  | Pass‑the‑hash attacks.           | Enforce strong passwords, disable SMBv1, enable SMB signing.                    |
| **Outdated Office/Adobe plugins**           | Macro‑based malware.             | Disable macros, update office suites.                                           |
| **Unrestricted PowerShell**                 | RCE via PowerShell scripts.      | Restrict via AppLocker, restrict execution policy (`RemoteSigned`).             |
| **Phishing / social engineering**           | Credential theft.                | User training, MFA, anti‑phish filters.                                         |
| **Misconfigured Windows Defender settings** | False negatives.                 | Enable cloud‑based protection, sign‑in with Microsoft 365 Defender integration. |
| **Weak Firewall rules**                     | Port scans & exploits.           | Default deny, only open necessary ports; use AppLocker + firewall profiles.     |

---

### Quick “Check‑list” for Hardening

1. **Updates** – `Windows Update` + WSUS / SCCM.
2. **Patch Windows Defender** – enable cloud‑based detection.
3. **Enable BitLocker** on OS volumes.
4. **Enforce MFA** via Azure AD or local policies.
5. **Configure UAC** to “Notify me only when apps try to make changes”.
6. **Restrict Remote Desktop** – use Network Level Authentication, firewall rules.
7. **Audit all privileged actions** in Security logs (Event IDs 4672, 4624).

That covers the core concepts of Windows OS, architecture, file system, security, administration tools, and common defense strategies. Happy managing!
