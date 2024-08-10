#!/bin/sh

systemctl enable NetworkManager
systemctl enable sshd

echo "root:demo1234" | chpasswd

