# E-commerce Platform

## 1. Identify three STRIDE threats for the checkout process. 


| STRIDE Category | Threat Description | Potential Impact | Suggested Mitigation |
|------------------|--------------------|------------------|----------------------|
| Spoofing  | An attacker hijacks a user’s session cookie or injects a forged token to perform a purchase on behalf of that user. | Fraudulent orders, loss of revenue, potential legal liability. | – Enforce HTTPS everywhere.<br>– Use secure, HttpOnly cookies with SameSite=Strict.<br>– Implement server‑side session validation (e.g., device fingerprinting). |
| Tampering  | A malicious user modifies the price or item quantity in the frontend request before it reaches the backend. | Incorrect billing, revenue loss, customer trust erosion. | – Recalculate prices on the server from authoritative data store.<br>– Sign order payloads and verify signature server‑side.<br>– Log all price changes for audit. |
| Information Disclosure  | An attacker intercepts or reads unencrypted payment data (card numbers, CVV) during transit. | Payment card theft → chargebacks, PCI‑DSS non‑compliance, brand damage. | – Enforce TLS 1.2/1.3 on all endpoints.<br>– Store only the last four digits of cards; never persist full PANs unless PCI‑DSS compliant.<br>– Use Stripe Elements / Checkout to offload card handling entirely to Stripe. |

---

## 2. What trust boundaries exist in this system?

| Boundary | Untrusted side → Trusted side | Why it matters |
|----------|------------------------------|----------------|
| **Client ↔ Node.js API** | Browser → Server | User input flows across the internet; all data must be validated/sanitized before use. |
| **Node.js API ↔ PostgreSQL DB** | Application layer → Data store | Database commands come from trusted code; still need to guard against SQL injection, improper privileges. |
| **Node.js API ↔ Stripe** | Server → External payment gateway | External calls must be authenticated (API keys) and response validated; data leaving the system is sensitive. |
|**React Frontend ↔ Browser execution context** | JavaScript code ↔ User’s device | Code can be tampered with in the user’s browser; protects against script injection attacks. |

---

## 3. Rate the threat of SQL injection in the product search functionality using DREAD

| Factor | Score (0–10) | Justification |
|--------|---------------|----------------|
| **Damage Potential** | 8 | Successful injection could expose all product data, pricing, inventory, or even user data if joins are involved. |
| **Exploitability** | 7 | The search endpoint is publicly reachable; if it concatenates user input into SQL, exploitation is straightforward. |
| **Affects** | 9 | Nearly every visitor uses the search bar; a single vulnerable page affects the entire user base. |
| **Discoverability** | 6 | The URL (`/search?q=`) is obvious and can be found via fuzzing or simple probing. |
| **Reproducibility** | 8 | Once the flaw is known, it can be repeated against any instance of the same code path. |
| **Total DREAD Score** | **38 / 50** | *High* threat—prioritize patching, input sanitization, and use parameterized queries or an ORM. |

---
