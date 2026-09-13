Observation 1 – Server Room Access:
Vulnerability: Generic badge opens server‑room door; no video surveillance or visitor log.
Threat: An unauthorized staff member or outsider obtains a badge and physically enters the server room, removes or tamper with servers/patch panels.
Impact: _Confidentiality_ – data on servers may be exfiltrated; _Integrity_ – hardware/software could be altered; _Availability_ – removal of critical servers disrupts services.
Severity: Critical – Physical intrusion into the heart of IT can compromise all hosted assets and disrupt patient‑care services.

---

Observation 2 – Network Closet:
Vulnerability: Unlocked closet with exposed network equipment and a printed “Network Maintenance Credentials” sheet containing a username/password for switch management.
Threat: An insider or opportunistic visitor retrieves the credentials, logs into the switches, reconfigures VLANs, opens management ports to the Internet, or installs rogue firmware.
Impact: _Confidentiality_ – unauthorized access to network traffic; _Integrity_ – malicious configuration changes; _Availability_ – denial‑of‑service if critical ports are closed.
Severity: High – Misconfiguration or compromise of core switches threatens the entire LAN and exposed services.

---

Observation 3 – Nurse Station Workstation:
Vulnerability: A workstation remains logged into a patient’s EHR record with no one present; sign discourages logging out between shifts.
Threat: An unauthorized employee, visitor, or thief simply opens the workstation to view the patient’s record.
Impact: _Confidentiality_ – patient's record is exposed without proper access controls.
Severity: High – Direct breach of patient privacy and potential HIPAA violations.

---

Observation 4 – Medical IoT Device:
Vulnerability: Vital‑sign monitor shows its IP address on the screen; firmware is outdated (v2.1.3, 2019); device shares the same internal IP subnet as workstations.
Threat: An attacker scans the network, identifies the monitor’s IP, exploits a known vulnerability in the old firmware to gain command‑and‑control access or tamper with patient data.
Impact: _Integrity_ – dosage/diagnostic data may be altered; _Confidentiality_ – device logs could leak PHI; _Availability_ – malfunctioning monitors endanger patient safety.
Severity: High – Compromise of critical medical devices can directly harm patients and violate regulatory requirements.

---

Observation 5 – Emergency Exit / Staff Passage:
Vulnerability: Fire exit propped open with a wedge, no restriction; hallway visible to IT and James Chen’s office.
Threat: An outsider gains temporary physical access to the IT area via the unsealed exit, then climbs onto equipment or tampers with cable infrastructure.
Impact: _Confidentiality_ – opportunity to sniff traffic or capture data; _Integrity_ – risk of tampering with network gear; _Availability_ – potential for service disruption.
Severity: Medium – While not directly compromising critical assets, it creates a clear physical pathway that lowers overall security posture and could facilitate more serious attacks.

---
