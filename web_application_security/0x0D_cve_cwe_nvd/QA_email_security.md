## Email Security Fundamentals  

| Question | Short Answer |
|----------|--------------|
| **What is email authentication and why is it important?** | Checks that a message really comes from the domain it claims to, protecting recipients from spoofed mail. |
| **What are the main threats that email authentication protocols protect against?** | Spoofing, phishing, domain impersonation, spam‑relay hijacking. |
| **How do SPF, DKIM, and DMARC work together to provide comprehensive email security?** | SPF verifies sending IP, DKIM signs message content, DMARC aggregates those results and applies policy (none/quarantine/reject). |
| **What is the difference between email spoofing and domain impersonation?** | Spoofing mimics a sender address; impersonation also tricks recipients into believing they’re interacting with a trusted domain. |

---

## Sender Policy Framework (SPF)  

| Question | Short Answer |
|----------|--------------|
| **What is SPF and what problem does it solve?** | DNS‑based list of authorized mail‑servers, stops unauthorised hosts from sending mail for a domain. |
| **How does SPF authorize sending mail servers?** | The receiving server queries the domain’s TXT record; each mechanism (ip4/ip6/ptr/mx/a/include) lists permitted IPs. |
| **What is the correct syntax for an SPF record?** | `v=spf1 <mechanisms> [<qualifiers>] -all` (published as a single‑line TXT). |
| **Mechanisms and when to use them** | `ip4/ip6` – specific ranges; `include:` – include another domain’s policy; `mx:` – the domain’s MX hosts; `a:` – the A/AAAA of host; `all` – default catch‑all. |
| **Qualifiers (+/-/~/?), meaning** | `+` pass, `-` fail, `~` softfail (treat as suspicious), `?` neutral (no recommendation). |
| **SPF evaluation order and why it matters** | Left‑to‑right, first matching mechanism stops evaluation; ordering controls precedence of allowed IPs vs. rejects. |
| **Results** | `pass`, `fail`, `softfail`, `neutral`, `temperror` (temporary DNS error), `permerror` (malformed record). |
| **10‑DNS‑lookup limit & why** | To keep validation fast and prevent DoS; includes `include:`, `mx:`, `a:`, `ptr:` count toward the 10 lookups. |
| **Why forwarding breaks SPF & mitigation** | Forwarding changes IP; add `-all` and use a “bounce‑to” domain with its own SPF or rely on DKIM+DMARC. |
| **What does `-all` mean?** | Explicitly rejects any server not listed earlier; ensures strict enforcement. |
| **How to test/validate an SPF record?** | Use tools like dig, `nslookup -q=TXT <domain>`, or online validators (e.g., MXToolbox). |

---

## DomainKeys Identified Mail (DKIM)  

| Question | Short Answer |
|----------|--------------|
| **What is DKIM and how does it differ from SPF?** | DKIM cryptographically signs message headers/body; unlike SPF which only checks the IP. |
| **How does DKIM use signatures?** | Signer creates hash of selected fields, encrypts with its private key; receiver verifies using public key in DNS. |
| **What is a DKIM selector and why used?** | Short label identifying the key pair; allows multiple keys per domain (key rotation or different senders). |
| **Components of a DKIM signature header** | `v=DKIM1; a=rsa-sha256; c=simple/simple; d=<domain>; s=<selector>; h=<headers>; bh=<bodyhash>; b=<signature>`. |
| **Signing process (step‑by‑step)** | 1. Pick headers to sign. 2. Canonicalize them. 3. Compute hash. 4. Sign with private key. 5. Add `DKIM-Signature` header. |
| **Verification process** | 1. Retrieve public key via `selector._domainkey.domain`. 2. Re‑canonicalize headers/body. 3. Verify signature against hash. |
| **Canonicalization methods** | `simple/simple`: no changes; `relaxed/relaxed`: fold lines, ignore whitespace. Use relaxed for body if minor edits are expected (e.g., MIME). |
| **DKIM DNS record format** | TXT: `v=DKIM1; k=rsa; p=<base64‑encoded public key>`. |
| **Generate DKIM keys & recommended size** | 2048‑bit RSA (or ECC if supported); use OpenSSL or hosting provider tools. |
| **Why DKIM forwarding‑friendly?** | Signature is on the message body, not altered by forwarders; SPF fails but DKIM can still validate. |
| **Key rotation** | Create new selector/key pair, publish in DNS, sign outgoing mail with new key for a period, then retire old key after all mail has been signed with new one. |
| **Test/validate signatures** | Use `openssl dgst -sha256`, online DKIM validators, or email‑clients that show DKIM status. |

---

## Domain‑based Message Authentication, Reporting & Conformance (DMARC)  

| Question | Short Answer |
|----------|--------------|
| **What is DMARC and how does it build on SPF/DKIM?** | Policy framework that tells receivers how to treat mail that fails SPF or DKIM, plus reporting. |
| **Required and optional tags** | `v=DMARC1` (required); required: `p=`; optional: `rua=`, `ruf=`, `pct=`, `sp=`, `adkim=`, `aspf=`, etc. |
| **Policy levels** | `none` – no action, only report. <br>`quarantine` – treat as spam/unknown. <br>`reject` – drop or refuse. |
| **DMARC alignment** | Ensures the domain in SPF (`envelope-from`) or DKIM signature matches the message’s From: domain. |
| **Strict vs relaxed alignment** | Strict – domains must match exactly; Relaxed – second‑level subdomains allowed (e.g., `mail.example.com` aligns with `example.com`). |
| **Evaluation of SPF/DKIM** | Receiver checks if either passes *and* is aligned; DMARC uses that to decide policy. |
| **Conditions for DMARC pass** | Either SPF or DKIM passes *and* the domain in that result aligns with From:. |
| **pct tag** | Percentage of messages subject to policy (0‑100); used for gradual rollout. |
| **sp tag** | Subdomain policy; if omitted, subdomains inherit parent’s `p=`. |
| **Aggregate reports (RUA)** | XML file summarizing authentication results per day (counts, IPs, etc.). |
| **Forensic reports (RUF)** | Full message payload for failures; sent only if supported and when `ruf` is set. |
| **Parse/analyze DMARC reports** | Use tools like OpenDMARC, DMARCian, or custom scripts to transform XML into CSV/JSON. |
| **Recommended deployment strategy** | 1️⃣ Publish `p=none`. ⬇️ Collect data for ~30 days → analyze → move to `quarantine` (pct=100) → finally to `reject`. |

---

## Protocol Integration  

| Question | Short Answer |
|----------|--------------|
| **How do SPF, DKIM, DMARC work together in the authentication flow?** | Receiver checks SPF (IP), DKIM (signature), then DMARC decides policy based on alignment of either. |
| **What if SPF passes but DKIM fails?** | DMARC can still pass if `p=` is `none` or `quarantine`, or fail if both failed and policy is stricter. |
| **If SPF fails but DKIM passes?** | Same: DMARC passes if DKIM is aligned; otherwise falls back to policy. |
| **If both fail?** | DMARC will enforce its policy (reject/quarantine/none). |
| **What threats does each protocol protect against?** | SPF – IP spoofing, spam relays. <br>DKIM – tampering, forging message body. <br>DMARC – all above plus reporting abuse. |
| **Limitations** | SPF: broken by forwarding. <br>DKIM: requires signing, vulnerable to key compromise. <br>DMARC: only works when SPF/DKIM are implemented; no protection if neither is present. |

---

## Implementation & Configuration  

| Question | Short Answer |
|----------|--------------|
| **How do you implement SPF for a domain?** | Create TXT record `v=spf1 ... -all`; list all legitimate senders (IP, MX, include). |
| **How do you implement DKIM?** | Generate key pair → publish public key in TXT at `selector._domainkey.<domain>`; configure mail server to sign outgoing mail. |
| **How do you implement DMARC?** | Add TXT record `_dmarc.<domain>`: e.g., `v=DMARC1; p=none; rua=mailto:dmarc-agg@<domain>`. |
| **Correct order for implementation?** | SPF → DKIM (so signing can happen) → DMARC. |
| **Configure subdomain policies?** | Set `sp=` in parent or add separate `_dmarc.sub.<domain>` record. |
| **Handle third‑party services in SPF?** | Use `include:thirdparty.com` or explicit IP ranges; keep under lookup limit. |
| **Troubleshoot authentication failures?** | Verify DNS propagation, check mechanisms order, test with `sendmail`, examine headers (`Received-SPF`, `DKIM-Signature`, `Authentication-Results`). |

---

## DNS & Technical Details  

| Question | Short Answer |
|----------|--------------|
| **Where are SPF/DKIM/DMARC records published?** | As TXT records (SPF, DMARC) and DKIM uses TXT at `selector._domainkey`. |
| **What DNS record type is used?** | TXT. |
| **How to query using dig/nslookup/tools?** | `dig txt <record>`, `nslookup -q=txt <record>`, or online utilities like MXToolbox. |
| **Format of each record** | SPF: `v=spf1 ... -all`; DKIM: `v=DKIM1; k=rsa; p=<key>`; DMARC: `v=DMARC1; p=none; rua=...`. |
| **DNS lookups for SPF includes?** | Each `include:` or `a/mx/ptr` triggers a separate DNS query; all count toward the 10‑lookup limit. |
| **DKIM public key lookup** | One TXT query at `selector._domainkey.domain`; no additional lookups unless the record contains pointers (rare). |

---

## Best Practices & Common Mistakes  

| Question | Short Answer |
|----------|--------------|
| **SPF best practices** | Keep under 10 lookups, use IP4/6 ranges not hosts, avoid `+all`, publish as TXT, test after changes. |
| **DKIM key management** | Use 2048‑bit RSA (or ECC), rotate every 3–12 months, keep selector names unique, never expose private key. |
| **DMARC deployment best practices** | Start with `p=none`; monitor aggregate reports; shift to quarantine after clean results; finally reject. |
| **Common mistakes** | Forgetting to publish SPF; using `ptr` (slow); mis‑aligned DKIM selectors; not setting `adkim/aspf`; using `-all` before testing. |
| **Avoid 10‑lookup limit** | Flatten includes, use IP ranges, combine multiple hosts into single mechanism. |
| **Never use `+all`** | It defeats authentication by allowing any server to send mail for the domain. |
| **Start with `p=none` in DMARC** | Allows collection of data without impacting delivery. |
| **Key rotation frequency** | Every 3–12 months; depends on risk profile and compliance requirements. |

--- 

> **Quick reference cheat‑sheet:**  
> • SPF = “who may send.”  
> • DKIM = “what the message really is.”  
> • DMARC = “policy + reports” based on the two above.

Let me know if you need deeper dives into any particular step or tool.