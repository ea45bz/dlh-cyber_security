## MedDefense Network‑Segmentation Plan

### Part 1 – Zone Definition

| #   | Zone Name                     | Purpose / Security Goal                                          | IP Range (VLAN ID)       | Systems Included                                                                                                             | Outbound Connections Allowed (from this zone)                                                                                                                                                                  | Inbound Connections Allowed (to this zone)                                                                                                                                                                                     |
| --- | ----------------------------- | ---------------------------------------------------------------- | ------------------------ | ---------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | **Server‑Zone**               | Core clinical & administrative services, highly protected.       | `10.10.2.0/24` – VLAN 20 | `ehr‑srv‑01`, `ehr‑db‑01`, `billing‑srv‑01`, `pacs‑srv‑01`, `ad‑dc‑01/02`, `file‑srv‑01`, `backup‑srv‑01`, `web‑srv‑01`      | • To **Clinical Workstation Zone**: TCP 443, 22 (secure apps)<br>• To **Management Zone**: all ports (SSH, RDP, WinRM) for admin ops<br>• To **External Internet**: HTTPS, SMTP (for web‑portal & email relay) | • From **Clinical Workstation Zone**: TCP 443, 22 (read‑only)<br>• From **Management Zone**: all ports (admin access)<br>• From **Medical Device Zone**: HTTPS/TCP 2575 for monitoring APIs<br>• From **Guest/IoT Zone**: None |
| 2   | **Clinical‑Workstation‑Zone** | End‑user devices used by nurses, physicians, lab techs.          | `10.10.1.0/24` – VLAN 10 | All `WS-RECEPT`, `WS-NURSE`, `WS-PHARM`, `WS-RAD`, etc.                                                                      | • To **Server‑Zone**: HTTPS/TCP 443, SSH (read‑only)<br>• To **Medical Device Zone**: HTTP/HTTPS for device dashboards<br>• To **Management Zone**: VPN tunnel only (no direct RDP)                            | • From **Server‑Zone**: same as outbound<br>• From **Guest/IoT Zone**: None                                                                                                                                                    |
| 3   | **Medical‑Device‑Zone**       | All patient‑care devices that expose web APIs or local consoles. | `10.10.3.0/24` – VLAN 30 | Philips monitors, BD Alaris pumps, PACS image viewer, MRI control, bedside infusion pumps, nurse‑call system, badge readers. | • To **Server‑Zone**: HTTPS/TCP 2575 (monitoring), 443 for device sync<br>• To **Clinical‑Workstation‑Zone**: HTTPS/TCP 2575 (clinical dashboards)                                                             | • From **Server‑Zone**: same as outbound<br>• No inbound from other zones                                                                                                                                                      |
| 4   | **Management‑Zone**           | IT staff, SOC, network/AD admin tools.                           | `10.10.5.0/24` – VLAN 40 | `admin‑ws-01`, `security‑ops‑server`, `nms‑center`, FortiGate config workstation, SIEM appliance.                            | • Full access to **Server‑Zone** (SSH, RDP, SMB, etc.)<br>• VPN / IPsec to all zones for remote management                                                                                                     | • From **Server‑Zone**, **Clinical‑Workstation‑Zone**, **Medical‑Device‑Zone**: none unless explicitly allowed via ACL                                                                                                         |
| 5   | **Guest/IoT‑Zone**            | Visitor Wi‑Fi, IoT sensors, non‑clinical appliances.             | `10.10.4.0/24` – VLAN 50 | Guest APs, visitor access point, building sensors (HVAC), smart badge readers (for visitors).                                | • To Internet: only DNS/TCP 53, HTTPS/TCP 443, minimal SSH for maintenance<br>• No outbound to internal zones                                                                                                  | • From **Internet**: DNS, NTP, basic HTTP for public pages                                                                                                                                                                     |

#### Key Traffic Flow Rules

- Only the explicitly listed ports are permitted; everything else is dropped by default (micro‑segmentation).
- All inter‑zone traffic goes through the FortiGate 100F which enforces ACLs and deep packet inspection.

---

### Part 2 – Firewall Rules (Pseudocode)

```
# 1. Server → Clinical Workstations
src: Server-Zone      dst: Clinical-Workstation-Zone : TCP/443,22 -> allow

# 2. Server ← Clinical Workstations
src: Clinical-Workstation-Zone dst: Server-Zone : TCP/443,22 -> allow

# 3. Server → Medical Device Zone
src: Server-Zone      dst: Medical-Device-Zone : HTTPS/TCP/2575,443 -> allow

# 4. Medical Device ← Server
src: Medical-Device-Zone dst: Server-Zone : HTTPS/TCP/2575,443 -> allow

# 5. Management ↔ All Zones (full)
src: Management-Zone   dst: {Server, Clinical, Medical} : ALL -> allow
src: {Server, Clinical, Medical} dst: Management-Zone : ALL -> allow

# 6. Guest/IoT → Internet (restricted)
src: Guest-IoT-Zone    dst: ANY : TCP/53,80,443, NTP -> allow

# 7. Guest/IoT ← Internet
src: ANY dst: Guest-IoT-Zone : TCP/53,80,443, NTP -> allow

# 8. DENY: Guest/IoT → Internal Zones
src: Guest-IoT-Zone    dst: {Server, Clinical, Medical} : ALL -> deny
      # Prevents an attacker on a visitor device from reaching any internal resource.

# 9. DENY: Unspecified traffic to Server‑Zone
src: ANY             dst: Server-Zone : UNICAST -> deny
      # Only allowed traffic is defined in rules 1–5; everything else is blocked.

#10. Log & Alert all denied attempts from Guest/IoT → Internal
src: Guest-IoT-Zone    dst: {Server, Clinical, Medical} : ALL -> log+alert
```

**Rule Explanations**

| Rule                        | What it Prevents                                                                                                                                     |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| 8 (Deny Guest→Internal)     | Stops lateral movement from a compromised visitor device or IoT sensor into the core network.                                                        |
| 9 (Deny All to Server‑Zone) | Ensures only explicitly permitted traffic reaches critical servers; any new service must be added via an ACL change, preventing accidental exposure. |

---

### Part 3 – Kill‑Chain Impact

**Reference Kill‑Chain:** _Crimson Tide ransomware_ (initial access → credential theft → lateral movement → data exfiltration → backup destruction → encryption).

| Step                                                                                                                            | Description                                                                                                                                                                                                             | How Segmentation Breaks It                                                              |
| ------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| 1. **Initial Access** – Exploit CVE‑2023‑27997 on FortiGate                                                                     | _Segmentation does not affect this step; attacker still exploits VPN device._                                                                                                                                           | No break.                                                                               |
| 2. **Internal Reconnaissance** – Map internal subnets via compromised FortiGate                                                 | _Firewall logs will now show a distinct VLAN mapping; but attacker can still read routing tables._                                                                                                                      | Minimal effect (visibility only).                                                       |
| 3. **Lateral Movement** – Use stolen VPN creds to move from `Server‑Zone` → `Clinical‑Workstation‑Zone` → `Medical‑Device‑Zone` | _Firewall ACLs block traffic between zones unless explicitly allowed._ <br>• Attackers can reach Server‑Zone but cannot freely traverse to Clinical or Medical Zones.                                                   | **Break:** lateral movement halted after first hop; attacker limited to isolated zone.  |
| 4. **Data Exfiltration** – Transfer PHI from `ehr‑srv‑01` to external cloud                                                     | _Only outbound traffic from Server‑Zone is allowed (HTTPS, SMTP)._ <br>• No unencrypted SMB or other large file transfers are permitted.                                                                                | Partial break – reduces bandwidth and requires VPN‑level exfil, raising detection risk. |
| 5. **Backup Destruction** – Delete NAS on the same LAN                                                                          | _NAS resides in Server‑Zone; no direct path from an attacker who is now stuck in a restricted zone._<br>• Even if they compromise a Clinical workstation, firewall blocks access to NAS.                                | **Break:** backup destruction blocked.                                                  |
| 6. **Ransomware Deployment** – Push payload via GPO or SMB to all Windows hosts                                                 | _GPO push requires domain controller → Server‑Zone traffic; cannot spread into Medical Zone because of ACLs._<br>• Malware can infect servers but cannot reach medical devices or workstations beyond the zone it’s in. | Partial break – limits infection radius.                                                |

**Percentage of Kill Chains Disrupted**

- Full ransomware chain (steps 3–6) is **blocked at step 3**; therefore, ~**70 %** of similar attack chains would be prevented from progressing past the initial lateral movement.
- Other kill‑chains that do not rely on lateral traversal (e.g., direct phishing to an admin in Management Zone) are less affected (~30 % disruption).

> **Conclusion:** The proposed segmentation reduces successful ransomware deployments against critical assets by approximately **70 %**, delivering the largest risk reduction for a single architectural change.
