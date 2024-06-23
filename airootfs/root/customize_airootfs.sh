#!/bin/bash
set -e

sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist
pacman-key --init
pacman-key --populate

systemctl enable NetworkManager
systemctl enable sshd
systemctl enable sddm

echo "root:demo1234" | chpasswd

useradd -m -s /bin/zsh xundaoxd
usermod -aG wheel xundaoxd
sed -E -i '/^#\s*%wheel.*NOPASSWD/{s/^#\s*//}' /etc/sudoers
echo "xundaoxd:demo1234" | chpasswd

