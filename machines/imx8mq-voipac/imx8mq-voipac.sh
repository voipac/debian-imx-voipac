#!/bin/bash
#
# Copyrigh: Voipac s.r.o.
# Author: Marek Belisko <marek.belisko@voipac.com>
#

# u-boot config
G_UBOOT_DEF_CONFIG_MMC="imx8mq_evk_voipac_defconfig"

UBOOT_SRCREV="4979a99482f7e04a3c1f4fb55e3182395ee8f710"
UBOOT_SRCBRANCH="imx_v2020.04_5.4.24_2.1.0"
UBOOT_PATH="sources/u-boot-imx"

# ATF
ATF_SRCREV="b0a00f22b09c13572d3e87902a1069dee34763bd"
ATF_SRCBRANCH="imx_5.4.24_2.1.0"
ATF_PATH="sources/imx-atf"

# firmware
FIRMWARE_BINARY="firmware-imx-8.9.bin"
FIRMWARE_IMX="https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/${FIRMWARE_BINARY}"
FIRMWARE_PATH="sources/firmware-imx"

# mkimage
IMX_MKIMAGE_SRCREV="57fec89e550864d2f7ac7fa01fd4143b3e18c71d"
IMX_MKIMAGE_SRCBRANCH="imx_5.4.70_2.3.0"
IMX_MKIMAGE_PATH="sources/imx-mkimage"


# kernel config
KERNEL_SRCBRANCH="5.4-2.1.x-imx"
KERNEL_SRCREV="074a74780f813c7e6037f3ca3e581c405276e502"
KERNEL_URL="https://github.com/Freescale/linux-fslc.git"
KERNEL_PATH="sources/linux-fslc-imx"
UIMAGE_LOADADDR="0x40480000"

KERNEL_DEVICETREE=" \
    arch/arm64/boot/dts/freescale/imx8mq-evk-voipac-dp.dtb \
    arch/arm64/boot/dts/freescale/imx8mq-evk-voipac-hdmi.dtb \
    arch/arm64/boot/dts/freescale/imx8mq-evk-voipac-lvds-koe.dtb \
    arch/arm64/boot/dts/freescale/imx8mq-evk-voipac-lvds-newhaven.dtb \
"

# debian release
DEBIAN_RELEASE="bullseye"
