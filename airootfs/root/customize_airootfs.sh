#!/bin/sh

opt_user="${USERNAME:-demo}"
opt_password="${PASSWORD:-demo1234}"

useradd -m -s /bin/zsh "${opt_user}"
printf "${opt_user}:${opt_password}" | chpasswd

usermod -aG wheel "${opt_user}"
sed -E -i 's/#\s*(%wheel\s+ALL=\(ALL:ALL\)\s+ALL)/\1/' /etc/sudoers

sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist
pacman-key --init
pacman-key --populate

systemctl enable NetworkManager
systemctl enable sshd
