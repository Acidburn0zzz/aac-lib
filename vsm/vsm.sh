#!/bin/sh
#
# Copyright (c) 2017 AstroArch Consulting, Inc. All rights reserved
#
# A Linux version of VMware Software Manager (VSM) with some added intelligence
# the intelligence is around what to download and picking up things
# available but not strictly listed, as well as bypassing packages not
# created yet
#
# Requires:
# wget python python-urllib3 libxml2 perl-XML-Twig ncurses


# TODO
# - Highlight CustomIso, OpenSource, DriversTools is something missing
#	This will be time consuming!

VERSIONID="1.6.6"

# args: stmt error
function colorecho() {
	COLOR=$PURPLE
	if [ Z"$2" = Z"1" ]
	then
		COLOR=$RED
	fi
	if [ $docolor -eq 1 ]
	then
		echo "${COLOR}${1}${NC}"
	else
		echo ${1}
	fi
}
function debugecho() {
	if [ $dodebug -eq 1 ]
	then
		echo ${1}
	fi
}

function vsmpkgs() {
	file=$1
	pkgs=""
	if [ $dlg -gt 0 ]
	then
		if [ $dolatest -eq 1 ]
		then
			npkg=""
			pkgs=`xml_grep --text_only '//*/a' $file  2>/dev/null| sed 's/\(dlg_[a-Z_]\+[0-9][0-9]\).*$/\1/' | sort -u`
			for x in $pkgs
			do
				l=${#x}
				$((l++)) 2> /dev/null
				e=$((l+1))
				# ignore VCENTER is a special case
				a=`ls ${x}* | grep -v 'OSS' | sed 's/\.xhtml//' | sed 's/U/0U/' | sort -rn -k1.${l},1.${e} | sort -n | sed 's/0U/U/' | egrep -v 'VCENTER|PLUGIN|SDK|OSL' | tail -1 | sed 's/dlg_//'`
				if [ Z"$npkg" = Z"" ]
				then
					npkg=$a
				else
					npkg="${npkg} ${a}"
				fi
			done
			pkgs=$npkg
		fi
	fi
	if [ Z"$pkgs" = Z"" ]
	then
		pkgs=`xml_grep --text_only '//*/a' $file  2>/dev/null| sed 's/dlg_//' | sed 's/\.xhtml//' | sed 's/,//g' `
	fi
	debugecho "DEBUG: $pkgs"
}

function save_vsmrc() {
	colorecho "Saving to $HOME/.vsmrc"
	echo "favorite='$favorite'" > $HOME/.vsmrc
	if [ $dosave -eq 1 ]
	then
		echo "repo='$repo'" >> $HOME/.vsmrc
		echo "cdir='$cdir'" >> $HOME/.vsmrc
		echo "myoem=$myoem" >> $HOME/.vsmrc
		echo "mydts=$mydts" >> $HOME/.vsmrc
		echo "myoss=$myoss" >> $HOME/.vsmrc
	fi
}

function menu() {
	all=""
	alln=""
	allm=""
	file=$1
	if [ Z"$1" = Z"All" ]
	then
		all=$1
		file=$2
		mark="Mark"
		if [ Z"$3" = Z"All_Plus_OpenSource" ]
		then
			allm=$2
			alln=$3
			file=$4
		fi
	fi
	back="Back"
	if [ Z"$choice" = Z"root" ]
	then
		back=""
	fi
	vsmpkgs $file
	select choice in $all $allm $alln $pkgs $mark $back Exit
	do
		if [ $choice = "Exit" ]
		then
			exit
		fi
		if [ $choice = "Mark" ]
		then
			favorite=$prevchoice
			colorecho "Favorite: $favorite"
			save_vsmrc
		else
			break
		fi
	done
	if [ $choice != "Back" ]
	then
		mchoice="$mchoice/$choice"
		debugecho "DEBUG: $mchoice"
	fi
}

function menu2() {
	all=""
	if [ Z"$2" = Z"OpenSource" ]
	then
		all="All_Plus_OpenSource"
	fi
	pkgs=`xml_grep --text_only '//*/a' $1 2>/dev/null`
	npkg=""
	f=`echo $1 |sed 's/\.xhtml//'`
	for x in $pkgs
	do
		if [ ! -e ${repo}/${f}/${x} ] && [ ! -e ${repo}/${f}/${x}.gz ]
		then
			if [ Z"$npkg" = Z"" ]
			then
				npkg="${BOLD}${x}${NB}"	
			else
				npkg="$npkg ${BOLD}${x}${NB}"
			fi
		else
			if [ Z"$npkg" = Z"" ]
			then
				npkg="$x"
			else
				npkg="$npkg $x"
			fi
		fi
	done
	select choice in All Minimum_Required $all $npkg $2 $3 $4 Back Exit
	do
		if [ $choice = "Exit" ]
		then
			exit
		fi
		break
	done
	if [ $choice != "Back" ]
	then
		mchoice="$mchoice/$choice"
		debugecho "DEBUG: $mchoice"
	fi
}

function getvsm() {
	lchoice=$1
	additional=$2
	name=`echo $data|xml_grep --html --text_only '//*/a' 2>/dev/null`

	# this gets the repo items
	# check if file or file.gz
	# does not exist
	cd $repo
	if [ ! -e dlg_$lchoice ]
	then
		mkdir dlg_$lchoice
	fi
	cd dlg_$lchoice 
	if [ Z"$additional" != Z"base" ] 
	then
		if [ ! -e $additional ]
		then
			mkdir $additional
		fi
		cd $additional
	fi
	debugecho "DEBUG: $currchoice: `pwd`"
	dovsmit=1
	# open source when not selected!
	if [ $additional != "OpenSource" ]
	then
		echo $name | egrep 'ODP|open_source' >/dev/null
		if [ $? -eq 0 ]
		then
			debugecho "DEBUG: Not in OSS Mode: $name"
			dovsmit=0
		fi
	fi
	if [ $dovsmit -eq 1 ]
	then
		if  ([ ! -e ${name} ] && [ ! -e ${name}.gz ]) || [ $doforce -eq 1 ]
		then 
			debugecho "DEBUG: $currchoice $name"
			#echo "Download $name to `pwd`?"
			#read c
			if [ $dryrun -eq 0 ]
			then
				href=`echo $data | xml_grep --pretty_print  --html --cond '//*/[@href]' 2>/dev/null | sed 's/ /\r\n/g' | grep href | awk -F\" '{print $2}'`
				drparams=`echo $data|xml_grep --html --text_only '//*/[@title="drparams"]' 2>/dev/null`
				durl=`echo $data|xml_grep --html --text_only '//*/[@title="download_url"]' 2>/dev/null`
				url="$href?params=$drparams&downloadurl=$durl&familyversion=$vers&productfamily=$prod"
				lurl=`wget --max-redirect 0 --load-cookies $cdir/cookies.txt --header='User-Agent: VMwareSoftwareManagerDownloadService/1.5.0.4237942.4237942 Windows/2012ServerR2' $url 2>&1 | grep Location | awk '{print $2}'`
				if [ Z"$lurl" != Z"" ]
				then
					eurl=`python -c "import urllib, sys; print urllib.unquote(sys.argv[1])" $lurl`
					wget -O $name --progress=bar:force -nd --load-cookies $cdir/cookies.txt --header='User-Agent: VMwareSoftwareManagerDownloadService/1.5.0.4237942.4237942 Windows/2012ServerR2' $eurl 2>&1 | tail -f -n +6
					diddownload=0
					if [ $? -eq 3 ]
					then
						colorecho "File Error: $name (disk full, etc.)" 1
					fi
					if [ $? -eq 0 ]
					then
						diddownload=1
					elif [ $? -ne 3 ]
					then
						colorecho "Error Getting $name" 1
					fi
				else
					debugecho "DEBUG: No Redirect"
				fi
			else
				echo "Download $name to `pwd`"
			fi
		fi
	fi
	cd ${cdir}/depot.vmware.com/PROD/channel
}

function version() {
	echo "$0 version $VERSIONID"
	exit
}

function usage() {
	echo "$0 [--dlg search] [-d|--dryrun] [-f|--force] [--favorite] [-e|--exit] [-h|--help] [-l|--latest] [-ns|--nostore] [-nc|--nocolor] [--dts|--nodts] [--oem|--nooem] [--oss|--nooss] [-p|--password password] [-r|--reset] [-u|--username username] [-v|--vsmdir VSMDirectory] [-V|--version] [-y] [--debug] [--repo repopath] [--save]"
	echo "	--dlg - download specific package by name or part of name"
	echo "	-d|--dryrun - dryrun, do not download"
	echo "	-f|--force - force download of packages"
	echo "	--favorite - download suite marked as favorite"
	echo "	-e|--exit - reset and exit"
	echo "	-h|--help - this help"
	echo "	-l|--latest - substitute latest for each package instead of listed"
	echo "		Only really useful for latest distribution at moment"
	echo "	-ns|--nostore - do not store credential data and remove if exists"
	echo "	-nc|--nocolor - do not output with color"
	echo "	-p|--password - specify password"
	echo "	-r|--reset - reset repos"
	echo "	-u|--username - specify username"
	echo "	-v|--vsmdir path - set VSM directory"
	echo "	-V|--version - version number"
	echo "	-y - do not ask to continue"
	echo "	--dts - include DriversTools in All-style downloads"
	echo "	--nodts - do not include DriversTools in All-style downloads"
	echo "	--oss - include OpenSource in All-style downloads"
	echo "	--nooss - do not include OpenSource in All-style downloads"
	echo "	--oem - include CustomIso in All-style downloads"
	echo "	--nooem - do not include CustomIso in All-style downloads"
	echo "	--debug - debug mode"
	echo "	--repo path - specify path of repo"
	echo "	--save - save settings to \$HOME/.vsmrc, favorite always saved on Mark"
	echo ""
	echo "	All-style downloads include: All, All_No_OpenSource, Minimum_Required"
	echo "	Requires packages:"
	echo "	wget python python-urllib3 libxml2 perl-XML-Twig ncurses"
	echo ""
	echo "To Download the latest Perl CLI use (to escape the wild cards):"
	echo "./vsm.sh --dlg CLI\.\*\\.x86_64.tar.gz"
	echo ""
	echo "Use of the Mark option, marks the current product suite as the" 
	echo "favorite. There is only 1 favorite slot available. Favorites"
	echo "can be downloaded without traversing the menus."

	exit;
}

function checkdep() {
	dep=$1
	rpm -q $dep > /dev/null
	if [ $? -eq 1 ]
	then
		echo "Missing Dependency $dep"
		needdep=1
	fi
}


# check dependencies
docolor=1
needdep=0
checkdep wget
checkdep python
checkdep python-urllib3
checkdep libxml2
checkdep perl-XML-Twig
checkdep ncurses

if [ $needdep -eq 1 ]
then
	colorecho "Install dependencies first!" 1
	exit
fi

#
# Default settings
dodebug=0
diddownload=0
doforce=0
dolatest=0
doreset=0
nostore=0
doexit=0
dryrun=0
dosave=0
mydts=-1
myoss=-1
myoem=-1
myyes=0
myfav=0
repo="/tmp/vsm"
cdir="/tmp/vsm"
mydlg=""
RED=`tput setaf 1`
PURPLE=`tput setaf 125`
NC=`tput sgr0`
BOLD=`tput smso`
NB=`tput rmso`

# import values from .vsmrc
if [ -e $HOME/.vsmrc ]
then
	. $HOME/.vsmrc
	# if we already use .vsmrc then continue to do so
	if [ Z"$repo" != Z"" ]
	then
		dosave=1
	fi
fi

while [[ $# -gt 0 ]]
do
	key="$1"
	case "$key" in
		-h|--help)
			usage
			;;
		-l|--latest)
			dolatest=1
			;;
		-r|--reset)
			doreset=1
			;;
		-f|--force)
			doforce=1
			;;
		-e|--exit)
			doreset=1
			doexit=1
			;;
		-y)
			myyes=1
			;;
		-u|--username)
			username=$2
			shift
			;;
		-p|--password)
			password=$2
			shift
			;;
		-ns|--nostore)
			nostore=1
			;;
		-d|--dryrun)
			dryrun=1
			;;
		-nc|--nocolor)
			docolor=0
			;;
		--repo)
			repo=$2
			shift
			;;
		--dlg)
			mydlg=$2
			shift
			;;
		-v|--vsmdir)
			cdir=$2
			shift
			;;
		--save)
			dosave=1
			;;
		--debug)
			dodebug=1
			;;
		--dts)
			mydts=1
			;;
		--oem)
			myoem=1
			;;
		--oss)
			myoss=1
			;;
		--nodts)
			mydts=0
			;;
		--nooem)
			myoem=0
			;;
		--nooss)
			myoss=0
			;;
		--favorite)
			if [ Z"$favorite" != Z"" ]
			then
				myfav=1
			fi
			;;
		-V|--version)
			version
			;;
		*)
			usage
			;;
	esac
	shift
done

# remote trailing slash
repo=$(echo $repo | sed 's:/*$::')

colorecho "Using the following options:"
echo "	Version:	$VERSIONID"
if [ Z"$username" != Z"" ]
then
	echo "	Username:		$username"
	echo "	Save Credentials:	$nostore"
fi
echo "	VSM XML Dir:	$cdir"
echo "	Repo Dir:	$repo"
echo "	Dryrun:		$dryrun"
echo "	Force Download:	$doforce"
echo "	Reset XML Dir:	$doreset"
echo "	Get Latest:	$dolatest"

if [ ! -e $cdir ]
then
	mkdir -p $cdir
fi
cd $cdir

# if we say to no store then remove!
if [ $nostore -eq 1 ]
then
	rm .credstore
fi

if [ ! -e .credstore ]
then
	if [ Z"$username" = Z"" ]
	then
		echo -n "Enter Username: "
		read username
	fi
	if [ Z"$password" = Z"" ]
	then
		echo -n "Enter Password: "
		read -s password
	fi

	auth=`echo -n "${username}:${password}" |base64`
	if [ $nostore -eq 0 ]
	then
		# handle storing 'Basic Auth' for reuse
		echo -n $auth > .credstore
	fi
	echo "	Use credstore:	0"
else
	echo "	Use credstore:	1"
	auth=`cat .credstore`
fi

# save a copy of the .vsmrc and continue
save_vsmrc

# Get Data for VSM
if [ $myyes -eq 0 ]
then
	echo ""
	echo "Continue with VSM (Y/n)?"
	read c
	if [ Z"$c" = Z"n" ] || [ Z"$c" = Z"N" ]
	then
		exit
	fi
fi

# Cleanup old data if any
rm cookies.txt index.html.* 2>/dev/null

if [ ! -e depot.vmware.com/PROD/channel/root.xhtml ]
then
	doreset=1
fi

debugecho "DEBUG: Auth request"
# Auth as VSM
wget --progress=bar:force --save-headers --cookies=on --save-cookies cookies.txt --keep-session-cookies --header='Cookie: JSESSIONID=' --header="Authorization: Basic $auth" --header='User-Agent: VMwareSoftwareManagerDownloadService/1.5.0.4237942.4237942 Windows/2012ServerR2' https://depot.vmware.com/PROD/ 2>&1 | tail -f -n +6

# Extract JSESSIONID
JS=`grep JSESSIONID index.html | awk -F\; '{print $1}' |awk -F= '{print $2}'`
TS=`grep vmware cookies.txt |awk '{print $5}'`
#echo $JS
echo ".vmware.com	TRUE	/	TRUE	$TS	JSESSIONID	$JS" >> cookies.txt

if [ $doreset -eq 1 ]
then
	debugecho "DEBUG: Reset Request"
	# Get index and subsequent data
	wget -rxl 1 --load-cookies cookies.txt --header='User-Agent: VMwareSoftwareManagerDownloadService/1.5.0.4237942.4237942 Windows/2012ServerR2' https://depot.vmware.com/PROD/index.xhtml
	if [ $doexit -eq 1 ]
	then
		exit
	fi
fi

# Present the list
cd depot.vmware.com/PROD/channel

# start of history
mlist=0
mchoice="root"
choice="root"
prevchoice=""
achoice=""
dlg=0
pkgs=""

if [ Z"$mydlg" != Z"" ]
then
	debugecho "DEBUG: $mydlg"
	# Find the file
	file=`egrep -il "$mydlg" *.xhtml | sort -V | tail -1 | sed 's/.xhtml//'`
	if [ Z"$file" = Z"" ]
	then
		colorecho "No file found!" 1
		exit
	fi
	debugecho "DEBUG: $file"

	# Find the product
	dlge=`grep -l $file *.xhtml | grep -v $file | sort -V | tail -1 | sed 's/.xhtml//'`
	d=`echo $dlge | sed 's/dlg//'`
	debugecho "DEBUG: $dlge $d"
	
	if [ Z"$dlge" != Z"$d" ]
	then
		prevchoice=`grep -l $d *.xhtml | grep -v $d | sort -V | tail -1 | sed 's/.xhtml//'`
		debugecho "DEBUG: $prevchoice"
	else 
		prevchoice=`echo $dlge|sed 's/dlg_//'`
	fi
	currchoice=`echo $file|sed 's/dlg_//'`
	debugecho "DEBUG: $mydlg found in $prevchoice -> $currchoice"
	# now we prepare to get the file
	prod=`xml_grep --html --text_only '*[@title="prod"]' ${prevchoice}.xhtml 2>/dev/null`
	eprod=`python -c "import urllib, sys; print urllib.quote(sys.argv[1])" $prod 2>/dev/null`
	prod=$eprod
	vers=`xml_grep --html --text_only '*[@title="version"]' ${prevchoice}.xhtml 2>/dev/null`
	cnt=`xml_grep --html --pretty_print --cond '//*/[@class="depot-content"]' dlg_${currchoice}.xhtml 2>/dev/null  |grep display-order | wc -l`
	x=1
	while [ $x -le $cnt ]
	do
		data=`xmllint --html --xpath "//*/li[@class=\"depot-content\"][$x]" dlg_${currchoice}.xhtml 2>/dev/null`
		name=`echo $data|xml_grep --html --text_only '//*/a' 2>/dev/null`
		d=`echo $name | sed "s/$mydlg//i"`
		debugecho "DEBUG: $name $d"
		if [ Z"$d" != Z"$name" ]
		then
			# get the file
			debugecho "DEBUG: get $name"
			echo "Local:$repo/dlg_$currchoice/$name"
			getvsm $currchoice "base"
		fi
		let x=$x+1
	done
	exit
fi

while [ $dlg -ne 2 ]
do
	all=""
	alln=""
	allm=""
	if [ $dlg -eq 1 ]
	then
		all="All"
		alln="All_Plus_OpenSource"
		allm="Minimum_Required"
		dlg=2
		if [ Z"$prevchoice" = Z"" ]
                then
                        prevchoice=$choice
                fi
	fi
	if [ $myfav -eq 0 ]
	then
		menu $all $allm $alln ${choice}.xhtml
	else
		# setup auto-download of favorite
		prevchoice=$favorite
		choice="All"
		dlg=2
	fi


	if [ $choice != "Back" ]
	then
		if [ $dlg -eq 0 ]
		then
			grep dlg_ ${choice}.xhtml > /dev/null
			if [ $? -eq 0 ]
			then
				dlg=1
			fi
		fi
	
		if [ $dlg -eq 2 ]
		then
			doall=0
			prod=`xml_grep --html --text_only '*[@title="prod"]' ${prevchoice}.xhtml 2>/dev/null`
			eprod=`python -c "import urllib, sys; print urllib.quote(sys.argv[1])" $prod`
			prod=$eprod
			vers=`xml_grep --html --text_only '*[@title="version"]' ${prevchoice}.xhtml 2>/dev/null`

			# if ALL then cycle through dlg in prevchoice
			#   set 'choices' array, then cycle through all $choices
			#   ensure 'selected' is in $choices so does this once
			if [ $choice = "All" ] || [ $choice = "All_Plus_OpenSource" ] || [ $choice = "Minimum_Required" ]
			then
				vsmpkgs ${prevchoice}.xhtml
				choices=$pkgs
				doall=1
				if [ $choice = "Minimum_Required" ]
				then
					doall=3
				fi
				if [ $choice = "All_Plus_OpenSource" ]
				then
					doall=2
				fi
			else
				choices=$choice
			fi
			
			for choice in $choices
			do
				oem=""
				dt=""
				oss=""
				oemlist=""
				osslist=""
				dtslist=""
				debugecho "DEBUG: Working on $choice"
				asso=`xml_grep --html --text_only '*[@title="associated-channels"]' dlg_${choice}.xhtml  2>/dev/null| sed 's/,//g'`

				# sometimes things exist that are not in asso lists
				# sometimes they use similar version numbers
				rchoice=`echo $choice | sed 's/U/*U/'` 
				for x in `ls dlg*${rchoice}_*.xhtml 2>/dev/null | grep -v dlg_${choice}.xhtml | grep -v VCENTER`
				do
					y=`echo $x | sed 's/\.xhtml//'`
					if [ Z"$asso" = Z"" ]
					then
						asso=$y
					else
						asso="$asso $y"
					fi
				done
	
				# Now go through asso list and split into parts
				for x in $asso
				do
					debugecho "$choice: $x"
					# sometimes files do not exist!
					if [ -e ${x}.xhtml ]
					then
						echo $x | grep OEM > /dev/null
						if [ $? -eq 0 ]
						then
							if [ Z"$oemlist" = Z"" ]
							then
								oemlist=$x
							else
								oemlist="$oemlist $x"
							fi
							oem="CustomIso"
						else
							echo $x | grep OSS > /dev/null
							if [ $? -eq 0 ]
							then
								if [ Z"$osslist" = Z"" ]
								then
									osslist=$x
								else
									osslist="$osslist $x"
								fi
								oss="OpenSource"
							else
								if [ Z"$dtslist" = Z"" ]
								then
									dtslist=$x
								else
									dtslist="$dtslist $x"
								fi
								dts="DriversTools"
							fi
						fi
					fi
				done
	
				#echo $prod
				#echo $vers
				#echo $choice
				dooem=0
				dooss=0
				dodts=0
				dodat=0
				myall=0
				mychoice=""
				currchoice=$choice;
	
				# do not show if ALL, choice set above!
				if [ $doall -eq 0 ]
				then
					menu2 dlg_${choice}.xhtml $oss $oem $dts
				fi
	
				case $choice in
					"All")
						dooem=1
						dodts=1
						dodat=1
						myall=1
						;;
					"Minimum_Required")
						dodat=1
						myall=1
						;;
					"All_Plus_OpenSource")
						dooss=1
						dooem=1
						dodts=1
						dodat=1
						myall=1
						;;
					"CustomIso")
						dooem=1
						;;
					"OpenSource")
						dooss=1
						;;
					"DriversTools")
						dodts=1
						;;
					"Back")
						;;
					*)
						mychoice=$choice
						dodat=1
						;;
				esac
				if [ $doall -eq 1 ]
				then
					dooss=0
					dooem=1
					dodts=1
					dodat=1
				fi
				if [ $doall -eq 2 ]
				then
					dooss=1
					dooem=1
					dodts=1
					dodat=1
				fi
				if [ $doall -eq 3 ]
				then
					dooss=0
					dooem=0
					dodts=0
					dodat=1
				fi
				if [ $doall -ne 0 ] || [ $myall -eq 1 ]
				then
					if [ $myoem -ne -1 ]
					then
						dooem=$myoem
					fi
					if [ $myoss -ne -1 ]
					then
						dooss=$myoss
					fi
					if [ $mydts -ne -1 ]
					then
						dodts=$mydts
					fi
				fi
	
				# do the regular including All/All_Plus_OpenSource
				if [ $dodat -eq 1 ]
				then
					cnt=`xml_grep --html --pretty_print --cond '//*/[@class="depot-content"]' dlg_${currchoice}.xhtml 2>/dev/null  |grep display-order | wc -l`
					x=1
					while [ $x -le $cnt ]
					do
						data=`xmllint --html --xpath "//*/li[@class=\"depot-content\"][$x]" dlg_${currchoice}.xhtml 2>/dev/null`
	
						# only do the selected
						doit=0
						if [ $doall -eq 0 ]
						then
							p=`echo $data | xml_grep --text_only '//*/a' 2>/dev/null `
							if [ Z"$p" = Z"$mychoice" ]
							then
								# got it so strip
								mchoice=`dirname $mchoice`
								doit=1
							fi
						else
							doit=1
						fi
						if [ $doit -eq 1 ]
						then
							getvsm $currchoice "base"
						fi
						# out to dev null seems to be required
						$((x++)) 2> /dev/null
					done
					if [ $diddownload -eq 1 ]
					then
						colorecho "Downloads to $repo/dlg_$currchoice"
					else
						colorecho "All $currchoice already downloaded!"
					fi
				fi
	
				# Now handle OpenSource, CustomIso, DriversTools
				# these are via $asso
				for x in oem dts oss
				do
					y="do${x}"
					l="${x}list"
					eval dom=\$$y
					eval om=\$${x}
					eval omlist=\$${l}
					if [ $dom -eq 1 ] && [ Z"$om" != Z"" ]
					then
						debugecho "DEBUG: $y"
						diddownload=0
						for o in `echo $omlist| sed 's/dlg_//g' |sed 's/\.xhtml//g'`
						do
							debugecho "DEBUG $y: $choice: $o"
							cnt=`xml_grep --html --pretty_print --cond '//*/[@class="depot-content"]' dlg_${o}.xhtml  2>/dev/null |grep display-order | wc -l`
							x=1
							while [ $x -le $cnt ]
							do
								data=`xmllint --html --xpath "//*/li[@class=\"depot-content\"][$x]" dlg_${o}.xhtml`
			
								# only do the selected
								getvsm $currchoice $om
								# out to dev null seems to be required
								let x=$x+1
							done
						done
						if [ $diddownload -eq 1 ]
						then
							colorecho "Downloads to $repo/dlg_$currchoice/$om"
						else
							colorecho "All $currchoice $om already downloaded!"
						fi
					fi
				done
				
				dlg=1
				diddownload=0
				#choice=$prevchoice
			done
			echo ""
			if [ $myfav -eq 1 ]
			then
				exit
			fi
			mchoice=`dirname $mchoice`
			debugecho "DEBUG: $mchoice"
			choice=`basename $mchoice`
		fi
	else
		# go back 2 entries as previous is current
		mchoice=`dirname $mchoice`
		debugecho "DEBUG: $mchoice"
		choice=`basename $mchoice`

		dlg=0
		if [ $dlg -eq 2 ] 
		then
			dlg=1
			#choice=$prevchoice
		fi
		prevchoice=""
		asso=""
	fi
done
