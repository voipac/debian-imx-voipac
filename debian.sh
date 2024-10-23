#!/bin/bash
#
# Copyrigh: Voipac s.r.o.
# Author: Marek Belisko <marek.belisko@voipac.com>
#

set -x

PARAM_CMD="all"

SCRIPT_NAME=${0##*/}

function usage()
{
    echo "Make Debian image and create a bootabled SD card"
    echo
    echo "Usage:"
    echo " MACHINE=imx8mq-voipac|imx93-voipac ./${SCRIPT_NAME} options"
    echo
    echo "Options:"
    echo "  -h|--help   -- print this help"
    echo "  -c|--cmd <command>"
    echo "     Supported commands:"
    echo "       all         -- build or rebuild kernel/bootloader/rootfs"
    echo "       bootloader  -- build or rebuild U-Boot"
    echo "       kernel      -- build or rebuild the Linux kernel"
    echo "       rootfs      -- build or rebuild the Debian root filesystem and create rootfs.tar.gz"
    echo "                       (including: make & install Debian packages, firmware and kernel modules & headers)"
    echo
}



## parse input arguments ##
readonly SHORTOPTS="c:o:d:h"
readonly LONGOPTS="cmd:,output:,dev:,help,debug"
  
ARGS=$(getopt -s bash --options ${SHORTOPTS}  \
  --longoptions ${LONGOPTS} --name "${SCRIPT_NAME}" -- "$@" )
        
eval set -- "$ARGS"
        
while true; do
        case $1 in
                -c|--cmd ) # script command
                        shift
                        PARAM_CMD="$1";
                        ;;
                -h|--help ) # get help
                        usage
                        exit 0;
                        ;;
                -- )
                        shift
                        break
                        ;;
                * )
                        shift
                        break
                        ;;
        esac
        shift
done

if [ -z "${MACHINE}" ]; then
    echo "Undefined machine."
    usage
    exit 1
fi

# prepare sources if do not exists yet
source helpers/commands_prepare.sh
source helpers/make_debian_image.sh
cmd_make_prepare

case $PARAM_CMD in
        rootfs )
                cmd_make_rootfs
                ;;
        bootloader )
                cmd_make_uboot
                ;;
        kernel )
                cmd_make_kernel
                ;;
        all )
                cmd_make_uboot  &&
                cmd_make_kernel &&
                cmd_make_rootfs
                cmd_make_sdimg
                ;;
        clean )
                cmd_make_clean
                ;;
        * )
                echo "Invalid input command: \"${PARAM_CMD}\"";
                ;;
esac
