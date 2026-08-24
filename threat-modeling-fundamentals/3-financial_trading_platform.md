# Financial Trading Platform

## 1. Which CIA component is most critical for this system and why? 

Integrity is the most critical, the platform must guarantee exact trade data, order execution, and account balances.

**Can security requirements conflict with performance requirements?**

Performance must not compromise integrity, optimization can the done on configuraion and infrastructure.

---

## 2. Threat model the "automated trading rules" feature. What are the top three risks and how would you mitigate them?

| Risk | Why it matters | Mitigation |
|------|----------------|------------|
| **Logic & Arithmetic Bugs** | Off‑by‑one or rounding errors can trigger thousands of erroneous orders, wiping out accounts. | • Code‑review + formal verification for core math.<br>• Unit tests with fuzzing on boundary values.<br>• Runtime assertions and safety checks (e.g., max position limits). |
| **Race Conditions / Order Conflicts** | Two concurrent rule engines may double‑execute the same trade or create a deadlock, causing lost profits or cascading failures. | • Serialize access to shared data structures via *transactional memory* or *locking*. <br>• Use event‑driven architecture (e.g., actor model) with message ordering guarantees. |
| **Unauthorized Rule Modification** | An attacker who gains write access can inject malicious logic that trades against the user’s interests. | • Strict role‑based access control; rules stored in immutable, signed data structures.<br>• Digital signing of rule payloads + integrity checks on load.<br>• Continuous monitoring and alerts for rule changes (audit trail). |

---


## 3. An attacker compromises a user account. What defense-in-depth controls should limit the damage? List at least five layers of security.


| Layer | Controls | Purpose |
|-------|----------|---------|
| **1. Authentication & MFA** | Password + TOTP / push notification + device fingerprinting | Prevents initial compromise; limits session hijackability. |
| **2. Least‑Privilege & Role-Based Access Control (RBAC)** | Users can only edit or execute rules they created, not admin functions. | Narrows the attack surface once inside. |
| **3. Transaction/Order Limits** | Per‑minute order cap, per‑day monetary ceiling, max position size checks. | Catches large anomalous trades early; protects liquidity. |
| **4. Anomaly & Fraud Detection** | Machine‑learning models on trade patterns, velocity monitoring, deviation thresholds. | Flags suspicious activity in real time for manual review or auto‑freeze. |
| **5. Immutable Audit Trail & Logging** | Write‑once storage (e.g., append‑only database, blockchain logs) for all authentication events, rule changes, and executed orders. | Enables post‑incident forensic analysis and regulatory compliance. |
