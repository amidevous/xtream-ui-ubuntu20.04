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
	find /etc/yum.repos.d -name '*.rpmnew' -exec rm -f {} \;
	find /etc/yum.repos.d -name '*.rpmsave' -exec rm -f {} \;
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
		enablerepo epel
	elif [ "$OS" = "Centos Stream" ]; then
		enablerepo baseos
		enablerepo appstream
		enablerepo extras
		enablerepo extras-common
		enablerepo epel
		enablerepo epel-modular
		dnf -y install wget
		wget https://copr.fedorainfracloud.org/coprs/andykimpe/Centos-Stream-Devel-php-build/repo/centos-stream-8/andykimpe-Centos-Stream-Devel-php-build-centos-stream-8.repo -O /etc/yum.repos.d/andykimpe-Centos-Stream-Devel-php-build-centos-stream-8.repo
	elif [ "$OS" = "Fedora" ]; then
		echo "fedora repo"
	fi
	enablerepo remi
	enablerepo remi-safe
	enablerepo remi-php73
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
	apt-get -y install debhelper cdbs lintian build-essential fakeroot devscripts dh-make wget
	apt-get -y build-dep php7.3
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
	$BUILDDEP -y /root/rpmbuild/SPECS/php.spec
	$BUILDDEP -y php73
	rm -rf php73-php-7.3.33-3.remi.src.rpm /root/rpmbuild/SPECS/php.spec /root/rpmbuild/SOURCES/php* /root/rpmbuild/SOURCES/10-opcache.ini ls /root/rpmbuild/SOURCES/20-oci8.ini /root/rpmbuild/SOURCES/macros.php /root/rpmbuild/SOURCES/opcache-default.blacklist
fi
echo "dep install pause 60 seconds"
sleep 60
mkdir -p /root/phpbuild
cd /root/phpbuild
wget https://github.com/amidevous/xtream-ui-ubuntu20.04/releases/download/start/main_xui_Ubuntu_18.04.tar.gz
tar -xvf main_xui_Ubuntu_18.04.tar.gz
rm -f main_xui_Ubuntu_18.04.tar.gz
mkdir -p /home/xtreamcodes/iptv_xtream_codes
cp -R iptv_xtream_codes/* /home/xtreamcodes/iptv_xtream_codes/
wget https://www.php.net/distributions/php-7.3.33.tar.gz
rm -rf php-7.3.33
tar -xvf php-7.3.33.tar.gz
echo "php download pause 60 seconds"
sleep 60
if [[ "$VER" = "22.04" || "$VER" = "8" || "$VER" = "34" || "$VER" = "35" || "$VER" = "36" ]]; then
wget "https://launchpad.net/~ondrej/+archive/ubuntu/php/+sourcefiles/php7.3/7.3.33-2+ubuntu22.04.1+deb.sury.org+1/php7.3_7.3.33-2+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz" -O debian.tar.xz
tar -xvf debian.tar.xz
rm -f debian.tar.xz
cd php-7.3.33
patch -p1 < ../debian/patches/0060-Add-minimal-OpenSSL-3.0-patch.patch
else
cd php-7.3.33
fi
sed -i "s|/usr/bin/sed|sed|" /home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
sed -i "s|/usr/sbin/sed|sed|" /home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
sed -i "s|/bin/sed|sed|" /home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
sed -i "s|/sbin/sed|sed|" /home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
./configure $(/home/xtreamcodes/iptv_xtream_codes/php/bin/php-config --configure-options)
echo "php configure pause 60 seconds"
sleep 60
make -j8
echo "php build pause 60 seconds"
sleep 60
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/GeoIP.dat
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/bin
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/etc/php-fpm.d
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/etc/php-fpm.conf.default
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/etc/pear.conf
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/include
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/sbin
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/var
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/Archive
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/Console
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/OS
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/PEAR
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/PEAR.php
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/Structures
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/System.php
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/XML
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/build
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/data
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/doc
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/pearcmd.php
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/peclcmd.php
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/test
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20180731/mcrypt.so
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20180731/opcache.a
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20180731/opcache.so
make install
echo "php install pause 60 seconds"
sleep 60
cd ..
rm -rf php* debian
if [[ "$OS" = "Ubuntu" || "$OS" = "debian" ]]; then
apt-get -y install libmcrypt-dev mcrypt
elif [[ "$OS" = "CentOs" || "$OS" = "Fedora" ]]; then
$PACKAGE_INSTALLER libmcrypt-devel mcrypt
fi
wget https://pecl.php.net/get/mcrypt-1.0.5.tgz
tar -xvf mcrypt-1.0.5.tgz
cd mcrypt-1.0.5
/home/xtreamcodes/iptv_xtream_codes/php/bin/phpize
echo "mcrypt phpize pause 60 seconds"
sleep 60
./configure --with-php-config=/home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
echo "mcrypt configure pause 60 seconds"
sleep 60
make -j8
echo "mcrypt build pause 60 seconds"
sleep 60
make install
echo "mcrypt install pause 60 seconds"
sleep 60
cd ..
rm -rf mcrypt*
if [[ "$OS" = "Ubuntu" || "$OS" = "debian" ]]; then
apt-get -y install libgeoip-dev
elif [[ "$OS" = "CentOs" || "$OS" = "Fedora" ]]; then
$PACKAGE_INSTALLER install GeoIP-devel
fi
wget https://pecl.php.net/get/geoip-1.1.1.tgz
tar -xvf geoip-1.1.1.tgz
cd geoip-1.1.1
/home/xtreamcodes/iptv_xtream_codes/php/bin/phpize
echo "geoip phpize pause 60 seconds"
sleep 60
./configure --with-php-config=/home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
echo "geoip configure pause 60 seconds"
sleep 60
make -j8
echo "geoip build pause 60 seconds"
sleep 60
make install
echo "geoip install pause 60 seconds"
sleep 60
cd ..
rm -rf geoip*
rm -rf iptv_xtream_codes/php/GeoIP.dat
rm -rf iptv_xtream_codes/php/bin
rm -rf iptv_xtream_codes/php/etc/php-fpm.d
rm -rf iptv_xtream_codes/php/etc/php-fpm.conf.default
rm -rf iptv_xtream_codes/php/etc/pear.conf
rm -rf iptv_xtream_codes/php/include
rm -rf iptv_xtream_codes/php/sbin
rm -rf iptv_xtream_codes/php/var
rm -rf iptv_xtream_codes/php/lib/php/Archive
rm -rf iptv_xtream_codes/php/lib/php/Console
rm -rf iptv_xtream_codes/php/lib/php/OS
rm -rf iptv_xtream_codes/php/lib/php/PEAR
rm -rf iptv_xtream_codes/php/lib/php/PEAR.php
rm -rf iptv_xtream_codes/php/lib/php/Structures
rm -rf iptv_xtream_codes/php/lib/php/System.php
rm -rf iptv_xtream_codes/php/lib/php/XML
rm -rf iptv_xtream_codes/php/lib/php/build
rm -rf iptv_xtream_codes/php/lib/php/data
rm -rf iptv_xtream_codes/php/lib/php/doc
rm -rf iptv_xtream_codes/php/lib/php/pearcmd.php
rm -rf iptv_xtream_codes/php/lib/php/peclcmd.php
rm -rf iptv_xtream_codes/php/lib/php/test
rm -rf iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20180731/mcrypt.so
rm -rf iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20180731/opcache.a
rm -rf iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20180731/opcache.so
cp -R /home/xtreamcodes/iptv_xtream_codes/php/* iptv_xtream_codes/php/
rm -f main_xui_"$OS"_"$VER".tar.gz
tar -cvf main_xui_"$OS"_"$VER".tar.gz iptv_xtream_codes/
echo "finish"
