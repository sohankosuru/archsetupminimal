#! /bin/bash
echo "Running preinstall checks..."
ping -c 3 "archlinux.org" > /dev/null 2>&1

# checking for internet
if ! [ $? -eq 0 ] ; then
    echo "Error: Internet connection failed. See README for instructions to setup network."
    exit 1
fi

# checking disk size
DISKSIZE=$(lsblk -b | awk '$0 ~ /^NAME/ { next } $0 ~ /^([a-z]+|nvme)/ { size=$4 } END { print size }')
MINREQ=$((8*1024*1024*1024))
if [ "$DISKSIZE" -lt  "$MINREQ" ]; then
    echo "Error: Disk size is under minimum 8GB. Current disk size is $DISKSIZE bytes."
    exit 1
fi

echo "Passed all preinstall tests, continuing to install"
exit 0
