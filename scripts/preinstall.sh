#! /bin/bash
echo "Running preinstall checks..."
UEFIMODE=$(cat /sys/firmware/efi/fw_platform_size)
if ["$UEFIMODE" -eq 64]; then 
    echo "UEFI in 64 bit mode"
else
    echo "UEFI not in 64 bit mode, exiting"
    exit 1
fi
