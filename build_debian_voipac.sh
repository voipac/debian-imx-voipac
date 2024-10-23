#!/bin/bash
#
# Copyrigh: Voipac s.r.o.
# Author: Marek Belisko <marek.belisko@voipac.com>
#

source docker/docker_info.sh

USE_TTY=""
test -t 1 && USE_TTY="-it"

DOCKER_ARGS="${USE_TTY} -v "`pwd`:/opt" -w /opt --privileged=true -v /dev:/dev -e "MACHINE=${MACHINE}" ${REPO}:${TAG} "

if ! docker image inspect ${REPO}:${TAG}  2>&1 > /dev/null; then
	echo "Build container not found, building one"
	docker/build_container.sh
fi

docker run ${DOCKER_ARGS} bash -c "./debian.sh $@"


