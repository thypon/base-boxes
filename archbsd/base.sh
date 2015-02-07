#!/usr/bin/bash
# Partition disk
gpart create -s gpt vtbd0
gpart add -s 64k -t freebsd-boot vtbd0
gpart add -t freebsd-ufs vtbd0
gpart bootcode -b /boot/pmbr -p /boot/gptboot -i 1 vtbd0
newfs -U -j -L root /dev/vtbd0p2

# Install the base system
mount /dev/vtbd0p2 /mnt

# Install Base System
install -o root -g wheel -dm755 /mnt/var/lib/pacman
install -o root -g wheel -dm755 /mnt/var/cache/pacman/pkg
pacman -b /mnt/var/lib/pacman --cachedir /mnt/var/cache/pacman/pkg -r /mnt --noconfirm -Sy base sudo rsync bash

# Chroot into the new system
arch-chroot /mnt <<ENDCHROOT
# Previously dhcpcd.service was enabled. However, in my testing it repeatedly
# failed to connect to the network on reboot. Enable dhcpcd@.service has worked
# in my case. My guess is that this is due to the line
# After=sys-subsystem-net-devices-%i.device
# in the service file.
# Restarting dhcpcd.service after boot or using Network Manager instead of
# dhcpcd also works
# Maybe a related bug report?
# https://bugs.freedesktop.org/show_bug.cgi?id=59964
# Replace this with a better fix, when available.

echo '/dev/vtbd0p3      /           ufs    rw 1 1
linproc        /compat/linux/proc linprocfs rw 0       0' > /etc/fstab
ln -s /usr/share/zoneinfo/Europe/London /etc/localtime
mkdir -p /etc/conf.d/
echo 'HOSTNAME="ArchBSD"' > /etc/conf.d/hostname
sysrc hostname="ArchBSD"
echo 'vfs.root.mountfrom="ufs:/dev/ufs/root"' >> /boot/loader.conf
echo 'linux_load="YES"' >> /boot/loader.conf
echo 'ifconfig_vtnet0="SYNCDHCP"' >> /etc/rc.conf

pacman-key --init; pacman-key --populate archbsd

mkdir -p /compat/linux/proc

# Change SSH Config
echo "X11Forwarding yes
PermitRootLogin yes" >> /etc/ssh/sshd_config

# Make sure sshd starts on boot
echo "sshd_enable='YES'" >> /etc/rc.conf

# Sudo setup
cat <<EOF > /etc/sudoers
root ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL
EOF

echo vagrant | pw user add -n vagrant -G wheel -c "Vagrant User" -m -s /usr/bin/bash
ENDCHROOT
