#!/bin/bash
#
# Copyrigh: Voipac s.r.o.
# Author: Marek Belisko <marek.belisko@voipac.com>
#

apt update

apt install \
	sudo \
	ssh \
	net-tools \
	network-manager \
	iputils-ping \
	rsyslog \
	htop \
	vim \
	openssh-server

# setup root pwd
echo "root:root" | chpasswd

# setup hostname
echo "imx8mq-voipac" > /etc/hostname

# added default name server
echo "nameserver 8.8.8.8" > /etc/resolv.conf

USERNAME="voipac"
PASSWD="voipac"

# added user
useradd  -m ${USERNAME}
echo "${USERNAME}:${PASSWD}" | chpasswd
