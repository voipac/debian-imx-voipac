#!/bin/bash
#
# Copyrigh: Voipac s.r.o.
# Author: Marek Belisko <marek.belisko@voipac.com>
#

set -e

source helpers/sources.sh
source "machines/${MACHINE}/${MACHINE}.sh"

KERNEL_SRCBRANCH="5.4-2.1.x-imx"
KERNEL_SRCREV="074a74780f813c7e6037f3ca3e581c405276e502"
KERNEL_URL="https://github.com/Freescale/linux-fslc.git"
KERNEL_PATH="sources/linux-fslc-imx"
UIMAGE_LOADADDR="0x40480000"

mkdir -p ${KERNEL_PATH}

# verify if we have sources available
if [ $(ls ${KERNEL_PATH} | wc -l) = 0 ]; then
    get_git_src ${KERNEL_URL} ${KERNEL_SRCBRANCH} "$(pwd)/${KERNEL_PATH}" ${KERNEL_SRCREV}
fi

function cmd_make_kernel()
{
    make_kernel "$(pwd)/machines/${MACHINE}/patches/kernel" "$(pwd)/sources/linux-fslc-imx"
}

function make_kernel()
{
    # apply board specific patches
    if [ ! -f "${KERNEL_PATH}/.applied" ]; then
        cd ${KERNEL_PATH}
        mkdir -p mbox
        cp -f ${1}/*.patch mbox
        git am -3 mbox/*
        touch .applied
        cd -
    fi

    cp ${1}/.config ${2}

    if [ ! -z "${UIMAGE_LOADADDR}" ]; then
		IMAGE_EXTRA_ARGS="LOADADDR=${UIMAGE_LOADADDR}"
    fi
    
    make ARCH=arm64 -j$(nproc) -C ${2} \
		CROSS_COMPILE=aarch64-linux-gnu- ${IMAGE_EXTRA_ARGS} Image
    
    make ARCH=arm64 -j$(nproc) -C ${2} \
		CROSS_COMPILE=aarch64-linux-gnu- dtbs

    make ARCH=arm64 -j$(nproc) -C ${2} \
		CROSS_COMPILE=aarch64-linux-gnu- modules

    rm -rf ${2}/modules
    
    make ARCH=arm64 -j$(nproc) -C ${2} V=1\
		CROSS_COMPILE=aarch64-linux-gnu- modules_install INSTALL_MOD_PATH=${2}/modules
}