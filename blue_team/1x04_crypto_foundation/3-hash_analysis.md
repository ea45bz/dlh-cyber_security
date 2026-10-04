# Part 1 - The Avalanche Effect

'''
echo -n "MedDefense" | sha256sum

39e026e107a44b2268e43e16e61033fdcc5d2bd62b23e03aca51db35c8671098 -

echo -n "MedDefense1" | sha256sum

97a4141d69cc726a7f6ef577df588d4010c3fe4f235a8bdb616732ba9bf17b92 -

echo -n "MedDefense" | md5sum

75d47fd4b4d183456d0f98fd9ba6ae4d -

echo -n "MedDefense1" | md5sum

0d2aed72043f78c2935e61ba8520306d -
'''

How many characters of the hex output differ ?

Many hex characters change even with a one-character input change.

# Part 2 - Hash Collisions and the Birthday Problem

| Algorithm | Hash Length | Possible unique outputs |
| --------- | ----------- | ----------------------- |
| MD5       | 128 bits    | 2^128 (≈ 3.4 × 10³⁸)    |
| SHA-256   | 256 bits    | 2^256 (≈ 1.15 × 10⁷⁷)   |

Shorter hash outputs expose more values per bit of entropy.

Because the number of possible collisions grows roughly as (\sqrt{N}), a birthday attack only needs about (2^{n/2}) attempts to find two messages that hash identically. Thus MD5’s collision resistance is effectively halved compared to SHA-256, making collision attacks far more feasible.

Finding 018 shows MedDefense’s AD still permits RC4‑Kerberos tickets; RC4’s key derivation uses an MD5 hash internally. In practice this means an attacker who can obtain a ticket could exploit MD5 collisions or the known weaknesses of RC4 to forge valid Kerberos authentications.

# Part 3 - Rainbow Table Demonstration

'''
echo -n "password123" | md5sum
482c811da5d5b4bc6d497ffa98491e38 -

echo -n "s4lt9xQ2:password123" | md5sum
6d537fa53f1db2c22b0451ef4ef9fbe8 -
'''

crackstation.net lookup result:

- no salted hash found
- salted hash not found

Salting appends random data to each password before hashing, which changes the input for every user; a single rainbow table built for unsalted values can no longer match because the hash outputs differ.  
When the salt is unique per account, identical passwords yield distinct hashes, preventing attackers from reusing precomputed tables or identifying reused passwords across accounts.

# Part 4 - Key Stretching

### Key‑Derivation Algorithms vs. Plain Hashing

| Algorithm  | How it differs from a simple hash                                                                                                                                                                                 | Why it resists brute‑force                                                                                                                                      | “Cost factor / iteration” control                                                                                               |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| **bcrypt** | Takes the password + a 128‑bit _salt_ and runs it through the Eksblowfish key‑expansion for **N rounds** (where N is a power of two). The algorithm also produces a fixed‑length output that cannot be truncated. | Each round expands CPU time exponentially; an attacker must spend _2ⁿ_ times more work per guess, and the fixed output size prevents simple dictionary pruning. | `cost` parameter = 2^c rounds (e.g., cost = 12 → 4096 iterations). Higher cost ⇒ longer hash computation, harder for attackers. |
| **PBKDF2** | Hash‑based: applies HMAC‑SHA‑1/256 to the password+salt repeatedly _T_ times and XORs the intermediate results. It is a general “Password‑Based Key Derivation Function.”                                         | Every iteration forces the attacker to run the underlying hash algorithm again; increasing iterations raises work factor linearly.                              | `iteration count` = number of HMAC invocations (e.g., 100 000). Larger → slower, more resistant.                                |
| **Argon2** | Memory‑hard: each round writes/reads from a large scratchpad while performing _T_ iterations of a lightweight hash, controlled by memory size, parallelism, and iteration count.                                  | Requires both CPU time AND memory; attackers with GPUs or FPGAs are throttled because memory bandwidth becomes the bottleneck.                                  | `t` = iterations, `m` = memory (KiB), `p` = parallelism factor. Adjusting them raises cost on both sides.                       |

I would recommend Argon2id for MedDefense's application password storage.
Memory‑hard and configurable, providing the strongest protection against GPU/ASIC cracking, currently NIST‑recommended .

### What does Active Directory store by default?

Active Directory by a 16‑byte MD4 digest of the UTF‑16LE password, without any salt or iterations.

The NT hash is no adequate a one‑time hash with no salt and extremely vulnerable to rainbow table attacks.
