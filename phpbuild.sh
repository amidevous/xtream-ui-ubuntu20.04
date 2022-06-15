#!/bin/bash
DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND=noninteractive
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
if [[ "$OS" = "Ubuntu" && ("$VER" = "18.04" || "$VER" = "20.04" || "$VER" = "22.04" ) && "$ARCH" == "x86_64" ||
"$OS" = "debian" && ("$VER" = "9" || "$VER" = "10" || "$VER" = "11" ) && "$ARCH" == "x86_64" || ]] ; then
    echo "Ok."
else
    echo "Sorry, this OS is not supported by Xtream UI."
    exit 1
fi
if [[ "$OS" = "Ubuntu" ]]; then 
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
    # Update the enabled Aptitude repositories
    echo -ne "Updating Aptitude Repos: " >/dev/tty
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
	cat > /etc/apt/sources.list/php.list <<EOF
	deb https://packages.sury.org/php/ $(lsb_release -sc) main
	deb-src https://packages.sury.org/php/ $(lsb_release -sc) main
	EOF
	cat > /etc/apt/sources.list/apache2.list <<EOF
	deb https://packages.sury.org/apache2/ $(lsb_release -sc) main
	deb-src https://packages.sury.org/apache2/ $(lsb_release -sc) main
	EOF
	wget -q -O- https://packages.sury.org/php/apt.gpg | apt-key add -
	wget -q -O- https://packages.sury.org/apache2/apt.gpg | apt-key add -
	apt-get update
fi
apt-get update
apt-get -y dist-upgrade
apt-get -y install debhelper cdbs lintian build-essential fakeroot devscripts dh-make
mkdir /root/phpbuild
cd /root/phpbuild
wget https://github.com/amidevous/xtream-ui-ubuntu20.04/releases/download/start/main_xui_Ubuntu_18.04.tar.gz
tar -xvf main_xui_Ubuntu_18.04.tar.gz
rm -f main_xui_Ubuntu_18.04.tar.gz
mkdir -p /home/xtreamcodes/iptv_xtream_codes
cp -R iptv_xtream_codes/* /home/xtreamcodes/iptv_xtream_codes/
apt-get -y build-dep php7.3
wget https://www.php.net/distributions/php-7.3.33.tar.gz
rm -rf php-7.3.33
tar -xvf php-7.3.33.tar.gz
if [[ "$VER" = "22.04" ]]; then
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
make -j8
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
cd ..
rm -rf php* debian
apt-get -y install libmcrypt-dev mcrypt
wget https://pecl.php.net/get/mcrypt-1.0.5.tgz
tar -xvf mcrypt-1.0.5.tgz
cd mcrypt-1.0.5
/home/xtreamcodes/iptv_xtream_codes/php/bin/phpize
./configure --with-php-config=/home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
make -j8
make install
cd ..
rm -f mcrypt*
apt-get -y install libgeoip-dev
wget https://pecl.php.net/get/geoip-1.1.1.tgz
tar -xvf geoip-1.1.1.tgz
cd geoip-1.1.1
/home/xtreamcodes/iptv_xtream_codes/php/bin/phpize
./configure --with-php-config=/home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
make -j8
make install
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
