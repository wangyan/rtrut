#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

if [ $(id -u) != "0" ]; then
	printf "Error: You must be root to run this script!"
	exit 1
fi

RTRUT_PATH=`pwd`
if [ `echo $RTRUT_PATH | awk -F/ '{print $NF}'` != "rtrut" ]; then
	clear && echo "Please enter rtrut script path:"
	read -p "(Default path: ${RTRUT_PATH}/rtrut):" RTRUT_PATH
	[ -z "$RTRUT_PATH" ] && RTRUT_PATH=$(pwd)/rtrut
	cd $RTRUT_PATH/
fi

clear
echo "#############################################################"
echo "# rTorrent + ruTorrent Auto Install Shell Script"
echo "# Env: Redhat/CentOS"
echo "# Intro: https://wangyan.org/blog/rtorrent-shell-script.html"
echo "# Version: $(awk '/version/{print $2}' $RTRUT_PATH/Changelog)"
echo "#"
echo "# Copyright (c) 2012, WangYan <WangYan@188.com>"
echo "# All rights reserved."
echo "# Distributed under the GNU General Public License, version 3.0."
echo "#"
echo "#############################################################"
echo ""

echo "Do you want install ruTorrent ? (y/n)"
read -p "(Default: n):" INSTALL_RUTORRENT
if [ -z $INSTALL_RUTORRENT ]; then
	INSTALL_RUTORRENT="n"
fi
echo "---------------------------"
echo "You choose = $INSTALL_RUTORRENT"
echo "---------------------------"
echo ""

if [ "$INSTALL_RUTORRENT" = "y" ]; then
	echo "Please enter the server IP address:"
	TEMP_IP=`ifconfig |grep 'inet' | grep -Evi '(inet6|127.0.0.1)' | awk '{print $2}' | cut -d: -f2 | tail -1`
	read -p "(e.g: $TEMP_IP):" IP_ADDRESS
	if [ -z $IP_ADDRESS ]; then
		IP_ADDRESS="$TEMP_IP"
	fi
	echo "---------------------------"
	echo "IP address = $IP_ADDRESS"
	echo "---------------------------"
	echo ""

	echo "Please enter the webroot dir:"
	read -p "(Default webroot dir: /var/www):" WEBROOT
	if [ -z $WEBROOT ]; then
		WEBROOT="/var/www"
	fi
	echo "---------------------------"
	echo "Webroot dir=$WEBROOT"
	echo "---------------------------"
	echo ""

	echo "Please input the nginx config path:"
	read -p "(Default path: /usr/local/nginx/conf/vhosts/localhost.conf):" NGINX_CONFIG
	if [ -z $NGINX_CONFIG ]; then
		NGINX_CONFIG="/usr/local/nginx/conf/vhosts/localhost.conf"
	fi
	echo "---------------------------"
	echo "Nginx config path=$NGINX_CONFIG"
	echo "---------------------------"
	echo ""
fi

get_char()
{
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}
echo "Press any key to start install..."
char=`get_char`

echo "---------- Disable SeLinux ----------"

if [ -s /etc/selinux/config ]; then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi

echo "---------- Dependent Packages ----------"

yum -y install make gcc-c++ libtool pkgconfig
yum -y install curl-devel openssl-devel ncurses-devel xmlrpc-c-devel
yum -y install screen xz

echo "================ rTorrent Install ==============="

echo "/usr/local/lib/" >> /etc/ld.so.conf
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

echo "---------- libsigc++ ----------"

if [ ! -s libsigc++-*.tar.xz ]; then
	wget http://ftp.gnome.org/pub/GNOME/sources/libsigc++/2.2/libsigc++-2.2.11.tar.xz
fi
xz -d libsigc++-*.tar.xz
tar -xf libsigc++-*.tar
cd libsigc++-*
./configure
make && make install

echo "---------- libtorrent ----------"

cd $RTRUT_PATH/

if [ ! -s libtorrent-*.tar.gz ]; then
    wget http://libtorrent.rakshasa.no/downloads/libtorrent-0.13.2.tar.gz
fi
tar -zxf libtorrent-*.tar.gz
cd libtorrent-*
./configure
make && make install
ldconfig

echo "---------- rTorrent ----------"

cd $RTRUT_PATH/

if [ ! -s rtorrent-*.tar.gz ]; then
    wget http://libtorrent.rakshasa.no/downloads/rtorrent-0.9.2.tar.gz
fi
tar -zxf rtorrent-*.tar.gz
cd rtorrent-*
./configure --with-xmlrpc-c
make && make install

echo "---------- rTorrent conf ----------"

mkdir -p ~/rtorrent/{download,session,watch}
cp $RTRUT_PATH/rtorrent.rc ~/.rtorrent.rc

cp $RTRUT_PATH/init.d.rtorrent /etc/init.d/rtorrent
chmod 755 /etc/init.d/rtorrent

echo "================ ruTorrent Install ==============="

if [ "$INSTALL_RUTORRENT" = "y" ]; then

	cat >>~/.rtorrent.rc<<-EOF
	execute_nothrow=rm,/tmp/rpc.socket
	scgi_local = /tmp/rpc.socket
	schedule = chmod,0,0,"execute=chmod,777,/tmp/rpc.socket"
	EOF

	if [ ! -s rutorrent-*.tar.gz ]; then
		wget http://rutorrent.googlecode.com/files/rutorrent-3.4.tar.gz
	fi
	tar -zxf rutorrent-*.tar.gz
	mv rutorrent  $WEBROOT

	cp $WEBROOT/rutorrent/conf/config.php $WEBROOT/rutorrent/conf/config.php.bak
	sed -i 's/\/\/ $scgi/$scgi/g' $WEBROOT/rutorrent/conf/config.php
	sed -i 's/$scgi_port = 5000/\/\/ $scgi_port = 5000/g' $WEBROOT/rutorrent/conf/config.php
	sed -i 's/$scgi_host = "127/\/\/ $scgi_host = "127/g' $WEBROOT/rutorrent/conf/config.php
	sed -i "s/\"curl\"\t=> ''/\"curl\"\t=> '\/usr\/bin\/curl'/g" $WEBROOT/rutorrent/conf/config.php
	sed -i "s/\"gzip\"\t=> ''/\"gzip\"\t=> '\/usr\/bin\/gzip'/g" $WEBROOT/rutorrent/conf/config.php
	sed -i "s/\"id\"\t=> ''/\"id\"\t=> '\/usr\/bin\/id'/g" $WEBROOT/rutorrent/conf/config.php
	sed -i "s/\"stat\"\t=> ''/\"stat\"\t=> '\/usr\/bin\/stat'/g" $WEBROOT/rutorrent/conf/config.php

	sed -i '1,/location/{/location/i\
	\nlocation /RPC2 {\ninclude scgi_params;\nscgi_pass unix:/tmp/rpc.socket;\n}\n
	}' $NGINX_CONFIG

	/etc/init.d/nginx restart
	/etc/init.d/rtorrent start

	which httpd > /dev/null 2>&1
	if [ $? -eq 0 ];then
		/etc/init.d/httpd restart
	fi

	service iptables stop > /dev/null 2>&1
fi

clear
echo ""
echo "===================== Install completed ====================="
echo ""
echo "rTorrent install completed!"
echo "Intro https://wangyan.org/blog/rtorrent-shell-script.html"
echo ""
if [ "$INSTALL_RUTORRENT" = "y" ]; then
	echo "ruTorrent Config: $WEBROOT/rutorrent/conf/config.php"
	echo "ruTorrent URL: http://$IP_ADDRESS/rutorrent"
	echo ""
fi
echo "============================================================="
echo ""
