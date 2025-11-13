#!/bin/bash
#
# Copyrigh: Voipac s.r.o.
# Author: Marek Belisko <marek.belisko@voipac.com>
#

PLAT="imx91"

# u-boot config
G_UBOOT_DEF_CONFIG_MMC="imx91_voipac_evk_defconfig"

UBOOT_SRCREV="6c4545203d123c246c5d7995f2893959506d28e0"
UBOOT_SRCBRANCH="lf-6.6.52-2.2.0"
UBOOT_PATH="sources/u-boot-imx"

# ATF
ATF_SRCREV="1b27ee3edbb40ef9432c69ccaa744d1ac5d54c5d"
ATF_SRCBRANCH="lf-6.6.52-2.2.0"
ATF_PATH="sources/imx-atf"

# firmware
FIRMWARE_BINARY="firmware-imx-8.26-d4c33ab.bin"
FIRMWARE_IMX="https://www.nxp.com/lgfiles/NMG/MAD/YOCTO//${FIRMWARE_BINARY}"
FIRMWARE_PATH="sources/firmware-imx"

FIRMWARE_SENTINEL="https://www.nxp.com/lgfiles/NMG/MAD/YOCTO//firmware-ele-imx-1.3.0-17945fc.bin"
FIRMWARE_SENTINEL_PATH="sources/firmware-sentinel"

# mkimage
IMX_MKIMAGE_SRCREV="71b8c18af93a5eb972d80fbec290006066cff24f"
IMX_MKIMAGE_SRCBRANCH="lf-6.6.52-2.2.0"
IMX_MKIMAGE_PATH="sources/imx-mkimage"


# kernel config
KERNEL_SRCBRANCH="lf-6.6.y"
KERNEL_SRCREV="e0f9e2afd4cff3f02d71891244b4aa5899dfc786"
KERNEL_URL="https://github.com/nxp-imx/linux-imx.git"
KERNEL_PATH="sources/linux-imx"

# kernel config
KERNEL_DEVICETREE=" \
    arch/arm64/boot/dts/freescale/imx91-voipac-evk.dtb \
"

# debian release
DEBIAN_RELEASE="bookworm"

# imx-boot offset
IMX_BOOT_OFFSET=32

# setup for pro and max
MEMORY_SIZE="2G"
