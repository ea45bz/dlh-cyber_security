Vulnerability Scenario: A remote code execution vulnerability in a widely used web server software. The vulnerability allows an attacker to execute arbitrary code remotely without requiring authentication.

| Metric                                                                    | Value (for this scenario) | Numeric value |
| ------------------------------------------------------------------------- | ------------------------- | ------------- |
| **Attack Vector** – how the attacker reaches the target                   | _Network_                 | 0.85          |
| **Attack Complexity** – conditions that make the attack harder or easier  | _Low_                     | 0.77          |
| **Privileges Required** – attacker’s privileges before exploitation       | _None_ (no auth needed)   | 0.85          |
| **User Interaction** – does a user have to do something?                  | _None_                    | 0.85          |
| **Scope** – does the exploit change privilege levels of other components? | _Unchanged_               | –             |

- **5.0 → Medium severity.**

The combination of network reachability and full control justifies rapid patching and robust containment measures.
