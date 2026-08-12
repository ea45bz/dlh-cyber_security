**1️⃣ What is cryptography in cybersecurity?**

Cryptography is the practice and study of techniques for securing communication and data in the presence of adversaries.

Techniques for securing information by transforming it so only authorized parties can read, verify, or tamper‑proof it.

---

**2️⃣ What are the different types of cryptography?**

| Type                        | Purpose                                                                                 |
| --------------------------- | --------------------------------------------------------------------------------------- |
| **Symmetric (secret‑key)**  | Same key encrypts & decrypts. Fast, used for bulk data.                                 |
| **Asymmetric (public‑key)** | Public key encrypts; private key decrypts. Enables key exchange and digital signatures. |
| **Hash functions**          | One‑way transformation to fixed‑size digest. Used for integrity, password storage.      |

---

**3️⃣ What is Encryption?**  
The process of converting plaintext into ciphertext using an algorithm & key so that it’s unreadable without the correct key.

---

**4️⃣ What is Decryption?**  
Reversing encryption: turning ciphertext back into the original plaintext with the appropriate key or key pair.

---

**5️⃣ What is the importance of cryptography?**

- Confirms confidentiality, integrity, authenticity, and non‑repudiation.
- Protects data at rest & in transit.
- Enables secure authentication, digital signatures, and secure key exchange.

---

**6️⃣ What are the types of cryptography?** _(same as #2)_

- Symmetric
- Asymmetric
- Hashing

---

**7️⃣ What are the applications of cryptography?**

| Application                    | Example                |
| ------------------------------ | ---------------------- |
| Secure communication (SSL/TLS) | HTTPS, VPNs            |
| Data at rest encryption        | Disk‑level, file‑level |
| Authentication & key exchange  | SSH, OAuth             |
| Digital signatures             | Code signing, email    |
| Password storage               | bcrypt, Argon2         |
| Blockchain & cryptocurrencies  | SHA‑256, ECDSA         |

---

**8️⃣ What is a hash algorithm?**  
A deterministic function that maps arbitrary data to a fixed‑size digest; designed to be one‑way and collision‑resistant.

---

**9️⃣ What does SHA stand for?**  
Secure Hash Algorithm. Part of the NIST family (SHA‑1, SHA‑2, SHA‑3).

---

**🔟 What is John the Ripper?**  
A fast password cracking tool that supports dictionary attacks, brute force, rule‑based transformations, and many hash types.

---

**1️⃣1️⃣ How to use John the Ripper?**

```bash
# Basic dictionary crack
john --wordlist=/path/to/words.txt hashes.txt

# Show cracked passwords
john --show hashes.txt

# Use rules for transformations
john --rules --wordlist=/path/to/words.txt hashes.txt
```

_`hashes.txt` should contain one hash per line in the format John expects._

---

**1️⃣2️⃣ How to crack advanced hashes with John the Ripper?**

1. **Identify hash type** – use `john --list=known` or external tools like `hash-identifier`.
2. **Choose mode** – dictionary + rules, rule‑based transformations, or incremental/brute‑force (`--incremental`).
3. **Use `john.conf` tweaks** – enable specific crack modes for the hash (e.g., `$pbkdf2-hmac-sha256$`).
4. **Parallelism** – run multiple instances on different CPUs or use GPU‑accelerated mode if available.

---

**1️⃣3️⃣ What is Hashcat?**  
A GPU‑accelerated password cracker that supports over 200 hash types and attack modes (dictionary, mask, combinator, rule‑based, brute force).

---

**1️⃣4️⃣ How to use Hashcat?**

```bash
# Basic dictionary + mask example
hashcat -m 0 -a 0 -o cracked.txt hashes.txt wordlist.txt

# Rules mode
hashcat -m 0 -a 0 -r rules/best64.rule -o cracked.txt hashes.txt wordlist.txt

# Mask attack (e.g., 8‑character lowercase)
hashcat -m 0 -a 3 -o cracked.txt hashes.txt ?l?l?l?l?l?l?l?l
```

_`-m` specifies the hash type, `-a` selects attack mode, and `-r` loads rule files._

---
