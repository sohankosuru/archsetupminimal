#! /bin/bash

# installing packages
pacstrap -K /mnt base linux linux-firmware sof-firmware base-devel \
    grub netctl dhcpcd lightdm lightdm-gtk-greeter sudo \
    xfce4 xfce4-goodies nano vim neofetch man-db man-pages texinfo \
    less firefox

if [ -d "/sys/firmware/efi" ]; then
    pacstrap -K /mnt efibootmgr
fi

touch /mnt/etc/fstab
genfstab -U /mnt >> /mnt/etc/fstab
SSID=$(iwgetid --raw)
INTERFACE=$(iwgetid | awk '{print $1}')

if [ -d /sys/firmware/efi ]; then
    UEFI=0  # UEFI is present
else
    UEFI=1  # UEFI is not present
fi

cp ./scripts/chrootconfig.sh /mnt/home

# configuring system in chroot
arch-chroot /mnt << EOC
cd /home
./chrootconfig.sh

EOC

umount -R /mnt
reboot