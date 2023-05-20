#!/bin/bash
# wget --no-check-certificate -qO- https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/phpbuild.sh | bash -s
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
"$OS" = "debian" && ("$VER" = "10" || "$VER" = "11" ) && "$ARCH" == "x86_64" ||
"$OS" = "Fedora" && ("$VER" = "37" || "$VER" = "38" ) && "$ARCH" == "x86_64" ]] ; then
    echo "Ok."
else
    echo "Sorry, this OS is not supported by Xtream UI."
    exit 1
fi
if [[ "$OS" = "Ubuntu" || "$OS" = "debian" ]] ; then
echo -e "\n-- Updating repositories and packages sources"
PACKAGE_INSTALLER="apt-get -y install"
PACKAGE_REMOVER="apt-get -y purge"
inst() {
   dpkg -l "$1" 2> /dev/null | grep '^ii' &> /dev/null
}
elif [[ "$OS" = "CentOS-Stream" || "$OS" = "Fedora" ]] ; then
PACKAGE_INSTALLER="dnf -y install"
PACKAGE_REMOVER="dnf -y remove"
inst() {
       rpm -q "$1" &> /dev/null
    }
fi
if [[ "$OS" = "CentOS-Stream" || "$OS" = "Fedora" ]] ; then
$PACKAGE_INSTALLER libX11-devel
$PACKAGE_INSTALLER X11-devel
$PACKAGE_INSTALLER libpng-devel
$PACKAGE_INSTALLER zlib-devel
$PACKAGE_INSTALLER bzip2-devel
$PACKAGE_INSTALLER gcc
$PACKAGE_INSTALLER libxml2-devel
$PACKAGE_INSTALLER libpng-devel
$PACKAGE_INSTALLER bzip2-devel
dnf groupinstall "Development Tools" "Development Libraries"
$PACKAGE_INSTALLER gnupg2
$PACKAGE_INSTALLER gnupg
$PACKAGE_INSTALLER bzip2-devel
$PACKAGE_INSTALLER curl-devel
$PACKAGE_INSTALLER libcurl-devel
$PACKAGE_INSTALLER curl
$PACKAGE_INSTALLER httpd
$PACKAGE_INSTALLER httpd-devel
$PACKAGE_INSTALLER pam-devel
$PACKAGE_INSTALLER pam
$PACKAGE_INSTALLER nginx
$PACKAGE_INSTALLER nginx-devel
$PACKAGE_INSTALLER libstdc++-devel
$PACKAGE_INSTALLER openssl-devel
$PACKAGE_INSTALLER sqlite-devel
$PACKAGE_INSTALLER zlib-devel
$PACKAGE_INSTALLER smtpdaemon
$PACKAGE_INSTALLER libedit-devel
$PACKAGE_INSTALLER pcre-devel
$PACKAGE_INSTALLER pcre2-devel
$PACKAGE_INSTALLER pcre3-devel
$PACKAGE_INSTALLER libxcrypt-devel
$PACKAGE_INSTALLER xcrypt-devel
$PACKAGE_INSTALLER perl-interpreter
$PACKAGE_INSTALLER autoconf
$PACKAGE_INSTALLER automake
$PACKAGE_INSTALLER make
$PACKAGE_INSTALLER gcc
$PACKAGE_INSTALLER gcc-c++
$PACKAGE_INSTALLER libtool
$PACKAGE_INSTALLER libtool-ltdl-devel
$PACKAGE_INSTALLER systemtap-sdt-devel
$PACKAGE_INSTALLER tzdata
$PACKAGE_INSTALLER procps
$PACKAGE_INSTALLER procps-ng
$PACKAGE_INSTALLER libacl-devel
$PACKAGE_INSTALLER systemd-devel
$PACKAGE_INSTALLER krb5-devel
$PACKAGE_INSTALLER libc-client-devel
$PACKAGE_INSTALLER cyrus-sasl-devel
$PACKAGE_INSTALLER openldap-devel
$PACKAGE_INSTALLER libpq-devel
$PACKAGE_INSTALLER unixODBC-devel
$PACKAGE_INSTALLER firebird-devel
$PACKAGE_INSTALLER net-snmp-devel
$PACKAGE_INSTALLER oniguruma-devel
$PACKAGE_INSTALLER gd-devel
$PACKAGE_INSTALLER gmp-devel
$PACKAGE_INSTALLER libdb-devel
$PACKAGE_INSTALLER tokyocabinet-devel
$PACKAGE_INSTALLER lmdb-devel
$PACKAGE_INSTALLER qdbm-devel
$PACKAGE_INSTALLER libtidy-devel
$PACKAGE_INSTALLER freetds-devel
$PACKAGE_INSTALLER aspell-devel
$PACKAGE_INSTALLER libicu-devel
$PACKAGE_INSTALLER enchant-devel
$PACKAGE_INSTALLER libenchant-devel
$PACKAGE_INSTALLER libsodium-devel
$PACKAGE_INSTALLER sodium-devel
$PACKAGE_INSTALLER libffi-devel
$PACKAGE_INSTALLER ffi-devel
$PACKAGE_INSTALLER libxslt-devel
$PACKAGE_INSTALLER xslt-devel
$PACKAGE_INSTALLER yasm
$PACKAGE_INSTALLER nasm
$PACKAGE_INSTALLER gnutls-devel
$PACKAGE_INSTALLER libass-devel
$PACKAGE_INSTALLER ass-devel
$PACKAGE_INSTALLER fdk-aac-free-devel
$PACKAGE_INSTALLER lame-devel
$PACKAGE_INSTALLER opus-devel
$PACKAGE_INSTALLER libopus-devel
if [[ "$OS" = "Fedora" ]]; then
dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
elif [[ "$OS" = "CentOS-Stream" ]]; then
dnf -y install --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm
dnf -y install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
elif [[ "$OS" = "CentOS" ]]; then
dnf -y install --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm
dnf -y install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
fi
$PACKAGE_INSTALLER librtmp-devel
$PACKAGE_INSTALLER librtmp
$PACKAGE_INSTALLER rtmp-devel
$PACKAGE_INSTALLER rtmp
$PACKAGE_INSTALLER rtmpdump
fi
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
apt-get update
apt-get -y install debhelper cdbs lintian build-essential fakeroot devscripts dh-make ca-certificates gpg reprepro
cat > /etc/apt/sources.list.d/php.list <<EOF
deb https://packages.sury.org/php/ $(lsb_release -sc) main
deb-src https://packages.sury.org/php/ $(lsb_release -sc) main
EOF
cat > /etc/apt/sources.list.d/apache2.list <<EOF
deb https://packages.sury.org/apache2/ $(lsb_release -sc) main
deb-src https://packages.sury.org/apache2/ $(lsb_release -sc) main
EOF
	wget --no-check-certificate -qO- https://packages.sury.org/php/apt.gpg | apt-key add -
	wget --no-check-certificate -qO- https://packages.sury.org/apache2/apt.gpg | apt-key add -
	apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
cat > /etc/apt/sources.list.d/mariadb.list <<EOF
deb [arch=amd64,arm64,ppc64el] https://mirrors.nxthost.com/mariadb/repo/10.9/debian/ $(lsb_release -cs) main
EOF
	apt-get update	
fi
if [[ "$OS" = "Ubuntu" || "$OS" = "debian" ]] ; then
apt-get -y dist-upgrade
apt-get -y install debhelper cdbs lintian build-essential fakeroot devscripts dh-make wget
apt-get -y build-dep php7.4
apt-get -y install libmariadb-dev libmariadb-dev-compat libmariadbd-dev dbconfig-mysql
apt-get -y install autoconf automake build-essential cmake git-core libass-dev libfreetype6-dev \
libgnutls28-dev libmp3lame-dev libsdl2-dev libtool libva-dev libvdpau-dev libvorbis-dev \
libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev meson ninja-build pkg-config texinfo \
yasm zlib1g-dev libxvidcore-dev libunistring-dev nasm libx264-dev \
libx265-dev libnuma-dev libvpx-dev libfdk-aac-dev libopus-dev unzip librtmp-dev libtheora-dev \
libbz2-dev libgmp-dev libssl-dev unzip zip
apt-get -y install libdav1d-dev
apt-get -y install libaom-dev
apt-get -y install reprepro
apt-get -y install subversion
apt-get -y install zstd
fi
cd
rm -rf /root/phpbuild
mkdir -p /root/phpbuild
cd /root/phpbuild
wget --no-check-certificate https://www.php.net/distributions/php-8.1.19.tar.gz
rm -rf php-8.1.19
tar -xf php-8.1.19.tar.gz
#if [[ "$VER" = "22.04" || "$VER" = "11" ]]; then
#wget --no-check-certificate "https://launchpad.net/~ondrej/+archive/ubuntu/php/+sourcefiles/php7.3/7.3.33-2+ubuntu22.04.1+deb.sury.org+1/php7.3_7.3.33-2+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz" -O debian.tar.xz
#tar -xf debian.tar.xz
#rm -f debian.tar.xz
#cd php-8.1.19
#patch -p1 < ../debian/patches/0060-Add-minimal-OpenSSL-3.0-patch.patch
#else
cd php-8.1.19
#fi
cd ..
if [[ "$OS" = "debian"  ]] ; then
rm -f "/etc/apt/sources.list.d/alvistack.list"
echo "deb http://download.opensuse.org/repositories/home:/alvistack/Debian_${VER}/ /" | tee "/etc/apt/sources.list.d/alvistack.list"
wget --no-check-certificate -qO- "http://download.opensuse.org/repositories/home:/alvistack/Debian_${VER}/Release.key" | gpg --dearmor | tee /etc/apt/trusted.gpg.d/alvistack.gpg > /dev/null
fi
$PACKAGE_UPDATER
$PACKAGE_INSTALLER podman
wget --no-check-certificate https://download.savannah.gnu.org/releases/freetype/freetype-2.12.0.tar.xz
tar -xf freetype-2.12.0.tar.xz
cd freetype-2.12.0
./autogen.sh
./configure --enable-freetype-config --prefix=/home/xtreamcodes/iptv_xtream_codes/freetype2
make -j$(nproc --all)
make install
cd ../php-8.1.19
'./configure'  '--prefix=/home/xtreamcodes/iptv_xtream_codes/php' '--with-zlib-dir' '--with-freetype-dir=/home/xtreamcodes/iptv_xtream_codes/freetype2' '--enable-mbstring' '--enable-calendar' '--with-curl' '--with-gd' '--disable-rpath' '--enable-inline-optimization' '--with-bz2' '--with-zlib' '--enable-sockets' '--enable-sysvsem' '--enable-sysvshm' '--enable-pcntl' '--enable-mbregex' '--enable-exif' '--enable-bcmath' '--with-mhash' '--enable-zip' '--with-pcre-regex' '--with-pdo-mysql=mysqlnd' '--with-mysqli=mysqlnd' '--with-openssl' '--with-fpm-user=xtreamcodes' '--with-fpm-group=xtreamcodes' '--with-libdir=/lib/x86_64-linux-gnu' '--with-gettext' '--with-xmlrpc' '--with-xsl' '--enable-opcache' '--enable-fpm' '--enable-libxml' '--enable-static' '--disable-shared' '--with-jpeg-dir' '--enable-gd-jis-conv' '--with-webp-dir' '--with-xpm-dir'
make -j$(nproc --all)
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/
make install
cd ..
$PACKAGE_INSTALLER libmcrypt-dev
$PACKAGE_INSTALLER mcrypt-dev
$PACKAGE_INSTALLER libmcrypt-devel
$PACKAGE_INSTALLER mcrypt-devel
$PACKAGE_INSTALLER mcrypt
wget --no-check-certificate -O mcrypt-1.0.5.tgz https://pecl.php.net/get/mcrypt-1.0.5.tgz
tar -xvf mcrypt-1.0.5.tgz
cd mcrypt-1.0.5
/home/xtreamcodes/iptv_xtream_codes/php/bin/phpize
./configure --with-php-config=/home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
make -j$(nproc --all)
make install
cd ..
$PACKAGE_INSTALLER libgeoip-dev
$PACKAGE_INSTALLER libgeoip-devel
$PACKAGE_INSTALLER geoip-devel
wget --no-check-certificate -O geoip-1.1.1.tgz https://pecl.php.net/get/geoip-1.1.1.tgz
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/geoip-php81.patch -O geoip-php81.patch
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/geoip-php8.patch -O geoip-php8.patch
tar -xf geoip-1.1.1.tgz
cd geoip-1.1.1
patch -p1 < ../geoip-php8.patch
patch -p1 < ../geoip-php81.patch
/home/xtreamcodes/iptv_xtream_codes/php/bin/phpize
./configure --with-php-config=/home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
make -j$(nproc --all)
make install
cd ..
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20210902/
wget --no-check-certificate -O ioncube_loaders_lin_x86-64.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar -xvf ioncube_loaders_lin_x86-64.tar.gz
rm -f ioncube_loaders_lin_x86-64.tar.gz
cp ioncube/ioncube_loader_lin_7.4.so /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20210902/
rm -rf ioncube
cd ..
wget --no-check-certificate https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/php.ini -O /home/xtreamcodes/iptv_xtream_codes/php/lib/php.ini
svn --non-interactive --trust-server-cert checkout https://svn.code.sf.net/p/xavs/code/trunk xavs-code
cd xavs-code
./configure --prefix="/root/ffmpeg_build" --libdir=/root/ffmpeg_build/lib64
make -j$(nproc --all)
make install
cd ..
wget --no-check-certificate -O ffmpeg-5.1.2.tar.bz2 https://ffmpeg.org/releases/ffmpeg-5.1.2.tar.bz2
tar -xvf ffmpeg-5.1.2.tar.bz2
cd ffmpeg-5.1.2
./configure \
  --prefix="/root/ffmpeg_build" \
  --bindir="/home/xtreamcodes/iptv_xtream_codes/bin/" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I/root/ffmpeg_build/include" \
  --extra-ldflags="-L/root/ffmpeg_build/lib64" \
  --extra-version=Xtream-Codes \
  --disable-debug \
  --disable-shared \
  --extra-libs=-lpthread \
  --extra-libs=-lm \
  --enable-gpl \
  --enable-libfdk_aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree \
  --disable-ffplay \
  --disable-doc \
  --enable-pthreads \
  --enable-postproc \
  --enable-libass \
  --enable-gray \
  --enable-runtime-cpudetect \
  --enable-gnutls \
  --enable-librtmp \
  --enable-libtheora \
  --enable-version3 \
  --enable-libvorbis \
  --enable-libxvid \
  --enable-static \
  --enable-bzlib \
  --enable-fontconfig \
  --enable-zlib \
  --enable-libxavs \
  --extra-libs='-lstdc++ -lrtmp -lgmp -lssl -lcrypto -lz -ldl -lm -lpthread -lunistring'
  make -j$(nproc --all)
make install
cd ..
echo "finish"

