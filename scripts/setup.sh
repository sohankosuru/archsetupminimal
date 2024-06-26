#! /bin/bash

device_selection() {
    # asking for install block
    BLOCKDEVICES=$(lsblk -o NAME --noheadings | awk '{print $1}' | tr '\n' '/')
    lsblk
    read -p "Which block device to partition format and install on? ($BLOCKDEVICES)" DEVICE
    if ! echo "${BLOCKDEVICES}" | grep -q "/${DEVICE}/"; then
        echo -e "Invalid: Please enter a valid block device name.\n"
        prompt_device_selection

    fi

}

partition_and_formatting(){
    umount -A --recursive /mnt

    # 256MB for ESP, 1GB [SWAP], rest root
    if [ -d "/sys/firmware/efi" ]; then

        sgdisk --clear \
        --new=1::+256M --typecode=1:ef00 --change-name=1:"EFI" \
        --new=2::+1G --typecode=2:8200 --change-name=2:"SWAP" \
        --new=3::-0 --typecode=3:8300 --change-name=3:"ROOT" \
        /dev/$DEVICE

    else
        echo "UEFI not detected, skipping EFI system partition"

        sgdisk --clear \
        --new=1::+1G --typecode=1:8200 --change-name=1:"SWAP" \
        --new=2::-0 --typecode=2:8300 --change-name=2:"ROOT" \
        /dev/$DEVICE
    fi
    
    partprobe /dev/$DEVICE

    # formatting
    if [ -d "/sys/firmware/efi" ]; then
        mkfs.fat -F32 /dev/${DEVICE}1
        echo "Formatted /dev/${DEVICE}1 to FAT32"

        mkswap /dev/${DEVICE}2
        echo "Added swap flag to /dev/${DEVICE}2"

        mkfs.ext4 /dev/${DEVICE}3
        echo "Formatted /dev/${DEVICE}3 to EXT4"

    else
        mkswap /dev/${DEVICE}1
        echo "Added swap flag to /dev/${DEVICE}1"

        mkfs.ext4 /dev/${DEVICE}2
        echo "Formatted /dev/${DEVICE}2 to EXT4"
    fi

}

# mounting filesystems
mounting(){
    if [ -d "/sys/firmware/efi" ]; then
        mount /dev/${DEVICE}3 /mnt
        echo "Mounted /dev/${DEVICE}3 to /mnt"

        swapon /dev/${DEVICE}2
        echo "Swapspace at /dev/${DEVICE}2 done"

        mount --mkdir /dev/${DEVICE}1 /mnt/boot
        echo "Mounted /dev/${DEVICE}1 to /mnt/boot"
        
    else
        swapon /dev/${DEVICE}1
        echo "Swapspace at /dev/${DEVICE}1 done"

        mount /dev/${DEVICE}2 /mnt
        echo "Mounted /dev/${DEVICE}2 to /mnt"
    fi

}

device_selection
partition_and_formatting
mounting

export DEVICE

exit 0

