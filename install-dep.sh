#!/bin/bash
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
if [[ "$VER" = "8" && "$OS" = "CentOs" ]]; then
	echo "Centos 8 obsolete udate to CentOS-Stream 8"
	echo "this operation may take some time"
	sleep 60
	# change repository to use vault.centos.org CentOS 8 found online to vault.centos.org
	find /etc/yum.repos.d -name '*.repo' -exec sed -i 's|mirrorlist=http://mirrorlist.centos.org|#mirrorlist=http://mirrorlist.centos.org|' {} \;
	find /etc/yum.repos.d -name '*.repo' -exec sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|' {} \;
	#update package list
	dnf update -y
	#upgrade all packages to latest CentOS 8
	dnf upgrade -y
	#install CentOS-Stream 8 repository
	dnf -y install centos-release-stream --allowerasing
	#install rpmconf
	dnf -y install rpmconf
	#set config file with rpmconf
	rpmconf -a
	# remove Centos 8 repository and set CentOS-Stream 8 repository by default
	dnf -y swap centos-linux-repos centos-stream-repos
	# system upgrade
	dnf -y distro-sync
	# ceanup old rpmconf file create
	find / -name '*.rpmnew' -exec rm -f {} \;
	find / -name '*.rpmsave' -exec rm -f {} \;
	OS="CentOS-Stream"
	fi

echo "Detected : $OS  $VER  $ARCH"
if [[ "$OS" = "CentOs" && "$VER" = "6" && "$ARCH" == "x86_64" ||
"$OS" = "CentOs" && "$VER" = "7" && "$ARCH" == "x86_64" ||
"$OS" = "CentOS-Stream" && "$VER" = "8" && "$ARCH" == "x86_64" ||
"$OS" = "CentOS-Stream" && "$VER" = "9" && "$ARCH" == "x86_64" ||
"$OS" = "Fedora" && ("$VER" = "36" || "$VER" = "37" || "$VER" = "38" ) && "$ARCH" == "x86_64" ||
"$OS" = "Ubuntu" && ("$VER" = "18.04" || "$VER" = "20.04" || "$VER" = "22.04" ) && "$ARCH" == "x86_64" ||
"$OS" = "debian" && ("$VER" = "10" || "$VER" = "11" ) && "$ARCH" == "x86_64" ]] ; then
echo "Ok."
else
    echo "Sorry, this OS is not supported by Xtream UI."
    exit 1
fi
echo -e "\n-- Updating repositories and packages sources"
if [[ "$OS" = "CentOs" ]] ; then
    PACKAGE_INSTALLER="yum -y install"
    PACKAGE_REMOVER="yum -y remove"
    PACKAGE_UPDATER="yum -y update"
    PACKAGE_UTILS="yum-utils"
    PACKAGE_GROUPINSTALL="yum -y groupinstall"
    PACKAGE_SOURCEDOWNLOAD="yumdownloader --source"
    BUILDDEP="yum-builddep -y"
    MYSQLCNF=/etc/my.cnf
elif [[ "$OS" = "Fedora" || "$OS" = "Centos Stream"  ]]; then
    PACKAGE_INSTALLER="dnf -y install"
    PACKAGE_REMOVER="dnf -y remove"
    PACKAGE_UPDATER="dnf -y update"
    PACKAGE_UTILS="dnf-utils" 
    PACKAGE_GROUPINSTALL="dnf -y groupinstall"
    PACKAGE_SOURCEDOWNLOAD="dnf download --source"
    BUILDDEP="dnf build-dep -y"
    MYSQLCNF=/etc/my.cnf
elif [[ "$OS" = "Ubuntu" || "$OS" = "debian" ]]; then
    PACKAGE_INSTALLER="apt-get -y install"
    PACKAGE_REMOVER="apt-get -y purge"
    MYSQLCNF=/etc/mysql/mariadb.cnf
    inst() {
       dpkg -l "$1" 2> /dev/null | grep '^ii' &> /dev/null
    }
fi
if [[ "$OS" = "CentOs" || "$OS" = "CentOS-Stream" || "$OS" = "Fedora" ]]; then
	if [[ "$OS" = "CentOs" || "$OS" = "CentOS-Stream" ]]; then
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
	fi
	$PACKAGE_INSTALLER $PACKAGE_UTILS
	#disable deposits that could result in installation errors
	# disable all repository
	if [[ "$OS" = "Fedora" ]]; then
		dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
	elif [[ "$OS" = "CentOS-Stream" ]]; then
		dnf -y install --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm
		dnf -y install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
	elif [[ "$OS" = "CentOS" ]]; then
		dnf -y install --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm
		dnf -y install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
	fi
	if [[ "$OS" = "CentOs" || "$OS" = "CentOS-Stream" ]]; then
if [[ "$OS" = "CentOs" && "$VER" = "6" && "$ARCH" == "x86_64" ]] ; then
cat > /etc/yum.repos.d/mariadb.repo <<EOF
[mariadb]
name=MariaDB RPM source
baseurl=http://mirror.mariadb.org/yum/10.2/rhel/$VER/x86_64/
enabled=1
gpgcheck=0
EOF
else
cat > /etc/yum.repos.d/mariadb.repo <<EOF
[mariadb]
name=MariaDB RPM source
baseurl=http://mirror.mariadb.org/yum/11.0.1/rhel/$VER/x86_64/
enabled=1
gpgcheck=0
EOF
fi
	elif [[ "$OS" = "Fedora" ]]; then
cat > /etc/yum.repos.d/mariadb.repo <<EOF
[mariadb]
name=MariaDB RPM source
baseurl=http://mirror.mariadb.org/yum/11.0.1/fedora/$VER/x86_64/
enabled=1
gpgcheck=0
EOF
	fi
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
		# enable official repository CentOs 7 Base
		enablerepo base
		# enable official repository CentOs 7 Updates
		enablerepo updates
		# enable official repository Fedora Epel
		enablerepo epel
		enablerepo centos-sclo-rh
		enablerepo centos-sclo-sclo
		enablerepo mariadb
		enablerepo rpmfusion-free
		enablerepo rpmfusion-free-updates
		enablerepo rpmfusion-nonfree
		enablerepo rpmfusion-nonfree-updates
	elif [ "$OS" = "CentOS-Stream" ]; then
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
		# enable official repository CentOs Stream Devel
		enablerepo devel
		# enable official repository CentOs Stream CRB
		enablerepo crb
		# enable official repository CentOs Stream CRB
		enablerepo CRB
		# enable official repository Fedora Epel
		enablerepo epel
		# enable official repository Fedora Epel
		enablerepo epel-modular
		enablerepo mariadb
		enablerepo rpmfusion-free
		enablerepo rpmfusion-free-updates
		enablerepo rpmfusion-nonfree
		enablerepo rpmfusion-nonfree-updates
		dnf -y install wget
	elif [ "$OS" = "Fedora" ]; then
		enablerepo fedora-cisco-openh264
		enablerepo fedora-modular
		enablerepo fedora
		enablerepo updates-modular
		enablerepo updates
		enablerepo mariadb
		enablerepo rpmfusion-free
		enablerepo rpmfusion-free-updates
		enablerepo rpmfusion-nonfree
		enablerepo rpmfusion-nonfree-updates
		dnf -y install wget
	fi
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
	$PACKAGE_INSTALLER yum-plugin-copr
	$PACKAGE_INSTALLER yum-plugins-copr
	$PACKAGE_INSTALLER dnf-plugin-core
	$PACKAGE_INSTALLER dnf-plugins-core
	$PACKAGE_INSTALLER dnf-plugin-copr
	$PACKAGE_INSTALLER dnf-plugins-copr
	$PACKAGE_INSTALLER sudo
	$PACKAGE_INSTALLER vim
	$PACKAGE_INSTALLER make
	$PACKAGE_INSTALLER wget
    	$PACKAGE_INSTALLER ld-linux.so.2
    	$PACKAGE_INSTALLER  libbz2.so.1
    	$PACKAGE_INSTALLER libdb-4.7.so
    	$PACKAGE_INSTALLER libgd.so.2
    	$PACKAGE_INSTALLER db-devel
    	$PACKAGE_INSTALLER libdb-devel
    	$PACKAGE_INSTALLER gd-devel
    	$PACKAGE_INSTALLER glibc32
    	$PACKAGE_INSTALLER bzip2-libs 
	$PACKAGE_INSTALLER curl-devel
	$PACKAGE_INSTALLER perl-libwww-perl
	$PACKAGE_INSTALLER libxml2
	$PACKAGE_INSTALLER libxml2-devel
	$PACKAGE_INSTALLER bzip2-devel
	$PACKAGE_INSTALLER gcc
	$PACKAGE_INSTALLER gcc-c++
	$PACKAGE_INSTALLER at
	$PACKAGE_INSTALLER make
	$PACKAGE_INSTALLER ca-certificates
	$PACKAGE_INSTALLER nano
	$PACKAGE_INSTALLER psmisc
	$PACKAGE_GROUPINSTALL --with-optional -y "C Development Tools and Libraries" "Development Tools" "Fedora Packager"
	$PACKAGE_INSTALLER at
	$PACKAGE_INSTALLER bash-completion
	$PACKAGE_INSTALLER ca-certificates
	$PACKAGE_INSTALLER jq
	$PACKAGE_INSTALLER sshpass
	$PACKAGE_INSTALLER net-tools
	$PACKAGE_INSTALLER curl
	$PACKAGE_INSTALLER e2fslibs
	$PACKAGE_INSTALLER e2fsprogs
	$PACKAGE_INSTALLER e2fsprogs-libs
	$PACKAGE_INSTALLER libcurl-devel
	$PACKAGE_INSTALLER libxslt-devel
	$PACKAGE_INSTALLER GeoIP-devel
	$PACKAGE_INSTALLER wget
	$PACKAGE_INSTALLER nscd
	$PACKAGE_INSTALLER htop
	$PACKAGE_INSTALLER unzip
	$PACKAGE_INSTALLER httpd
	$PACKAGE_INSTALLER httpd-devel
	$PACKAGE_INSTALLER zip
	$PACKAGE_INSTALLER mc
	$PACKAGE_INSTALLER libpng-devel
	$PACKAGE_INSTALLER python3
	$PACKAGE_INSTALLER python3-pip
	$PACKAGE_INSTALLER python
	$PACKAGE_INSTALLER python-pip
	$PACKAGE_INSTALLER python2
	$PACKAGE_INSTALLER python2-pip
	$PACKAGE_INSTALLER mcrypt
	$PACKAGE_INSTALLER mcrypt-devel
	$PACKAGE_INSTALLER libmcrypt
	$PACKAGE_INSTALLER libmcrypt-devel
	$PACKAGE_INSTALLER MariaDB-client
	$PACKAGE_INSTALLER MariaDB
	$PACKAGE_INSTALLER mariadb-client
	$PACKAGE_INSTALLER mariadb
	$PACKAGE_INSTALLER MariaDB-server
	$PACKAGE_INSTALLER mariadb-server
	$PACKAGE_INSTALLER MariaDB-devel
	$PACKAGE_INSTALLER mariadb-devel
	$PACKAGE_INSTALLER python
	$PACKAGE_INSTALLER python-paramiko
	$PACKAGE_INSTALLER python-pip
	$PACKAGE_INSTALLER python2
	$PACKAGE_INSTALLER python2-paramiko
	$PACKAGE_INSTALLER python2-pip
	$PACKAGE_INSTALLER python3
	$PACKAGE_INSTALLER python3-paramiko
	$PACKAGE_INSTALLER python3-pip
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
	$PACKAGE_INSTALLER GeoIP-devel
	$PACKAGE_INSTALLER tar
	$PACKAGE_INSTALLER unzip
	$PACKAGE_INSTALLER curl
	$PACKAGE_INSTALLER wget
	$PACKAGE_INSTALLER git
	$PACKAGE_INSTALLER libmaxminddb-devel
	$PACKAGE_INSTALLER libmcrypt-dev
	$PACKAGE_INSTALLER mcrypt-dev
	$PACKAGE_INSTALLER libmcrypt-devel
	$PACKAGE_INSTALLER mcrypt-devel
	$PACKAGE_INSTALLER mcrypt$PACKAGE_INSTALLER libgeoip-dev
	$PACKAGE_INSTALLER libgeoip-devel
	$PACKAGE_INSTALLER geoip-devel
	$PACKAGE_INSTALLER podman
	$PACKAGE_INSTALLER bison
	$PACKAGE_INSTALLER boost-devel
	$PACKAGE_INSTALLER cmake
	$PACKAGE_INSTALLER libevent-devel
	$PACKAGE_INSTALLER flex
	$PACKAGE_INSTALLER cracklib-devel
	$PACKAGE_INSTALLER Judy-devel
	$PACKAGE_INSTALLER libaio-devel
	$PACKAGE_INSTALLER xz-devel
	$PACKAGE_INSTALLER lz4-devel
	$PACKAGE_INSTALLER lzo-devel
	$PACKAGE_INSTALLER libpmem-devel
	$PACKAGE_INSTALLER readline-devel
	$PACKAGE_INSTALLER policycoreutils-python
	$PACKAGE_INSTALLER libzstd-devel
	$PACKAGE_INSTALLER librabbitmq-devel
	$PACKAGE_INSTALLER libedit-devel
	if [[ "$OS" = "CentOs" && "$VER" = "6" ]] ; then
	$PACKAGE_INSTALLER devtoolset-9
	$PACKAGE_INSTALLER devtoolset-9-binutils
	$PACKAGE_INSTALLER devtoolset-9-gcc-c++
	$PACKAGE_INSTALLER devtoolset-9-gdb
	$PACKAGE_INSTALLER devtoolset-9-gcc
	$PACKAGE_INSTALLER devtoolset-9-binutils-devel
	$PACKAGE_INSTALLER devtoolset-9-dyninst-devel
	$PACKAGE_INSTALLER devtoolset-9-elfutils-devel
	$PACKAGE_INSTALLER devtoolset-9-elfutils-libelf-devel
	$PACKAGE_INSTALLER devtoolset-9-gcc-plugin-devel
	$PACKAGE_INSTALLER devtoolset-9-libasan-devel
	$PACKAGE_INSTALLER devtoolset-9-libatomic-devel
	$PACKAGE_INSTALLER devtoolset-9-libitm-devel
	$PACKAGE_INSTALLER devtoolset-9-libquadmath-devel
	$PACKAGE_INSTALLER devtoolset-9-libstdc++-devel
	$PACKAGE_INSTALLER devtoolset-9-libtsan-devel
	$PACKAGE_INSTALLER devtoolset-9-libubsan-devel
	$PACKAGE_INSTALLER devtoolset-9-oprofile-devel
	$PACKAGE_INSTALLER devtoolset-9-systemtap-devel
	$PACKAGE_INSTALLER devtoolset-9-systemtap-sdt-devel
	$PACKAGE_INSTALLER devtoolset-9-valgrind-devel
	/opt/rh/devtoolset-9/enable
	source /opt/rh/devtoolset-9/enable
	fi
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
	apt-get install apt-apt-key -y
        add-apt-repository -y ppa:ondrej/apache2
	add-apt-repository -y -s ppa:ondrej/php
cat > /etc/apt/sources.list.d/podman.list <<EOF
deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_$VER/ /
EOF
wget -qO- "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_$VER/Release.key" | sudo apt-key add -
	apt-get update
	apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
	add-apt-repository -y "deb [arch=amd64,arm64,ppc64el] https://mirrors.nxthost.com/mariadb/repo/11.0.1/ubuntu/ $(lsb_release -cs) main"
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
	apt-get update
	apt-get install software-properties-common dirmngr --install-recommends -y
	apt-get install apt-apt-key --install-recommends -y
        apt-get update
	apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
	add-apt-repository -y "deb [arch=amd64,arm64,ppc64el] https://mirrors.nxthost.com/mariadb/repo/11.0.1/debian/ $(lsb_release -cs) main"
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
cat > /etc/apt/sources.list.d/podman.list <<EOF
deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_$VER/ /
EOF
wget -qO- "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_$VER/Release.key" | sudo apt-key add -
	wget --no-check-certificate -qO- https://packages.sury.org/php/apt.gpg | apt-key add -
	wget --no-check-certificate -qO- https://packages.sury.org/apache2/apt.gpg | apt-key add -
	apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
	apt-get update
fi
if [[ "$OS" = "Ubuntu" || "$OS" = "debian" ]]; then
	DEBIAN_FRONTEND=noninteractive
	export DEBIAN_FRONTEND=noninteractive
	apt-get -y dist-upgrade
	apt-get -y install debhelper 
	apt-get -y install cdbs
	apt-get -y install lintian
	apt-get -y install build-essential
	apt-get -y install fakeroot
	apt-get -y install devscripts
	apt-get -y install dh-make
	apt-get -y install mariadb-server
	apt-get -y install curl
	apt-get -y install libxslt1-dev
	apt-get -y install libcurl3-gnutls
	apt-get -y install libgeoip-dev
	apt-get -y install python
	apt-get -y install python2
	apt-get -y install python33
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
	apt-get -y install python2-paramiko
	apt-get -y install python-pip
	apt-get -y install python2-pip
	apt-get -y install python3-pip
	apt-get -y dist-upgrade
	apt-get -y install debhelper cdbs lintian build-essential fakeroot devscripts dh-make wget
	apt-get -y build-dep php7.4
	apt-get -y install libmariadb-dev
	apt-get -y install libmariadb-dev-compat
	apt-get -y install libmariadbd-dev
	apt-get -y install dbconfig-mysql
	apt-get -y install autoconf
	apt-get -y install automake
	apt-get -y install build-essential
	apt-get -y install cmake
	apt-get -y install git-core
	apt-get -y install git
	apt-get -y install libass-dev
	apt-get -y install libfreetype6-dev
	apt-get -y install libgnutls28-dev
	apt-get -y install libmp3lame-dev
	apt-get -y install libsdl2-dev
	apt-get -y install libtool
	apt-get -y install libva-dev
	apt-get -y install libvdpau-dev
	apt-get -y install libvorbis-dev
	libxcb1-dev libxcb-shm0-dev
	apt-get -y install libxcb-xfixes0-dev
	apt-get -y install meson
	apt-get -y install ninja-build
	apt-get -y install pkg-config
	apt-get -y install texinfo
	apt-get -y install yasm
	apt-get -y install zlib1g-dev
	apt-get -y install libxvidcore-dev
	apt-get -y install libunistring-dev
	apt-get -y install nasm
	apt-get -y install libx264-dev
	apt-get -y install libx265-dev
	apt-get -y install libnuma-dev
	apt-get -y install libvpx-dev
	apt-get -y install libfdk-aac-dev
	apt-get -y install libopus-dev
	apt-get -y install unzip
	apt-get -y install librtmp-dev
	apt-get -y install libtheora-dev
	apt-get -y install libbz2-dev
	apt-get -y install libgmp-dev
	apt-get -y install libssl-dev
	apt-get -y install zip
	apt-get -y install libdav1d-dev
	apt-get -y install libaom-dev
	apt-get -y install reprepro
	apt-get -y install subversion
	apt-get -y install zstd
	apt-get -y install libpcre3
	apt-get -y install libpcre3-dev
	apt-get -y install pcre3
	apt-get -y install libpcre
	apt-get -y install libpcre-dev
	apt-get -y install pcre
	apt-get -y install libpcre2
	apt-get -y install libpcre2-dev
	apt-get -y install pcre2
	apt-get -y install libgd-dev
	apt-get -y install libxslt-dev
	apt-get -y install libgeoip-dev
	apt-get -y install tar
	apt-get -y install curl
	apt-get -y install wget
	apt-get -y install git
	apt-get -y install libmaxminddb-dev
	apt-get -y install libmcrypt-dev
	apt-get -y install mcrypt-dev
	apt-get -y install libmcrypt-devel
	apt-get -y install mcrypt-devel
	apt-get -y install mcrypt
	apt-get -y install libgeoip-dev
	apt-get -y install libgeoip-devel
	apt-get -y install geoip-devel
	apt-get -y install podman
	apt-get -y purge postfix
	debconf-set-selections <<< "postfix postfix/mailname string redhat"
	debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
	DEBIAN_FRONTEND=noninteractive apt-get -y install postfix
	
fi
	systemctl start mariadb
	systemctl enable mariadb

