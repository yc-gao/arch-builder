#!/bin/sh

systemctl enable NetworkManager
systemctl enable sshd

useradd -m -s /bin/zsh demo
usermod -aG wheel demo
echo "demo:demo1234" | chpasswd
chown -Rh demo:demo /home/demo

