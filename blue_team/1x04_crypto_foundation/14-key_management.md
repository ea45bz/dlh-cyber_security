# Part 1 - Technology Comparison

| Technology                                                          | What It Is                                                                                                 | What It Protects                                                                                           | Typical Cost                                                                                                                                   | Typical Deployment                                                                                            |
| ------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| **TPM** (Trusted Platform Module)                                   | A small, tamper‑resistant chip on the motherboard that stores keys                                         | - Platform integrity measurement<br>- Key storage for local disk encryption, user authentication tokens    | **$20–$50 per server** (OEM cost).                                                                                                             | Embedded in most modern servers/desktops; accessed via OS APIs (`tpm2-tools`, `Windows BitLocker`).           |
| **HSM** (Hardware Security Module)                                  | A dedicated cryptographic appliance that generates, stores and uses keys under strict physical protection. | - Any application‑critical key: database TDE, TLS server certs, VPN pre‑shared keys, cloud KMS integration | **$5 – $10 / key/month** for cloud HSM services (e.g., AWS CloudHSM, Azure Key Vault HSM) or **$12 k–$25 k upfront** for an on‑prem appliance. | Physical rack unit or virtual instance in a secure data center; accessed via APIs (`PKCS#11`, `AWS KMS SDK`). |
| **Secure Enclave** (Intel SGX, Apple Secure Enclave, ARM TrustZone) | A protected CPU subsystem that isolates code and data from the rest of the OS.                             | - Local application secrets (e.g., session keys), sensitive computation results                            | **No separate hardware cost**; depends on platform (free with iOS/macOS/Windows 10).                                                           | Built into modern CPUs or mobile SoCs; accessed via SDKs (`sgx-sdk`, Apple CryptoKit).                        |
| **KMS (Software)**                                                  | A software‑based key vault running inside an application server or container.                              | - Non‑mission critical keys, test data encryption, dev environments                                        | **$0–$200/month** (open‑source like HashiCorp Vault) + compute cost                                                                            | Runs on any Linux/Windows host; accessed via REST APIs or CLI (`vault`).                                      |

> _TPM_ protects only the machine it resides in.  
> _HSM_ is a centralized, highly secure key store that can be shared across many services.  
> _Secure enclave_ is ideal for protecting secrets inside a single host (e.g., a web server).  
> _Software KMS_ provides convenience but should not hold keys that protect PHI in production.

---

# 2 MedDefense Key Management Design

| Asset                                                      | Encryption Key(s)                         | Storage Location                                                              | Who Can Access?                                                                          | Rotation Policy                                                                                                            | Compromise Procedure                                                                                                                                                               | Lost‑Key Procedure                                                                                                                                                                            |
| ---------------------------------------------------------- | ----------------------------------------- | ----------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **patient database (PostgreSQL TDE)**                      | Master key `DB‑TDE‑MK`                    | **Dedicated HSM** (cloud HSM, AWS CloudHSM) via `PKCS#11`.                    | _System Admins_ (via privileged CLI), _Database Engineers_, _Security Officer_ (audits). | **Annual** – key rollover in a phased “key‑wrap” process; new key wrapped with current master, then re‑encrypt all tables. | 1. Mark `DB‑TDE‑MK` as compromised.<br>2. Generate new HSM master key.<br>3. Re‑wrap all data using the new key (online or offline job).<br>4. Update DB config; restart services. | 1. Recover from **key escrow** stored in a separate, offline HSM in another region.<br>2. If escrow is missing → data becomes unrecoverable; trigger incident response and notify regulators. |
| **Backup Storage (NAS‑01)**                                | NAS encryption key `NAS‑ENC‑K`            | **TPM** on each NAS node or a **dedicated HSM** for cross‑site sync.          | _Storage Admins_, _Infrastructure Ops_ (via SSH/Ansible), _Security Officer_.            | **Quarterly** – re‑encrypt volumes, update TPM keys, rotate in the cloud KMS.                                              | Immediate key revocation; generate new NAS key; re‑encrypt backups locally and on the remote replica; audit logs for access.                                                       | Use a **vaulted backup of the TPM seed** (encrypted with an offline key) stored at the corporate vault.                                                                                       |
| **Portal TLS**                                             | Server certificate private key `SSL‑KEY`. | **HSM** in the web‑server rack or **cloud HSM** if services are cloud‑hosted. | _System Admins_, _Web Ops_; only read via application, no direct file access.            | Replace the cert every 90 days; rotate the private key yearly (or after any breach).                                       | Revoke current certificate in CA portal, generate new CSR, store new key in HSM, redeploy web server.                                                                              | Keep a **key escrow** of the previous HSM key in an offline vault; if lost, regenerate and re‑issue certs.                                                                                    |
| **VPN Tunnels (site‑to‑site)**                             | Pre‑shared keys or PSK `VPN‑PSK`.         | **HSM** (or secure enclave on FortiGate).                                     | _Network Admin_, _Security Officer_.                                                     | Every 6 months – generate new PSKs, push to all FortiGates via automated scripts.                                          | If compromised: invalidate old PSK in HSM; immediately re‑key tunnels; audit for anomalous traffic.                                                                                | Use **HSM key backup** (offline) as escrow.                                                                                                                                                   |
| **All other application secrets (API keys, DB passwords)** | Random strings or KDF outputs             | **Software KMS (Vault)** with encryption-at-rest via HSM integration.         | _Developers_, _Ops_ under RBAC.                                                          | Quarterly review; daily rotation for high‑risk secrets.                                                                    | Revoke secret in Vault, generate new one, update env vars.                                                                                                                         | Vault’s key‑wrap feature ensures recovery if keys are lost; otherwise application cannot start – triggers incident response.                                                                  |

**Key‑access policy diagram (simplified)**

```
┌───────────────────────┐
│   HSM / TPM / Vault  │
├─────────────┬─────────┤
│     Admins  │  Ops    │
│ (read/write)│(rotate) │
└─────────────┴─────────┘
```

_All key‑usage is logged via the HSM’s audit trail; any privileged action requires two‑factor authentication._

---

# 3 The HSM Decision

### Risk from the Register

| Threat                                            | Likelihood (annual) | Impact (USD)                                          |
| ------------------------------------------------- | ------------------- | ----------------------------------------------------- |
| **Key compromise** (e.g., stolen or mis‑used key) | 0.10 (10 %)         | $1,200,000 (PHI breach, regulatory fines, litigation) |

### ALE Calculation

```
ALE = Likelihood × Impact
ALE = 0.10 × 1,200,000 ≈ $120,000 per year
```

### HSM Cost Estimate

| Option                             | Cost per month                            | Annual Cost |
| ---------------------------------- | ----------------------------------------- | ----------- |
| **Cloud HSM (e.g., AWS CloudHSM)** | $2 / key/month × 4 keys = $8/mo           | $96/yr      |
| **Dedicated on‑prem appliance**    | $15,000 upfront + $1,200 maintenance/year | $16,200/yr  |
| **TPM + software KMS** (no HSM)    | ~$0 (TPM included) + $300 KMS per year    | $300/yr     |

> Even the most conservative estimate ($96 / yr) is far lower than the ALE of a key compromise ($120 k/yr).

### Justification

1. **Cost‑to‑Benefit**
   - _Cloud HSM_ protects all critical keys (DB, TLS, VPN). The yearly cost (~$100) is < 0.1 % of the potential breach impact.
2. **Risk Reduction**
   - An HSM enforces strict API access, key‑wraps, and provides tamper‑evidence logs that satisfy HIPAA & NIST SP 800‑57. The probability drop from 10 % to < 1 % is a net annual saving of ~$118 k.
3. **Operational Simplicity**
   - Centralized key store eliminates “key drift” and simplifies rotation across services, reducing human error risk.

> **Conclusion:** Deploying an HSM for database encryption (and other mission‑critical keys) is financially justified and materially reduces the overall risk profile.

---

## Summary of Recommendations

1. **Adopt a dedicated HSM** (cloud or on‑prem) to hold all critical keys: DB TDE, TLS certs, VPN PSKs.
2. **Use TPM** only for per‑host data that does not cross administrative boundaries (e.g., local workstation disk encryption).
3. **Implement an enterprise KMS** for application secrets; secure with the HSM and enforce strict RBAC.
4. **Automate key rotation**: DB keys once a year, TLS certs quarterly, VPN PSKs semi‑annually, backup keys quarterly.
5. **Maintain escrow backups** of all master keys in an offline vault in another region – the only path to data recovery if a key is lost.
6. **Document all access logs**, enforce MFA for privileged users, and schedule annual audits to verify compliance with HIPAA & NIST requirements.
