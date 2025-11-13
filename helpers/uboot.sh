#!/bin/bash
#
# Copyrigh: Voipac s.r.o.
# Author: Marek Belisko <marek.belisko@voipac.com>
#

set -x

source helpers/sources.sh
#source helpers/toolchain.sh
source "machines/${MACHINE}/${MACHINE}.sh"


TOP_DIR="$(pwd)"


mkdir -p sources

# verify if we have sources available
#if [ $(ls ${UBOOT_PATH} | wc -l) = 0 ]; then
    get_git_src "https://github.com/nxp-imx/uboot-imx.git" "${UBOOT_SRCBRANCH}" "$(pwd)/${UBOOT_PATH}" "${UBOOT_SRCREV}"
#fi

#if [ $(ls ${ATF_PATH} | wc -l) = 0 ]; then
    get_git_src "https://github.com/nxp-imx/imx-atf.git" "${ATF_SRCBRANCH}" "$(pwd)/${ATF_PATH}" "${ATF_SRCREV}"
#fi

#if [ $(ls ${IMX_MKIMAGE_PATH} | wc -l) = 0 ]; then
    get_git_src "https://github.com/nxp-imx/imx-mkimage.git" "${IMX_MKIMAGE_SRCBRANCH}" "$(pwd)/${IMX_MKIMAGE_PATH}" "${IMX_MKIMAGE_SRCREV}"
#fi


# $1 - path to machine specific patches
function cmd_make_uboot()
{
    make_uboot "$(pwd)/machines/${MACHINE}/patches/u-boot" "$(pwd)/sources/u-boot-imx"
}

function make_uboot()
{
    # apply board specific patches
    cd ${UBOOT_PATH}
    mkdir -p mbox
    cp -f ${1}/*.patch mbox
    git am -3 mbox/*
    cd -

    # make atf image
    cd ${ATF_PATH}
    LDFLAGS="" make -j$(nproc) CROSS_COMPILE=aarch64-linux-gnu- \
                    PLAT=${PLAT} bl31
    if [ ${PLAT} = "imx8mq" ]; then
        cp build/${PLAT}/release/bl31.bin "../../${IMX_MKIMAGE_PATH}/iMX8M"
    elif [ ${PLAT} = "imx93" ]; then
        cp build/${PLAT}/release/bl31.bin "../../${IMX_MKIMAGE_PATH}/iMX93"
    elif [ ${PLAT} = "imx91" ]; then
        cp build/${PLAT}/release/bl31.bin "../../${IMX_MKIMAGE_PATH}/iMX91"
    fi
    cp build/${PLAT}/release/bl31.bin "../../${UBOOT_PATH}"
    cd -

    # fetch and process firmware
    mkdir -p ${FIRMWARE_PATH}
    get_remote_file ${FIRMWARE_IMX} ${FIRMWARE_PATH}/${FIRMWARE_BINARY}

    cd ${FIRMWARE_PATH}
    chmod +x ${FIRMWARE_BINARY}
    if [ ! -d $(basename ${FIRMWARE_BINARY} .bin) ]; then
       ./${FIRMWARE_BINARY}
    fi
    if [ ${PLAT} = "imx8mq" ]; then
        cp $(basename ${FIRMWARE_BINARY} .bin)/firmware/hdmi/cadence/signed_hdmi_imx8m.bin "../../${UBOOT_PATH}"
	cp $(basename ${FIRMWARE_BINARY} .bin)/firmware/hdmi/cadence/signed_hdmi_imx8m.bin "../../${IMX_MKIMAGE_PATH}/iMX8M"
	cp $(basename ${FIRMWARE_BINARY} .bin)/firmware/ddr/synopsys/lpddr4*.bin "../../${UBOOT_PATH}"
	cp $(basename ${FIRMWARE_BINARY} .bin)/firmware/ddr/synopsys/lpddr4*.bin "../../${IMX_MKIMAGE_PATH}/iMX8M"
    elif [ ${PLAT} = "imx93" ]; then
        cp $(basename ${FIRMWARE_BINARY} .bin)/firmware/ddr/synopsys/lpddr4*.bin "../../${IMX_MKIMAGE_PATH}/iMX93"
    elif [ ${PLAT} = "imx91" ]; then
        cp $(basename ${FIRMWARE_BINARY} .bin)/firmware/ddr/synopsys/lpddr4*.bin "../../${IMX_MKIMAGE_PATH}/iMX91"

    fi
    cd -

    # firmware sentinel
    if [ ${PLAT} = "imx93" ] || [ ${PLAT} = "imx91" ]; then
        mkdir -p ${FIRMWARE_SENTINEL_PATH}
       	BINARY=$(basename "${FIRMWARE_SENTINEL}")
        get_remote_file ${FIRMWARE_SENTINEL} ${FIRMWARE_SENTINEL_PATH}/${BINARY}
	    cd ${FIRMWARE_SENTINEL_PATH}
    	chmod +x ${BINARY} && ./${BINARY} --auto-accept --force
	    echo "Done"
        if [ ${PLAT} = "imx93" ]; then
	        cp $(basename ${BINARY} .bin)/mx93a1-ahab-container.img "../../${IMX_MKIMAGE_PATH}/iMX93"
        elif [ ${PLAT} = "imx91" ]; then
        	cp $(basename ${BINARY} .bin)/mx91a0-ahab-container.img "../../${IMX_MKIMAGE_PATH}/iMX91"
        fi
	    cd -
    fi

    # cd to sources
    cd ${UBOOT_PATH}

    # make u-boot image
    # clean work directory
	make ARCH=arm -C ${2} mrproper

	# make U-Boot mmc defconfig
	make -C ${2} ${G_UBOOT_DEF_CONFIG_MMC}

	# adjust .config with proper memory size
	case $MEMORY_SIZE in
		"2G")
			echo "Memory size is 2G"
			sed -i 's?CONFIG_DRAM_SIZE_512M=y?CONFIG_DRAM_SIZE_2G=y?g' ${2}/.config;;

		"1G")
			echo "Memory size is 1G"
			sed -i 's?CONFIG_DRAM_SIZE_512M=y?CONFIG_DRAM_SIZE_1G=y?g' ${2}/.config;;
	esac


	# make U-Boot
	make -j$(nproc)  -C ${2} \
		CROSS_COMPILE=aarch64-linux-gnu- \
		${G_CROSS_COMPILER_JOPTION}

	# make fw_printenv
	make envtools -C ${2} \
		CROSS_COMPILE=aarch64-linux-gnu- \
		${G_CROSS_COMPILER_JOPTION}

	#cp ${1}/tools/env/fw_printenv ${2}
    if [ ${PLAT} = "imx8mq" ]; then
        cp spl/u-boot-spl.bin "../../${IMX_MKIMAGE_PATH}/iMX8M"
        cp u-boot-nodtb.bin "../../${IMX_MKIMAGE_PATH}/iMX8M"
        cp arch/arm/dts/imx8mq-evk-voipac.dtb "../../${IMX_MKIMAGE_PATH}/iMX8M"
        cp tools/mkimage "../../${IMX_MKIMAGE_PATH}/iMX8M/mkimage_uboot"
    elif [ ${PLAT} = "imx93" ]; then
	cp spl/u-boot-spl.bin "../../${IMX_MKIMAGE_PATH}/iMX93"
        cp u-boot.bin "../../${IMX_MKIMAGE_PATH}/iMX93"
    elif [ ${PLAT} = "imx91" ]; then
	cp spl/u-boot-spl.bin "../../${IMX_MKIMAGE_PATH}/iMX91"
        cp u-boot.bin "../../${IMX_MKIMAGE_PATH}/iMX91"

    fi
    cd -

    cd ${IMX_MKIMAGE_PATH}

    if [ ${PLAT} = "imx8mq" ]; then
        cd iMX8M
        ln -sf imx8mq-evk-voipac.dtb imx8mq-evk.dtb
        cd -
        make SOC=iMX8MQ flash_evk
    elif [ ${PLAT} = "imx93" ]; then
        make SOC=iMX9 REV=A1 flash_singleboot
    elif [ ${PLAT} = "imx91" ]; then
        make SOC=iMX91 flash_singleboot
    fi
    cd -

    cd ${TOP_DIR}
}

# $1 - destination path
function copy_bootloader()
{
    dts="$1"
    if [ ${PLAT} = "imx8mq" ]; then
        cp ${IMX_MKIMAGE_PATH}/iMX8M/flash.bin ${dts}
    elif [ ${PLAT} = "imx93" ]; then
        cp ${IMX_MKIMAGE_PATH}/iMX93/flash.bin ${dts}
    elif [ ${PLAT} = "imx91" ]; then
        pwd

        cp ${IMX_MKIMAGE_PATH}/iMX91/flash.bin ${dts}
    fi
}






