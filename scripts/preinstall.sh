#! /bin/bash
echo "Running preinstall checks..."

if [[ $EUID -ne 0 ]]; then
    echo "Error: Permission Denied. This script must be run as root."
    exit 1
fi

# checking for internet
ping -c 3 "archlinux.org" > /dev/null 2>&1
if ! [ $? -eq 0 ] ; then
    echo "Error: Internet connection failed. See README for instructions to setup network."
    exit 1
fi

# checking disk size
DISKSIZE=$(lsblk -b | awk '$0 ~ /^NAME/ { next } $0 ~ /^([a-z]+|nvme)/ { size=$4 } END { print size }')
MINREQ=$((8000000000))
if [ "$DISKSIZE" -lt  "$MINREQ" ]; then
    echo "Error: Install requires minimum 8GB of disk space. Current disk size is $DISKSIZE bytes."
    exit 1
fi

# check pacman access
if [[ -f /var/lib/pacman/db.lck ]]; then
    echo "Error: Pacman is blocked, if Pacman is not running remove /var/lib/pacman/db.lck and try again."
    exit 1
fi

exit 0


