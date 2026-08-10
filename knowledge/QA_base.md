# Linux Security Basics

## 1️⃣ What is **Linux**

A family of Unix‑like open‑source operating systems built on the Linux kernel.  
Used for servers, desktops, embedded devices, IoT, mobile (Android), etc.

## 2️⃣ What is a **Linux command**

A shell program that performs a specific function – e.g., `ls`, `chmod`, `systemctl`.

## 3️⃣ Structure of the Linux OS

```
┌───────────────────────────┐
│   User Space (Applications) ──┬────► syscalls → kernel
│                                 │
├─────────────────────────────────┘
│            Kernel (core)
├─────────────────────────────────┐
│      Device Drivers & IPC          │
└──────────────────────────────────────┘
```

- **User space**: user programs, libraries (`glibc`), utilities.
- **Kernel**: manages memory, CPU scheduling, I/O, networking, security hooks.

---

## 4️⃣ The Filesystem Hierarchy Standard (FHS)

FHS-compliant file system supports the same basic security features found in most UNIX filesystems.

It is possible to define two independent distinctions among files: shareable vs. unshareable and variable vs. static. In general, files that differ in either of these respects should be located in different directories. This makes it easy to store files with different usage characteristics on different filesystems.

## 5️⃣ Key Directories & Their Purposes

| Directory                | Typical Content                                                                  | Purpose                                                               |
| ------------------------ | -------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| `/bin`, `/sbin`          | Essential user/ system executables (`ls`, `mount`).                              | Must stay on the root filesystem; available even in single‑user mode. |
| `/usr/bin`, `/usr/sbin`  | Non‑essential programs (e.g., `vim`, `systemd`).                                 | Hierarchy for installed software, shared by users and administrators. |
| `/lib`, `/lib64`         | Shared libraries used by binaries in `/bin`, `/sbin`.                            | Kernel & userland share code here.                                    |
| `/usr/lib`, `/usr/lib64` | Libraries for applications under `/usr`.                                         | Keeps application libraries separate from core system libs.           |
| `/etc`                   | System configuration files (`/etc/passwd`, `fstab`).                             | Human‑readable, non‑binary config data.                               |
| `/var`                   | Variable state: logs (`/var/log`), spool (`/var/spool`), caches.                 | Data that changes frequently and may be rotated or deleted.           |
| `/tmp`                   | Temporary files for all users; world writable but cleaned on boot (or manually). | Short‑term scratch space.                                             |
| `/root`                  | Home directory of the root user.                                                 | Separate from normal user homes (`/home`).                            |
| `/home`                  | Regular user home directories.                                                   | User data, personal configuration.                                    |
| `/dev`                   | Device nodes (`/dev/sda`, `tty0`).                                               | Interface to hardware via kernel drivers.                             |
| `/proc`                  | Virtual filesystem exposing kernel & process information.                        | Read‑only view of system state (`/proc/<pid>`).                       |
| `/sys`                   | Sysfs – runtime kernel objects (devices, drivers).                               | Interface for low‑level configuration.                                |
| `/run`                   | Runtime data that doesn’t survive reboots (PID files, sockets).                  | Modern alternative to legacy `/var/run`.                              |
| `/boot`                  | Kernel images & bootloader config (`vmlinuz`, `initrd.img`).                     | Required for the kernel to start.                                     |

---

## 6️⃣ Protecting Files and Directories

| Tool / Command                  | Use                                          |
| ------------------------------- | -------------------------------------------- |
| **chmod**                       | Set permissions (e.g., `chmod 750 file`)     |
| **chown/chgrp**                 | Change owner/group (`chown user:group file`) |
| **ACLs (`setfacl`, `getfacl`)** | Fine‑grained per‑user/per‑group access       |

_Tip:_ Use `chmod 700` for private scripts and `chgrp staff; chmod 750` to give a group limited access.

---

## 7️⃣ Monitoring & Investigating System Activity

| Tool                                                | What it gives you                                  |
| --------------------------------------------------- | -------------------------------------------------- |
| **auditd / ausearch**                               | Kernel‑level syscall logs (chmod, fork, network).  |
| **journalctl**                                      | Systemd journal; view `system`, `user` or by unit. |
| **syslog (`/var/log/syslog`, `/var/log/messages`)** | Traditional log files for services.                |
| **ps / top / htop / glances**                       | Current processes, CPU/memory usage.               |
| **netstat / ss**                                    | Active sockets and listening ports.                |
| **dmesg**                                           | Kernel ring buffer (boot messages, driver errors). |

---

## 8️⃣ Secure File Transfer

| Method             | How it works                                                           |
| ------------------ | ---------------------------------------------------------------------- |
| `scp`/`sftp` (SSH) | Encrypts both payload and control channel; no plaintext over the wire. |
| `rsync -e ssh`     | Efficient incremental copy with encryption.                            |

## 9️⃣ Firewall Configuration

| Tool                        | Typical distro                                               |
| --------------------------- | ------------------------------------------------------------ |
| **iptables** / **nftables** | Traditional packet filtering (iptables → nftable migration). |
| **firewalld**               | Zone‑based abstraction on top of nftables/iptables.          |
| **ufw**                     | Uncomplicated firewall – front‑end to iptables.              |

## 🔟 Identify & Terminate Malicious Processes

| Tool / Technique     | What it helps with                                      |
| -------------------- | ------------------------------------------------------- |
| **ps/pgrep/top**     | Locate suspicious PIDs by name, CPU usage, memory.      |
| **auditd + SELinux** | Log denied attempts that may reveal malicious activity. |

# Linux shell, processes and signals

## What is a PID

The **Process IDentifier (PID)** is the unique number assigned by the kernel to each running process.

## What is a process

A _process_ is an executing instance of a program:

## What is a signal

Signals are software interrupts

## What are the 2 signals that cannot be ignored

**`SIGKILL` (signal 9)**
**`SIGSTOP` (signal 19 on Linux)**

# Permissions, SUID & SGID

### What is the purpose of the setuid and setgid in Linux file Purpose of **setuid** and **setgid** in Linux

| Bit              | Symbol in `ls -l`                                                                                 | What it does                                                                                                                                                   |
| ---------------- | ------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **SetUID (`s`)** | Executable bit _plus_ setuid → `-rwsr-xr-x` or `-rwSr--...` (uppercase `S` if executable not set) | When the file is run, its effective UID becomes the owner’s UID, regardless of who invoked it.                                                                 |
| **SetGID (`s`)** | Executable bit _plus_ setgid → `-rwxr-sr-x` or `-rwSr--...` (uppercase `S` if executable not set) | When the file is run, its effective GID becomes the owner’s GID. If set on a **directory**, new files inherit that directory’s GID (group‑shared directories). |

### Why use them?

| Reason                                           | Scenario                                                                                                                                                         |
| ------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Run privileged code without giving full root** | A helper program needs to read `/etc/shadow`. Grant it `setuid` to the `root` owner.                                                                             |
| **Maintain group ownership for shared dirs**     | A collaborative project folder where all files should belong to a particular group. Setgid on the directory ensures any file created inside inherits that group. |
| **Security isolation**                           | `setuid` binaries are monitored (e.g., via SELinux/AppArmor) so they can’t do anything beyond their intended privileges.                                         |

### How can you audit file permissions changes on your system

install Audit Daemon
add Audit rules

For example, to log every permission change inside `/etc/ssh`:

```bash
sudo auditctl -w /etc/ssh -p wa -k perm_change

### What is Umask in Linux
the “file‑mode mask” to set permissions to fiels
```
