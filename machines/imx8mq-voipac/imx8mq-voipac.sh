#!/bin/bash
#
# Copyrigh: Voipac s.r.o.
# Author: Marek Belisko <marek.belisko@voipac.com>
#

# u-boot config
G_UBOOT_DEF_CONFIG_MMC="imx8mq_evk_voipac_defconfig"

# kernel config
KERNEL_DEVICETREE=" \
    arch/arm64/boot/dts/freescale/imx8mq-evk-voipac-dp.dtb \
    arch/arm64/boot/dts/freescale/imx8mq-evk-voipac-hdmi.dtb \
    arch/arm64/boot/dts/freescale/imx8mq-evk-voipac-lvds-koe.dtb \
    arch/arm64/boot/dts/freescale/imx8mq-evk-voipac-lvds-newhaven.dtb \
"

