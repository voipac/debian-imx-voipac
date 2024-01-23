#!/bin/bash

G_TOOLS_PATH="tools"
G_CROSS_COMPILER_NAME="gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu.tar.xz"
G_CROSS_COMPILER_PATH="$(pwd)/${G_TOOLS_PATH}/$(basename ${G_CROSS_COMPILER_NAME} .tar.xz)/bin"
G_CROSS_COMPILER_PREFIX="aarch64-linux-gnu-"
ARCH_ARGS="arm64"

G_EXT_CROSS_64BIT_COMPILER_LINK="https://releases.linaro.org/components/toolchain/binaries/6.3-2017.05/aarch64-linux-gnu/${G_CROSS_COMPILER_NAME}"

source helpers/sources.sh

mkdir -p ${G_TOOLS_PATH}

# fetch toolchain only if empty directory
if [ $(ls -la ${G_CROSS_COMPILER_PATH} | wc -l) = 0 ]; then
    get_remote_file ${G_EXT_CROSS_64BIT_COMPILER_LINK} ${G_TOOLS_PATH}/${G_CROSS_COMPILER_NAME}
    cd tools
    tar -xvf ${G_CROSS_COMPILER_NAME}
    cd -
fi

