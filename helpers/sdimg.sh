#!/bin/bash
#
# Copyrigh: Voipac s.r.o.
# Author: Marek Belisko <marek.belisko@voipac.com>
#

set -ex

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
    # copy it to root of project also
    copy_bootloader "$(pwd)"


    dd if=/tmp/flash.bin of=${loopback} bs=1K seek=${IMX_BOOT_OFFSET}

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
    if [ ${PLAT} = "imx8mq" ]; then
        cp ${KERNEL_PATH}/arch/arm64/boot/dts/freescale/imx8mq-evk-voipac-*.dtb /mnt/boot
    elif [ ${PLAT} = "imx93" ]; then
        cp ${KERNEL_PATH}/arch/arm64/boot/dts/freescale/imx93-voipac*.dtb /mnt/boot
    elif [ ${PLAT} = "imx91" ]; then
        cp ${KERNEL_PATH}/arch/arm64/boot/dts/freescale/imx91-voipac*.dtb /mnt/boot
    fi

    mkdir -p /mnt/root/lib/modules
    cp -r ${KERNEL_PATH}/modules/lib /mnt/root/usr
    ls -la /mnt/root/usr/lib/modules

    # copy out of tree modules + firmware
    if [ ${PLAT} = "imx93" ] || [ ${PLAT} = "imx91" ]; then

    	source helpers/imx9x/build_nxp_wlan_modules.sh
        local MODULES_VERSION=$(ls /mnt/root/usr/lib/modules/)
	    local MODULES_PATH="/mnt/root/usr/lib/modules/${MODULES_VERSION}/kernel/extra"
    	mkdir -p "${MODULES_PATH}"
	    cp $(pwd)/${MODULE_PATH}/mxm_wifiex/wlan_src/result/*.ko "${MODULES_PATH}"

    	# copy imx-firmware
	    FW_PATH="/mnt/root/usr/lib/firmware/nxp"
    	mkdir -p "${FW_PATH}"
    	cp -r $(pwd)/${NXP_FIRMWARE_PATH}/nxp/FwImage_IW416_SD/* "${FW_PATH}"
    	cp $(pwd)/${NXP_FIRMWARE_PATH}/nxp/wifi_mod_para.conf "${FW_PATH}"
    fi

    umount /mnt/*
    losetup -d ${loopback}
}
