#!/bin/bash

readonly DEB_RELEASE="bullseye"
PARAM_CMD="all"

SCRIPT_NAME=${0##*/}

function usage()
{
    echo "Make Debian ${DEB_RELEASE} image and create a bootabled SD card"
    echo
    echo "Usage:"
    echo " MACHINE=<imx8mq-voipac ./${SCRIPT_NAME} options"
    echo
    echo "Options:"
    echo "  -h|--help   -- print this help"
    echo "  -c|--cmd <command>"
    echo "     Supported commands:"
    echo "       all         -- build or rebuild kernel/bootloader/rootfs"
    echo "       bootloader  -- build or rebuild U-Boot"
    echo "       kernel      -- build or rebuild the Linux kernel"
    echo "       kernelheaders -- build or rebuild Linux kernel headers"
    echo "       modules     -- build or rebuild the Linux kernel modules & headers and install them in the rootfs dir"
    echo "       rootfs      -- build or rebuild the Debian root filesystem and create rootfs.tar.gz"
    echo "                       (including: make & install Debian packages, firmware and kernel modules & headers)"
    echo "       rtar        -- generate or regenerate rootfs.tar.gz image from the rootfs folder"
    echo "       clean       -- clean all build artifacts (without deleting sources code or resulted images)"
    echo "       sdcard      -- create a bootable SD card"
    echo "  -o|--output -- custom select output directory (default: \"${PARAM_OUTPUT_DIR}\")"
    echo "  -d|--dev    -- specify SD card device (exmple: -d /dev/sde)"
    echo "Examples of use:"
    echo "  deploy and build:                 sudo ./${SCRIPT_NAME} --cmd all"
    echo "  make the Linux kernel only:       sudo ./${SCRIPT_NAME} --cmd kernel"
    echo "  make rootfs only:                 sudo ./${SCRIPT_NAME} --cmd rootfs"
    echo "  create SD card:                   sudo ./${SCRIPT_NAME} --cmd sdcard --dev /dev/sdX"
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
                -o|--output ) # select output dir
                        shift
                        PARAM_OUTPUT_DIR="$1";
                        ;;
                -d|--dev ) # SD card block device
                        shift
                        [ -e "${1}" ] && {
                                PARAM_BLOCK_DEVICE=${1};
                        };
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
        modules )
                cmd_make_kmodules
                ;;
        kernelheaders )
                cmd_make_kernel_header_deb
                ;;
        sdcard )
                cmd_make_sdcard
                ;;
        rtar )
                cmd_make_rfs_tar
                ;;

        all )
                cmd_make_uboot  &&
                cmd_make_kernel &&
                cmd_make_kmodules &&
                cmd_make_rootfs
                ;;
        clean )
                cmd_make_clean
                ;;
        * )
                pr_error "Invalid input command: \"${PARAM_CMD}\"";
                ;;
esac
