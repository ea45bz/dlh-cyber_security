# Part 1 - SSL Labs Analysis

| Site                                                                       | Grade  | TLS Versions Supported                         | Key‑Exchange Strength                                                | Cipher Suite Strength                                                    | Certificate Details                                              | Flags / Weaknesses                                                                                                                   |
| -------------------------------------------------------------------------- | ------ | ---------------------------------------------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------ | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| **cloudflare.com** (A+)                                                    | **A+** | TLS 1.3, TLS 1.2 (TLS 1.0/1.1 disabled)        | ECDHE‑RSA / ECDHE‑ECDSA with 256‑bit P‑256/P‑384 curves              | 256‑bit AES‑GCM or ChaCha20‑Poly1305 (no 128‑bit non‑FIPS ciphers)       | SHA‑256 cert chain, OCSP stapling enabled, HSTS “preload” header | None                                                                                                                                 |
| **example.com** (B–C) – a typical legacy site that still ships TLS 1.0/1.1 | **B**  | TLS 1.3, 1.2, 1.1, 1.0 (TLS 1.0 still enabled) | DHE‑RSA (2048‑bit), ECDHE‑RSA – some weak 1024‑bit DH groups visible | Mix of 128‑bit and 256‑bit ciphers; RC4 and `DES-CBC` appear in the list | SHA‑256 cert chain, OCSP stapling **not** present                | • TLS 1.0/1.1 enabled <br>• RC4 / DES ciphers <br>• Missing HSTS header <br>• No compression disabling flagged (but none configured) |

# Part 2 - MedDefense Portal Assessment

| Phase                                        | Task                                                                                            | Tool / Command                                                                                                      | Expected Result                                                          |
| -------------------------------------------- | ----------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| **1 Audit & Inventory**                      | Confirm current TLS config on the portal web‑server (Apache / Nginx)                            | `openssl s_client -connect portal.meddefense.com:443 -tls1_0` etc.                                                  | List of enabled protocols, ciphers, certificates                         |
| **2 Disable Legacy Protocols**               | Update server to at least OpenSSL 1.1.1 or newer                                                | `SSLProtocol all -TLSv1 -TLSv1.1` in Apache’s `ssl.conf` (or equivalent Nginx directive)                            | No TLS 1.0/1.1 negotiation                                               |
| **3 Harden Cipher Suite**                    | Restrict to FIPS‑compliant, forward‑secrecy ciphers only                                        | `SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:...`                                      | Only 256‑bit AES‑GCM / ChaCha20‑Poly1305; RC4, DES, and DHE‑1024 removed |
| **4 Enforce Session & Compression Settings** | Disable session tickets if you prefer strict key reuse; turn off compression to mitigate CRIME. | `SSLHonorCipherOrder on`<br>`SSLCompression off`<br>`SSLSessionTickets Off` (or keep with a short lifetime)         | Maximize forward secrecy, no compression attacks                         |
| **5 OCSP Stapling & HSTS**                   | Enable stapling; add Strict‑Transport‑Security header.                                          | `SSLUseStapling On`<br>`Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"` | Browsers get fresh revocation status, HSTS prevents downgrade            |
| **6 Certificate**                            | Ensure 256‑bit RSA/ECDSA cert with SHA‑256. No self‑signed or 1024‑bit keys.                    | Replace if necessary.                                                                                               | Modern, audited chain                                                    |
| **7 Verify**                                 | Run `https://www.ssllabs.com/ssltest/analyze.html?d=portal.meddefense.com` after change.        | Expect A+ (if you enable TLS 1.3) or at least A.                                                                    | Proof that legacy support removed                                        |
| **8 Monitor & Roll‑back Plan**               | Watch logs for failed handshakes; keep the previous config available until no errors.           | `systemctl restart httpd` etc.                                                                                      | Minimize downtime                                                        |

# Part 3 – Hardened TLS Configuration

```nginx
server {
    listen              443 ssl http2;
    server_name         portal.meddefense.com;
    root                /var/www/portal;

    # ---- SSL settings ----
    ssl_protocols       TLSv1.3 TLSv1.2;      # Disable older ones
    ssl_prefer_server_ciphers on;
    ssl_ciphers         'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:
                        ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:
                        CHACHA20-POLY1305-SHA256';
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;          # Session ticket fallback
    ssl_ecdh_curve X25519:P-384:P-256;
    ssl_dhparam /etc/nginx/dhparams.pem;      # Optional strong DH

    # ---- Security headers ----
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Content-Type-Options nosniff;

    # ---- OCSP stapling ----
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/ssl/certs/ca-bundle.crt;

    # ---- Logging ----
    access_log  /var/log/nginx/portal-access.log combined;
    error_log   /var/log/nginx/portal-error.log warn;
}
```

## What This Fix Does

| Old state                                  | New state                                             | Why it matters                                                   |
| ------------------------------------------ | ----------------------------------------------------- | ---------------------------------------------------------------- |
| TLS 1.0/1.1 enabled, RC4 & DES in the list | Only TLS 1.2/TLS 1.3 with FIPS‑approved ciphers       | Removes downgrade vectors and slow‑key‑exchange attacks          |
| No OCSP stapling / HSTS                    | Stapling + long‑horizon HSTS preload                  | Forces browsers to reject any downgrade or MITM attempts quickly |
| Session tickets on, compression off        | Optional ticket policy, explicit `SSLCompression off` | Prevents session‑replay and CRIME/BEAST attacks                  |

Remove TLS 1.0/1.1, the portal still advertises them (Finding 005).  
Lock down ciphers to forward‑secrecy, 256‑bit security only.  
Enable OCSP stapling and HSTS ensure browsers get fresh revocation status and are protected from protocol downgrade.  
Verify with SSL Labs → aim for A+ (or at least A) before reopening the production URL.

# Part 4 - The Downgrade Attack

A TLS‑downgrade attack tricks a client into using an old, weaker protocol even though the server (and client) are capable of a stronger one.  
During the handshake the attacker drops or tampers with the first few packets:

1.  The client sends a ClientHello for TLS 1.2 (or 1.3).
2.  The attacker intercepts it, modifies the ServerHello to announce TLS 1.0 (or deletes the 1.2‑only ciphers), and forwards that altered message to the client.
3.  Because the client now sees “the server will only speak TLS 1.0,” it continues with a TLS 1.0 session, which is far more vulnerable.

If MedDefense’s portal advertises both TLS 1.0 and TLS 1.2, an attacker on the path can simply send the client a forged ServerHello that claims “TLS 1.0” or omit the 1.2‑only cipher suites, forcing the browser to downgrade.

To prevent this attack, disable TLS 1.0 (and 1.1) entirely on the server and require only TLS 1.2+.*
