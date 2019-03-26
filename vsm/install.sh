#!/bin/bash
# Copyright (c) AstroArch Consulting, Inc.  2017,2018
# All rights reserved
# vim: tabstop=4 shiftwidth=4
#
# An installer for the Linux version of VMware Software Manager (VSM)
# with some added intelligence the intelligence is around what to download
# and picking up things available but not strictly listed, as well as
# bypassing packages not created yet
#
# Requires:
# wget 
#
function findos() {
	if [ -e /etc/os-release ]
	then
		. /etc/os-release
		theos=`echo $ID | tr [:upper:] [:lower:]`
	elif [ -e /etc/centos-release ]
	then
		theos=`cut -d' ' -f1 < /etc/centos-release | tr [:upper:] [:lower:]`
	elif [ -e /etc/redhat-release ]
	then
		theos=`cut -d' ' -f1 < /etc/redhat-release | tr [:upper:] [:lower:]`
	elif [ -e /etc/fedora-release ]
	then
		theos=`cut -d' ' -f1 < /etc/fedora-release | tr [:upper:] [:lower:]`
	elif [ -e /etc/debian-release ]
	then
		theos=`cut -d' ' -f1 < /etc/debian-release | tr [:upper:] [:lower:]`
	else
		colorecho "Do not know this operating system. LinuxVSM may not work." 1
		theos="unknown"
	fi
}

doit=1
if [ Z"$1" != Z"" ]
then
	grep ${1}: /etc/passwd >& /dev/null
	if [ $? -ne 0 ]
	then
		doit=0
	fi
else
	doit=0
fi
if [ $doit -eq 0 ]
then
	echo "Error: Requires a valid non-root username as an argument"
	echo "Usage: $0 username"
	exit
fi

theos=''
findos
which wget >& /dev/null
if [ $? -eq 1 ]
then
	if [ Z"$theos" = Z"centos" ] || [ Z"$theos" = Z"redhat" ] || [ Z"$theos" = Z"fedora" ]
	then
        	sudo yum -y install wget
	elif [ Z"$theos" = Z"debian" ] || [ Z"$theos" = Z"ubuntu" ]
	then
        	sudo apt-get install -y wget
	fi
fi

mkdir aac-base
cd aac-base
wget -O aac-base.install https://raw.githubusercontent.com/Texiwill/aac-lib/master/base/aac-base.install
chmod +x aac-base.install
./aac-base.install -u $1
sudo ./aac-base.install -i vsm $1

cat > update.sh << EOF
cd $HOME/aac-base
./aac-base.install -u $1
./aac-base.install -i vsm $1
EOF
chmod +x update.sh

PURPLE=`tput setaf 5`
NC=`tput sgr0`
echo "${PURPLE}VSM is now in /usr/local/bin/vsm.sh${NC}"
