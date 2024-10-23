#!/bin/bash
#
# Copyrigh: Voipac s.r.o.
# Author: Marek Belisko <marek.belisko@voipac.com>
#

set -e

source "machines/${MACHINE}/${MACHINE}.sh"

ROOTFS_PATH="debian-rootfs"

mkdir -p ${ROOTFS_PATH}

function cmd_make_rootfs()
{
	if [ $(ls ${ROOTFS_PATH} | wc -l) = 0 ];then
		# debootstrap debian
		debootstrap --arch arm64 ${DEBIAN_RELEASE} ${ROOTFS_PATH} http://ftp.uk.debian.org/debian

		mkdir -p ${ROOTFS_PATH}/etc/sudoers.d/
		echo "user ALL=(root) /usr/bin/apt-get, /usr/bin/dpkg, /usr/bin/vi, /sbin/reboot" > ${ROOTFS_PATH}/etc/sudoers.d/user
			chmod 0440 ${ROOTFS_PATH}/etc/sudoers.d/user
	fi
	# copy update script
	cp helpers/update_ubuntu_image_${PLAT}.sh ${ROOTFS_PATH}/update_ubuntu_image.sh

	# copy qemu binary
	cp /usr/bin/qemu-aarch64-static ${ROOTFS_PATH}/usr/bin/qemu-aarch64-static
	# change root with update script
	chroot ${ROOTFS_PATH} ./update_ubuntu_image.sh
	# remove update file
	rm -rf ${ROOTFS_PATH}/update_ubuntu_image.sh
}
