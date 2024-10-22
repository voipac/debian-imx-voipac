#!/bin/bash
#
# Copyrigh: Voipac s.r.o.
# Author: Marek Belisko <marek.belisko@voipac.com>
#

# get git sources
# $1 - repo
# $2 - branch
# $3 - target
# $4 - commit
function get_git_src()
{
	git config --global user.email "builder@example.com"
	git config --global user.name "Builder"

	if [ $(ls ${3} | wc -l) = 0 ]; then
	        # clone src code
        	git clone ${1} -b ${2} --single-branch ${3}
	fi
	
	cd ${3}
	git config --global --add safe.directory ${3}
	git fetch -p
	git checkout $2
        git reset --hard ${4}
        cd -
}

# get remote file
# $1 - remote file
# $2 - local file
function get_remote_file()
{
        # download remote file
        wget -c ${1} -O ${2}
}
