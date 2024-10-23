#!/bin/bash
#
# Copyrigh: Voipac s.r.o.
# Author: Marek Belisko <marek.belisko@voipac.com>
#

set -e

source docker/docker_info.sh

echo "Building docker image ${REPO} - tag: ${TAG}"

docker build \
	-t $REPO:$TAG docker/
