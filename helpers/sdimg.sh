#!/bin/bash
#
# Copyrigh: Voipac s.r.o.
# Author: Marek Belisko <marek.belisko@voipac.com>
#

set -e

source helpers/uboot.sh

function cmd_make_sdimg()
{
    name="image.sdimg"
    # create dummy file
    dd if=/dev/zero of=${name} bs=1M count=2000

    # mount it using loopback
    loopback=$(losetup --find --show -P ${name})

    echo "Using loopback device: ${loopback}"

    # create one partition with ext4 rootfs and add offset for imx-boot
    parted --script ${loopback} mklabel gpt mkpart primary 10MiB 100MiB mkpart primary 101MiB 100%
    
    ls -la ${loopback}*

    fdisk -l ${name}

    # copy bootloader and dd it to final image
    copy_bootloader "/tmp"

    dd if=/tmp/flash.bin of=${loopback} bs=1K seek=33

    rm -rf "/tmp/flash.bin"

    mkfs.vfat ${loopback}p1 -n boot
    mkfs.ext4 ${loopback}p2 -L root

    mkdir -p /mnt/boot /mnt/root

    mount ${loopback}p1 /mnt/boot
    mount ${loopback}p2 /mnt/root

    # copy rootfs
    cp -rf ${ROOTFS_PATH}/* /mnt/root
    
    # copy kernel + modules
    cp ${KERNEL_PATH}/arch/arm64/boot/Image /mnt/boot
    cp ${KERNEL_PATH}/arch/arm64/boot/dts/freescale/imx8mq-evk-voipac-*.dtb /mnt/boot
    
    mkdir -p /mnt/root/lib/modules
    cp -r ${KERNEL_PATH}/modules/lib /mnt/root/usr
    ls -la /mnt/root/usr/lib/modules
    
    umount /mnt/*
    losetup -d ${loopback}
}