#!/bin/bash
# wget -qO- https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/phpbuild.sh | bash -s
echo -e "\nChecking that minimal requirements are ok"

# Ensure the OS is compatible with the launcher
if [ -f /etc/centos-release ]; then
    inst() {
       rpm -q "$1" &> /dev/null
    } 
    if (inst "centos-stream-repos"); then
    OS="CentOS-Stream"
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


echo "Detected : $OS  $VER  $ARCH"
if [[ "$OS" = "Ubuntu" && ("$VER" = "18.04" || "$VER" = "20.04" || "$VER" = "22.04" ) && "$ARCH" == "x86_64" ||
"$OS" = "debian" && ("$VER" = "10" || "$VER" = "11" ) && "$ARCH" == "x86_64" ]] ; then
    echo "Ok."
else
    echo "Sorry, this OS is not supported by Xtream UI."
    exit 1
fi
echo -e "\n-- Updating repositories and packages sources"
PACKAGE_INSTALLER="apt-get -yqq install"
PACKAGE_REMOVER="apt-get -yqq purge"
inst() {
   dpkg -l "$1" 2> /dev/null | grep '^ii' &> /dev/null
}
if [[ "$OS" = "Ubuntu" ]]; then
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
deb http://deb.debian.org/debian $(lsb_release -sc)-backports main
deb-src http://deb.debian.org/debian $(lsb_release -sc)-backports main
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
	apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
cat > /etc/apt/sources.list.d/mariadb.list <<EOF
deb [arch=amd64,arm64,ppc64el] https://mirrors.nxthost.com/mariadb/repo/10.9/debian/ $(lsb_release -cs) main
EOF
	apt-get update
fi
apt-get -y dist-upgrade
apt-get -y install debhelper cdbs lintian build-essential fakeroot devscripts dh-make wget
apt-get -y build-dep php7.4
apt-get -y install libmariadb-dev libmariadb-dev-compat libmariadbd-dev dbconfig-mysql
apt-get -y install autoconf automake build-essential cmake git-core libass-dev libfreetype6-dev \
libgnutls28-dev libmp3lame-dev libsdl2-dev libtool libva-dev libvdpau-dev libvorbis-dev \
libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev meson ninja-build pkg-config texinfo \
wget yasm zlib1g-dev libxvidcore-dev libunistring-dev nasm libx264-dev \
libx265-dev libnuma-dev libvpx-dev libfdk-aac-dev libopus-dev unzip librtmp-dev libtheora-dev \
libbz2-dev libgmp-dev libssl-dev unzip zip wget
apt-get -y install libdav1d-dev
apt-get -y install libaom-dev
cd
rm -rf /root/phpbuild
mkdir -p /root/phpbuild
cd /root/phpbuild
if [[ "$OS" = "Ubuntu" ]]; then
dist=Ubuntu-$(lsb_release -sc)
elif [[ "$OS" = "debian" ]]; then
dist=debian-$(lsb_release -sc)
fi
#wget https://github.com/amidevous/xtream-ui-ubuntu20.04/releases/download/start/main_xui_Ubuntu_18.04.tar.gz
#tar -xvf main_xui_Ubuntu_18.04.tar.gz
#rm -f main_xui_Ubuntu_18.04.tar.gz
#mkdir -p /home/xtreamcodes/iptv_xtream_codes
#cp -R iptv_xtream_codes/* /home/xtreamcodes/iptv_xtream_codes/
wget https://www.php.net/distributions/php-7.4.33.tar.gz
rm -rf php-7.4.33
tar -xf php-7.4.33.tar.gz
if [[ "$VER" = "22.04" || "$VER" = "11" ]]; then
wget "https://launchpad.net/~ondrej/+archive/ubuntu/php/+sourcefiles/php7.3/7.3.33-2+ubuntu22.04.1+deb.sury.org+1/php7.3_7.3.33-2+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz" -O debian.tar.xz
tar -xf debian.tar.xz
rm -f debian.tar.xz
cd php-7.4.33
patch -p1 < ../debian/patches/0060-Add-minimal-OpenSSL-3.0-patch.patch
else
cd php-7.4.33
fi
sed -i "s|/usr/bin/sed|sed|" /home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
sed -i "s|/usr/sbin/sed|sed|" /home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
sed -i "s|/bin/sed|sed|" /home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
sed -i "s|/sbin/sed|sed|" /home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
#if [[ "$VER" = "22.04" || "$VER" = "10" ]]; then
cd ..
wget https://download.savannah.gnu.org/releases/freetype/freetype-2.12.0.tar.xz
tar -xf freetype-2.12.0.tar.xz
cd freetype-2.12.0
./autogen.sh
./configure --enable-freetype-config --prefix=/home/xtreamcodes/iptv_xtream_codes/freetype2
make
$PACKAGE_INSTALLER checkinstall
$PACKAGE_REMOVER xtreamui-freetype2
mkdir -p /home/xtreamcodes/iptv_xtream_codes/freetype2/include
mkdir -p /home/xtreamcodes/iptv_xtream_codes/freetype2/share
mkdir -p /home/xtreamcodes/iptv_xtream_codes/freetype2/include/freetype2/freetype
mkdir -p /home/xtreamcodes/iptv_xtream_codes/freetype2/share/man
mkdir -p /home/xtreamcodes/iptv_xtream_codes/freetype2/lib/
checkinstall \
    --pkgsource="" \
    --pkglicense="GPL3" \
    --deldesc=no \
    --nodoc \
    --maintainer="amidevous@gmail.com" \
    --pkgarch=$(dpkg --print-architecture) \
    --pkgversion="2.12" \
    --pkgrelease=1.$dist \
    --pkgname=xtreamui-freetype2 \
    --requires="" -y
echo "pause 60 seconde checkinstall xtreamui-freetype2"
sleep 60
cd ..
cd php-7.4.33
'./configure'  '--prefix=/home/xtreamcodes/iptv_xtream_codes/php' '--with-zlib-dir' '--with-freetype-dir=/home/xtreamcodes/iptv_xtream_codes/freetype2' '--enable-mbstring' '--enable-calendar' '--with-curl' '--with-gd' '--disable-rpath' '--enable-inline-optimization' '--with-bz2' '--with-zlib' '--enable-sockets' '--enable-sysvsem' '--enable-sysvshm' '--enable-pcntl' '--enable-mbregex' '--enable-exif' '--enable-bcmath' '--with-mhash' '--enable-zip' '--with-pcre-regex' '--with-pdo-mysql=mysqlnd' '--with-mysqli=mysqlnd' '--with-openssl' '--with-fpm-user=xtreamcodes' '--with-fpm-group=xtreamcodes' '--with-libdir=/lib/x86_64-linux-gnu' '--with-gettext' '--with-xmlrpc' '--with-xsl' '--enable-opcache' '--enable-fpm' '--enable-libxml' '--enable-static' '--disable-shared' '--with-jpeg-dir' '--enable-gd-jis-conv' '--with-webp-dir' '--with-xpm-dir'
#else
#./configure $(/home/xtreamcodes/iptv_xtream_codes/php/bin/php-config --configure-options)
#fi
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
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20180731/
$PACKAGE_INSTALLER checkinstall
$PACKAGE_REMOVER xtreamui-php
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/bin
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/etc/php-fpm.d
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/include
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/sbin
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/var
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/lib/php/Archive
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/lib/php/Console
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/lib/php/OS
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/lib/php/PEAR
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/lib/php/Structures
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/lib/php/XML
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/lib/php/build
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/lib/php/data
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/lib/php/doc
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/lib/php/test
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20180731/
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20180731
checkinstall \
    --pkgsource="" \
    --pkglicense="GPL3" \
    --deldesc=no \
    --nodoc \
    --maintainer="amidevous@gmail.com" \
    --pkgarch=$(dpkg --print-architecture) \
    --pkgversion="7.4.33" \
    --pkgrelease=1.$dist \
    --pkgname=xtreamui-php \
    --requires="xtreamui-freetype2" -y
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20180731/
echo "pause 60 seconde checkinstall xtreamui-php"
sleep 60
cd ..
rm -rf debian
$PACKAGE_INSTALLER libmcrypt-dev mcrypt
wget https://pecl.php.net/get/mcrypt-1.0.5.tgz
tar -xvf mcrypt-1.0.5.tgz
cd mcrypt-1.0.5
/home/xtreamcodes/iptv_xtream_codes/php/bin/phpize
./configure --with-php-config=/home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
make -j8
$PACKAGE_INSTALLER checkinstall
$PACKAGE_REMOVER xtreamui-php-mcrypt
checkinstall \
    --pkgsource="" \
    --pkglicense="GPL3" \
    --deldesc=no \
    --nodoc \
    --maintainer="amidevous@gmail.com" \
    --pkgarch=$(dpkg --print-architecture) \
    --pkgversion="1.0.5" \
    --pkgrelease=1.$dist \
    --pkgname=xtreamui-php-mcrypt \
    --requires="xtreamui-php" -y
echo "pause 60 seconde checkinstall xtreamui-php-mcrypt"
sleep 60
cd ..
$PACKAGE_INSTALLER libgeoip-dev
wget https://pecl.php.net/get/geoip-1.1.1.tgz
tar -xf geoip-1.1.1.tgz
cd geoip-1.1.1
/home/xtreamcodes/iptv_xtream_codes/php/bin/phpize
./configure --with-php-config=/home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
make -j8
$PACKAGE_REMOVER xtreamui-php-geoip
checkinstall \
    --pkgsource="" \
    --pkglicense="GPL3" \
    --deldesc=no \
    --nodoc \
    --maintainer="amidevous@gmail.com" \
    --pkgarch=$(dpkg --print-architecture) \
    --pkgversion="1.1.1" \
    --pkgrelease=1.$dist \
    --pkgname=xtreamui-php-geoip \
    --requires="xtreamui-php" -y
echo "pause 60 seconde checkinstall xtreamui-php-geoip"
sleep 60
cd ..
if [[ "$OS" = "Ubuntu" ]]; then
dist=Ubuntu-$(lsb_release -sc)
elif [[ "$OS" = "debian" ]]; then
dist=debian-$(lsb_release -sc)
fi
mkdir -p xtreamui-php-ioncube-loader_12.0.5-1.$dist_amd64
cd xtreamui-php-ioncube-loader_12.0.5-1.$dist_amd64
mkdir -p home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20190902/
mkdir -p DEBIAN
echo "2.0" > debian-binary
touch DEBIAN/conffiles
cat > DEBIAN/control <<EOF
Package: xtreamui-php-ioncube-loader
Priority: extra
Section: checkinstall
Installed-Size: 70176
Maintainer: amidevous@gmail.com
Architecture: amd64
Version: 12.0.5-1.$dist
Depends: xtreamui-php
Provides: xtreamui-php-ioncube-loader
Description: Package created with checkinstall 1.6.2
EOF
wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar -xvf ioncube_loaders_lin_x86-64.tar.gz
rm -f ioncube_loaders_lin_x86-64.tar.gz
cp ioncube/ioncube_loader_lin_7.4.so home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20190902/
rm -rf ioncube
cd ..
dpkg --build xtreamui-php-ioncube-loader_12.0.5-1.$dist_amd64
mkdir -p xtreamui-php_7.4.33-2.$dist_amd64
cp php-7.4.33/xtreamui-php_7.4.33-1.$dist_amd64.deb xtreamui-php_7.4.33-2.$dist_amd64/
cd xtreamui-php_7.4.33-2.$dist_amd64
ar xv xtreamui-php_7.4.33-1.$dist_amd64.deb
rm -f xtreamui-php_7.4.33-1.$dist_amd64.deb
tar-xvf data.tar.xz
rm -f data.tar.xz
mkdir DEBIAN
cd DEBIAN
tar -xvf ../control.tar.xz
cd ../
rm -rf control.tar.xz
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/php.ini -O home/xtreamcodes/iptv_xtream_codes/php/lib/php.ini
sed -i 's|7.4.33-1|7.4.33-2|' "DEBIAN/control"
sed -i 's|xtreamui-freetype2|xtreamui-freetype2, xtreamui-php-geoip, xtreamui-php-ioncube-loader, xtreamui-php-mcrypt|' "DEBIAN/control"
cd ..
dpkg --build xtreamui-php_7.4.33-2.$dist_amd64
find ./ -name '*.deb'
echo "finish"

