#! /bin/bash
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
read -p "Enter a ROOT USER password: " ROOTPWD
echo $ROOTPWD | passwd --stdin 
read -p "Enter a username for a new user: " USERNAME
useradd -m -G wheel -s /bin/bash ":${USERNAME}"
read -p "Enter a password for ${USERNAME}: " USERPWD
echo $USERPWD | passwd $USERNAME --stdin
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
systemctl enable dhcpd

unset DEVICE