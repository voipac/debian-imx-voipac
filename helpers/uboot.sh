#!/bin/bash

set -e

source helpers/sources.sh
source helpers/toolchain.sh
source "machines/${MACHINE}/${MACHINE}.sh"

UBOOT_SRCREV="4979a99482f7e04a3c1f4fb55e3182395ee8f710"
UBOOT_SRCBRANCH="imx_v2020.04_5.4.24_2.1.0"
UBOOT_PATH="sources/u-boot-imx"

ATF_SRCREV="b0a00f22b09c13572d3e87902a1069dee34763bd"
ATF_SRCBRANCH="imx_5.4.24_2.1.0"
ATF_PATH="sources/imx-atf"

FIRMWARE_BINARY="firmware-imx-8.9.bin"
FIRMWARE_IMX="https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/${FIRMWARE_BINARY}"
FIRMWARE_PATH="sources/firmware-imx"

IMX_MKIMAGE_SRCREV="57fec89e550864d2f7ac7fa01fd4143b3e18c71d"
IMX_MKIMAGE_SRCBRANCH="imx_5.4.70_2.3.0"
IMX_MKIMAGE_PATH="sources/imx-mkimage"


mkdir -p sources

# verify if we have sources available
if [ $(ls ${UBOOT_PATH} | wc -l) = 0 ]; then
    get_git_src "https://github.com/nxp-imx/uboot-imx.git" "${UBOOT_SRCBRANCH}" "$(pwd)/${UBOOT_PATH}" "${UBOOT_SRCREV}"
fi

if [ $(ls ${ATF_PATH} | wc -l) = 0 ]; then
    get_git_src "https://github.com/nxp-imx/imx-atf.git" "${ATF_SRCBRANCH}" "$(pwd)/${ATF_PATH}" "${ATF_SRCREV}"
fi

if [ $(ls ${IMX_MKIMAGE_PATH} | wc -l) = 0 ]; then
    get_git_src "https://github.com/nxp-imx/imx-mkimage.git" "${IMX_MKIMAGE_SRCBRANCH}" "$(pwd)/${IMX_MKIMAGE_PATH}" "${IMX_MKIMAGE_SRCREV}"
fi


# $1 - path to machine specific patches
function cmd_make_uboot()
{
    make_uboot "$(pwd)/machines/${MACHINE}/patches/u-boot" "$(pwd)/sources/u-boot-imx"
}

function make_uboot()
{
    # apply board specific patches
    if [ ! -f "${UBOOT_PATH}/.applied" ]; then
        cd ${UBOOT_PATH}
        mkdir -p mbox
        cp -f ${1}/*.patch mbox
        git am -3 mbox/*
        touch .applied
        cd -
    fi

    # make atf image
    cd ${ATF_PATH}
    LDFLAGS="" make -j$(nproc) CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
                    PLAT=imx8mq bl31
    cp build/imx8mq/release/bl31.bin ../../${UBOOT_PATH} "../../${IMX_MKIMAGE_PATH}/iMX8M"
    cd -

    # fetch and process firmware
    mkdir -p ${FIRMWARE_PATH}
    get_remote_file ${FIRMWARE_IMX} ${FIRMWARE_PATH}/${FIRMWARE_BINARY}

    cd ${FIRMWARE_PATH}
        chmod +x ${FIRMWARE_BINARY} 
        if [ ! -d $(basename ${FIRMWARE_BINARY} .bin) ]; then
            ./${FIRMWARE_BINARY}
        fi
        cp $(basename ${FIRMWARE_BINARY} .bin)/firmware/hdmi/cadence/signed_hdmi_imx8m.bin ../../${UBOOT_PATH} "../../${IMX_MKIMAGE_PATH}/iMX8M"
        cp $(basename ${FIRMWARE_BINARY} .bin)/firmware/ddr/synopsys/lpddr4*.bin ../../${UBOOT_PATH} "../../${IMX_MKIMAGE_PATH}/iMX8M"
    cd -

    # cd to sources
    cd ${UBOOT_PATH}
   
    # make u-boot image
    # clean work directory
	make ARCH=arm -C ${2} mrproper

	# make U-Boot mmc defconfig
	make -C ${2} ${G_UBOOT_DEF_CONFIG_MMC}

	# make U-Boot
	make -j$(nproc)  -C ${2} \
		CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
		${G_CROSS_COMPILER_JOPTION}

	# make fw_printenv
	make envtools -C ${2} \
		CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
		${G_CROSS_COMPILER_JOPTION}

	#cp ${1}/tools/env/fw_printenv ${2}
    cp spl/u-boot-spl.bin "../../${IMX_MKIMAGE_PATH}/iMX8M"
    cp u-boot-nodtb.bin "../../${IMX_MKIMAGE_PATH}/iMX8M"
    cp arch/arm/dts/imx8mq-evk-voipac.dtb "../../${IMX_MKIMAGE_PATH}/iMX8M"
    cp tools/mkimage "../../${IMX_MKIMAGE_PATH}/iMX8M/mkimage_uboot"
    cd -

    cd ${IMX_MKIMAGE_PATH}
    cd iMX8M
    ln -sf imx8mq-evk-voipac.dtb imx8mq-evk.dtb
    cd -
    make SOC=iMX8MQ flash_evk
    cd -
}






