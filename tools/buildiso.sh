#!/usr/bin/env bash
set -Eeuo pipefail

opt_output="archlinux.iso"
opt_work="workdir"

pkg_conf="packages.x86_64"

fs_uuid=
fs_label="archiso_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"

tmp_dir="${opt_work}/tmp"
rootfs_dir="${opt_work}/rootfs"
espfs_dir="${opt_work}/esp"
isofs_dir="${opt_work}/iso"

refresh_opts() {
    fs_uuid="$(uuidgen)"

    tmp_dir="${opt_work}/tmp"
    rootfs_dir="${opt_work}/rootfs"
    espfs_dir="${opt_work}/esp"
    isofs_dir="${opt_work}/iso"

    rm -rf "${opt_work}"
    mkdir -p "${tmp_dir}" "${rootfs_dir}" "${espfs_dir}" "${isofs_dir}"
}

make_rootfs() {
    echo "Generating root filesystem..."

    cp -af --no-preserve=ownership,mode airootfs/* "${rootfs_dir}/"

    local -a pkg_lst
    mapfile -t pkg_lst < <(sed '/^[[:blank:]]*#.*/d;s/#.*//;/^[[:blank:]]*$/d' "${pkg_conf}")
    pacstrap -C pacman.conf -c -G -M "${rootfs_dir}" "${pkg_lst[@]}"

    if [[ -e "${rootfs_dir}/root/customize_airootfs.sh" ]]; then
        echo "Running customize_airootfs.sh in '${rootfs_dir}' chroot..."
        chmod -f -- +x "${rootfs_dir}/root/customize_airootfs.sh"
        # Unset TMPDIR to work around https://bugs.archlinux.org/task/70580
        eval -- env -u TMPDIR arch-chroot "${rootfs_dir}" "/root/customize_airootfs.sh"
        rm "${rootfs_dir}/root/customize_airootfs.sh"
        echo "Done! customize_airootfs.sh run successfully."
    fi
}

make_esp() {
    echo "Generating ESP image..."
    cat grub.embed.cfg \
        | sed "s|%ARCHISO_UUID%|${fs_uuid}|g" \
        | sed "s|%ARCHISO_LABEL%|${fs_label}|g" \
        >"${tmp_dir}/grub.cfg"
    echo "Generated embedded grub.cfg at ${tmp_dir}/grub.cfg"

    local grubmodules=(all_video at_keyboard boot btrfs cat chain configfile echo efifwsetup efinet exfat ext2 f2fs fat font \
                gfxmenu gfxterm gzio halt hfsplus iso9660 jpeg keylayouts linux loadenv loopback lsefi lsefimmap \
                minicmd normal ntfs ntfscomp part_apple part_gpt part_msdos png read reboot regexp search \
                search_fs_file search_fs_uuid search_label serial sleep tpm udf usb usbserial_common usbserial_ftdi \
                usbserial_pl2303 usbserial_usbdebug video xfs zstd)
    mkdir -p "${espfs_dir}/EFI/BOOT"
    grub-mkstandalone -O x86_64-efi \
        --modules="${grubmodules[*]}" \
        -o "${espfs_dir}/EFI/BOOT/BOOTx64.EFI" \
        "boot/grub/grub.cfg=${tmp_dir}/grub.cfg"
    echo "ESP image generated at ${espfs_dir}/EFI/BOOT/BOOTx64.EFI"
}

make_iso() {
    echo "Generating ISO image..."

    install -D -m 0644 -- /dev/null "${isofs_dir}/boot/${fs_uuid}.uuid"
    install -D -m 0644 -t "${isofs_dir}/linux" "${rootfs_dir}/boot/initramfs-"*".img" "${rootfs_dir}/boot/vmlinuz-"*
    echo "Copied kernel and initramfs to ${isofs_dir}/linux"

    mkfs.erofs \
        "${isofs_dir}/linux/airootfs.erofs" "${rootfs_dir}"
    echo "Generated root filesystem image at \"${isofs_dir}/linux/airootfs.erofs\""

    local efibootimg="${tmp_dir}/efiboot.img"
    mkfs.fat -C -F 32 "${efibootimg}" $((256*1024))
    mmd -i "${efibootimg}" ::/EFI ::/EFI/BOOT
    mcopy -i "${efibootimg}" -s "${espfs_dir}/EFI" ::
    echo "Generated efiboot.img at ${efibootimg}"

    xorriso -as mkisofs \
        -o "${opt_output}" \
        -iso-level 3 \
        -volid "${fs_label}" \
        -appended_part_as_gpt \
        -partition_offset 16 \
        -append_partition 2 0xef "${efibootimg}" \
        -e --interval:appended_partition_2:all:: \
        -no-emul-boot \
        "${isofs_dir}"
    echo "ISO image generated at ${opt_output}"
}

main() {
    while (($#)); do
        case "$1" in
            -w)
                opt_work="$2"
                shift 2
                ;;
            -o)
                opt_output="$2"
                shift 2
                ;;
            *)
                break
                ;;
        esac
    done

    refresh_opts
    make_rootfs
    make_esp
    make_iso
}

main "$@"

