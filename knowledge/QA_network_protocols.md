## Core Security Principles & Protocol Differentiation

| #   | Question                                                                                     | Short Answer                                                                                                                                    |
| --- | -------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | What are the three core security goals that secure protocols aim to achieve?                 | **Confidentiality, Integrity, Availability** (often referred to as CIA).                                                                        |
| 2   | What is the main difference between application‑layer protocols and network‑layer protocols? | App‑layer protocols (e.g., HTTP, SMTP) define data semantics; net‑layer protocols (IP, ICMP) handle addressing, routing, and packet delivery.   |
| 3   | Explain the concept of port numbers and their significance in network communication.         | Port numbers (0–65535) identify specific processes or services on a host; they let a single IP address support multiple concurrent connections. |

---

## Secure Web & Remote Access Protocols

| #   | Question                                                                                           | Short Answer                                                                                                                                                                                                                                                                             |
| --- | -------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Difference between SSL and TLS, and which is actually used today?                                  | **TLS** (Transport Layer Security) replaced SSL; today only TLS 1.2/1.3 are supported in browsers.                                                                                                                                                                                       |
| 2   | How the TLS handshake works when visiting a secure website?                                        | 1️⃣ Client → Server: `ClientHello` (cipher suites). <br>2️⃣ Server → Client: `ServerHello`, cert, `ServerKeyExchange`. <br>3️⃣ Client verifies cert, sends premaster secret encrypted with server’s public key. <br>4️⃣ Both sides derive session keys and confirm with `Finished` messages. |
| 3   | What problem did SSH solve that older protocols like Telnet couldn't handle?                       | Telnet sent clear‑text credentials; SSH provides encrypted channel + strong authentication.                                                                                                                                                                                              |
| 4   | How does SSH authentication with public keys work?                                                 | Client holds private key; server has matching public key in `~/.ssh/authorized_keys`. During handshake, the client signs a challenge; the server verifies using the stored public key.                                                                                                   |
| 5   | Differentiate between secure protocols like HTTPS, SFTP and their insecure counterparts HTTP, FTP. | **HTTPS/SFTP**: encryption (TLS for HTTPS; SSH/ECDH for SFTP) + authentication. <br>**HTTP/FTP**: plaintext traffic, no built‑in integrity or auth.                                                                                                                                      |
| 6   | Explain why HTTPS is mandatory for user trust, data protection, and modern web features.           | HTTPS encrypts data, prevents eavesdropping/man‑in‑the‑middle, enables cookie security, allows HTTP/2 & TLS‑based APIs, and is required by many browsers (e.g., for geolocation, service workers).                                                                                       |

---

## Network Layer & VPN Protocols

| #   | Question                                                                                | Short Answer                                                                                                                                                                         |
| --- | --------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | Difference between Transport Mode and Tunnel Mode in IPSec, and which is used for VPNs? | **Transport** encrypts only payload of IP packet (end‑to‑end). <br>**Tunnel** encapsulates entire original packet into a new one; used for site‑to‑site or remote‑access VPNs.       |
| 2   | Difference between AH and ESP in IPSec?                                                 | **AH** provides integrity & authentication but no encryption. <br>**ESP** can provide both integrity (optional) and encryption, plus optional auth.                                  |
| 3   | Why should PPTP never be used for security‑sensitive tasks?                             | Weak encryption (MPPE), trivial password cracking, and deprecated due to known vulnerabilities in the GRE tunnel & shared secrets.                                                   |
| 4   | What makes WireGuard faster and more efficient than OpenVPN?                            | Uses modern cryptography (Curve25519, ChaCha20, Poly1305), no per‑session key renegotiation, single lightweight process, zero‑copy kernel networking → lower CPU overhead & latency. |

---

## Common Protocol Auditing & Risk Assessment

| #   | Question                                                                              | Short Answer                                                                                                                                                                      |
| --- | ------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Purpose of NFS and how misconfigurations can expose shares?                           | NFS allows file sharing over a network. If exported without authentication or with `ro`/`rw` to `*`, any host on the subnet can read/write files, exposing sensitive data.        |
| 2   | How SMTP VRFY and EXPN can be exploited for user enumeration?                         | They reveal whether an email address exists on the server; attackers harvest valid addresses for phishing or targeted attacks.                                                    |
| 3   | Purpose of SNMP and security risks with unencrypted data / default community strings? | SNMP monitors network devices. Using v1/v2c transmits plain text passwords (e.g., “public”/“private”), allowing eavesdroppers to read/modify device configuration or perform DoS. |

---

## System Hardening & Vulnerability Management

| #   | Question                                                               | Short Answer                                                                                                                                                                                         |
| --- | ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Importance of keeping network protocols and server configs up‑to‑date? | Patch known vulnerabilities, close exploited attack vectors (e.g., CVE‑2023‑xxxx), and comply with security standards.                                                                               |
| 2   | Need for basic firewall rules (iptables) to control access?            | Restricts inbound/outbound traffic to only necessary ports, limiting exposure to brute‑force or lateral movement attacks.                                                                            |
| 3   | Common SSH configuration weaknesses that require hardening?            | - Allowing `PermitRootLogin yes` – enables direct root attacks.<br> - Enabling `PasswordAuthentication yes` – exposes password guessing.<br> - Using weak key sizes or default `sshd_config` values. |

---
