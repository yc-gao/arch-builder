#!/bin/sh

opt_user="${USERNAME:-root}"
opt_password="${PASSWORD:-demo1234}"

echo "${opt_user}:${opt_password}" | chpasswd

sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist
pacman-key --init
pacman-key --populate

systemctl enable NetworkManager
systemctl enable sshd

systemctl enable libvirtd.service
systemctl enable cockpit.socket
sed -i '/root/d' /etc/cockpit/disallowed-users
