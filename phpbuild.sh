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
if [[ "$OS" = "Fedora" ]]; then
dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
elif [[ "$OS" = "CentOS-Stream" ]]; then
dnf -y install --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm
dnf -y install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
elif [[ "$OS" = "CentOS" ]]; then
dnf -y install --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm
dnf -y install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
fi
dnf group install --with-optional -y "C Development Tools and Libraries" "Development Tools"
$PACKAGE_INSTALLER libX11-devel
$PACKAGE_INSTALLER X11-devel
$PACKAGE_INSTALLER libpng-devel
$PACKAGE_INSTALLER zlib-devel
$PACKAGE_INSTALLER bzip2-devel
$PACKAGE_INSTALLER gcc
$PACKAGE_INSTALLER libxml2-devel
$PACKAGE_INSTALLER libpng-devel
$PACKAGE_INSTALLER bzip2-devel
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
$PACKAGE_REMOVER fdk-aac-free-devel
$PACKAGE_INSTALLER fdk-aac-devel
$PACKAGE_INSTALLER lame-devel
$PACKAGE_INSTALLER opus-devel
$PACKAGE_INSTALLER libopus-devel
$PACKAGE_INSTALLER librtmp-devel
$PACKAGE_INSTALLER librtmp
$PACKAGE_INSTALLER rtmp-devel
$PACKAGE_INSTALLER rtmp
$PACKAGE_INSTALLER rtmpdump
$PACKAGE_INSTALLER alsa-lib-devel
$PACKAGE_INSTALLER AMF-devel
$PACKAGE_INSTALLER faac-devel
$PACKAGE_INSTALLER flite-devel
$PACKAGE_INSTALLER fontconfig-devel
$PACKAGE_INSTALLER freetype-devel
$PACKAGE_INSTALLER fribidi-devel
$PACKAGE_INSTALLER frei0r-devel
$PACKAGE_INSTALLER game-music-emu-devel
$PACKAGE_INSTALLER gsm-devel
$PACKAGE_INSTALLER ilbc-devel
$PACKAGE_INSTALLER jack-audio-connection-kit-devel
$PACKAGE_INSTALLER ladspa-devel
$PACKAGE_INSTALLER libaom-devel
$PACKAGE_INSTALLER libdav1d-devel
$PACKAGE_INSTALLER libass-devel
$PACKAGE_INSTALLER libbluray-devel
$PACKAGE_INSTALLER libbs2b-devel
$PACKAGE_INSTALLER libcaca-devel
$PACKAGE_INSTALLER libcdio-paranoia-devel
$PACKAGE_INSTALLER libchromaprint-devel
$PACKAGE_INSTALLER libcrystalhd-devel
$PACKAGE_INSTALLER lensfun-devel
$PACKAGE_INSTALLER libavc1394-devel
$PACKAGE_INSTALLER libdc1394-devel
$PACKAGE_INSTALLER libiec61883-devel
$PACKAGE_INSTALLER libdrm-devel
$PACKAGE_INSTALLER libgcrypt-devel
$PACKAGE_INSTALLER libGL-devel
$PACKAGE_INSTALLER libmodplug-devel
$PACKAGE_INSTALLER libmysofa-devel
$PACKAGE_INSTALLER libopenmpt-devel
$PACKAGE_INSTALLER librsvg2-devel
$PACKAGE_INSTALLER libsmbclient-devel
$PACKAGE_INSTALLER libssh-devel
$PACKAGE_INSTALLER libtheora-devel
$PACKAGE_INSTALLER libv4l-devel
$PACKAGE_INSTALLER libva-devel
$PACKAGE_INSTALLER libvdpau-devel
$PACKAGE_INSTALLER libvorbis-devel
$PACKAGE_INSTALLER vapoursynth-devel
$PACKAGE_INSTALLER libvpx-devel
$PACKAGE_INSTALLER libmfx
$PACKAGE_INSTALLER mfx
$PACKAGE_INSTALLER libmfx-devel
$PACKAGE_INSTALLER mfx-devel
$PACKAGE_INSTALLER nasm
$PACKAGE_INSTALLER libwebp-devel
$PACKAGE_INSTALLER netcdf-devel
$PACKAGE_INSTALLER raspberrypi-vc-devel
$PACKAGE_INSTALLER nv-codec-headers
$PACKAGE_INSTALLER opencore-amr-devel vo-amrwbenc-devel
$PACKAGE_INSTALLER libomxil-bellagio-devel
$PACKAGE_INSTALLER libxcb-devel
$PACKAGE_INSTALLER libxml2-devel
$PACKAGE_INSTALLER lilv-devel lv2-devel
$PACKAGE_INSTALLER openal-soft-devel
$PACKAGE_INSTALLER opencl-headers ocl-icd-devel
$PACKAGE_INSTALLER openjpeg2-devel
$PACKAGE_INSTALLER pulseaudio-libs-devel
$PACKAGE_INSTALLER podman
$PACKAGE_INSTALLER rav1e-devel
$PACKAGE_INSTALLER rubberband-devel
$PACKAGE_INSTALLER SDL2-devel
$PACKAGE_INSTALLER snappy-devel
$PACKAGE_INSTALLER soxr-devel
$PACKAGE_INSTALLER speex-devel
$PACKAGE_INSTALLER srt-devel
$PACKAGE_INSTALLER srt-libs
$PACKAGE_INSTALLER srt-lib
$PACKAGE_INSTALLER srt
$PACKAGE_INSTALLER svt-av1-devel
$PACKAGE_INSTALLER tesseract-devel
$PACKAGE_INSTALLER texi2html
$PACKAGE_INSTALLER texinfo
$PACKAGE_INSTALLER twolame-devel
$PACKAGE_INSTALLER libvmaf-devel
$PACKAGE_INSTALLER wavpack-devel
$PACKAGE_INSTALLER vid.stab-devel
$PACKAGE_INSTALLER vulkan-loader-devel
$PACKAGE_INSTALLER libshaderc-devel
$PACKAGE_INSTALLER libshaderc
$PACKAGE_INSTALLER spirv-tools-libs
$PACKAGE_INSTALLER x264-devel
$PACKAGE_INSTALLER x264-libs
$PACKAGE_INSTALLER x264-lib
$PACKAGE_INSTALLER libx264-devel
$PACKAGE_INSTALLER x264
$PACKAGE_INSTALLER x265-devel
$PACKAGE_INSTALLER x265-libs
$PACKAGE_INSTALLER x265-lib
$PACKAGE_INSTALLER libx265-devel
$PACKAGE_INSTALLER x265
$PACKAGE_INSTALLER xvidcore-devel
$PACKAGE_INSTALLER libxvidcore-devel
$PACKAGE_INSTALLER xvid-devel
$PACKAGE_INSTALLER libxvid-devel
$PACKAGE_INSTALLER xvidcore
$PACKAGE_INSTALLER xvid
$PACKAGE_INSTALLER zimg-devel
$PACKAGE_INSTALLER zlib-devel
$PACKAGE_INSTALLER zeromq-devel
$PACKAGE_INSTALLER zvbi-devel
$PACKAGE_INSTALLER vmaf-models
$PACKAGE_INSTALLER pkgconfig
$PACKAGE_INSTALLER libunistring-devel
$PACKAGE_INSTALLER unistring-devel
$PACKAGE_INSTALLER libunistring
$PACKAGE_INSTALLER unistring
$PACKAGE_INSTALLER libxslt-devel
$PACKAGE_INSTALLER GeoIP-deve
$PACKAGE_INSTALLER tar
$PACKAGE_INSTALLER unzip
$PACKAGE_INSTALLER curl
$PACKAGE_INSTALLER wget
$PACKAGE_INSTALLER git
$PACKAGE_INSTALLER libmaxminddb-devel
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
	add-apt-repository ppa:maxmind/ppa -y
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
apt-get -y install build-essential zlib1g-dev libpcre3 libpcre3-dev libbz2-dev libssl-dev libgd-dev libxslt-dev libgeoip-dev tar unzip curl wget git
apt-get -y install libmaxminddb-dev
fi
cd
rm -rf /root/phpbuild
mkdir -p /root/phpbuild
cd /root/phpbuild
rm -rf /root/phpbuild/ngx_http_geoip2_module
rm -rf /root/phpbuild/nginx-1.24.0
rm -rf /root/phpbuild/openssl-OpenSSL_1_1_1h
wget https://github.com/openssl/openssl/archive/OpenSSL_1_1_1h.tar.gz -O /root/phpbuild/OpenSSL_1_1_1h.tar.gz
tar -xzvf OpenSSL_1_1_1h.tar.gz
wget http://nginx.org/download/nginx-1.24.0.tar.gz -O /root/phpbuild/nginx-1.24.0.tar.gz
tar -xzvf nginx-1.24.0.tar.gz
git clone https://github.com/leev/ngx_http_geoip2_module.git
cd /root/phpbuild/nginx-1.24.0
if [[ "$OS" = "CentOS-Stream" || "$OS" = "Fedora" ]] ; then
./configure --prefix=/home/xtreamcodes/iptv_xtream_codes/nginx/ \
--http-client-body-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/client_temp \
--http-proxy-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/proxy_temp \
--http-fastcgi-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/fastcgi_temp \
--lock-path=/home/xtreamcodes/iptv_xtream_codes/tmp/nginx.lock \
--http-uwsgi-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/uwsgi_temp \
--http-scgi-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/scgi_temp \
--conf-path=/home/xtreamcodes/iptv_xtream_codes/nginx/conf/nginx.conf \
--error-log-path=/home/xtreamcodes/iptv_xtream_codes/logs/error.log \
--http-log-path=/home/xtreamcodes/iptv_xtream_codes/logs/access.log \
--pid-path=/home/xtreamcodes/iptv_xtream_codes/nginx/nginx.pid \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_v2_module \
--with-pcre \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-http_auth_request_module \
--with-threads \
--with-mail \
--with-mail_ssl_module \
--with-file-aio \
--with-cpu-opt=generic \
--add-module=/root/phpbuild/ngx_http_geoip2_module \
--with-openssl=/root/phpbuild/openssl-OpenSSL_1_1_1h \
--with-ld-opt='-Wl,-z,relro -Wl,--as-needed -Wl,-z,now -specs=/usr/lib/rpm/redhat/redhat-hardened-ld -specs=/usr/lib/rpm/redhat/redhat-annobin-cc1 -Wl,--build-id=sha1' \
--with-cc-opt='-O2 -flto=auto -ffat-lto-objects -fexceptions -g -grecord-gcc-switches -pipe -Wall -Werror=format-security -Wp,-U_FORTIFY_SOURCE,-D_FORTIFY_SOURCE=3 -Wp,-D_GLIBCXX_ASSERTIONS -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -fstack-protector-strong -specs=/usr/lib/rpm/redhat/redhat-annobin-cc1 -m64 -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer'
else
./configure --prefix=/home/xtreamcodes/iptv_xtream_codes/nginx/ \
--http-client-body-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/client_temp \
--http-proxy-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/proxy_temp \
--http-fastcgi-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/fastcgi_temp \
--lock-path=/home/xtreamcodes/iptv_xtream_codes/tmp/nginx.lock \
--http-uwsgi-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/uwsgi_temp \
--http-scgi-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/scgi_temp \
--conf-path=/home/xtreamcodes/iptv_xtream_codes/nginx/conf/nginx.conf \
--error-log-path=/home/xtreamcodes/iptv_xtream_codes/logs/error.log \
--http-log-path=/home/xtreamcodes/iptv_xtream_codes/logs/access.log \
--pid-path=/home/xtreamcodes/iptv_xtream_codes/nginx/nginx.pid \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_v2_module \
--with-pcre \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-http_auth_request_module \
--with-threads \
--with-mail \
--with-mail_ssl_module \
--with-file-aio \
--with-cpu-opt=generic \
--add-module=/tmp/ngx_http_geoip2_module \
--with-openssl=/tmp/openssl-OpenSSL_1_1_1h \
--with-ld-opt='-Wl,-z,relro -Wl,--as-needed -static' \
--with-cc-opt='-static -static-libgcc -g -O2 -Wformat -Wall'
fi
make -j$(nproc --all)
mkdir -p "/home/xtreamcodes/iptv_xtream_codes/nginx/"
mkdir -p "/home/xtreamcodes/iptv_xtream_codes/nginx/sbin/"
mkdir -p "/home/xtreamcodes/iptv_xtream_codes/nginx/modules"
mkdir -p  "/home/xtreamcodes/iptv_xtream_codes/nginx/conf"
mkdir -p  "/home/xtreamcodes/iptv_xtream_codes/logs/"
mkdir -p  "/home/xtreamcodes/iptv_xtream_codes/tmp/client_temp"
mkdir -p  "/home/xtreamcodes/iptv_xtream_codes/tmp/proxy_temp"
mkdir -p  "/home/xtreamcodes/iptv_xtream_codes/tmp/fastcgi_temp"
mkdir -p  "/home/xtreamcodes/iptv_xtream_codes/tmp/uwsgi_temp"
mkdir -p  "/home/xtreamcodes/iptv_xtream_codes/tmp/scgi_temp"
killall nginx
kill $(ps aux | grep 'xtreamcodes' | grep -v grep | grep -v 'start_services.sh' | awk '{print $2}') 2>/dev/null
killall nginx
kill $(ps aux | grep 'xtreamcodes' | grep -v grep | grep -v 'start_services.sh' | awk '{print $2}') 2>/dev/null
killall nginx
kill $(ps aux | grep 'xtreamcodes' | grep -v grep | grep -v 'start_services.sh' | awk '{print $2}') 2>/dev/null
rm -f /home/xtreamcodes/iptv_xtream_codes/nginx/sbin/nginx
cp /root/phpbuild/nginx-1.24.0/objs/nginx /home/xtreamcodes/iptv_xtream_codes/nginx/sbin/
cd /root/phpbuild/
rm -rf /root/phpbuild/ngx_http_geoip2_module
rm -rf /root/phpbuild/nginx-1.24.0
rm -rf /root/phpbuild/openssl-OpenSSL_1_1_1h
wget https://github.com/openssl/openssl/archive/OpenSSL_1_1_1h.tar.gz -O /root/phpbuild/OpenSSL_1_1_1h.tar.gz
tar -xzvf OpenSSL_1_1_1h.tar.gz
wget http://nginx.org/download/nginx-1.24.0.tar.gz -O /root/phpbuild/nginx-1.24.0.tar.gz
tar -xzvf nginx-1.24.0.tar.gz
git clone https://github.com/leev/ngx_http_geoip2_module.git
rm -rf /root/phpbuild/v1.2.2.zip
rm -rf /root/phpbuild/nginx-rtmp-module-1.2.2
wget https://github.com/arut/nginx-rtmp-module/archive/v1.2.2.zip
unzip /root/phpbuild/v1.2.2.zip
cd /root/phpbuild/nginx-1.24.0
if [[ "$OS" = "CentOS-Stream" || "$OS" = "Fedora" ]] ; then
./configure --prefix=/home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/ \
--http-client-body-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/client_temp \
--http-proxy-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/proxy_temp \
--http-fastcgi-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/fastcgi_temp \
--lock-path=/home/xtreamcodes/iptv_xtream_codes/tmp/nginx.lock \
--http-uwsgi-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/uwsgi_temp \
--http-scgi-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/scgi_temp \
--conf-path=/home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/conf/nginx.conf \
--error-log-path=/home/xtreamcodes/iptv_xtream_codes/logs/rtmp_error.log \
--http-log-path=/home/xtreamcodes/iptv_xtream_codes/logs/rtmp_access.log \
--pid-path=/home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/nginx.pid \
--add-module=/root/phpbuild/nginx-rtmp-module-1.2.2 \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_v2_module \
--with-pcre \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-http_auth_request_module \
--with-threads \
--with-mail \
--with-mail_ssl_module \
--with-file-aio \
--with-cpu-opt=generic \
--with-pcre \
--without-http_rewrite_module \
--add-module=/root/phpbuild/ngx_http_geoip2_module \
--with-openssl=/root/phpbuild/openssl-OpenSSL_1_1_1h \
--with-ld-opt='-Wl,-z,relro -Wl,--as-needed -Wl,-z,now -specs=/usr/lib/rpm/redhat/redhat-hardened-ld -specs=/usr/lib/rpm/redhat/redhat-annobin-cc1 -Wl,--build-id=sha1' \
--with-cc-opt='-O2 -flto=auto -ffat-lto-objects -fexceptions -g -grecord-gcc-switches -pipe -Wall -Werror=format-security -Wp,-U_FORTIFY_SOURCE,-D_FORTIFY_SOURCE=3 -Wp,-D_GLIBCXX_ASSERTIONS -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -fstack-protector-strong -specs=/usr/lib/rpm/redhat/redhat-annobin-cc1 -m64 -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer'
else
./configure --prefix=/home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/ \
--lock-path=/home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/nginx_rtmp.lock \
--http-client-body-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/client_temp \
--http-proxy-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/proxy_temp \
--http-fastcgi-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/fastcgi_temp \
--lock-path=/home/xtreamcodes/iptv_xtream_codes/tmp/nginx.lock \
--http-uwsgi-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/uwsgi_temp \
--http-scgi-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/scgi_temp \
--conf-path=/home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/conf/nginx.conf \
--error-log-path=/home/xtreamcodes/iptv_xtream_codes/logs/rtmp_error.log \
--http-log-path=/home/xtreamcodes/iptv_xtream_codes/logs/rtmp_access.log \
--pid-path=/home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/nginx.pid \
--add-module=/root/phpbuild/nginx-rtmp-module-1.2.2 \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_v2_module \
--with-pcre \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-http_auth_request_module \
--with-threads \
--with-mail \
--with-mail_ssl_module \
--with-file-aio \
--with-cpu-opt=generic \
--add-module=/tmp/ngx_http_geoip2_module \
--with-openssl=/tmp/openssl-OpenSSL_1_1_1h \
--with-ld-opt='-Wl,-z,relro -Wl,--as-needed -static' \
--with-cc-opt='-static -static-libgcc -g -O2 -Wformat -Wall'
fi
make -j$(nproc --all)
mkdir -p "/home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/"
mkdir -p "/home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/sbin/"
mkdir -p "/home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/modules"
mkdir -p  "/home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/conf"
mkdir -p  "/home/xtreamcodes/iptv_xtream_codes/logs/"
mkdir -p  "/home/xtreamcodes/iptv_xtream_codes/tmp/client_temp"
mkdir -p  "/home/xtreamcodes/iptv_xtream_codes/tmp/proxy_temp"
mkdir -p  "/home/xtreamcodes/iptv_xtream_codes/tmp/fastcgi_temp"
mkdir -p  "/home/xtreamcodes/iptv_xtream_codes/tmp/uwsgi_temp"
mkdir -p  "/home/xtreamcodes/iptv_xtream_codes/tmp/scgi_temp"
killall nginx_rtmp
kill $(ps aux | grep 'xtreamcodes' | grep -v grep | grep -v 'start_services.sh' | awk '{print $2}') 2>/dev/null
killall nginx_rtmp
kill $(ps aux | grep 'xtreamcodes' | grep -v grep | grep -v 'start_services.sh' | awk '{print $2}') 2>/dev/null
killall nginx_rtmp
kill $(ps aux | grep 'xtreamcodes' | grep -v grep | grep -v 'start_services.sh' | awk '{print $2}') 2>/dev/null
rm -f /home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/sbin/nginx_rtmp
mv /root/phpbuild/nginx-1.24.0/objs/nginx /root/phpbuild/nginx-1.24.0/objs/nginx_rtmp
cp /root/phpbuild/nginx-1.24.0/objs/nginx_rtmp /home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/sbin/
wget --no-check-certificate https://www.php.net/distributions/php-7.4.33.tar.gz
rm -rf php-7.4.33
tar -xf php-7.4.33.tar.gz
if [[ "$VER" = "18.04" || "$VER" = "20.04" || "$VER" = "22.04" || "$VER" = "11" || "$VER" = "37" || "$VER" = "38" ]]; then
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
make install
cd ../php-7.4.33
'./configure'  '--prefix=/home/xtreamcodes/iptv_xtream_codes/php' '--with-zlib-dir' '--with-freetype-dir=/home/xtreamcodes/iptv_xtream_codes/freetype2' '--enable-mbstring' '--enable-calendar' '--with-curl' '--with-gd' '--disable-rpath' '--enable-inline-optimization' '--with-bz2' '--with-zlib' '--enable-sockets' '--enable-sysvsem' '--enable-sysvshm' '--enable-pcntl' '--enable-mbregex' '--enable-exif' '--enable-bcmath' '--with-mhash' '--enable-zip' '--with-pcre-regex' '--with-pdo-mysql=mysqlnd' '--with-mysqli=mysqlnd' '--with-openssl' '--with-fpm-user=xtreamcodes' '--with-fpm-group=xtreamcodes' '--with-libdir=/lib/x86_64-linux-gnu' '--with-gettext' '--with-xmlrpc' '--with-xsl' '--enable-opcache' '--enable-fpm' '--enable-libxml' '--enable-static' '--disable-shared' '--with-jpeg-dir' '--enable-gd-jis-conv' '--with-webp-dir' '--with-xpm-dir'
make -j$(nproc --all)
killall php
killall php-fpm
kill $(ps aux | grep 'xtreamcodes' | grep -v grep | grep -v 'start_services.sh' | awk '{print $2}') 2>/dev/null
killall php
killall php-fpm
kill $(ps aux | grep 'xtreamcodes' | grep -v grep | grep -v 'start_services.sh' | awk '{print $2}') 2>/dev/null
killall php
killall php-fpm
kill $(ps aux | grep 'xtreamcodes' | grep -v grep | grep -v 'start_services.sh' | awk '{print $2}') 2>/dev/null
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
tar -xf geoip-1.1.1.tgz
cd geoip-1.1.1
/home/xtreamcodes/iptv_xtream_codes/php/bin/phpize
./configure --with-php-config=/home/xtreamcodes/iptv_xtream_codes/php/bin/php-config
make -j$(nproc --all)
make install
cd /root
mkdir -p /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20210902/
wget --no-check-certificate -O ioncube_loaders_lin_x86-64.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar -xvf ioncube_loaders_lin_x86-64.tar.gz
rm -f ioncube_loaders_lin_x86-64.tar.gz
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20210902/ioncube_loader_lin_*.so
cp ioncube/ioncube_loader_lin_7.4.so /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20210902/
rm -rf ioncube
chmod 777 /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20210902/ioncube_loader_lin_7.4.so
cd /root
wget --no-check-certificate https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/php.ini -O /home/xtreamcodes/iptv_xtream_codes/php/lib/php.ini
cd /root
rm -rf /root/ffmpeg_build
rm -rf /root/xavs-code
cd /home/xtreamcodes/iptv_xtream_codes/bin/
wget https://bitbucket.org/emre1393/xtreamui_mirror/downloads/ffmpeg_v5.0.1_amd64.zip -O ffmpeg_v5.0.1_amd64.zip
rm -f /home/xtreamcodes/iptv_xtream_codes/bin/ffmpeg
rm -f /home/xtreamcodes/iptv_xtream_codes/bin/ffprobe
unzip ffmpeg_v5.0.1_amd64.zip
rm -f ffmpeg_v5.0.1_amd64.zip
cd /root
rm -rf /root/ffmpeg_build
rm -rf /root/xavs-code
rm -rf rm -rf /root/phpbuild
/home/xtreamcodes/iptv_xtream_codes/permissions.sh
/home/xtreamcodes/iptv_xtream_codes/start_services.sh
echo "finish"

