#!/bin/sh

useradd -m -s /bin/zsh demo
echo "demo:demo1234" | chpasswd
chown -Rh demo:demo /home/demo

usermod -aG wheel "demo"
sed -E -i 's/#\s*(%wheel\s+ALL=\(ALL:ALL\)\s+ALL)/\1/' /etc/sudoers

systemctl enable NetworkManager
systemctl enable sshd

