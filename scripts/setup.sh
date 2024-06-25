#! /bin/bash

device_selection() {
    read -p "Which block device to partition format and install on? ($BLOCKDEVICES)" DEVICE
    if ! echo "${BLOCKDEVICES}" | grep -q "/${DEVICE}/"; then
        echo "Invalid: Please enter a valid block device name."
        prompt_device_selection

    fi

}


# asking for install block
BLOCKDEVICES=$(lsblk -o NAME --noheadings | awk '{print $1}' | tr '\n' '/')
device_selection

umount -A --recursive /mnt

exit 0

