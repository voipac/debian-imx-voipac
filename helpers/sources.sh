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
        # clone src code
        git clone ${1} -b ${2} --single-branch ${3}
        cd ${3}
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
