# Exercise 1: Deconstruction

### 1. What each part of the vector means

| Metric                  | Abbreviation | Value in the scan | Meaning of that value                                                                                                                     | Other possible values & how they change the score                                                                                                       |
| ----------------------- | ------------ | ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Attack Vector**       | AV           | N                 | _Network_ – the vulnerability can be triggered by an attacker who can reach the target over a network (usually Internet or internal LAN). | A (Adjacent) = 0.62, L (Local) = 0.55, P (Physical) = 0.20. Lower values reduce the **Exploitability** sub‑score, thus lowering the overall base score. |
| **Access Complexity**   | AC           | L                 | _Low_ – the attacker does not need special conditions; any user can launch the attack once network access is available.                   | M (Medium) = 0.44, H (High) = 0.20. Higher complexity raises the sub‑score and therefore the base score.                                                |
| **Privileges Required** | PR           | N                 | _None_ – an attacker needs no privileges on the system to exploit the flaw.                                                               | L (Low) = 0.62, H (High) = 0.27. Requiring privileges lowers the sub‑score.                                                                             |
| **User Interaction**    | UI           | N                 | _None_ – the attack can be carried out without any user action.                                                                           | R (Required) = 0.95. If user interaction were needed, the sub‑score would drop slightly.                                                                |
| **Scope**               | S            | U                 | _Unchanged_ – exploitation of this vulnerability does not affect components other than the one it directly attacks.                       | C (Changed) – increases the Impact sub‑score by a larger multiplier.                                                                                    |
| **Confidentiality**     | C            | H                 | _High_ – an exploit results in full loss of confidentiality (e.g., data read).                                                            | L = 0.22, N = 0.00. Lower values reduce impact.                                                                                                         |
| **Integrity**           | I            | H                 | _High_ – the attacker can modify or delete data.                                                                                          | Same as C.                                                                                                                                              |
| **Availability**        | A            | H                 | _High_ – the service becomes unavailable (e.g., crash).                                                                                   | Same as C.                                                                                                                                              |

#### Why those values were chosen for CVE‑2021‑44790

AV:N The flaw is triggered via a malicious HTTP request sent over the network to Apache’s `mod_lua`.|
AC:L The exploit only requires sending a crafted multipart body; no special setup or conditions. |
PR:N No authentication or privileged user context is needed; any web‑server user (www-data) can trigger it. |
UI:N An attacker just needs to send the request; no end‑user interaction is required. |
S:U The vulnerability affects only the Apache HTTP server process; it does not alter other system components. |
C/I/A:H Remote code execution allows an attacker to read, modify or delete any data and can crash or otherwise deny the service, giving full confidentiality, integrity and availability impact. |

---

### Score change if **AV** is switched from **N → L**

#### Original vector

`AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H` → Base score = **9.8**

| Calculation step                                         | Value  |
| -------------------------------------------------------- | ------ |
| AV = 0.85 (Network)                                      | –      |
| AC = 0.77 (Low)                                          | –      |
| PR = 0.85 (None, S:U)                                    | –      |
| UI = 0.85 (None)                                         | –      |
| **Exploitability** = 8.22 × AV × AC × PR × UI            | ≈ 3.88 |
| Impact metrics all _H_ → `Impact` = 1 – (0.44³) ≈ 0.9148 | –      |
| **Impact sub‑score** = 6.42 × Impact                     | ≈ 5.87 |
| **Base score** (rounded to one decimal)                  | 9.8    |

#### New vector

`AV:L/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`

- AV now equals **0.55** (Local).

| Calculation step                                      | Value   |
| ----------------------------------------------------- | ------- |
| **Exploitability** = 8.22 × 0.55 × 0.77 × 0.85 × 0.85 | ≈ 2.52  |
| Impact sub‑score remains 5.87                         | –       |
| Sum = 5.87 + 2.52 = 8.39                              | –       |
| **Base score** (rounded)                              | **8.4** |

#### Why the score drops

The Attack Vector metric directly influences the _Exploitability_ sub‑score:

- Network (0.85) → higher likelihood that an attacker can reach the target.
- Local (0.55) → attacker must already be on or have access to the host, making exploitation harder.

Because Exploitability contributes directly to the final base score, lowering AV from **N** to **L** reduces the overall score from **9.8** to **8.4**, reflecting a slightly lower ease of attack though the impact (confidentiality/integrity/availability) remains unchanged.

# Exercise 2: Construction

CVSS vector string:
'''
CVSS:3.1/AV:A/AC:H/PR:L/UI:N/S:U/C:H/I:N/A:N
'''

CVSS Base Score: 4.7
Severity: Medium

# Exercise 3: Comparison

1. CVE: CVE-2021-44790
   CVSS Base: 9.8
   Vector: CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
   Impact Subscore: 5.9
   Exploitability Subscore: 3.9

2. CVE: CVE-2019-0211
   CVSS Base: 7.8
   Vector: CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H
   Impact Subscore: 5.9
   Exploitability Subscore: 1.8

Exploitability is the major difference, attacker needs access to the network
