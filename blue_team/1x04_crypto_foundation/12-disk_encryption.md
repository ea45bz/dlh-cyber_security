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

Can you see the data you wrote ? 

No, the data is not readable 

What does this prove about encryption at rest ?

Reopen  the volume and verify:

```
sudo cryptsetup luksOpen encrypted_volume.img secure_vol
Enter passphrase for encrypted_volume.img:

sudo  mount /dev/mapper/secure_vol /mnt/secure_vol
sudo cat /mnt/secure_vol/test.txt

test data

# Part 3 - The LUKS Automation Script


# Part 4 - MedDefense Backup Encryption Design
