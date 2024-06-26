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


# configuring system in chroot
arch-chroot /mnt << EOC
    ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
    hwclock --systohc
    
    # locale config
    locale-gen
    sed -i "/^#en_US.UTF UTF-8/s/^#//" /etc/locale.gen
    touch /etc/locale.conf
    echo "LANG=en_us.UTF-8" >> /etc/locale.conf
    touch /etc/vconsole.conf
    echo "KEYMAP=us" >> /etc/vconsole.conf

    # ask for hostname
    touch /etc/hostname
    read -p "Enter a hostname: " HOSTNAME
    echo ${HOSTNAME} >> /etc/hostname

    # users and sudo
    passwd --stdin << read -p "Enter a ROOT USER password: "
    read -p "Enter a username for a new user: " ${USERNAME}
    useradd -m -G wheel -s /bin/bash ${USERNAME}
    passwd --stdin ${USERNAME} << read -p "Enter a password for ${USERNAME}: "
    echo "%wheel ALL=(ALL:ALL) ALL" | EDITOR='tee -a' visudo

    # netctl config, assumes wpa wireless
    
    HASHED_PSK=$(wpa_supplicant "$SSID" | grep -oP 'psk=\K[a-f0-9]+')
    touch /etc/netctl/mywpaprofile 

    cat >/etc/netctl/mywpaprofile <<EOL
    Description: 'WPA-PSK wireless profile generated by archsetupminimal'
    Interface:${INTERFACE}
    Connection:wireless
    Security=wpa
    IP=dhcp
    ESSID=${SSID}
    Key=${HASHED_PSK}
    EOL

    if [ $UEFI -eq 0 ]; then
        grub-install --efi-directory=/dev/${DEVICE}1
        grub-mkconfig -o /boot/grub/grub.cfg
    else
        grub-install --target=i386-pc /dev/${DEVICE}
        grub-mkconfig -o /boot/grub/grub.cfg
    fi

    netctl enable mywpaprofile
    systemctl enable lightdm
    echo "nameserver 1.1.1.2" >> /etc/resolv.conf

    unset DEVICE

EOC

umount -R /mnt
reboot