#!/bin/sh

systemctl enable NetworkManager
systemctl enable sshd

useradd -m -s /bin/zsh demo
echo "demo:demo1234" | chpasswd

usermod -aG wheel "demo"
sed -E -i 's/#\s*(%wheel\s+ALL=\(ALL:ALL\)\s+ALL)/\1/' /etc/sudoers

chown -Rh demo:demo /home/demo

