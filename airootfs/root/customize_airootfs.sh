#!/bin/sh

useradd -m -s /bin/zsh demo
echo "demo:demo1234" | chpasswd
chown -Rh demo:demo /home/demo

usermod -aG wheel "demo"
sed -E -i 's/#\s*(%wheel\s+ALL=\(ALL:ALL\)\s+ALL)/\1/' /etc/sudoers

sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist
pacman-key --init
pacman-key --populate

systemctl enable NetworkManager
systemctl enable sshd

