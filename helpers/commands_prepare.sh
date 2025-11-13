#!/bin/bash
#
# Copyrigh: Voipac s.r.o.
# Author: Marek Belisko <marek.belisko@voipac.com>
#

function cmd_make_prepare()
{
    source helpers/uboot.sh
    source helpers/kernel.sh
    source helpers/imx9x/build_nxp_wlan_modules.sh
    source helpers/sdimg.sh
}
