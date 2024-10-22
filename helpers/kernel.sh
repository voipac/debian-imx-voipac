#!/bin/bash
#
# Copyrigh: Voipac s.r.o.
# Author: Marek Belisko <marek.belisko@voipac.com>
#

set -e

source helpers/sources.sh
source "machines/${MACHINE}/${MACHINE}.sh"

mkdir -p ${KERNEL_PATH}

# verify if we have sources available
#if [ $(ls ${KERNEL_PATH} | wc -l) = 0 ]; then
    get_git_src ${KERNEL_URL} ${KERNEL_SRCBRANCH} "$(pwd)/${KERNEL_PATH}" ${KERNEL_SRCREV}
#fi

function cmd_make_kernel()
{
    make_kernel "$(pwd)/machines/${MACHINE}/patches/kernel" "$(pwd)/${KERNEL_PATH}"
}

function make_kernel()
{
    # apply board specific patches
#    if [ ! -f "${KERNEL_PATH}/.applied" ]; then
        cd ${KERNEL_PATH}
        mkdir -p mbox
        cp -f ${1}/*.patch mbox
        git am -3 mbox/*
        touch .applied
        cd -
 #   fi

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
