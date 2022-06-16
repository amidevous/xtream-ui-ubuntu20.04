#!/bin/bash
echo -e "\nChecking that minimal requirements are ok"
# Ensure the OS is compatible with the launcher
if [ -f /etc/centos-release ]; then
    OS="CentOs"
    VERFULL=$(sed 's/^.*release //;s/ (Fin.*$//' /etc/centos-release)
    VER=${VERFULL:0:1} # return 6, 7 or 8
elif [ -f /etc/fedora-release ]; then
    OS="Fedora"
    VERFULL=$(sed 's/^.*release //;s/ (Fin.*$//' /etc/fedora-release)
    VER=${VERFULL:0:2} # return 34 or 35
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
echo "Detected : $OS  $VER  $ARCH"
if [[ "$OS" = "CentOs" && ("$VER" = "7" || "$VER" = "8" ) && "$ARCH" == "x86_64" ||
"$OS" = "Fedora" && ("$VER" = "34" || "$VER" = "35" ) && "$ARCH" == "x86_64" ||
"$OS" = "Ubuntu" && ("$VER" = "18.04" || "$VER" = "20.04" || "$VER" = "22.04" ) && "$ARCH" == "x86_64" ||
"$OS" = "debian" && ("$VER" = "10" || "$VER" = "11" ) && "$ARCH" == "x86_64" ]] ; then
    echo "Ok."
else
    echo "Sorry, this OS is not supported by Xtream UI."
    exit 1
fi
if [[ "$OS" = "CentOs" || "$OS" = "Fedora" ]]; then
	if [[ "$OS" = "CentOs" ]]; then
		#EPEL Repo Install
		yum -y install epel-release
		yum -y install https://rpms.remirepo.net/enterprise/remi-release-"$VER".rpm
		#To fix some problems of compatibility use of mirror centos.org to all users
		#Replace all mirrors by base repos to avoid any problems.
		sed -i 's|mirrorlist=http://mirrorlist.centos.org|#mirrorlist=http://mirrorlist.centos.org|' "/etc/yum.repos.d/CentOS-Base.repo"
		sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://mirror.centos.org|' "/etc/yum.repos.d/CentOS-Base.repo"

		#check if the machine and on openvz
		if [ -f "/etc/yum.repos.d/vz.repo" ]; then
			sed -i "s|mirrorlist=http://vzdownload.swsoft.com/download/mirrors/centos-$VER|baseurl=http://vzdownload.swsoft.com/ez/packages/centos/$VER/$ARCH/os/|" "/etc/yum.repos.d/vz.repo"
			sed -i "s|mirrorlist=http://vzdownload.swsoft.com/download/mirrors/updates-released-ce$VER|baseurl=http://vzdownload.swsoft.com/ez/packages/centos/$VER/$ARCH/updates/|" "/etc/yum.repos.d/vz.repo"
		fi
	elif [[ "$OS" = "Fedora" ]]; then
		yum -y install https://rpms.remirepo.net/fedora/remi-release-"$VER".rpm
	fi
	#disable deposits that could result in installation errors
	disablerepo() {
	if [ -f "/etc/yum.repos.d/$1.repo" ]; then
            sed -i 's/enabled=1/enabled=0/g' "/etc/yum.repos.d/$1.repo"
        fi
	}
	disablerepo "elrepo"
	disablerepo "epel-testing"
	disablerepo "rpmforge"
	disablerepo "rpmfusion-free-updates"
	disablerepo "rpmfusion-free-updates-testing"
	disablerepo "remi"
	disablerepo "remi-php55"
	disablerepo "remi-php56"
	disablerepo "remi-test"
	disablerepo "remi-safe"
	disablerepo "remi-php73"
	disablerepo "remi-php72"
	disablerepo "remi-php71"
	disablerepo "remi-php70"
	disablerepo "remi-php54"
	disablerepo "remi-glpi94"
	disablerepo "remi-glpi93"
	disablerepo "remi-glpi92"
	disablerepo "remi-glpi91"
	disablerepo "remi-php80"
	disablerepo "remi-php81"
	disablerepo "remi-modular"
	yum-config-manager --enable remi
	yum-config-manager --enable remi-safe
	yum-config-manager --enable remi-php73
	yum-config-manager --enable epel
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
	# We need to disable SELinux...
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	setenforce 0
	# Stop conflicting services and iptables to ensure all services will work
	if  [[ "$VER" = "7" || "$VER" = "8" || "$VER" = "31" || "$VER" = "32" ]]; then
		systemctl  stop sendmail.service
		systemctl  disabble sendmail.service
	else
		service sendmail stop
		chkconfig sendmail off
	fi
	# disable firewall
	yum -y install iptables
	yum -y install firewalld
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
	echo -ne "\nUpdating Aptitude Repos: " >/dev/tty
	mkdir -p "/etc/apt/sources.list.d.save"
	cp -R "/etc/apt/sources.list.d/*" "/etc/apt/sources.list.d.save" &> /dev/null
	rm -rf "/etc/apt/sources.list/*"
	cp "/etc/apt/sources.list" "/etc/apt/sources.list.save"
	cat > /etc/apt/sources.list <<EOF
#Depots main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt $(lsb_release -sc) main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt $(lsb_release -sc)-security main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt $(lsb_release -sc)-updates main restricted universe multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt $(lsb_release -sc) main restricted universe multiverse 
deb-src mirror://mirrors.ubuntu.com/mirrors.txt $(lsb_release -sc)-updates main restricted universe multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt $(lsb_release -sc)-security main restricted universe multiverse
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
deb http://deb.debian.org/debian/ $(lsb_release -sc)/updates main contrib non-free
deb-src http://deb.debian.org/debian/ $(lsb_release -sc)/updates main contrib non-free
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
	apt-get -y install debhelper cdbs lintian build-essential fakeroot devscripts dh-make
	apt-get -y build-dep php7.3
elif [[ "$OS" = "CentOs" || "$OS" = "Fedora" ]]; then
	yum -y groupinstall "Fedora Packager" "Development Tools"
	yum -y install yum-utils
	yum -y install dnf-utils
	yum -y install dnf
	yum-builddep -y php73
	yumdownloader --source php73-php
	yum-builddep -y php73-php-7.3.*.remi.src.rpm
	rm -f php73-php-7.3.*.remi.src.rpm
#	yum -y install libxml2-devel xz-devel zlib-devel openssl-devel bzip2-devel
#	yum -y install curl-devel
#	yum -y install libcurl-devel
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
if [[ "$VER" = "22.04" || "$VER" = "8" || "$VER" = "34" || "$VER" = "35" ]]; then
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
apt-get -y install libmcrypt-dev mcrypt
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
apt-get -y install libgeoip-dev
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
