# Part 1 - RSA Key Generation and Encryption

Encrypt a small file with RSA public key:
'''
openssl rsautl -encrypt -pubin -inkey rsa_public.pem -in enc.txt -out enc.txt_rsa
'''
Decrypt:
'''
openssl rsautl -decrypt -inkey rsa_private.pem -in enc.txt_rsa -out enc.txt_out
'''

encrypt the 100MB test file:
'''
RSA operation error
8516066688:error:04FFF06E:rsa routines:CRYPTO_internal:data too large for key size
'''

# Part 2 - ECC Key Generation

Ratio: 5.5

Elliptic‑curve cryptography relies on the hardness of the elliptic‑curve discrete‑log problem, which grows roughly exponentially with key length. A 256‑bit EC key delivers about the same security as a 3072‑bit RSA key—roughly a 12:1 size reduction.
For small devices this matters because smaller keys mean lower memory, less bandwidth and reduced CPU work.

# Part 3 - The Hybrid Model

TLS uses a hybrid design: during the handshake an asymmetric algorithm is used to securely transmit a randomly generated symmetric “session” key; thereafter all application traffic is encrypted with symmetric cipher.  
The asymmetric phase guarantees confidentiality, while the symmetric phase provides high throughput and low latency for large payloads. Using only asymmetry would be slow because each message would require a costly public‑key operation; using only symmetry would expose the key to eavesdroppers since it would need to be sent in cleartext.

In MedDefense’s patient portal, the TLS handshake exchanges the session key, and once the handshake completes the HTTP payloads are protected by the symmetric cipher chosen during the negotiation.

# Part 4 - The Key Length Table

| Algorithm             | Type                                  | Key Lengths (typical)       | Equivalent Security                                                                 | Status (HIPAA‑regulated data)                                | MedDefense Usage                                                                           |
| --------------------- | ------------------------------------- | --------------------------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------ |
| **AES‑128**           | Symmetric block cipher                | 128 bits                    | ~112‑bit security                                                                   | **Approved** – standard for encrypted storage, TLS, and VPNs | Not currently used (no disk‑level AES in MedDefense)                                       |
| **AES‑192**           | Symmetric block cipher                | 192 bits                    | ~128‑bit security                                                                   | **Approved**                                                 | None                                                                                       |
| **AES‑256**           | Symmetric block cipher                | 256 bits                    | ~256‑bit security                                                                   | **Approved** – strongest option for HIPAA data               | None                                                                                       |
| **RSA‑2048**          | Asymmetric RSA                        | 2048 bits                   | ~112‑bit security (symmetric equivalent)                                            | **Approved** – acceptable key size for TLS, key exchange     | Not used; TLS on patient portal currently relies on older TLS 1.0/1.2 with weak ciphers    |
| **RSA‑4096**          | Asymmetric RSA                        | 4096 bits                   | ~128‑bit security                                                                   | **Approved**                                                 | None                                                                                       |
| **ECC P‑256**         | Elliptic‑curve Diffie‑Hellman / ECDSA | 256 bits                    | ~128‑bit security                                                                   | **Approved** – recommended for TLS, Kerberos                 | Active Directory supports AES‑256 Kerberos; legacy DES/RC4 still enabled but ECC available |
| **ECC P‑384**         | Elliptic‑curve Diffie‑Hellman / ECDSA | 384 bits                    | ~192‑bit security                                                                   | **Approved** – higher security margin                        | None                                                                                       |
| **DES (single)**      | Symmetric block cipher                | 56 bits                     | ~~56‑bit security (trivially breakable)                                             | **Disapproved** – deprecated, insecure                       | Not used; legacy config shows DES enabled in Kerberos                                      |
| **3DES**              | Symmetric block cipher (TDEA)         | 168 bits effective          | ~112‑bit security but vulnerable to length‑extension and meet‑in‑the‑middle attacks | **Disapproved** – deprecated by NIST                         | Not used (but legacy Kerberos configs still enable DES/RC4)                                |
| **ChaCha20–Poly1305** | AEAD stream cipher                    | 256 bits key / Poly1305 MAC | ~256‑bit security, comparable to AES‑256                                            | **Approved** – modern alternative to TLS 1.3 ciphers         | Not used; TLS on patient portal lacks ChaCha20 support                                     |
| **RC4**               | Stream cipher                         | 128–512 bits (variable)     | ~~40–112‑bit security but highly insecure                                           | **Disapproved** – strong cryptanalytic attacks               | Legacy Kerberos still allows RC4; not recommended for any data in MedDefense               |
