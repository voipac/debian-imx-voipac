#!/bin/bash
#
# Copyrigh: Voipac s.r.o.
# Author: Marek Belisko <marek.belisko@voipac.com>
#

set -e

source helpers/sources.sh
source "machines/${MACHINE}/${MACHINE}.sh"
    
MODULE_PATH="sources/mwifiex"
NXP_FIRMWARE_PATH="sources/imx-firmware"

get_git_src "https://github.com/nxp-imx/mwifiex.git" "lf-6.6.3_1.0.0" "$(pwd)/${MODULE_PATH}" "a84df583155bad2a396a937056805550bdf655ab"

get_git_src "https://github.com/nxp-imx/imx-firmware.git" "lf-6.6.3_1.0.0" "$(pwd)/${NXP_FIRMWARE_PATH}" "2afa15e77f0b58eade42b4f59c9215339efcca66"


function cmd_make_mwifiex()
{
    make_mwifiex "$(pwd)/${KERNEL_PATH}"
}

function make_mwifiex()
{
    
    cd ${MODULE_PATH}"/mxm_wifiex/wlan_src"

    make ARCH=arm64 -j$(nproc) CROSS_COMPILE=aarch64-linux-gnu- KERNELDIR="$1"
    mkdir -p "$(pwd)/result"
    make ARCH=arm64 -j$(nproc) CROSS_COMPILE=aarch64-linux-gnu- KERNELDIR="$1" INSTALLDIR="$(pwd)/result" install
}
