#!/bin/bash
echo -n "password" >.keyfile
if [ "$1" = "create" ]; then
    sudo dd if=/dev/zero of=encrypted_volume.img bs=1M count=500
    sudo cryptsetup  luksFormat --key-file  .keyfile --batch-mode  encrypted_volume.img
    sudo cryptsetup luksOpen --key-file  .keyfile --batch-mode  encrypted_volume.img secure_vol
    sudo mkfs.ext4 /dev/mapper/secure_vol
    sudo cryptsetup luksClose secure_vol
elif [ "$1" = "open" ]; then
    sudo cryptsetup luksOpen --key-file  .keyfile --batch-mode  encrypted_volume.img secure_vol
    sudo mount /dev/mapper/secure_vol /mnt
elif [ "$1" = "close" ]; then
    sudo umount /dev/mapper/secure_vol
    sudo cryptsetup luksClose secure_vol
fi
