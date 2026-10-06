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
