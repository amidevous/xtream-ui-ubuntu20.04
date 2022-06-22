#!/usr/bin/env bash
# Official Xtream UI Automated Installation Script
# =============================================
# Beta Version dot not use in production
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Supported Operating Systems: 
# Ubuntu server 18.04/20.04/22.04
# soon
# CentOS 7.*
# Fedora 34/35
# Debian 10/11
# 64bit online system
#
while getopts ":t:a:p:o:c:r:e:m:s:h:" option; do
    case "${option}" in
        t)
            tz=${OPTARG}
            ;;
        a)
            adminn=${OPTARG}
            ;;
        p)
            adminpass=${OPTARG}
            ;;
        o)
            ACCESPORT=${OPTARG}
            ;;
        c)
            CLIENTACCESPORT=${OPTARG}
            ;;
        r)
            APACHEACCESPORT=${OPTARG}
            ;;
        e)
            EMAIL=${OPTARG}
            ;;
        m)
            PASSMYSQL=${OPTARG}
            ;;
        s)
            silent=yes
            ;;
        h)
            echo "help usage"
			echo "curl -L https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/install.sh | sudo bash -s -- -a adminusername -t timezone -p adminpassord -o adminaccesport -c clientaccesport -r apacheport -e email -m mysqlpassword -s yes"
			echo "./install.sh -a adminusernamesername -t timezone -p adminpassord -o adminaccesport -c clientaccesport -r apacheport -e email -m mysqlpassword -s yes"
			echo "option -t for set Time Zone"
			echo "option -a Enter Your Desired Admin Login Access"
			echo "option -p Enter Your Desired Admin Password Access"
			echo "option -o Enter Your Desired Admin Port Access"
			echo "option -c Enter Your Desired Client Port Access"
			echo "option -r Enter Your Desired Apache Port Access"
			echo "option -e Enter Your Email Addres"
			echo "option -m Enter Your Desired MYSQL Password"
			echo "option -s for silent use yes option for remove confirm install"
			echo "option -h for write this help"
			echo "full exeple"
			echo "curl -L https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/install.sh | sudo bash -s -- -a admin -t Europe/Paris -p admin -o 25500 -c 80 -r 8080 -e amidevous@example.com -m mysqlpassword -s yes"
			echo "./install.sh -a admin -t Europe/Paris -p admin -o 25500 -c 80 -r 8080 -e amidevous@example.com -m mysqlpassword -s yes"
			exit
            ;;
        *)
            		tz=
			adminn=
			adminpass=
			ACCESPORT=
			CLIENTACCESPORT=
			APACHEACCESPORT=
			EMAIL
			PASSMYSQL=
			silent=no
            ;;
    esac
done
clear
XC_VERSION="22 CK 41"
PANEL_PATH="/home/xtreamcodes/iptv_xtream_codes"
#--- Display the 'welcome' splash/user warning info..
echo ""
echo "#############################################################"
echo "#  Welcome to the Official Xtream UI Installer $XC_VERSION  #"
echo "#############################################################"
echo -e "\nChecking that minimal requirements are ok"
# Ensure the OS is compatible with the launcher
if [ -f /etc/centos-release ]; then
    inst() {
       rpm -q "$1" &> /dev/null
    } 
    if (inst "centos-stream-repos"); then
    OS="Centos Stream"
    else
    OS="CentOs"
    fi    
    VERFULL=$(sed 's/^.*release //;s/ (Fin.*$//' /etc/centos-release)
    VER=${VERFULL:0:1} # return 6, 7 or 8
elif [ -f /etc/fedora-release ]; then
    inst() {
       rpm -q "$1" &> /dev/null
    } 
    OS="Fedora"
    VERFULL=$(sed 's/^.*release //;s/ (Fin.*$//' /etc/fedora-release)
    VER=${VERFULL:0:2} # return 34 35 or 36
elif [ -f /etc/lsb-release ]; then
    OS=$(grep DISTRIB_ID /etc/lsb-release | sed 's/^.*=//')
    VER=$(grep DISTRIB_RELEASE /etc/lsb-release | sed 's/^.*=//')
elif [ -f /etc/os-release ]; then
    OS=$(grep -w ID /etc/os-release | sed 's/^.*=//')
    VER=$(grep VERSION_ID /etc/os-release | sed 's/^.*"\(.*\)"/\1/' | head -n 1 | tail -n 1)
 else
    OS=$(uname -s)
    VER=$(uname -r)
fi
ARCH=$(uname -m)
if [[ "$VER" = "8" && "$OS" = "CentOs" ]]; then
	echo "Centos 8 obsolete udate to Centos Stream 8"
	echo "this operation may take some time"
	sleep 60
	# change repository to use vault.centos.org CentOS 8 found online to vault.centos.org
	find /etc/yum.repos.d -name '*.repo' -exec sed -i 's|mirrorlist=http://mirrorlist.centos.org|#mirrorlist=http://mirrorlist.centos.org|' {} \;
	find /etc/yum.repos.d -name '*.repo' -exec sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|' {} \;
	#update package list
	dnf update -y
	#upgrade all packages to latest CentOS 8
	dnf upgrade -y
	#install Centos Stream 8 repository
	dnf -y install centos-release-stream --allowerasing
	#install rpmconf
	dnf -y install rpmconf
	#set config file with rpmconf
	rpmconf -a
	# remove Centos 8 repository and set CentOS Stream 8 repository by default
	dnf -y swap centos-linux-repos centos-stream-repos
	# system upgrade
	dnf -y distro-sync
	# ceanup old rpmconf file create
	find / -name '*.rpmnew' -exec rm -f {} \;
	find / -name '*.rpmsave' -exec rm -f {} \;
	OS="Centos Stream"
	fi
echo "Detected : $OS  $VER  $ARCH"
#if [[ "$OS" = "CentOs" && ("$VER" = "6" || "$VER" = "7" || "$VER" = "8" ) ||
#      "$OS" = "Fedora" && ("$VER" = "34" || "$VER" = "35" ) ||
#      "$OS" = "Ubuntu" && ("$VER" = "12.04" || "$VER" = "14.04" || "$VER" = "16.04" || "$VER" = "18.04" ) || 
#      "$OS" = "debian" && ("$VER" = "7" || "$VER" = "8" || "$VER" = "9" || "$VER" = "10" ) ]] ; then
if [[ "$OS" = "Ubuntu" && ("$VER" = "18.04" || "$VER" = "20.04" || "$VER" = "22.04" ) && "$ARCH" == "x86_64" ||
"$OS" = "debian" && ("$VER" = "10" || "$VER" = "11" ) && "$ARCH" == "x86_64" ||
"$OS" = "CentOs" && ("$VER" = "6" || "$VER" = "7" || "$VER" = "8" ) && "$ARCH" == "x86_64" ||
"$OS" = "Centos Stream" && "$VER" = "8" && "$ARCH" == "x86_64" ]] ; then
    echo "Ok."
else
    echo "Sorry, this OS is not supported by Xtream UI."
    exit 1
fi
# Check if the user is 'root' before allowing installation to commence
if [ $UID -ne 0 ]; then
    echo "Install failed: you must be logged in as 'root' to install."
    echo "Use command 'sudo -i', then enter root password and then try again."
    exit 1
fi
if [ -e /usr/local/cpanel ] || [ -e /usr/local/directadmin ] || [ -e /usr/local/solusvm/www ] || [ -e /usr/local/home/admispconfig ] || [ -e /usr/local/lxlabs/kloxo ] ; then
    echo "It appears that a control panel is already installed on your server; This installer"
    echo "is designed to install and configure Sentora on a clean OS installation only."
    echo -e "\nPlease re-install your OS before attempting to install using this script."
    exit 1
fi
if [[ "$OS" = "CentOs" ]] ; then
    PACKAGE_INSTALLER="yum -y -q install"
    PACKAGE_REMOVER="yum -y -q remove"
    PACKAGE_UPDATER="yum -y -q update"
    PACKAGE_UTILS="yum-utils"
    PACKAGE_GROUPINSTALL="yum -y -q groupinstall"
    PACKAGE_SOURCEDOWNLOAD="yumdownloader --source"
    BUILDDEP="yum-builddep -y"
    MYSQLCNF=/etc/my.cnf
    MARIADBSERVICE=mariadbd
elif [[ "$OS" = "Fedora" || "$OS" = "Centos Stream"  ]]; then
    PACKAGE_INSTALLER="dnf -y -q install"
    PACKAGE_REMOVER="dnf -y -q remove"
    PACKAGE_UPDATER="dnf -y -q update"
    PACKAGE_UTILS="dnf-utils" 
    PACKAGE_GROUPINSTALL="dnf -y -q groupinstall"
    PACKAGE_SOURCEDOWNLOAD="dnf download --source"
    BUILDDEP="dnf build-dep -y"
    MYSQLCNF=/etc/my.cnf
    MARIADBSERVICE=mariadbd
elif [[ "$OS" = "Ubuntu" || "$OS" = "debian" ]]; then
    PACKAGE_INSTALLER="apt-get -yqq install"
    PACKAGE_REMOVER="apt-get -yqq purge"
    MYSQLCNF=/etc/mysql/my.cnf
    MARIADBSERVICE=mariadb
    inst() {
       dpkg -l "$1" 2> /dev/null | grep '^ii' &> /dev/null
    }
fi
#--- Prepare or query informations required to install
# Update repositories and Install wget and util used to grab server IP
echo -e "\n-- Installing wget and dns utils required to manage inputs"
if [[ "$OS" = "CentOs" || "$OS" = "Fedora" || "$OS" = "Centos Stream" ]]; then
	$PACKAGE_INSTALLER $PACKAGE_UTILS
   	$PACKAGE_UPDATER
        $PACKAGE_INSTALLER bind-utils
elif [[ "$OS" = "Ubuntu" || "$OS" = "debian" ]]; then
	DEBIAN_FRONTEND=noninteractive
	export DEBIAN_FRONTEND=noninteractive
	if [ -f "/etc/apt/apt.conf.d/99needrestart" ]; then
	sed -i 's|DPkg::Post-Invoke|#DPkg::Post-Invoke|' "/etc/apt/apt.conf.d/99needrestart"
	fi
    	apt-get -qq update   #ensure we can install
    	$PACKAGE_INSTALLER dnsutils net-tools
fi
$PACKAGE_INSTALLER curl wget
ipaddr="$(wget -qO- http://api.sentora.org/ip.txt)"
local_ip=$(ip addr show | awk '$1 == "inet" && $3 == "brd" { sub (/\/.*/,""); print $2 }')
networkcard=$(route | grep default | awk '{print $8}')
blofish=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 50 | head -n 1)
alg=6
salt='rounds=20000$xtreamcodes'
XPASS=$(</dev/urandom tr -dc A-Z-a-z-0-9 | head -c16)
zzz=$(</dev/urandom tr -dc A-Z-a-z-0-9 | head -c20)
eee=$(</dev/urandom tr -dc A-Z-a-z-0-9 | head -c10)
rrr=$(</dev/urandom tr -dc A-Z-a-z-0-9 | head -c20)
versionn=$(lsb_release -d -s)
nginx111='$uri'
nginx222='$document_root$fastcgi_script_name'
nginx333='$fastcgi_script_name'
nginx444='$host:$server_port$request_uri'
spinner()
{
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}
if [[ "$tz" == "" ]] ; then
    # Propose selection list for the time zone
    echo "Preparing to select timezone, please wait a few seconds..."
    sleep 30
    $PACKAGE_INSTALLER tzdata
    # setup server timezone
    if [[ "$OS" = "CentOs" || "$OS" = "Fedora" || "$OS" = "Centos Stream" ]]; then
        # make tzselect to save TZ in /etc/timezone
        echo "echo \$TZ > /etc/timezone" >> /usr/bin/tzselect
        tzselect
        tz=$(cat /etc/timezone)
	rm -f /etc/localtime
	ln -s /usr/share/zoneinfo/$tz /etc/localtime
	timedatectl set-timezone $tz
    elif [[ "$OS" = "Ubuntu" || "$OS" = "debian" ]]; then
        DEBIAN_FRONTEND=dialog dpkg-reconfigure tzdata
		DEBIAN_FRONTEND=noninteractive
		export DEBIAN_FRONTEND=noninteractive
        tz=$(cat /etc/timezone)
	rm -f /etc/localtime
	ln -s /usr/share/zoneinfo/$tz /etc/localtime
	timedatectl set-timezone $tz
    fi
else
	echo "time zone set $tz"
	echo $tz > /etc/timezone
	rm -f /etc/localtime
	ln -s /usr/share/zoneinfo/$tz /etc/localtime
	timedatectl set-timezone $tz
fi
if [[ "$adminn" == "" ]] ; then
read -p "...... Enter Your Desired Admin Login Access: " adminn
else
	echo "Desired Admin Login Access set $adminn"
fi
echo " "
if [[ "$adminpass" == "" ]] ; then
read -p "...... Enter Your Desired Admin Password Access: " adminpass
else
	echo "Desired Admin Password Access set $adminpass"
fi
echo " "
if [[ "$ACCESPORT" == "" ]] ; then
read -p "...... Enter Your Desired Admin Port Access: " ACCESPORT
else
	echo "Desired Admin Port Access set $ACCESPORT"
fi
echo " "
if [[ "$CLIENTACCESPORT" == "" ]] ; then
read -p "...... Enter Your Desired Client Port Access: " CLIENTACCESPORT
else
	echo "Desired Client Port Access set $CLIENTACCESPORT"
fi
echo " "
if [[ "$APACHEACCESPORT" == "" ]] ; then
read -p "...... Enter Your Desired Apache Port Access: " APACHEACCESPORT
echo " "
else
	echo "Desired Apache Port Acces set $APACHEACCESPORT"
fi
if [[ "$EMAIL" == "" ]] ; then
read -p "...... Enter Your Email Addres: " EMAIL
else
	echo "Your Email Addres set $EMAIL"
fi
echo " "
if [[ "$PASSMYSQL" == "" ]] ; then
read -p "...... Enter Your Desired MYSQL Password: " PASSMYSQL
else
	echo "Desired MYSQL Password set $PASSMYSQL"
fi
echo " . "
PORTSSH=22
echo " "
kkkk=$(perl -e 'print crypt($ARGV[1], "\$" . $ARGV[0] . "\$" . $ARGV[2]), "\n";' "$alg" "$adminpass" "$salt")
sleep 1
if [[ "$silent" != "yes" ]] ; then
read -e -p "All is ok. Do you want to install Xtream UI now (y/n)? " yn
case $yn in
    [Yy]* ) break;;
    [Nn]* ) exit;;
esac
fi
clear
# ***************************************
# Installation really starts here

#--- Set custom logging methods so we create a log file in the current working directory.
logfile=$(date +%Y-%m-%d_%H.%M.%S_xtream_ui_install.log)
touch "$logfile"
exec > >(tee "$logfile")
exec 2>&1
echo "Installing Xtream UI $XC_VERSION at http://$ipaddr:$ACCESPORT"
echo "on server under: $OS  $VER  $ARCH"
uname -a
# Function to disable a file by appending its name with _disabled
disable_file() {
    mv "$1" "$1_disabled_by_xtream_ui" &> /dev/null
}
#--- Ubuntu and Debian AppArmor must be disabled to avoid problems
if [[ "$OS" = "Ubuntu" || "$OS" = "debian" ]]; then
    [ -f /etc/init.d/apparmor ]
    if [ $? = "0" ]; then
        echo -e "\n-- Disabling and removing AppArmor, please wait..."
        systemctl stop apparmor &> /dev/null
        systemctl disable apparmor &> /dev/null
        PACKAGE_REMOVER apparmor* &> /dev/null
        disable_file /etc/init.d/apparmor &> /dev/null
        echo -e "AppArmor has been removed."
    fi
	ufw disable
fi
#--- Adapt repositories and packages sources
echo -e "\n-- Updating repositories and packages sources"
if [[ "$OS" = "CentOs" || "$OS" = "Fedora" || "$OS" = "Centos Stream" ]]; then
	if [[ "$OS" = "CentOs" || "$OS" = "Centos Stream" ]]; then
		find /etc/yum.repos.d -name '*.repo' -exec sed -i 's|mirrorlist=http://mirrorlist.centos.org|#mirrorlist=http://mirrorlist.centos.org|' {} \;
		find /etc/yum.repos.d -name '*.repo' -exec sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://mirror.centos.org|' {} \;
		yum -y install https://rpms.remirepo.net/enterprise/remi-release-"$VER".rpm
		#check if the machine and on openvz
		if [ -f "/etc/yum.repos.d/vz.repo" ]; then
			sed -i "s|mirrorlist=http://vzdownload.swsoft.com/download/mirrors/centos-$VER|baseurl=http://vzdownload.swsoft.com/ez/packages/centos/$VER/$ARCH/os/|" "/etc/yum.repos.d/vz.repo"
			sed -i "s|mirrorlist=http://vzdownload.swsoft.com/download/mirrors/updates-released-ce$VER|baseurl=http://vzdownload.swsoft.com/ez/packages/centos/$VER/$ARCH/updates/|" "/etc/yum.repos.d/vz.repo"
		fi
		$PACKAGE_INSTALLER epel-releas
		$PACKAGE_INSTALLER https://rpms.remirepo.net/enterprise/remi-release-"$VER".rpm
	elif [[ "$OS" = "Fedora" ]]; then
		yum -y install https://rpms.remirepo.net/fedora/remi-release-"$VER".rpm
	fi
	#disable deposits that could result in installation errors
	find /etc/yum.repos.d -name '*.repo' -exec sed -i 's|enabled=1|enabled=0|' {} \;
	if [ -f "/etc/yum.repos.d/vz.repo" ]; then
		sed -i "s|enabled=0|enabled=1|" "/etc/yum.repos.d/vz.repo"
	fi
	enablerepo() {
	if [ "$OS" = "CentOs" ]; then
        	yum-config-manager --enable $1
	else
		dnf config-manager --set-enabled $1
        fi
	}
	if [ "$OS" = "CentOs" ]; then
		# enable official repository CentOs Base
		enablerepo base
		# enable official repository CentOs Updates
		enablerepo updates
		
		enablerepo epel
	elif [ "$OS" = "Centos Stream" ]; then
		# enable official repository CentOs Stream BaseOS
		enablerepo baseos
		# enable official repository CentOs Stream AppStream
		enablerepo appstream
		# enable official repository CentOs Stream extra
		enablerepo extras
		# enable official repository CentOs Stream extra-common
		enablerepo extras-common
		# enable official repository CentOs Stream PowerTools
		enablerepo powertools
		# enable official repository Fedora Epel
		enablerepo epel
		# enable official repository Fedora Epel Modular
		enablerepo epel-modular
		# install wget and add copr repo for devel package not build on official depots
		# temporary solve bug
		# https://bugzilla.redhat.com/show_bug.cgi?id=2099386
		dnf -y install wget
		wget https://copr.fedorainfracloud.org/coprs/andykimpe/Centos-Stream-Devel-php-build/repo/centos-stream-8/andykimpe-Centos-Stream-Devel-php-build-centos-stream-8.repo -O /etc/yum.repos.d/andykimpe-Centos-Stream-Devel-php-build-centos-stream-8.repo
	elif [ "$OS" = "Fedora" ]; then
		echo "fedora repo"
	fi
	# enable repository Remi's RPM repository
	enablerepo remi
	enablerepo remi-safe
	yumpurge() {
	for package in $@
	do
		echo "removing config files for $package"
		for file in $(rpm -q --configfiles $package)
		do
			echo "  removing $file"
			rm -f $file
		done
		rpm -e $package
	done
	}
cat > /etc/yum.repos.d/remi-source.repo <<EOF
[remi-source]
name=Remi's RPM source repository
baseurl=https://rpms.remirepo.net/SRPMS/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi
EOF
	if [[ "$OS" = "CentOs" || "$OS" = "Centos Stream" ]]; then
cat > /etc/yum.repos.d/mariadb.repo <<EOF
[mariadb]
name=MariaDB RPM source
baseurl=http://mirror.mariadb.org/yum/10.9/rhel/$VER/x86_64/
enabled=1
gpgcheck=0
EOF
	elif [[ "$OS" = "Fedora" ]]; then
cat > /etc/yum.repos.d/mariadb.repo <<EOF
[mariadb]
name=MariaDB RPM source
baseurl=http://mirror.mariadb.org/yum/10.9/fedora/$VER/x86_64/
enabled=1
gpgcheck=0
EOF
	fi
	# We need to disable SELinux...
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	setenforce 0
	# Stop conflicting services and iptables to ensure all services will work
	if  [[ "$VER" = "7" || "$VER" = "8" || "$VER" = "31" || "$VER" = "32" ]]; then
		systemctl  stop sendmail.service
		systemctl  disable sendmail.service
	else
		service sendmail stop
		chkconfig sendmail off
	fi
	# disable firewall
	$PACKAGE_INSTALLER iptables
	$PACKAGE_INSTALLER firewalld
	if  [[ "$VER" = "7" || "$VER" = "8" || "$VER" = "34" || "$VER" = "35" ]]; then
		FIREWALL_SERVICE="firewalld"
	else
		FIREWALL_SERVICE="iptables"
	fi
	if  [[ "$VER" = "7" || "$VER" = "8" || "$VER" = "34" || "$VER" = "35" ]]; then
		systemctl  save "$FIREWALL_SERVICE".service
		systemctl  stop "$FIREWALL_SERVICE".service
		systemctl  disable "$FIREWALL_SERVICE".service
	else
		service "$FIREWALL_SERVICE" save
		service "$FIREWALL_SERVICE" stop
		chkconfig "$FIREWALL_SERVICE" off
	fi
	# Removal of conflicting packages prior to installation.
	yumpurge bind-chroot
	yumpurge qpid-cpp-client
elif [[ "$OS" = "Ubuntu" ]]; then
	DEBIAN_FRONTEND=noninteractive
	export DEBIAN_FRONTEND=noninteractive
	# Update the enabled Aptitude repositories
	echo -e "\nUpdating Aptitude Repos: "
	mkdir -p "/etc/apt/sources.list.d.save"
	cp -R "/etc/apt/sources.list.d/*" "/etc/apt/sources.list.d.save" &> /dev/null
	rm -rf "/etc/apt/sources.list/*"
	cp "/etc/apt/sources.list" "/etc/apt/sources.list.save"
	cat > /etc/apt/sources.list <<EOF
#Depots main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc)-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc)-updates main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main restricted universe multiverse 
deb-src http://archive.ubuntu.com/ubuntu $(lsb_release -sc)-updates main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu $(lsb_release -sc)-security main restricted universe multiverse
deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner
deb-src http://archive.canonical.com/ubuntu $(lsb_release -sc) partner
EOF
	echo "update mirror list"
	apt-get update
	echo "install software-properties-common"
	apt-get install software-properties-common dirmngr --install-recommends -y
	echo "install ppa apache2"
	add-apt-repository -y ppa:ondrej/apache2
	echo "install ppa php"
	add-apt-repository -y -s ppa:ondrej/php
	echo "install ppa curl"
	add-apt-repository ppa:andykimpe/curl -y
	echo "updatelist after ppa add"
	apt-get update
	echo "add mariadb key"
	apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
	echo "add mariadb repo"
	add-apt-repository -y "deb [arch=amd64,arm64,ppc64el] https://mirrors.nxthost.com/mariadb/repo/10.9/ubuntu/ $(lsb_release -cs) main"
	echo "final update list"
	apt-get update
	echo "final update list end"
elif [[ "$OS" = "debian" ]]; then
	DEBIAN_FRONTEND=noninteractive
	export DEBIAN_FRONTEND=noninteractive
	# Update the enabled Aptitude repositories
	echo -ne "\nUpdating Aptitude Repos: " >/dev/tty
	apt-get update
	apt install curl wget apt-transport-https gnupg2 dirmngr -y
	mkdir -p "/etc/apt/sources.list.d.save"
	cp -R "/etc/apt/sources.list.d/*" "/etc/apt/sources.list.d.save" &> /dev/null
	rm -rf "/etc/apt/sources.list/*"
	cp "/etc/apt/sources.list" "/etc/apt/sources.list.save"
	cat > /etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian/ $(lsb_release -sc) main contrib non-free
deb-src http://deb.debian.org/debian/ $(lsb_release -sc) main contrib non-free
deb http://deb.debian.org/debian/ $(lsb_release -sc)-updates main contrib non-free
deb-src http://deb.debian.org/debian/ $(lsb_release -sc)-updates main contrib non-free
deb http://deb.debian.org/debian-security/ $(lsb_release -sc)/updates main contrib non-free
deb-src http://deb.debian.org/debian-security/ $(lsb_release -sc)/updates main contrib non-free
EOF
	cat > /etc/apt/sources.list.d/php.list <<EOF
deb https://packages.sury.org/php/ $(lsb_release -sc) main
deb-src https://packages.sury.org/php/ $(lsb_release -sc) main
EOF
	cat > /etc/apt/sources.list.d/apache2.list <<EOF
deb https://packages.sury.org/apache2/ $(lsb_release -sc) main
deb-src https://packages.sury.org/apache2/ $(lsb_release -sc) main
EOF
	apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
	echo "deb [arch=amd64,arm64,ppc64el] https://mirrors.nxthost.com/mariadb/repo/10.9/debian/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/mariadb.list
	wget -q -O- https://packages.sury.org/php/apt.gpg | apt-key add -
	wget -q -O- https://packages.sury.org/apache2/apt.gpg | apt-key add -
	apt-get update

fi
#--- List all already installed packages (may help to debug)
echo -e "\n-- Listing of all packages installed:"
if [[ "$OS" = "CentOs" || "$OS" = "Fedora" || "$OS" = "Centos Stream" ]]; then
    rpm -qa | sort
elif [[ "$OS" = "Ubuntu" || "$OS" = "debian" ]]; then
    dpkg --get-selections
fi
	#--- Ensures that all packages are up to date
echo -e "\n-- Updating+upgrading system, it may take some time..."
if [[ "$OS" = "CentOs" || "$OS" = "Fedora" ]]; then
    $PACKAGE_UPDATER
elif [[ "$OS" = "Ubuntu" || "$OS" = "debian" ]]; then
    apt-get update
    apt-get -y dist-upgrade
fi
if [[ "$OS" = "Ubuntu" ]]; then
    apt-get purge libcurl3 -y
fi
#--- Install utility packages required by the installer and/or Sentora.
echo -e "\n-- Downloading and installing required tools..."
if [[ "$OS" = "CentOs" || "$OS" = "Fedora" || "$OS" = "Centos Stream" ]]; then
    $PACKAGE_INSTALLER sudo vim make zip unzip chkconfig bash-completion
    if  [["$VER" = "7" ]]; then
    	$PACKAGE_INSTALLER ld-linux.so.2 libbz2.so.1 libdb-4.7.so libgd.so.2
    else
    	$PACKAGE_INSTALLER glibc32 bzip2-libs 
    fi
    $PACKAGE_INSTALLER sudo curl curl-devel perl-libwww-perl libxml2 libxml2-devel zip bzip2-devel gcc gcc-c++ at make
    $PACKAGE_INSTALLER ca-certificates nano
    $PACKAGE_GROUPINSTALL "Fedora Packager" "Development Tools"
	if [[ "$VER" = "7" ]]; then
$PACKAGE_INSTALLER https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-basic-21.6.0.0.0-1.x86_64.rpm \
https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-sqlplus-21.6.0.0.0-1.x86_64.rpm \
https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-tools-21.6.0.0.0-1.x86_64.rpm \
https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-devel-21.6.0.0.0-1.x86_64.rpm \
https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-jdbc-21.6.0.0.0-1.x86_64.rpm \
https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-odbc-21.6.0.0.0-1.x86_64.rpm
$PACKAGE_INSTALLER http://packages.psychotic.ninja/7/plus/x86_64/RPMS/libzip-0.11.2-6.el7.psychotic.x86_64.rpm http://packages.psychotic.ninja/7/plus/x86_64/RPMS/libzip-devel-0.11.2-6.el7.psychotic.x86_64.rpm
	else
$PACKAGE_INSTALLER https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-basic-21.6.0.0.0-1.el8.x86_64.rpm \
https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-sqlplus-21.6.0.0.0-1.el8.x86_64.rpm \
https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-tools-21.6.0.0.0-1.el8.x86_64.rpm \
https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-devel-21.6.0.0.0-1.el8.x86_64.rpm \
https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-jdbc-21.6.0.0.0-1.el8.x86_64.rpm \
https://download.oracle.com/otn_software/linux/instantclient/216000/oracle-instantclient-odbc-21.6.0.0.0-1.el8.x86_64.rpm
$PACKAGE_INSTALLER libzip-devel
	fi
	$PACKAGE_SOURCEDOWNLOAD php73-php-7.3.33-3.remi.src
	rpm -i php73-php-7.3.33-3.remi.src.rpm
	$BUILDDEP /root/rpmbuild/SPECS/php.spec
	$BUILDDEP php73
	rm -rf php73-php-7.3.33-3.remi.src.rpm /root/rpmbuild/SPECS/php.spec /root/rpmbuild/SOURCES/php* /root/rpmbuild/SOURCES/10-opcache.ini ls /root/rpmbuild/SOURCES/20-oci8.ini /root/rpmbuild/SOURCES/macros.php /root/rpmbuild/SOURCES/opcache-default.blacklist
	$PACKAGE_INSTALLER sudo vim make zip unzip at bash-completion ca-certificates e2fslibs jq sshpass net-tools curl
	$PACKAGE_INSTALLER libcurl-devel
	$PACKAGE_INSTALLER libxslt-devel GeoIP-devel e2fsprogs wget mcrypt nscd htop unzip httpd httpd-devel zip mc libpng-devel python2 python3
	$PACKAGE_INSTALLER MariaDB-client MariaDB-server MariaDB-devel
	$PACKAGE_INSTALLER python3-pip python3
	#install pip2
	wget -qO- https://bootstrap.pypa.io/pip/2.7/get-pip.py | python2 - 'pip==20.3.4'
	#upgrade pip3
	pyfv=$(python3 --version | sed  "s|Python ||g")
	pyv=${pyfv:0:3}
	wget -qO- https://bootstrap.pypa.io/pip/$pyv/get-pip.py | python3
	rm -rf /usr/local/bin/pip /usr/local/bin/pip2 /usr/local/bin/pip3  /usr/bin/pip /usr/bin/pip2 /usr/bin/pip3
cat > /usr/bin/pip2 <<EOF
#!/usr/bin/python2
# -*- coding: utf-8 -*-
import re
import sys
from pip._internal.cli.main import main
if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
    sys.exit(main())
EOF
chmod +x /usr/bin/pip2
cat > /usr/bin/pip3 <<EOF
#!/usr/bin/python3
# -*- coding: utf-8 -*-
import re
import sys
from pip._internal.cli.main import main
if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
    sys.exit(main())
EOF
	chmod +x /usr/bin/pip3
	ln -s /usr/bin/pip2 /usr/local/bin/pip2
	ln -s /usr/bin/pip3 /usr/local/bin/pip3
	pip2 install paramiko
	update-alternatives --remove-all pip
	update-alternatives --install /usr/bin/pip pip /usr/bin/pip2 2
	ln -s /usr/bin/pip /usr/local/bin/pip
	update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
	rm -f /usr/bin/python
	update-alternatives --remove-all python
	update-alternatives --install /usr/bin/python pythonp /usr/bin/python3 2
	update-alternatives --install /usr/bin/python python /usr/local/bin/python2 1
	sed -i "s/Listen 80/Listen $APACHEACCESPORT/g" /etc/httpd/conf/httpd.conf
elif [[ "$OS" = "Ubuntu" || "$OS" = "debian" ]]; then
	$PACKAGE_INSTALLER debhelper cdbs lintian build-essential fakeroot devscripts dh-make
	apt-get -y build-dep php7.3
        $PACKAGE_INSTALLER sudo vim make zip unzip debconf-utils at bash-completion ca-certificates e2fslibs jq sshpass
	$PACKAGE_INSTALLER net-tools curl 
	apt-get purge libcurl3 -y
	$PACKAGE_INSTALLER libcurl4 libxslt1-dev libgeoip-dev e2fsprogs wget mcrypt libmcrypt-dev nscd htop unzip ufw apache2 zip mc libpng16-16 python2 python3
	ufw disable
	$PACKAGE_INSTALLER libmcrypt4 libmcrypt-dev mcrypt libgeoip-dev
	$PACKAGE_INSTALLER libzip5
	$PACKAGE_INSTALLER libzip4
	apt-get update
	debconf-set-selections <<< "mariadb-server-10.5 mysql-server/root_password password $PASSMYSQL"
	debconf-set-selections <<< "mariadb-server-10.5 mysql-server/root_password_again password $PASSMYSQL"
	$PACKAGE_INSTALLER mariadb-client-10.5
	$PACKAGE_INSTALLER  mariadb-client
	$PACKAGE_INSTALLER mariadb-server-10.5
	$PACKAGE_INSTALLER mariadb-server
	systemctl restart $MARIADBSERVICE
	echo "postfix postfix/mailname string postfixmessage" | debconf-set-selections
	echo "postfix postfix/main_mailer_type string 'Local only'" | debconf-set-selections
	$PACKAGE_INSTALLER postfix
	if [[ "$VER" = "18.04" ]]; then
		$PACKAGE_INSTALLER python python-paramiko python-pip
		$PACKAGE_INSTALLER python3-pip python3
		#upgrade pip3
		pyfv=$(python3 --version | sed  "s|Python ||g")
		pyv=${pyfv:0:3}
		wget -qO- https://bootstrap.pypa.io/pip/$pyv/get-pip.py | python3
		rm -rf /usr/local/bin/pip /usr/local/bin/pip2 /usr/local/bin/pip3  /usr/bin/pip /usr/bin/pip2 /usr/bin/pip3
cat > /usr/bin/pip3 <<EOF
!/usr/bin/python3
 -*- coding: utf-8 -*-
import re
import sys
from pip._internal.cli.main import main
if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
    sys.exit(main())
EOF
		chmod +x /usr/bin/pip3
		ln -s /usr/bin/pip3 /usr/local/bin/pip3
cat > /usr/bin/pip <<EOF
#!/usr/bin/python2
# GENERATED BY DEBIAN
import sys
# Run the main entry point, similarly to how setuptools does it, but because
# we didn't install the actual entry point from setup.py, don't use the
# pkg_resources API.
from pip import main
if __name__ == '__main__':
    sys.exit(main())
EOF
		chmod +x /usr/bin/pip
		ln -s /usr/bin/pip /usr/local/bin/pip
cat > /usr/bin/pip2 <<EOF
#!/usr/bin/python2
# GENERATED BY DEBIAN
import sys
# Run the main entry point, similarly to how setuptools does it, but because
# we didn't install the actual entry point from setup.py, don't use the
# pkg_resources API.
from pip import main
if __name__ == '__main__':
    sys.exit(main())
EOF
		chmod +x /usr/bin/pip2
		ln -s /usr/bin/pip2 /usr/local/bin/pip2
	else
		$PACKAGE_INSTALLER python3-pip python3
		#install pip2
		wget -qO- https://bootstrap.pypa.io/pip/2.7/get-pip.py | python2 - 'pip==20.3.4'
		#upgrade pip3
		pyfv=$(python3 --version | sed  "s|Python ||g")
		pyv=${pyfv:0:3}
		wget -qO- https://bootstrap.pypa.io/pip/$pyv/get-pip.py | python3
		rm -rf /usr/local/bin/pip /usr/local/bin/pip2 /usr/local/bin/pip3  /usr/bin/pip /usr/bin/pip2 /usr/bin/pip3
cat > /usr/bin/pip2 <<EOF
#!/usr/bin/python2
# -*- coding: utf-8 -*-
import re
import sys
from pip._internal.cli.main import main
if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
    sys.exit(main())
EOF
chmod +x /usr/bin/pip2
cat > /usr/bin/pip3 <<EOF
#!/usr/bin/python3
# -*- coding: utf-8 -*-
import re
import sys
from pip._internal.cli.main import main
if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
    sys.exit(main())
EOF
	chmod +x /usr/bin/pip3
	ln -s /usr/bin/pip2 /usr/local/bin/pip2
	ln -s /usr/bin/pip3 /usr/local/bin/pip3
	pip2 install paramiko
	update-alternatives --remove-all pip
	update-alternatives --install /usr/bin/pip pip /usr/bin/pip2 2
	ln -s /usr/bin/pip /usr/local/bin/pip
	update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
	rm -f /usr/bin/python
	update-alternatives --remove-all python
	update-alternatives --install /usr/bin/python pythonp /usr/bin/python3 2
	update-alternatives --install /usr/bin/python python /usr/local/bin/python2 1
	fi
	debconf-set-selections <<<'phpmyadmin phpmyadmin/internal/skip-preseed boolean true'
	debconf-set-selections <<<'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'
	debconf-set-selections <<<'phpmyadmin phpmyadmin/dbconfig-install boolean false'
	$PACKAGE_INSTALLER  phpmyadmin
	mv /usr/share/phpmyadmin/ /usr/share/phpmyadmin.bakkk
	wget https://xtream-brutus.com/v3/phpMyAdmin-4.9.5-all-languages.zip
	unzip phpMyAdmin-4.9.5-all-languages.zip
	mv phpMyAdmin-4.9.5-all-languages /usr/share/phpmyadmin
	rm -r phpMyAdmin-4.9.5-all-languages.zip
	sed -i "s/blowfish_secret'] = '/blowfish_secret'] = '$blofish/g" /usr/share/phpmyadmin/libraries/config.default.php
	sed -i "s/Listen 80/Listen $APACHEACCESPORT/g" /etc/apache2/ports.conf
	sed -i "s/Listen 443/Listen 70/g" /etc/apache2/ports.conf
	sed -i "s/80/$APACHEACCESPORT/g" /etc/apache2/sites-available/000-default.conf
	sed -i "s/443/70/g" /etc/apache2/sites-available/default-ssl.conf
	systemctl restart apache2
	fi
$PACKAGE_INSTALLER daemonize
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$PASSMYSQL'; flush privileges;"
echo -e "\\r${CHECK_MARK} Installation Of Packages Done"
sleep 1s
echo -n "[+] Installation Of XtreamCodes..."
sleep 1s
#### installation de xtream codes
if [[ "$OS" = "Ubuntu" || "$OS" = "debian" ]]; then
adduser --system --shell /bin/false --group --disabled-login xtreamcodes
else
adduser --system --shell /bin/false --group xtreamcodes
fi
wget -q -O /tmp/xtreamcodes.tar.gz https://github.com/amidevous/xtream-ui-ubuntu20.04/releases/download/start/main_xui_"$OS"_"$VER".tar.gz
tar -xf "/tmp/xtreamcodes.tar.gz" -C "/home/xtreamcodes/"
rm -r /tmp/xtreamcodes.tar.gz
mv $MYSQLCNF $MYSQLCNF.xc
echo IyBYdHJlYW0gQ29kZXMNCg0KW2NsaWVudF0NCnBvcnQgICAgICAgICAgICA9IDMzMDYNCg0KW215c3FsZF9zYWZlXQ0KbmljZSAgICAgICAgICAgID0gMA0KDQpbbXlzcWxkXQ0KdXNlciAgICAgICAgICAgID0gbXlzcWwNCnBvcnQgICAgICAgICAgICA9IDc5OTkNCmJhc2VkaXIgICAgICAgICA9IC91c3INCmRhdGFkaXIgICAgICAgICA9IC92YXIvbGliL215c3FsDQp0bXBkaXIgICAgICAgICAgPSAvdG1wDQpsYy1tZXNzYWdlcy1kaXIgPSAvdXNyL3NoYXJlL215c3FsDQpza2lwLWV4dGVybmFsLWxvY2tpbmcNCnNraXAtbmFtZS1yZXNvbHZlPTENCg0KYmluZC1hZGRyZXNzICAgICAgICAgICAgPSAqDQprZXlfYnVmZmVyX3NpemUgPSAxMjhNDQoNCm15aXNhbV9zb3J0X2J1ZmZlcl9zaXplID0gNE0NCm1heF9hbGxvd2VkX3BhY2tldCAgICAgID0gNjRNDQpteWlzYW0tcmVjb3Zlci1vcHRpb25zID0gQkFDS1VQDQptYXhfbGVuZ3RoX2Zvcl9zb3J0X2RhdGEgPSA4MTkyDQpxdWVyeV9jYWNoZV9saW1pdCAgICAgICA9IDRNDQpxdWVyeV9jYWNoZV9zaXplICAgICAgICA9IDI1Nk0NCg0KDQpleHBpcmVfbG9nc19kYXlzICAgICAgICA9IDEwDQptYXhfYmlubG9nX3NpemUgICAgICAgICA9IDEwME0NCg0KbWF4X2Nvbm5lY3Rpb25zICA9IDIwMDAwDQpiYWNrX2xvZyA9IDQwOTYNCm9wZW5fZmlsZXNfbGltaXQgPSAyMDI0MA0KaW5ub2RiX29wZW5fZmlsZXMgPSAyMDI0MA0KbWF4X2Nvbm5lY3RfZXJyb3JzID0gMzA3Mg0KdGFibGVfb3Blbl9jYWNoZSA9IDQwOTYNCnRhYmxlX2RlZmluaXRpb25fY2FjaGUgPSA0MDk2DQoNCg0KdG1wX3RhYmxlX3NpemUgPSAxRw0KbWF4X2hlYXBfdGFibGVfc2l6ZSA9IDFHDQoNCmlubm9kYl9idWZmZXJfcG9vbF9zaXplID0gMTBHDQppbm5vZGJfYnVmZmVyX3Bvb2xfaW5zdGFuY2VzID0gMTANCmlubm9kYl9yZWFkX2lvX3RocmVhZHMgPSA2NA0KaW5ub2RiX3dyaXRlX2lvX3RocmVhZHMgPSA2NA0KaW5ub2RiX3RocmVhZF9jb25jdXJyZW5jeSA9IDANCmlubm9kYl9mbHVzaF9sb2dfYXRfdHJ4X2NvbW1pdCA9IDANCmlubm9kYl9mbHVzaF9tZXRob2QgPSBPX0RJUkVDVA0KcGVyZm9ybWFuY2Vfc2NoZW1hID0gMA0KaW5ub2RiLWZpbGUtcGVyLXRhYmxlID0gMQ0KaW5ub2RiX2lvX2NhcGFjaXR5PTIwMDAwDQppbm5vZGJfdGFibGVfbG9ja3MgPSAwDQppbm5vZGJfbG9ja193YWl0X3RpbWVvdXQgPSAwDQppbm5vZGJfZGVhZGxvY2tfZGV0ZWN0ID0gMA0KDQoNCnNxbC1tb2RlPSJOT19FTkdJTkVfU1VCU1RJVFVUSU9OIg0KDQpbbXlzcWxkdW1wXQ0KcXVpY2sNCnF1b3RlLW5hbWVzDQptYXhfYWxsb3dlZF9wYWNrZXQgICAgICA9IDE2TQ0KDQpbbXlzcWxdDQoNCltpc2FtY2hrXQ0Ka2V5X2J1ZmZlcl9zaXplICAgICAgICAgICAgICA9IDE2TQ0K | base64 --decode > $MYSQLCNF
systemctl restart $MARIADBSERVICE
echo -e "\\r${CHECK_MARK} Installation Of XtreamCodes Done"
echo -n "[+] Configuration Of Mysql & Nginx..."
#### config database
## add python script
python2 << END
# coding: utf-8
import subprocess, os, random, string, sys, shutil, socket
from itertools import cycle, izip
class col:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
rHost = "127.0.0.1"
rPassword = "$XPASS"
rServerID = 1
rUsername = "user_iptvpro"
rDatabase = "xtream_iptvpro"
rPort = 7999
rExtra = " -p$PASSMYSQL"
reseau = "$networkcard"
portadmin = "$ACCESPORT"
getIP = "$ipaddr"
sshssh = "$PORTSSH"
getVersion = "$versionn"
generate1 = "$zzz"
generate2 = "$eee"
generate3 = "$rrr"
def encrypt(rHost="127.0.0.1", rUsername="user_iptvpro", rPassword="", rDatabase="xtream_iptvpro", rServerID=1, rPort=7999):
    rf = open('/home/xtreamcodes/iptv_xtream_codes/config', 'wb')
    rf.write(''.join(chr(ord(c)^ord(k)) for c,k in izip('{\"host\":\"%s\",\"db_user\":\"%s\",\"db_pass\":\"%s\",\"db_name\":\"%s\",\"server_id\":\"%d\", \"db_port\":\"%d\"}' % (rHost, rUsername, rPassword, rDatabase, rServerID, rPort), cycle('5709650b0d7806074842c6de575025b1'))).encode('base64').replace('\n', ''))
    rf.close()
def modifyNginx():
    rPath = "/home/xtreamcodes/iptv_xtream_codes/nginx/conf/nginx.conf"
    rPrevData = open(rPath, "r").read()
    rData = "}".join(rPrevData.split("}")[:-1]) + "    server {\n        listen $ACCESPORT;\n        index index.php index.html index.htm;\n        root /home/xtreamcodes/iptv_xtream_codes/admin/;\n\n        location ~ \.php$ {\n			limit_req zone=one burst=8;\n            try_files ${nginx111} =404;\n			fastcgi_index index.php;\n			fastcgi_pass php;\n			include fastcgi_params;\n			fastcgi_buffering on;\n			fastcgi_buffers 96 32k;\n			fastcgi_buffer_size 32k;\n			fastcgi_max_temp_file_size 0;\n			fastcgi_keep_conn on;\n			fastcgi_param SCRIPT_FILENAME ${nginx222};\n			fastcgi_param SCRIPT_NAME ${nginx333};\n        }\n    }\n}"
    rFile = open(rPath, "w")
    rFile.write(rData)
    rFile.close()
    if not "api.xtream-codes.com" in open("/etc/hosts").read(): os.system('echo "127.0.0.1    api.xtream-codes.com" >> /etc/hosts')
    if not "downloads.xtream-codes.com" in open("/etc/hosts").read(): os.system('echo "127.0.0.1    downloads.xtream-codes.com" >> /etc/hosts')
    if not " xtream-codes.com" in open("/etc/hosts").read(): os.system('echo "127.0.0.1    xtream-codes.com" >> /etc/hosts')
def mysql():
    os.system('mysql -u root%s -e "DROP DATABASE IF EXISTS xtream_iptvpro; CREATE DATABASE IF NOT EXISTS xtream_iptvpro;" > /dev/null' % rExtra)
    os.system("mysql -u root%s xtream_iptvpro < /home/xtreamcodes/iptv_xtream_codes/database.sql > /dev/null" % rExtra)
    os.system('mysql -u root%s -e "USE xtream_iptvpro; REPLACE INTO streaming_servers (id, server_name, domain_name, server_ip, vpn_ip, ssh_password, ssh_port, diff_time_main, http_broadcast_port, total_clients, system_os, network_interface, latency, status, enable_geoip, geoip_countries, last_check_ago, can_delete, server_hardware, total_services, persistent_connections, rtmp_port, geoip_type, isp_names, isp_type, enable_isp, boost_fpm, http_ports_add, network_guaranteed_speed, https_broadcast_port, https_ports_add, whitelist_ips, watchdog_data, timeshift_only) VALUES (1, \'Main Server\', \'\', \'%s\', \'\', NULL, \'%s\', 0, 2082, 1000, \'%s\', \'%s\', 0, 1, 0, \'\', 0, 0, \'{}\', 3, 0, 2086, \'low_priority\', \'\', \'low_priority\', 0, 0, \'\', 1000, 2083, \'\', \'[\"127.0.0.1\",\"\"]\', \'{}\', 0);" > /dev/null' % (rExtra, getIP, sshssh, getVersion, reseau))
    os.system('mysql -u root%s -e "GRANT ALL PRIVILEGES ON *.* TO \'%s\'@\'%%\' IDENTIFIED BY \'%s\' WITH GRANT OPTION; FLUSH PRIVILEGES;" > /dev/null' % (rExtra, rUsername, rPassword))
mysql()
encrypt(rHost, rUsername, rPassword, rDatabase, rServerID, rPort)
modifyNginx()
END
wget -qO install.sql https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/install.sql
sed -i "s|adminn|$adminn|g" install.sql
sed -i "s|kkkk|$kkkk|g" install.sql
sed -i "s|EMAIL|$EMAIL|g" install.sql
mysql -u root -p$PASSMYSQL xtream_iptvpro < install.sql
rm -f install.sql
echo -e "\\r${CHECK_MARK} Configuration Of Mysql & Nginx Done"
echo -n "[+] Configuration Of Crons & Autorisations..."
rm -r /home/xtreamcodes/iptv_xtream_codes/database.sql
if ! grep -q "xtreamcodes ALL = (root) NOPASSWD: /sbin/iptables, /usr/bin/chattr, /usr/bin/python2, /usr/bin/python" /etc/sudoers; then
    echo "xtreamcodes ALL = (root) NOPASSWD: /sbin/iptables, /usr/bin/chattr, /usr/bin/python2, /usr/bin/python" >> /etc/sudoers;
fi
ln -s /home/xtreamcodes/iptv_xtream_codes/bin/ffmpeg /usr/bin/
if ! grep -q "tmpfs /home/xtreamcodes/iptv_xtream_codes/streams tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=90% 0 0" /etc/fstab; then
	echo "tmpfs /home/xtreamcodes/iptv_xtream_codes/streams tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=90% 0 0" >> /etc/fstab;
fi
if ! grep -q "tmpfs /home/xtreamcodes/iptv_xtream_codes/tmp tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=2G 0 0" /etc/fstab; then
	echo "tmpfs /home/xtreamcodes/iptv_xtream_codes/tmp tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=2G 0 0" >> /etc/fstab;
fi
chmod -R 0777 /home/xtreamcodes
cat > /home/xtreamcodes/iptv_xtream_codes/nginx/conf/nginx.conf <<EOR
user  xtreamcodes;
worker_processes  auto;

worker_rlimit_nofile 300000;
events {
    worker_connections  16000;
    use epoll;
	accept_mutex on;
	multi_accept on;
}
thread_pool pool_xtream threads=32 max_queue=0;
http {

    include       mime.types;
    default_type  application/octet-stream;

    sendfile           on;
    tcp_nopush         on;
    tcp_nodelay        on;
	reset_timedout_connection on;
    gzip off;
    fastcgi_read_timeout 200;
	access_log off;
	keepalive_timeout 10;
	include balance.conf;
	send_timeout 20m;	
	sendfile_max_chunk 512k;
	lingering_close off;
	aio threads=pool_xtream;
	client_body_timeout 13s;
	client_header_timeout 13s;
	client_max_body_size 3m;

	limit_req_zone \$binary_remote_addr zone=one:30m rate=20r/s;
    server {
        listen $CLIENTACCESPORT;listen 25463 ssl;ssl_certificate server.crt;ssl_certificate_key server.key; ssl_protocols SSLv3 TLSv1.1 TLSv1.2;
        index index.php index.html index.htm;
        root /home/xtreamcodes/iptv_xtream_codes/wwwdir/;
        server_tokens off;
        chunked_transfer_encoding off;

		if ( \$request_method !~ ^(GET|POST)\$ ) {
			return 200;
		}

        rewrite_log on;
        rewrite ^/live/(.*)/(.*)/(.*)\.(.*)\$ /streaming/clients_live.php?username=\$1&password=\$2&stream=\$3&extension=\$4 break;
        rewrite ^/movie/(.*)/(.*)/(.*)\$ /streaming/clients_movie.php?username=\$1&password=\$2&stream=\$3&type=movie break;
		rewrite ^/series/(.*)/(.*)/(.*)\$ /streaming/clients_movie.php?username=\$1&password=\$2&stream=\$3&type=series break;
        rewrite ^/(.*)/(.*)/(.*).ch\$ /streaming/clients_live.php?username=\$1&password=\$2&stream=\$3&extension=ts break;
        rewrite ^/(.*)\.ch\$ /streaming/clients_live.php?extension=ts&stream=\$1&qs=\$query_string break;
        rewrite ^/ch(.*)\.m3u8\$ /streaming/clients_live.php?extension=m3u8&stream=\$1&qs=\$query_string break;
		rewrite ^/hls/(.*)/(.*)/(.*)/(.*)/(.*)\$ /streaming/clients_live.php?extension=m3u8&username=\$1&password=\$2&stream=\$3&type=hls&segment=\$5&token=$4 break;
		rewrite ^/hlsr/(.*)/(.*)/(.*)/(.*)/(.*)/(.*)\$ /streaming/clients_live.php?token=\$1&username=\$2&password=\$3&segment=\$6&stream=\$4&key_seg=\$5 break;
		rewrite ^/timeshift/(.*)/(.*)/(.*)/(.*)/(.*)\.(.*)\$ /streaming/timeshift.php?username=\$1&password=\$2&stream=\$5&extension=\$6&duration=\$3&start=\$4 break;
		rewrite ^/timeshifts/(.*)/(.*)/(.*)/(.*)/(.*)\.(.*)\$ /streaming/timeshift.php?username=\$1&password=\$2&stream=\$4&extension=\$6&duration=\$3&start=\$5 break;
		
		rewrite ^/(.*)/(.*)/(\d+)\$ /streaming/clients_live.php?username=\$1&password=\$2&stream=\$3&extension=ts break;
		#add pvr support
		rewrite ^/server/load.php\$ /portal.php break;
		
		location /stalker_portal/c {
			alias /home/xtreamcodes/iptv_xtream_codes/wwwdir/c;
		}
		
		#FFmpeg Report Progress
		location = /progress.php {
		    allow 127.0.0.1;
			deny all;
			fastcgi_pass php;
			include fastcgi_params;
			fastcgi_ignore_client_abort on;
			fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
			fastcgi_param SCRIPT_NAME \$fastcgi_script_name;
		}


        location ~ \.php\$ {
			limit_req zone=one burst=8;
            try_files \$uri =404;
			fastcgi_index index.php;
			fastcgi_pass php;
			include fastcgi_params;
			fastcgi_buffering on;
			fastcgi_buffers 96 32k;
			fastcgi_buffer_size 32k;
			fastcgi_max_temp_file_size 0;
			fastcgi_keep_conn on;
			fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
			fastcgi_param SCRIPT_NAME \$fastcgi_script_name;
        }
    }
    server {
        listen $ACCESPORT;
        index index.php index.html index.htm;
        root /home/xtreamcodes/iptv_xtream_codes/admin/;

        location ~ \.php\$ {
			limit_req zone=one burst=8;
            try_files \$uri =404;
			fastcgi_index index.php;
			fastcgi_pass php;
			include fastcgi_params;
			fastcgi_buffering on;
			fastcgi_buffers 96 32k;
			fastcgi_buffer_size 32k;
			fastcgi_max_temp_file_size 0;
			fastcgi_keep_conn on;
			fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
			fastcgi_param SCRIPT_NAME \$fastcgi_script_name;
        }
    }
    #ISP CONFIGURATION

    server {
         listen 8805;
         root /home/xtreamcodes/iptv_xtream_codes/isp/;
         location / {
                      allow 127.0.0.1;
                      deny all;
         }
         location ~ \.php\$ {
                             limit_req zone=one burst=8;
                             try_files \$uri =404;
                             fastcgi_index index.php;
                             fastcgi_pass php;
                             include fastcgi_params;
                             fastcgi_buffering on;
                             fastcgi_buffers 96 32k;
                             fastcgi_buffer_size 32k;
                             fastcgi_max_temp_file_size 0;
                             fastcgi_keep_conn on;
                             fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                             fastcgi_param SCRIPT_NAME \$fastcgi_script_name;
         }
    }
}
EOR
mysql -u root -p$PASSMYSQL xtream_iptvpro -e "UPDATE streaming_servers SET http_broadcast_port = '$CLIENTACCESPORT' WHERE streaming_servers.id = 1;"
#update gen pass
mysql -u root -p$PASSMYSQL xtream_iptvpro -e "UPDATE settings SET live_streaming_pass = '$zzz' WHERE settings.id = 1;"
mysql -u root -p$PASSMYSQL xtream_iptvpro -e "UPDATE settings SET unique_id = '$eee' WHERE settings.id = 1;"
mysql -u root -p$PASSMYSQL xtream_iptvpro -e "UPDATE settings SET crypt_load_balancing = '$rrr' WHERE settings.id = 1;"
mysql -u root -p$PASSMYSQL xtream_iptvpro -e "UPDATE settings SET crypt_load_balancing = '$rrr' WHERE settings.id = 1;"
#update php.ini timezone
sed -i "s|;date.timezone =|date.timezone = $timezone|g" /home/xtreamcodes/iptv_xtream_codes/php/lib/php.ini
#replace python by python2
#local and security patching settings and admin_settings
echo -e "\\r${CHECK_MARK} Configuration Of Crons & Autorisations Done"
echo -n "[+] installation Of Admin Web Access..."
#### update xtream cr 41
# backup R41
#wget -q -O /tmp/update.zip https://github.com/amidevous/xtream-ui-ubuntu20.04/releases/download/start/update.zip
#xcversion=41
#install latest
wget -q -O /tmp/update.zip http://xcodes.mine.nu/XCodes/update.zip
unzip -o /tmp/update.zip -d /tmp/update/
chattr -i /home/xtreamcodes/iptv_xtream_codes/GeoLite2.mmdb
rm -rf /tmp/update/XtreamUI-master/php
rm -rf /tmp/update/XtreamUI-master/GeoLite2.mmdb
cp -rf /tmp/update/XtreamUI-master/* /home/xtreamcodes/iptv_xtream_codes/
rm -rf /tmp/update/XtreamUI-master
rm /tmp/update.zip
rm -rf /tmp/update
xcversion=$(wget -qO- http://xcodes.mine.nu/XCodes/current.json | jq -r ".version")
mysql -u root -p$PASSMYSQL xtream_iptvpro -e "UPDATE admin_settings SET value = '$xcversion' WHERE admin_settings.type = 'panel_version'; "
chattr -i /home/xtreamcodes/iptv_xtream_codes/GeoLite2.mmdb
wget -O /home/xtreamcodes/iptv_xtream_codes/GeoLite2.mmdb http://xcodes.mine.nu/XCodes/GeoLite2.mmdb
chattr +i /home/xtreamcodes/iptv_xtream_codes/GeoLite2.mmdb
geoliteversion=$(wget -qO- http://xcodes.mine.nu/XCodes/status.json | jq -r ".version")
mysql -u root -p$PASSMYSQL xtream_iptvpro -e "UPDATE admin_settings SET value = '$geoliteversion' WHERE admin_settings.type = 'geolite2_version'; "
chown xtreamcodes:xtreamcodes -R /home/xtreamcodes
chmod +x /home/xtreamcodes/iptv_xtream_codes/start_services.sh
chmod +x /home/xtreamcodes/iptv_xtream_codes/permissions.sh
chmod -R 0777 /home/xtreamcodes/iptv_xtream_codes/crons
#### start xtream after boot
echo "@reboot root sudo /home/xtreamcodes/iptv_xtream_codes/start_services.sh" >> /etc/crontab
/home/xtreamcodes/iptv_xtream_codes/permissions.sh
killall php-fpm
rm -f /home/xtreamcodes/iptv_xtream_codes/php/VaiIb8.pid /home/xtreamcodes/iptv_xtream_codes/php/JdlJXm.pid /home/xtreamcodes/iptv_xtream_codes/php/CWcfSP.pid
rm -f /home/xtreamcodes/iptv_xtream_codes/pytools/balancer.py
rm -f /home/xtreamcodes/iptv_xtream_codes/crons/balancer.php
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/balancer.php -O /home/xtreamcodes/iptv_xtream_codes/crons/balancer.php
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/balancer.sh -O /home/xtreamcodes/iptv_xtream_codes/pytools/balancer.sh
chmod +x /home/xtreamcodes/iptv_xtream_codes/pytools/balancer.sh
/home/xtreamcodes/iptv_xtream_codes/start_services.sh
##################
echo -e "\\r${CHECK_MARK} Configuration Auto Start Done"
echo " "
echo " ┌────────────────────────────────────────────┐ "
echo " │[R]        XtreamCodes Is Ready...          │ "
echo " └────────────────────────────────────────────┘ "

############## info install /root/infoinstall.txt ###################
## print infos on putty or openssh client
echo "
─────────────────  Saved In: /root/Xtreaminfo.txt  ─────────────────
│ PANEL ACCESS: http://$ipaddr:$ACCESPORT
│ USERNAME: $adminn
│ PASSWORD: $adminpass
│ MYSQL root PASS: $PASSMYSQL
│ MYSQL user_iptvpro PASS: $XPASS
────────────────────────────────────────────────────────────────────
"
######################################################################
## copy info to file text
echo "
───────────────────────────  INFO  ─────────────────────────────────
│
│ PANEL ACCESS: http://$ipaddr:$ACCESPORT
│ 
│ USERNAME: $adminn
│
│ PASSWORD: $adminpass
│ 
│ MYSQL root PASS: $PASSMYSQL
│
│ MYSQL user_iptvpro PASS: $XPASS
│ 
────────────────────────────────────────────────────────────────────
" >> /root/Xtreaminfo.txt
