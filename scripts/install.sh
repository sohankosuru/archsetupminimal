#! /bin/bash

# installing packages
pacstrap -K /mnt base linux linux-firmware sof-firmware base-devel \
    grub netcli dhcpcd lightdm lightdm-gtk-greeter sudo \
    xfce4 xfce4-goodies nano vim neofetch man-db man-pages texinfo \
    less 

if [ -d "/sys/firmware/efi" ]; then
    pacstrap -K efibootmgr
fi

touch /mnt/etc/fstab
genfstab -U /mnt >> /mnt/etc/fstab

# configuring system in chroot
arch-chroot /mnt << EOC
    ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
    hwclock --systohc

    
    locale-gen
    sed -i "/^#en_US.UTF UTF-8/s/^#//" /etc/locale.gen
    touch /etc/locale.conf
    echo "LANG=en_us.UTF-8" >> /etc/locale.conf
    touch /etc/vconsole.conf
    echo "KEYMAP=us" >> /etc/vconsole.conf

    touch /etc/hostname
    read -p "Enter a hostname: " HOSTNAME
    echo $HOSTNAME >> /etc/hostname

    passwd --stdin << read -p "Enter a ROOT USER password: "
    read -p "Enter a username for a new user: " $USERNAME
    useradd -m -G wheel -s /bin/bash $USERNAME
    passwd --stdin $USERNAME << read -p "Enter a password for ${USERNAME}: "
    echo "%wheel ALL=(ALL:ALL) ALL" | EDITOR='tee -a' visudo

    
EOC