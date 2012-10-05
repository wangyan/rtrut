#! /bin/bash
#====================================================================
# install.sh
#
# rTorrent + ruTorrent Auto Install Script
#
# Copyright (c) 2012, WangYan <WangYan@188.com>
# All rights reserved.
# Distributed under the GNU General Public License, version 3.0.
#
# Intro: https://wangyan.org/blog/rtorrent-shell-script.html
#
#====================================================================

if [ $(id -u) != "0" ]; then
    clear && echo "Error: You must be root to run this script!"
    exit 1
fi

RTRUT_PATH=`pwd`
if [ `echo $RTRUT_PATH | awk -F/ '{print $NF}'` != "rtrut" ]; then
	clear && echo "Please enter rtrut script path:"
	read -p "(Default path: ${RTRUT_PATH}/rtrut):" RTRUT_PATH
	[ -z "$RTRUT_PATH" ] && RTRUT_PATH=$(pwd)/rtrut
	cd $RTRUT_PATH/
fi

DISTRIBUTION=`awk 'NR==1{print $1}' /etc/issue`

if echo $DISTRIBUTION | grep -Eqi '(Red Hat|CentOS|Fedora|Amazon)';then
    PACKAGE="rpm"
elif echo $DISTRIBUTION | grep -Eqi '(Debian|Ubuntu)';then
    PACKAGE="deb"
else
    if cat /proc/version | grep -Eqi '(redhat|centos)';then
        PACKAGE="rpm"
    elif cat /proc/version | grep -Eqi '(debian|ubuntu)';then
        PACKAGE="deb"
    else
        echo "Please select the package management! (rpm/deb)"
        read -p "(Default: rpm):" PACKAGE
        if [ -z "$PACKAGE" ]; then
            PACKAGE="rpm"
        fi
        if [[ "$PACKAGE" != "rpm" && "$PACKAGE" != "deb" ]];then
            echo -e "\nNot supported linux distribution!"
            echo "Please contact me! WangYan <WangYan@188.com>"
            exit 0
        fi
    fi
fi

[ -r "$RTRUT_PATH/fifo" ] && rm -rf $RTRUT_PATH/fifo
mkfifo $RTRUT_PATH/fifo
cat $RTRUT_PATH/fifo | tee $RTRUT_PATH/log.txt &
exec 1>$RTRUT_PATH/fifo
exec 2>&1

/bin/bash ${RTRUT_PATH}/${PACKAGE}.sh

sed -i '/password/d' $RTRUT_PATH/log.txt
rm -rf $RTRUT_PATH/fifo
