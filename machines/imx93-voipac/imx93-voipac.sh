#!/bin/bash
#
# Copyrigh: Voipac s.r.o.
# Author: Marek Belisko <marek.belisko@voipac.com>
#

PLAT="imx93"

# u-boot config
G_UBOOT_DEF_CONFIG_MMC="imx93_voipac_evk_defconfig"

UBOOT_SRCREV="de16f4f17221b2ff72b8cb18c28cd8a29f3c2710"
UBOOT_SRCBRANCH="lf-6.6.36-2.1.0"
UBOOT_PATH="sources/u-boot-imx"

# ATF
ATF_SRCREV="28affcae957cb8194917b5246276630f9e6343e1"
ATF_SRCBRANCH="lf-6.6.36-2.1.0"
ATF_PATH="sources/imx-atf"

# firmware
FIRMWARE_BINARY="firmware-imx-8.18.bin"
FIRMWARE_IMX="https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/${FIRMWARE_BINARY}"
FIRMWARE_PATH="sources/firmware-imx"

FIRMWARE_SENTINEL="https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/firmware-ele-imx-0.1.1.bin"
FIRMWARE_SENTINEL_PATH="sources/firmware-sentinel"

# mkimage
IMX_MKIMAGE_SRCREV="4622115cbc037f79039c4522faeced4aabea986b"
IMX_MKIMAGE_SRCBRANCH="lf-6.6.36_2.1.0"
IMX_MKIMAGE_PATH="sources/imx-mkimage"


# kernel config
KERNEL_SRCBRANCH="lf-6.6.y"
KERNEL_SRCREV="d23d64eea5111e1607efcce1d601834fceec92cb"
KERNEL_URL="https://github.com/nxp-imx/linux-imx.git"
KERNEL_PATH="sources/linux-imx"

# kernel config
KERNEL_DEVICETREE=" \
    arch/arm64/boot/dts/freescale/imx93-voipac-evk.dtb \
    arch/arm64/boot/dts/freescale/imx93-voipac-evk-boe-wxga-lvds-panel.dtb \
"

# debian release
DEBIAN_RELEASE="bookworm"

# imx-boot offset
IMX_BOOT_OFFSET=32

# setup for pro and max
MEMORY_SIZE="2G"
