#!/bin/bash

# Requires
#   base.sh

cp /etc/pacman.conf /etc/pacman.conf.backup 
printf '\n\n[archassault]\nServer = http://repo.archassault.org/archassault/$repo/os/$arch\n\n[multilib]\nInclude = /etc/pacman.d/mirrorlist' | tee --append /etc/pacman.conf     
timeout 10 dirmngr
pacman-key -r CC1D2606 && pacman-key --lsign-key CC1D2606

pacman -Syyu --noconfirm archassault-keyring
printf "y\n\n" | pacman -S gcc-libs-multilib
pacman -S --noconfirm vim dtach git htop tig base-devel xorg-xauth libxtst 
