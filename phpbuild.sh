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
cd
rm -rf /root/phpbuild
mkdir -p /root/phpbuild
cd /root/phpbuild
if [[ "$OS" = "Ubuntu" ]]; then
dist=Ubuntu-$(lsb_release -sc)
elif [[ "$OS" = "debian" ]]; then
dist=debian-$(lsb_release -sc)
fi
wget --no-check-certificate https://www.php.net/distributions/php-7.4.33.tar.gz
rm -rf php-7.4.33
tar -xf php-7.4.33.tar.gz
if [[ "$VER" = "22.04" || "$VER" = "11" ]]; then
wget --no-check-certificate "https://launchpad.net/~ondrej/+archive/ubuntu/php/+sourcefiles/php7.3/7.3.33-2+ubuntu22.04.1+deb.sury.org+1/php7.3_7.3.33-2+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz" -O debian.tar.xz
tar -xf debian.tar.xz
rm -f debian.tar.xz
cd php-7.4.33
patch -p1 < ../debian/patches/0060-Add-minimal-OpenSSL-3.0-patch.patch
else
cd php-7.4.33
fi
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
if [[ "$OS" = "debian" ]]; then
apt-get -y install debhelper cdbs lintian build-essential fakeroot devscripts dh-make dput docbook-to-man
wget --no-check-certificate -O checkinstall_1.6.2+git20170426.d24a630.orig.tar.xz http://archive.ubuntu.com/ubuntu/pool/universe/c/checkinstall/checkinstall_1.6.2+git20170426.d24a630.orig.tar.xz
wget --no-check-certificate -O checkinstall_1.6.2+git20170426.d24a630-2ubuntu2.debian.tar.xz http://archive.ubuntu.com/ubuntu/pool/universe/c/checkinstall/checkinstall_1.6.2+git20170426.d24a630-2ubuntu2.debian.tar.xz
tar -xvf checkinstall_1.6.2+git20170426.d24a630.orig.tar.xz
cd checkinstall
tar -xvf ../checkinstall_1.6.2+git20170426.d24a630-2ubuntu2.debian.tar.xz
debuild
cd ..
dpkg -i checkinstall*.deb
apt-get update
apt-get -yf install
inst() {
       dpkg-query --showformat='${Version}' --show "$1"
    }
else
$PACKAGE_INSTALLER checkinstall
fi
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
mkdir -p /root/package/$OS/
mkdir -p /root/package/$OS/conf
mkdir -p /root/package/$OS/incoming
cat > /root/package/$OS/conf/distributions <<EOF
Origin: local
Label: local
Suite: $(lsb_release -sc)
Codename: $(lsb_release -sc)
Version: $VER
Architectures: amd64
Components: main
Description: local repo for php build
EOF
mkdir -p /root/package/$OS/$VER/$ARCH/
cat > /root/package/$OS/$VER/$ARCH/repoadd <<EOF
#!/bin/bash
reprepro -Vb /root/package/$OS/ includedeb $(lsb_release -sc) \$1
cp /root/package/$OS/dists/$(lsb_release -sc)/Release /root/package/$OS/dists/$(lsb_release -sc)/InRelease
chown -R _apt:root /root/package/$OS/
chown -R _apt:root /root/package/$OS/*
chmod -R 700 /root/package/$OS/
chmod -R 700 /root/package/$OS/*
EOF
chmod +x /root/package/$OS/$VER/$ARCH/repoadd
cat > /etc/apt/sources.list.d/local.list <<EOF
deb [trusted=yes] file:/root/package/$OS $(lsb_release -sc) main
EOF
find ./ -name '*.deb' -exec /root/package/$OS/$VER/$ARCH/repoadd {} \;
cd ..
cd php-7.4.33
'./configure'  '--prefix=/home/xtreamcodes/iptv_xtream_codes/php' '--with-zlib-dir' '--with-freetype-dir=/home/xtreamcodes/iptv_xtream_codes/freetype2' '--enable-mbstring' '--enable-calendar' '--with-curl' '--with-gd' '--disable-rpath' '--enable-inline-optimization' '--with-bz2' '--with-zlib' '--enable-sockets' '--enable-sysvsem' '--enable-sysvshm' '--enable-pcntl' '--enable-mbregex' '--enable-exif' '--enable-bcmath' '--with-mhash' '--enable-zip' '--with-pcre-regex' '--with-pdo-mysql=mysqlnd' '--with-mysqli=mysqlnd' '--with-openssl' '--with-fpm-user=xtreamcodes' '--with-fpm-group=xtreamcodes' '--with-libdir=/lib/x86_64-linux-gnu' '--with-gettext' '--with-xmlrpc' '--with-xsl' '--enable-opcache' '--enable-fpm' '--enable-libxml' '--enable-static' '--disable-shared' '--with-jpeg-dir' '--enable-gd-jis-conv' '--with-webp-dir' '--with-xpm-dir'
make -j$(nproc --all)
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
find ./ -name '*.deb' -exec /root/package/$OS/$VER/$ARCH/repoadd {} \;
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20180731/
cd ..
$PACKAGE_INSTALLER libmcrypt-dev mcrypt
wget --no-check-certificate -O mcrypt-1.0.5.tgz https://pecl.php.net/get/mcrypt-1.0.5.tgz
tar -xvf mcrypt-1.0.5.tgz
cd mcrypt-1.0.5
/home/xtreamcodes/iptv_xtream_codes/php/bin/phpize
./configure --with-php-config=/home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
make -j$(nproc --all)
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
find ./ -name '*.deb' -exec /root/package/$OS/$VER/$ARCH/repoadd {} \;
cd ..
$PACKAGE_INSTALLER libgeoip-dev
wget --no-check-certificate -O geoip-1.1.1.tgz https://pecl.php.net/get/geoip-1.1.1.tgz
tar -xf geoip-1.1.1.tgz
cd geoip-1.1.1
/home/xtreamcodes/iptv_xtream_codes/php/bin/phpize
./configure --with-php-config=/home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
make -j$(nproc --all)
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
find ./ -name '*.deb' -exec /root/package/$OS/$VER/$ARCH/repoadd {} \;
cd ..
if [[ "$OS" = "Ubuntu" ]]; then
dist=Ubuntu-$(lsb_release -sc)
elif [[ "$OS" = "debian" ]]; then
dist=debian-$(lsb_release -sc)
fi
mkdir -p "xtreamui-php-ioncube-loader_12.0.5-1."$dist"_amd64"
cd "xtreamui-php-ioncube-loader_12.0.5-1."$dist"_amd64"
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
wget --no-check-certificate -O ioncube_loaders_lin_x86-64.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar -xvf ioncube_loaders_lin_x86-64.tar.gz
rm -f ioncube_loaders_lin_x86-64.tar.gz
cp ioncube/ioncube_loader_lin_7.4.so home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20190902/
rm -rf ioncube
cd ..
dpkg --build "xtreamui-php-ioncube-loader_12.0.5-1."$dist"_amd64"
/root/package/$OS/$VER/$ARCH/repoadd "xtreamui-php-ioncube-loader_12.0.5-1."$dist"_amd64.deb"
mkdir -p "xtreamui-php_7.4.33-2."$dist"_amd64"
cp "php-7.4.33/xtreamui-php_7.4.33-1."$dist"_amd64.deb" "xtreamui-php_7.4.33-2."$dist"_amd64/"
cd "xtreamui-php_7.4.33-2."$dist"_amd64"
ar xv "xtreamui-php_7.4.33-1."$dist"_amd64.deb"
rm -f "xtreamui-php_7.4.33-1."$dist"_amd64.deb"
if [ -f "data.tar.xz" ]; then
tar -xvf data.tar.xz
rm -f data.tar.xz
fi
if [ -f "data.tar.zst" ]; then
tar --use-compress-program=unzstd -xvf data.tar.zst
rm -f data.tar.zst
fi
mkdir DEBIAN
cd DEBIAN
if [ -f "../control.tar.xz" ]; then
tar -xvf ../control.tar.xz
cd ../
rm -rf control.tar.xz
fi
if [ -f "../control.tar.zst" ]; then
tar --use-compress-program=unzstd -xvf ../control.tar.zst
cd ../
rm -rf ../control.tar.zst
fi
wget --no-check-certificate https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/php.ini -O home/xtreamcodes/iptv_xtream_codes/php/lib/php.ini
sed -i 's|7.4.33-1|7.4.33-2|' "DEBIAN/control"
sed -i 's|xtreamui-freetype2|xtreamui-freetype2, xtreamui-php-geoip, xtreamui-php-ioncube-loader, xtreamui-php-mcrypt|' "DEBIAN/control"
cd ..
dpkg --build "xtreamui-php_7.4.33-2."$dist"_amd64"
/root/package/$OS/$VER/$ARCH/repoadd "xtreamui-php_7.4.33-2."$dist"_amd64.deb"
svn --non-interactive --trust-server-cert checkout https://svn.code.sf.net/p/xavs/code/trunk xavs-code
cd xavs-code
./configure --prefix="/root/ffmpeg_build" --libdir=/root/ffmpeg_build/lib64
make -j$(nproc --all)
checkinstall \
	--type=debian \
    --pkgsource=xavs \
    --pkglicense=GPL3 \
    --deldesc=no \
    --nodoc \
    --maintainer=amidevous@gmail.com \
    --pkgarch=amd64 \
    --pkgversion=$(date +%Y.%m) \
    --pkgrelease=1.$dist \
    --pkgname=xtreamui-xavs -y
find ./ -name '*.deb' -exec /root/package/$OS/$VER/$ARCH/repoadd {} \;
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
checkinstall \
    --type=debian \
    --pkgsource=ffmpeg \
    --pkglicense=GPL3 \
    --deldesc=no \
    --nodoc \
    --maintainer=amidevous@gmail.com \
    --pkgarch=amd64 \
    --pkgversion=5.1.2 \
    --pkgrelease=1.$dist \
    --exclude=/root/ffmpeg_build \
    --pkgname=xtreamui-ffmpeg -y
find ./ -name '*.deb' -exec /root/package/$OS/$VER/$ARCH/repoadd {} \;
cd ..
rm -f /etc/apt/sources.list.d/local.list
apt-get update
find /root/package -name '*.deb'
echo "finish"

