**Networking & Foundations**

| Question                                                      | Short answer                                                                                                                                                                                                                                                                                                    |
| ------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| What is networking and why is it essential?                   | The interconnection of devices to share resources, data, and services—essential for communication, collaboration, and access to the internet.                                                                                                                                                                   |
| What is the difference between LAN and WAN?                   | A **LAN** covers a small geographic area (e.g., office) using Ethernet/Wi‑Fi; a **WAN** spans large areas (countries/continents) and relies on leased lines, satellites, or VPNs.                                                                                                                               |
| What are the main network topologies (Bus, Star, Ring, Mesh)? | • **Bus** – all nodes share one cable.<br>• **Star** – each node connects to a central hub/switch.<br>• **Ring** – nodes connect in a closed loop.<br>• **Mesh** – many redundant links between nodes.                                                                                                          |
| What is the difference between physical and logical topology? | Physical shows the actual cabling/links; logical shows how data flows across that hardware (e.g., VLANs or routing paths).                                                                                                                                                                                      |
| What are the 7 layers of the OSI model and their functions?   | 1) **Physical** – raw bits.<br>2) **Data Link** – framing & MAC.<br>3) **Network** – addressing & routing.<br>4) **Transport** – reliable flow control (TCP)/best‑effort (UDP).<br>5) **Session** – sync, dialog control.<br>6) **Presentation** – encoding/translation.<br>7) **Application** – user programs. |
| What happens at each layer during data transmission?          | Data enters at Layer 7; each layer adds its own header (or trailer), passes it down, and removes the header on return—encapsulation.                                                                                                                                                                            |
| What is encapsulation and decapsulation?                      | The process of wrapping data with protocol headers as it goes down the stack; stripping those headers when it returns up the stack.                                                                                                                                                                             |
| What are the 4 layers of the TCP/IP model?                    | 1) **Link** (physical+data link), 2) **Internet**, 3) **Transport**, 4) **Application**.                                                                                                                                                                                                                        |
| How does TCP/IP compare to the OSI model?                     | TCP/IP has fewer, more pragmatic layers and maps loosely onto OSI; it’s the real‑world stack used on the internet.                                                                                                                                                                                              |

---

### Protocols & Transmission

| Question                                                                | Short answer                                                                                                                                                      |
| ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| What are the main network protocols (HTTP, HTTPS, FTP, SSH, DNS, DHCP)? | HTTP – web traffic; HTTPS – secure HTTP; FTP – file transfer; SSH – secure shell/remote login; DNS – domain name resolution; DHCP – dynamic IP allocation.        |
| What is the difference between TCP and UDP?                             | **TCP** provides reliable, ordered delivery with flow control; **UDP** offers lightweight, connectionless packets without guarantees.                             |
| What are the different types of transmission media (wired vs wireless)? | Wired: copper Ethernet, fiber; Wireless: Wi‑Fi, cellular, Bluetooth, satellite.                                                                                   |
| What is the role of a Hub, Switch, Router, Firewall?                    | Hub – repeats signals; Switch – MAC‑based forwarding; Router – IP routing & NAT; Firewall – packet filtering/control policies.                                    |
| What is the difference between Layer 2 and Layer 3 devices?             | L2 devices (switches) forward frames using MAC; L3 devices (routers) forward packets using IP addresses.                                                          |
| What is a VLAN and why is it used?                                      | A virtual LAN partitions a broadcast domain, improving security, traffic segregation, and management.                                                             |
| What is 802.1Q tagging?                                                 | Insertion of a VLAN ID field into Ethernet frames to identify which VLAN a frame belongs to.                                                                      |
| What are VLAN hopping attacks and how to prevent them?                  | Attacks that send double‑tagged or untagged packets to reach another VLAN; prevent by disabling unused ports, enabling 802.1Q filtering, and using port security. |
| What is Inter‑VLAN routing?                                             | Routing traffic between VLANs via a Layer 3 device (router or L3 switch).                                                                                         |
| What is a MAC address and how is it structured?                         | 48‑bit identifier: first 24 bits are the OUI (manufacturer), last 24 bits are NIC‑specific.                                                                       |
| What is the difference between OUI and NIC‑specific portions?           | **OUI** identifies the vendor; **NIC portion** uniquely identifies each device from that vendor.                                                                  |
| What are special MAC addresses (broadcast, multicast)?                  | Broadcast: `ff:ff:ff:ff:ff:ff`; Multicast: first octet has LSB = 1 (e.g., `01:00:5e:xx:xx:xx`).                                                                   |
| What is an IPv4 address and its format?                                 | 32‑bit dotted decimal (`a.b.c.d`), divided into network & host portions.                                                                                          |
| What are IP address classes (A, B, C, D, E)?                            | Class A: `0.xxx`; B: `10.xx`; C: `110x`; D: multicast; E: reserved.                                                                                               |
| What are private IP ranges (RFC 1918)?                                  | `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`.                                                                                                                  |
| What are special IP addresses (loopback, broadcast)?                    | Loopback: `127.0.0.1`; Broadcast: `.255` of a subnet or `255.255.255.255`.                                                                                        |
| What is CIDR notation?                                                  | Network prefix length appended to an address (`192.168.1.0/24`).                                                                                                  |
| How to calculate subnets, hosts per subnet, and network ranges?         | Subnet mask → network bits; Hosts = `2^(host_bits) - 2`; ranges from base +1 to base+hosts‑2.                                                                     |
| How to perform subnetting manually?                                     | Decide host bits needed, compute mask, split address space, assign each block a unique prefix.                                                                    |
| What is ARP and how does it work?                                       | Address Resolution Protocol resolves IP→MAC on a local link via broadcast requests/replies.                                                                       |
| What are the security concerns with ARP (ARP spoofing)?                 | Malicious hosts send fake ARP replies to redirect traffic; mitigated by static ARP, dynamic ARP inspection, or encryption.                                        |
| Why was IPv6 developed and how does it differ from IPv4?                | To solve address exhaustion, include built‑in security, auto‑config, and improved routing; uses 128‑bit addresses & different header format.                      |
| What are well‑known ports (0‑1023)?                                     | Ports reserved for standard services (e.g., HTTP 80, HTTPS 443).                                                                                                  |
| What are registered ports and dynamic ports?                            | Registered: `1024–49151` for specific applications; Dynamic/Private: `49152–65535` for client use.                                                                |
| What is DHCP and what problem does it solve?                            | Dynamically assigns IPs & config parameters to devices, simplifying network administration.                                                                       |
| What is the DORA process (Discover, Offer, Request, Acknowledge)?       | Sequence of DHCP messages to lease an IP: Discover → Offer → Request → ACK.                                                                                       |
| What is a DHCP lease and how does renewal work?                         | Lease time limits usage; client sends REQUEST before expiry to renew or rebind.                                                                                   |
| What are DHCP attacks (Rogue Server, Starvation)?                       | Rogue: fake server offers malicious config; Starvation: exhausting all IPs via spoofed requests.                                                                  |
| What is DHCP Snooping and how does it protect networks?                 | Switch feature that validates DHCP messages from trusted interfaces only, preventing rogue servers.                                                               |
| What is NAT and why is it used?                                         | Network Address Translation maps private to public addresses, conserving IPv4 space & providing basic firewalling.                                                |
| What is the difference between Static NAT, Dynamic NAT, and PAT?        | **Static**: one‑to‑one mapping; **Dynamic**: many-to-many with a pool; **PAT (port‑s)**: multiple hosts share one public IP via port translation.                 |
| What is Port Forwarding?                                                | A NAT rule that forwards incoming traffic on specific ports to internal hosts/ports.                                                                              |
| What is NAT Traversal (STUN, TURN, ICE)?                                | Techniques for establishing peer‑to‑peer connections through NAT/firewalls; STUN discovers external address, TURN relays media, ICE orchestrates the best path.   |
| What is Carrier‑Grade NAT (CGNAT)?                                      | Large‑scale NAT performed by ISPs to share a single public IP across many customers.                                                                              |
| What is DNS and how does it work?                                       | Domain Name System translates human‑readable names to IPs via a hierarchical cache of records.                                                                    |
| What is the DNS hierarchy (Root, TLD, Authoritative)?                   | Root zone (`.`) → Top‑Level Domains (`.com`, `.org`) → Authority servers for specific domains.                                                                    |
| What is the DNS resolution process?                                     | Client queries local resolver → recursive resolver traverses root→TLD→authoritative to get IP, caching along the way.                                             |
| What are the main DNS record types (A, AAAA, CNAME, MX, NS, TXT, PTR)?  | A: IPv4; AAAA: IPv6; CNAME: alias; MX: mail server; NS: name server; TXT: text data; PTR: reverse lookup.                                                         |
| What are DNS security threats (Spoofing, Hijacking, Tunneling)?         | Adversaries redirect queries to malicious servers, alter responses, or embed data in DNS traffic.                                                                 |
| What is DNSSEC and encrypted DNS (DoH, DoT)?                            | **DNSSEC** signs records for integrity; **DoH/DoT** encrypts DNS queries over HTTPS/TLS to prevent eavesdropping.                                                 |

---

### Authentication & Directory Services

| Question                                            | Short answer                                                                                                                  |
| --------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| What is RADIUS and how does it work?                | Remote Authentication Dial‑In User Service authenticates users via username/password or token, returning access attributes.   |
| What is TACACS+ and how does it differ from RADIUS? | TACACS+ separates authentication, authorization, and accounting into distinct packets, often used for device management.      |
| What is Kerberos and what attacks target it?        | Ticket‑Granting Service based protocol; attacks include Pass‑the‑Ticket, Golden Ticket, Silver Ticket, replay.                |
| What is LDAP and how is it used in networks?        | Lightweight Directory Access Protocol stores user/group data; used for authentication & resource lookup.                      |
| Why is NTP important for security?                  | Time synchronization ensures accurate logs, certificate validity, and prevents replay attacks.                                |
| What is Syslog and its severity levels?             | Standard logging protocol with levels: EMERG (0) to DEBUG (7).                                                                |
| What is an Autonomous System (AS) and ASN?          | A network or group of networks under a single administrative domain; assigned an Autonomouse System Number by IANA.           |
| What is BGP and how does it work?                   | Border Gateway Protocol exchanges reachability info between ASes; uses path vectors to avoid loops.                           |
| What are BGP hijacking attacks?                     | Malicious AS advertises incorrect prefixes to redirect traffic.                                                               |
| What is peering vs transit?                         | **Peering**: exchange traffic directly between ASes; **Transit**: purchase bandwidth from a provider for global connectivity. |
| What is an Internet Exchange Point (IXP)?           | Physical hub where multiple ISPs exchange traffic locally, reducing latency & cost.                                           |
| What is a CDN and how does Anycast work?            | Content Delivery Network caches content at edge nodes; anycast routes users to the nearest node via routing.                  |

---

### Wi‑Fi Basics & Security

| Question                                                          | Short answer                                                                                                                                               |
| ----------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| What are the Wi‑Fi frequency bands (2.4 GHz, 5 GHz, 6 GHz)?       | 2.4 GHz: wide coverage, more interference; 5 GHz: higher throughput, less crowded; 6 GHz: newest, high capacity, minimal interference.                     |
| What are the Wi‑Fi standards (802.11a/b/g/n/ac/ax)?               | Evolution of speed and modulation: a/b – 2.4 GHz (~54 Mbps); g – up to 54 Mbps; n – MIMO up to 600 Mbps; ac – 5 GHz, >1 Gbps; ax – Wi‑Fi 6 up to 9 Gbps.   |
| What is the difference between WEP, WPA, WPA2, WPA3?              | WEP: weak keying.<br>WPA/WPA2-PSK: TKIP/CCMP cipher suites.<br>WPA3: Simultaneous Authentication of Equals (SAE), stronger encryption and forward secrecy. |
| What are common wireless attacks (Evil Twin, Deauth, KRACK)?      | Evil Twin: rogue AP masquerading as legitimate.<br>Deauth: spoofed disassociation frames.<br>KRACK: exploits WPA2 key‑renewal to sniff traffic.            |
| What are wireless security best practices?                        | Use WPA3/802.1X, disable SSID broadcast, change default creds, segment guest traffic, keep firmware updated.                                               |
| What is the difference between PSK and Enterprise authentication? | **PSK**: shared pre‑shared key; **Enterprise**: 802.1X with RADIUS/TLS for per‑user credentials.                                                           |

---

### Core Security Concepts

| Question                                                                    | Short answer                                                                                                                             |
| --------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| What is the CIA Triad (Confidentiality, Integrity, Availability)?           | Fundamental security goals: keep data secret, unaltered, and reachable when needed.                                                      |
| What is Defense in Depth?                                                   | Layered security controls so failure of one doesn’t expose everything.                                                                   |
| What are the key security principles (Least Privilege, Zero Trust)?         | Grant minimal rights necessary; never trust an internal or external actor by default.                                                    |
| What is AAA (Authentication, Authorization, Accounting)?                    | Framework for verifying identity, controlling resources, and tracking usage.                                                             |
| What are the main attack categories (Reconnaissance, Interception, DoS)?    | Gathering info → intercepting data → denying services.                                                                                   |
| What is a Man‑in‑the‑Middle (MitM) attack?                                  | Adversary intercepts & possibly alters traffic between two parties.                                                                      |
| What are DDoS attacks (Volumetric, Protocol, Application)?                  | **Volumetric**: flooding bandwidth.<br>**Protocol**: exhausting server resources.<br>**Application**: attacking application layer logic. |
| What are common password attacks?                                           | Brute‑force, dictionary, rainbow tables, credential stuffing, phishing.                                                                  |
| What are the types of firewalls (Packet Filtering, Stateful, NGFW)?         | **PF** – stateless packet checks.<br>**SF** – tracks connection state.<br>**NGFW** – deep packet inspection, application awareness.      |
| How to write firewall rules?                                                | Permit essential ports, deny default all, order top‑down; use least‑privilege logic.                                                     |
| What is a DMZ?                                                              | Isolated subnet that hosts publicly exposed services while protecting internal networks.                                                 |
| What is the difference between IDS and IPS?                                 | **IDS** – detects & alerts.<br>**IPS** – blocks malicious traffic in real time.                                                          |
| What are detection methods (Signature, Anomaly, Heuristic)?                 | Signature: pattern match.<br>Anomaly: deviation from baseline.<br>Heuristic: rule‑based inference.                                       |
| What is network segmentation and why is it important?                       | Dividing networks into zones limits lateral movement & reduces blast radius of breaches.                                                 |
| What is Zero Trust architecture?                                            | Assume breach; authenticate, authorize, log every access regardless of origin.                                                           |
| What is a SIEM and what logs should be monitored?                           | Security Information and Event Management aggregates logs (auth, firewall, IDS, endpoints) for correlation & alerting.                   |
| What is NAC (Network Access Control)?                                       | Enforces device health, compliance, or policy before granting network access.                                                            |
| What is 802.1X authentication and the EAP methods?                          | Extensible Authentication Protocol over LAN; common methods: EAP‑TLS, PEAP, TTLS, FAST.                                                  |
| What are the types of port scans (TCP Connect, SYN, UDP)?                   | **Connect** – full handshake.<br>**SYN** – half‑handshake (stealth).<br>**UDP** – sends empty packet, observes responses.                |
| What are the port states (Open, Closed, Filtered)?                          | **Open**: responds; **Closed**: connection refused; **Filtered**: no response due to firewall/ICMP block.                                |
| What protocols are used for network enumeration (SNMP, NetBIOS, SMB, LDAP)? | SNMP – device info.<br>NetBIOS – host names.<br>SMB – shares & users.<br>LDAP – directory data.                                          |
| How to defend against reconnaissance?                                       | Implement firewalls, rate‑limit probes, use intrusion detection, hide open ports, enable honeypots, employ DLP.                          |

Feel free to ask for deeper dives or code examples on any of these topics!
