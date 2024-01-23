#!/bin/bash

# get git sources
# $1 - repo
# $2 - branch
# $3 - target
# $4 - commit
function get_git_src()
{
        # clone src code
        git clone ${1} -b ${2} ${3}
        cd ${3}
        git reset --hard ${4}
        cd -
}

# get remote file
# $1 - remote file
# $2 - local file
# $3 - optional sha256sum
function get_remote_file()
{
        # download remote file
        wget -c ${1} -O ${2}

        # verify sha256sum
        if [ -n "${3}" ]; then
                echo "${3} ${2}" | sha256sum -c
        fi
}
