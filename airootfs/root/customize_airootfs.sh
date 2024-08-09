#!/bin/bash
set -e

sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist
pacman-key --init
pacman-key --populate

systemctl enable NetworkManager
systemctl enable sshd

echo "root:demo1234" | chpasswd

useradd -m -s /bin/zsh demo
usermod -aG wheel demo
sed -E -i '/^#\s*%wheel.*NOPASSWD/{s/^#\s*//}' /etc/sudoers
echo "demo:demo1234" | chpasswd
su -c 'cp -r /root/demo/* $HOME/' demo
rm -rf /root/demo

