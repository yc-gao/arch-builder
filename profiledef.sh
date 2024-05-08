#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="archiso"
iso_label="arch_$(date +%Y%m)"
iso_publisher="xundaoxd <https://github.com/xundaoxd>"
iso_application="Arch Linux Live/Rescue CD"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
bootmodes=('uefi-x64.grub.esp')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd')

file_permissions=(
    ["/home/xundaoxd/"]="1000:1000:0700"
)
