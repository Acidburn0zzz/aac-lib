# aac-lib
AAC Library of Tools

- <a href=https://github.com/Texiwill/aac-lib/tree/master/>List of Tools</a>

## vsm
Linux Version of VMware Software Manager

### Description
A Linux and slightly more intelligent version of VSM for Linux. It ignores
missing definition files that cause the VMware version to stop working. It
also finds ones not in the definitions yet. It is also possible to find
the latest of every package.

This version was optimized for RedHat style distributions and will need
a change to work on non-RedHat style distributions. If someone uses
debian and wants this to work there, get me the dpkg commands needed.

<pre>
   $ ./vsm.sh --help
   ./vsm.sh [--dlg search] [-d|--dryrun] [-f|--force] [-e|--exit] [-h|--help] [-l|--latest] [-ns|--nostore] [-nc|--nocolor] [--dts|--nodts] [--oem|--nooem] [--oss|--nooss] [-p|--password password] [-r|--reset] [-u|--username username] [-v|--vsmdir VSMDirectory] [-V|--version] [-y] [--debug] [--repo repopath] [--save]
	--dlg - download specific package by name or part of a name
	-d|--dryrun - dryrun, do not download
	-f|--force - force download of packages
	-e|--exit - reset and exit
	-h|--help - this help
	-l|--latest - substitute latest for each package instead of listed
		Only really useful for latest distribution at moment
	-ns|--nostore - do not store credential data and remove if exists
	-nc|--nocolor - do not output with color
	-p|--password - specify password
	-r|--reset - reset repos
	-u|--username - specify username
	-v|--vsmdir path - set VSM directory
	                   saved to configuration file
	-V|--version - version number
	-y - do not ask to continue
	--dts - include DriversTools in All-style downloads
	        saved to configuration file
	--nodts - do not include DriversTools in All-style downloads
	          saved to configuration file
	--oss - include OpenSource in All-style downloads
	        saved to configuration file
	--nooss - do not include OpenSource in All-style downloads
	          saved to configuration file
	--oem - include CustomIso in All-style downloads
	        saved to configuration file
	--nooem - do not include CustomIso in All-style downloads
	          saved to configuration file
	--debug - debug mode
	--repo path - specify path of repo
	              saved to configuration file
	--save - save defaults to $HOME/.vsmrc

	All-style downloads include: All, All_No_OpenSource, Minimum_Required
	Requires packages:
	wget python python-urllib3 libxml2 perl-XML-Twig ncurses

	To Download the latest Perl CLI use (to escape the wild cards):
	./vsm.sh --dlg CLI\.\*\\.x86_64.tar.gz

   $ ./vsm.sh
   <span style="color:purple">Using the following options:</span>
   	Version:	1.0.0
   	VSM XML Dir:	/tmp/vsm
   	Repo Dir:	/mnt/rainbow/iso/vmware/depot/content
   	Dryrun:		0
   	Force Download:	0
   	Reset XML Dir:	0
   	Get Latest:	0
   	Use credstore:	1
   
   Continue with VSM (Y/n)?
   
   Saving to: ‘index.html.1’
   
   100%[======================================>] 455,010     1.87MB/s   in 0.2s   
   
   2017-09-14 08:03:49 (1.87 MB/s) - ‘index.html.1’ saved [455010/455010]
   
   1) Datacenter_Cloud_Infrastructure
   2) Infrastructure_Operations_Management
   3) Back
   4) Exit
   #? 1
   1) Datacenter_Cloud_Infrastructure_VMware_Software_Manager
   2) Datacenter_Cloud_Infrastructure_VMware_vCloud_Suite
   3) Datacenter_Cloud_Infrastructure_VMware_vSphere
   4) Datacenter_Cloud_Infrastructure_VMware_vSphere_with_Operations_Management
   5) Back
   6) Exit
   #? 3
   1) Datacenter_Cloud_Infrastructure_VMware_vSphere_6_5
   2) Datacenter_Cloud_Infrastructure_VMware_vSphere_6_0
   3) Datacenter_Cloud_Infrastructure_VMware_vSphere_5_5
   4) Datacenter_Cloud_Infrastructure_VMware_vSphere_5_1
   5) Back
   6) Exit
   #? 1
   1) Datacenter_Cloud_Infrastructure_VMware_vSphere_6_5_English_Desktop
   2) Datacenter_Cloud_Infrastructure_VMware_vSphere_6_5_English_Enterprise
   3) Datacenter_Cloud_Infrastructure_VMware_vSphere_6_5_English_Enterprise_Plus
   4) Datacenter_Cloud_Infrastructure_VMware_vSphere_6_5_English_Essentials
   5) Datacenter_Cloud_Infrastructure_VMware_vSphere_6_5_English_Essentials_Plus
   6) Datacenter_Cloud_Infrastructure_VMware_vSphere_6_5_English_Standard
   7) Back
   8) Exit
   #? 3
   1) All			  6) VIC120		  11) VR651
   2) All_Plus_OpenSource	  7) NSXV_633		  12) VROPS_661
   3) ESXI65U1		  8) VROVA_730		  13) Back
   4) VC65U1		  9) VRLI_450_VCENTER	  14) Exit
   5) VDP615		 10) BDE_232
   #? 3
    1) All
    2) All_Plus_OpenSource
    3) VMware-VMvisor-Installer-6.5.0.update01-5969303.x86_64.iso
    4) update-from-esxi6.5-6.5_update01.zip
    5) VMware-ESXi-6.5U1-RollupISO.iso
    6) <span sytle="background: black; color:white">ESXi6.5U1-RollupISO-README.pdf</span>
    7) OpenSource
    8) CustomIso
    9) Back
   10) Exit
   #? 6
   Saving to: ‘ESXi6.5U1-RollupISO-README.pdf’
   
   100%[======================================>] 747,087     2.43MB/s   in 0.3s   
   
   2017-09-14 08:03:59 (2.43 MB/s) - ‘ESXi6.5U1-RollupISO-README.pdf’ saved [747087/747087]
   
   <span style="color:purple">Downloads to /mnt/rainbow/iso/vmware/depot/content/dlg_ESXI65U1</span>
   
   1) All			  6) VIC120		  11) VR651
   2) All_Plus_OpenSource	  7) NSXV_633		  12) VROPS_661
   3) ESXI65U1		  8) VROVA_730		  13) Back
   4) VC65U1		  9) VRLI_450_VCENTER	  14) Exit
   5) VDP615		 10) BDE_232
   #? 14
</pre>

### Installation
Place in any directory. Requires the following packages:
	wget python python-urllib3 libxml2 perl-XML-Twig ncurses

### Support
Email elh at astroarch dot com for assistance or if you want to add
for more items.

If someone can provide debian package maangement bits, send them on as
that is the only distribution specific bits in the script.

### Changelog
1.6.5 - added --nooem|--oem, --nodts|--dts, --nooss|--oss to the .vsmrc
configuration file when options are saved

1.6.1 - moved variable and removed check for perl-XML-XPath as it is no
longer required.

1.6.0 - cleaned up code pulling unique items into one loop not 3
separate loops. Fixed Mark to only appear in one spot.

1.5.0 - added ability to download specific file by name or part of a
name and fixed major bug on associated products list where resultant
list was malformed

1.1.0 - fixed 'Back' to actually send you back just 1 level at all times
by creating a path variable that gets updated for every menu call and
Back used

1.0.1 - fixed 'Back' menu item when actual packages are shown

1.0.0 - added Minimum_Required menu item, do only download the base files
and not OpenSource, DriversTools, or CustomIso. Also added the
--dts|--nodts, --oem|--nooem, --oss|--nooss to set what to download when
any of the 'All' styles are selected.

0.9.5 - fixed latest parsing. It was too broad and did not confine to
the latest of a specific major version. I.e. 60 vs 65

0.9.4 - fixed issue where too much was include in the 'smarts'. Main
Product Downloads were being placed into CustomIso and DriverTools.

0.9.3 - Initial public launch
