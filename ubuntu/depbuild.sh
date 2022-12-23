#!/bin/bash
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
    VER=${VERFULL:0:2} # return 34, 35 or 36
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
if [[ "$OS" = "CentOs" && "$VER" = "7" && "$ARCH" == "x86_64" ||
"$OS" = "Centos Stream" && "$VER" = "8" && "$ARCH" == "x86_64" ||
"$OS" = "Fedora" && ("$VER" = "34" || "$VER" = "35" || "$VER" = "36" ) && "$ARCH" == "x86_64" ||
"$OS" = "Ubuntu" && ("$VER" = "18.04" || "$VER" = "20.04" || "$VER" = "22.04" ) && "$ARCH" == "x86_64" ||
"$OS" = "debian" && ("$VER" = "10" || "$VER" = "11" ) && "$ARCH" == "x86_64" ]] ; then
    echo "Ok."
else
    echo "Sorry, this OS is not supported by Xtream UI."
    exit 1
fi
echo -e "\n-- Updating repositories and packages sources"
if [[ "$OS" = "CentOs" ]] ; then
    PACKAGE_INSTALLER="yum -y -q install"
    PACKAGE_REMOVER="yum -y -q remove"
    PACKAGE_UPDATER="yum -y -q update"
    PACKAGE_UTILS="yum-utils"
    PACKAGE_GROUPINSTALL="yum -y -q groupinstall"
    PACKAGE_SOURCEDOWNLOAD="yumdownloader --source"
    BUILDDEP="yum-builddep -y"
elif [[ "$OS" = "Fedora" || "$OS" = "Centos Stream"  ]]; then
    PACKAGE_INSTALLER="dnf -y -q install"
    PACKAGE_REMOVER="dnf -y -q remove"
    PACKAGE_UPDATER="dnf -y -q update"
    PACKAGE_UTILS="dnf-utils" 
    PACKAGE_GROUPINSTALL="dnf -y -q groupinstall"
    PACKAGE_SOURCEDOWNLOAD="dnf download --source"
    BUILDDEP="dnf build-dep -y"
elif [[ "$OS" = "Ubuntu" || "$OS" = "debian" ]]; then
    PACKAGE_INSTALLER="apt-get -yqq install"
    PACKAGE_REMOVER="apt-get -yqq purge"
    inst() {
       dpkg -l "$1" 2> /dev/null | grep '^ii' &> /dev/null
    }
fi
if [[ "$OS" = "CentOs" || "$OS" = "Centos Stream" || "$OS" = "Fedora" ]]; then
	if [[ "$OS" = "CentOs" || "$OS" = "Centos Stream" ]]; then
		#To fix some problems of compatibility use of mirror centos.org to all users
		#Replace all mirrors by base repos to avoid any problems.
		find /etc/yum.repos.d -name '*.repo' -exec sed -i 's|mirrorlist=http://mirrorlist.centos.org|#mirrorlist=http://mirrorlist.centos.org|' {} \;
		find /etc/yum.repos.d -name '*.repo' -exec sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://mirror.centos.org|' {} \;
		#check if the machine and on openvz
		if [ -f "/etc/yum.repos.d/vz.repo" ]; then
			sed -i "s|mirrorlist=http://vzdownload.swsoft.com/download/mirrors/centos-$VER|baseurl=http://vzdownload.swsoft.com/ez/packages/centos/$VER/$ARCH/os/|" "/etc/yum.repos.d/vz.repo"
			sed -i "s|mirrorlist=http://vzdownload.swsoft.com/download/mirrors/updates-released-ce$VER|baseurl=http://vzdownload.swsoft.com/ez/packages/centos/$VER/$ARCH/updates/|" "/etc/yum.repos.d/vz.repo"
		fi
		#EPEL Repo Install
		$PACKAGE_INSTALLER epel-release
		$PACKAGE_INSTALLER https://rpms.remirepo.net/enterprise/remi-release-"$VER".rpm
	elif [[ "$OS" = "Fedora" ]]; then
		$PACKAGE_INSTALLER https://rpms.remirepo.net/fedora/remi-release-"$VER".rpm
	fi
	$PACKAGE_INSTALLER $PACKAGE_UTILS
	#disable deposits that could result in installation errors
	# disable all repository
	find /etc/yum.repos.d -name '*.repo' -exec sed -i 's|enabled=1|enabled=0|' {} \;
	# enable vz repository if present for openvz system
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
		# enable official repository Fedora Epel
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
	if  [[ "$VER" = "7" || "$VER" = "8" || "$VER" = "34" || "$VER" = "35" || "$VER" = "36" ]]; then
		systemctl  stop sendmail.service
		systemctl  disabble sendmail.service
	else
		service sendmail stop
		chkconfig sendmail off
	fi
	# disable firewall
	$PACKAGE_INSTALLER iptables
	$PACKAGE_INSTALLER firewalld
	if  [[ "$VER" = "7" || "$VER" = "8" || "$VER" = "34" || "$VER" = "35" || "$VER" = "36" ]]; then
		FIREWALL_SERVICE="firewalld"
	else
		FIREWALL_SERVICE="iptables"
	fi
	if  [[ "$VER" = "7" || "$VER" = "8" || "$VER" = "34" || "$VER" = "35" || "$VER" = "36" ]]; then
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
	echo -ne "\nUpdating Aptitude Repos: " >/dev/tty
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
	apt-get update
	apt-get install software-properties-common dirmngr --install-recommends -y
	add-apt-repository -y ppa:ondrej/apache2
	add-apt-repository -y -s ppa:ondrej/php
	add-apt-repository ppa:andykimpe/curl -y
	apt-get update
	apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
	add-apt-repository -y "deb [arch=amd64,arm64,ppc64el] https://mirrors.nxthost.com/mariadb/repo/10.9/ubuntu/ $(lsb_release -cs) main"
	apt-get update
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
	wget -q -O- https://packages.sury.org/php/apt.gpg | apt-key add -
	wget -q -O- https://packages.sury.org/apache2/apt.gpg | apt-key add -
	apt-get update
fi
if [[ "$OS" = "Ubuntu" || "$OS" = "debian" ]]; then
	apt-get -y dist-upgrade
	apt-get -y install debhelper 
	apt-get -y install cdbs
	apt-get -y install lintian
	apt-get -y install build-essential
	apt-get -y install fakeroot
	apt-get -y install devscripts
	apt-get -y install dh-make
	apt-get -y build-dep php7.3
	apt-get -y install mariadb-server
	apt-get -y install curl
	apt-get -y install libxslt1-dev
	apt-get -y install libcurl3-gnutls
	apt-get -y install libgeoip-dev
	apt-get -y install python
	apt-get -y install e2fsprogs
	apt-get -y install wget
	apt-get -y install mcrypt
	apt-get -y install nscd
	apt-get -y install htop
	apt-get -y install zip
	apt-get -y install unzip
	apt-get -y install mc
	apt-get -y install python3-paramiko
	apt-get -y install python-paramiko
	if [[ "$VER" = "20.04" ]]; then
	wget -q -O /tmp/libpng12.deb "https://www.dropbox.com/s/qqz00uqtnx869yp/libpng12-0_1.2.54-1ubuntu1.1%2B1_ppa0_eoan_amd64.deb?dl=1"
	elif
	if [[ "$VER" = "18.04" ]]; then
	wget -q -O /tmp/libpng12.deb https://www.dropbox.com/s/u12csy63mmayii1/libpng12-0_1.2.54-1ubuntu1_amd64.deb?dl=1
	fi
	dpkg -i /tmp/libpng12.deb
	apt-get -yf install
	rm -f /tmp/libpng12.deb
elif [[ "$OS" = "CentOs" || "$OS" = "Centos Stream" ]]; then
	$PACKAGE_INSTALLER wget
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
	$PACKAGE_GROUPINSTALL "Fedora Packager" "Development Tools"
	$PACKAGE_SOURCEDOWNLOAD php73-php-7.3.33-3.remi.src
	rpm -i php73-php-7.3.33-3.remi.src.rpm
	$BUILDDEP /root/rpmbuild/SPECS/php.spec
	$BUILDDEP php73
	rm -rf php73-php-7.3.33-3.remi.src.rpm /root/rpmbuild/SPECS/php.spec /root/rpmbuild/SOURCES/php* /root/rpmbuild/SOURCES/10-opcache.ini ls /root/rpmbuild/SOURCES/20-oci8.ini /root/rpmbuild/SOURCES/macros.php /root/rpmbuild/SOURCES/opcache-default.blacklist
fi
