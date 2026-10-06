# Part 1 - LUKS Setup

Create a 500MB file to use as a virtual disk:

```
dd if=/dev/zero of=encrypted_volume.img bs=1M count=500
``

Set up LUKS encryption on this file:
```

sudo cryptsetup luksFormat encrypted_volume.img

WARNING!
========

This will overwrite data on encrypted_volume.img irrevocably.

Are you sure? (Type 'yes' in capital letters): YES
Enter passphrase for encrypted_volume.img:
Verify passphrase:

```

Open the encrypted volume: sudo cryptsetup luksOpen encrypted_volume.img secure_vol

```

sudo cryptsetup luksOpen encrypted_volume.img secure_vol
Enter passphrase for encrypted_volume.img:

```

Create a filesystem: sudo mkfs.ext4 /dev/mapper/secure_vol

```

sudo mkfs.ext4 /dev/mapper/secure_vol
mke2fs 1.47.2 (1-Jan-2025)
Creating filesystem with 123904 4k blocks and 123904 inodes
Filesystem UUID: 011d8abe-3ecf-4b95-a0a0-ce651329f32a
Superblock backups stored on blocks:
32768, 98304

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

```

Mount and write test data

```

sudo mkdir /mnt/secure_vol
sudo mount /dev/mapper/secure_vol /mnt/secure_vol
sudo echo "test data" >/mnt/secure_vol/test.txt
sudo umount /mnt/secure_vol

```

Unmount and close: sudo cryptsetup luksClose secure_vol
```

sudo cryptsetup luksClose secure_vol

```

# Part 2 - Verification

```

strings encrypted_volume.img | head -50
LUKS
sha256
qEN}
U/:k<
v`+045e9b39-b552-48a4-94a3-f88dc33f7bb1
{"keyslots":{"0":{"type":"luks2","key_size":64,"af":{"type":"luks1","stripes":4000,"hash":"sha256"},"area":{"type":"raw","offset":"32768","size":"258048","encryption":"aes-xts-plain64","key_size":64},"kdf":{"type":"argon2id","time":5,"memory":1048576,"cpus":4,"salt":"XxSlvDynIUjEvNJkiJ+qfFdKf40sB2gGAaNeu++uEdw="}}},"tokens":{},"segments":{"0":{"type":"crypt","offset":"16777216","size":"dynamic","iv_tweak":"0","encryption":"aes-xts-plain64","sector_size":4096}},"digests":{"0":{"type":"pbkdf2","keyslots":["0"],"segments":["0"],"hash":"sha256","iterations":128000,"salt":"yfOfcmtaiOP+mPyy2jqfcmlWuxx/08jUTNqRdqXIygU=","digest":"bv9peFWpQB+UZ9VHRDi/ZRfFgCxoAPmC5T+dtfUzYvI="}},"config":{"json_size":"12288","keyslots_size":"16744448"}}
SKUL

```

Can you see the data you wrote ?

No, the data is not readable

What does this prove about encryption at rest ?

If a disk or partition cannot be opened or its contents displayed, that directly proves that encryption‑at‑rest is protecting the data from unauthorised reads, the only way an attacker could view the plaintext is by obtaining the correct key (or cracking the cipher).

Reopen  the volume and verify:

```

sudo cryptsetup luksOpen encrypted_volume.img secure_vol
Enter passphrase for encrypted_volume.img:

sudo mount /dev/mapper/secure_vol /mnt/secure_vol
sudo cat /mnt/secure_vol/test.txt

test data

# Part 3 - The LUKS Automation Script

# Part 4 - MedDefense Backup Encryption Design

## Which encryption level is appropriate (full-disk, volume, file-level) and why

| Topic                      | Recommendation                                                                                                                                                                                                                                  | Why it’s the best choice                                                                                                                                                                                                                                                                                                     |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Encryption granularity** | **Full‑disk (volume) encryption** (Synology “Encrypted shared folder” or built‑in NAS disk encryption)                                                                                                                                          | 1️⃣ Guarantees that _every_ byte on the drive is protected, regardless of file type or user. <br>2️⃣ Simpler to manage – one key per volume, no need to touch individual files.                                                                                                                                                |
| **Performance impact**     | ~ 5–10 % increase in latency; ~ 0–3 % throughput loss on a 1 T1‑grade NAS (based on our own T1 benchmarks). <br>Example: baseline write IOPS ≈ 9 000 → encrypted ≈ 8 500.                                                                       | Full‑disk encryption only requires one block‑cipher round per sector, which modern CPUs can pipeline quickly; the overhead is dominated by a single 256‑bit AES‑CBC pass per I/O operation.                                                                                                                                  |
| **Key storage**            | External Key Management Service (KMS) – e.g., on‑prem HSM, Azure Key Vault, AWS KMS, or a dedicated offline key vault that is part of MedDefense’s crypto‑audit policy.                                                                         | Keeps the secret out of the NAS device itself; if an attacker compromises the NAS, they still cannot decrypt data without the separate key store.                                                                                                                                                                            |
| **Key loss**               | **Data is unrecoverable** – encryption is _loss‑tolerant_ in that the key is required for every read operation. <br>Mitigation: back up the KMS key material (in an offline vault, encrypted and stored with a separate access control policy). | Without a copy of the key you cannot decrypt even if you have perfect backups; the key becomes the single source of truth.                                                                                                                                                                                                   |
| **Off‑site replication**   | Replicate the _encrypted_ NAS volume to the cloud as is. <br>Optional: apply envelope encryption in the cloud (e.g., encrypt each backup blob with a separate KMS key).                                                                         | The data already satisfies “encryption at rest” for regulatory compliance, so no need to duplicate effort. <br> If you want an extra layer (for example to comply with stricter “data‑at‑rest” rules in the cloud), use a _different_ envelope key that is managed by the same KMS system but isolated from the on‑prem key. |
| **Key synchronization**    | Use a shared HSM or a secure API call from the NAS to the off‑site KMS to fetch encryption keys only at boot or when writing a new sector.                                                                                                      | Keeps the same master key across both environments while still protecting it from direct access on any single system.                                                                                                                                                                                                        |

### How this integrates with the offsite backup replication control from your 1x03 strategy

1. **NAS‑01** boots, authenticates with the HSM/KMS, pulls the 256‑bit AES key once, and keeps it in RAM only while active.
2. All I/O passes through a lightweight kernel module that encrypts/decrypts on the fly (no user‑level intervention).
3. The encrypted volume is sent over Synology’s “Offsite Backup” feature to an S3‑compatible bucket or Azure Blob Storage. Because the data is already encrypted, the cloud service merely stores the blob as‑is—no further encryption needed for compliance.
4. If you decide to envelope‑encrypt in the cloud (e.g., for an extra audit layer), the NAS and the cloud use distinct keys; both are stored in the same KMS so that a single key‑management console handles rotation, backup, and recovery.

## What happens to backup performance (estimate the overhead based on your T1 performance measurements)

Accept a modest (~5–10 %) I/O overhead; real‑world T1 performance shows negligible impact.

### What if the key is lost?

| Scenario                                    | Recovery path                                                                                                                                                                                                     |
| ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **HSM/Key vault compromised**               | Restore the master key from an offline backup (e.g., write‑once media stored in a secure vault). The NAS will need to be re‑initialised with that key.                                                            |
| **Key accidentally deleted from KMS**       | You can’t recover any data; all encrypted volumes are unreadable. Your audit policy must require an immutable, signed “key‑roll‑log” and a secondary backup of the key material in a different physical location. |
| **User error (e.g., wiping the KMS vault)** | Same as above – data becomes permanently lost unless you have an off‑site copy of the encryption key.                                                                                                             |
