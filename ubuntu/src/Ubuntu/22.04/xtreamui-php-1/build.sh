#!/bin/bash
apt-get update
apt-get -y install debhelper cdbs lintian build-essential fakeroot devscripts dh-make dput
apt-get -y install zlib1g-dev
apt-get -y install libz-dev
apt-get -y install libpng-dev
apt-get -y install autotools-dev
apt-get -y install libc6-dev
apt-get -y install libc-dev
apt-get -y install apache2-dev
apt-get -y install autoconf
apt-get -y install automake
apt-get -y install bison
apt-get -y install chrpath
apt-get -y install default-libmysqlclient-dev
apt-get -y install libmysqlclient-dev
apt-get -y install dh-apache2
apt-get -y install dpkg-dev
apt-get -y install firebird-dev
apt-get -y install firebird2.5-dev
apt-get -y install firebird2.1-dev
apt-get -y install flex
apt-get -y install freetds-dev
apt-get -y install libacl1-dev
apt-get -y install libapparmor-dev
apt-get -y install libapr1-dev
apt-get -y install libargon2-dev
apt-get -y install libargon2-0-dev
apt-get -y install libbz2-dev
apt-get -y install libc-client-dev
apt-get -y install libcurl4-openssl-dev
apt-get -y install libcurl-dev
apt-get -y install libdb-dev
apt-get -y install libedit-dev
apt-get -y install libenchant-2-dev
apt-get -y install libevent-dev
apt-get -y install libexpat1-dev
apt-get -y install libffi-dev
apt-get -y install libfreetype6-dev
apt-get -y install libgcrypt20-dev
apt-get -y install libgcrypt11-dev
apt-get -y install libgd-dev
apt-get -y install libgd2-dev
apt-get -y install libglib2.0-dev
apt-get -y install libgmp3-dev
apt-get -y install libicu-dev
apt-get -y install libjpeg-dev
apt-get -y install libkrb5-dev
apt-get -y install libldap2-dev
apt-get -y install liblmdb-dev
apt-get -y install libmagic-dev
apt-get -y install libmhash-dev
apt-get -y install libnss-myhostname
apt-get -y install libonig-dev
apt-get -y install libpam0g-dev
apt-get -y install libpcre2-dev
apt-get -y install libpng-dev
apt-get -y install libpq-dev
apt-get -y install libpspell-dev
apt-get -y install libqdbm-dev
apt-get -y install libsasl2-dev
apt-get -y install libsnmp-dev
apt-get -y install libsodium-dev
apt-get -y install libsqlite3-dev
apt-get -y install libssl-dev
apt-get -y install libsystemd-dev
apt-get -y install libtidy-dev
apt-get -y install libtool
apt-get -y install libwebp-dev
apt-get -y install libwrap0-dev
apt-get -y install libxml2-dev
apt-get -y install libxmlrpc-epi-dev
apt-get -y install libxmltok1-dev
apt-get -y install libxslt1-dev
apt-get -y install libzip-dev
apt-get -y install locales-all
apt-get -y install language-pack-de
apt-get -y install netbase
apt-get -y install netcat-openbsd
apt-get -y install re2c
apt-get -y install systemtap-sdt-dev
apt-get -y install tzdata
apt-get -y install unixodbc-dev
apt-get -y install zlib1g-dev
apt-get -y purge bind-dev
apt-get -y purge libxmlrpc-core-c3-dev
cd /root
wget -O /root/xtreamui-php_7.4.33-1.Ubuntu.orig.tar.xz https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-php-1/xtreamui-php_7.4.33-1.Ubuntu.orig.tar.xz
mkdir -p /root/xtreamui-php_7.4.33-1.Ubuntu/
cd /root/xtreamui-php_7.4.33-1.Ubuntu/
tar -xf /root/xtreamui-php_7.4.33-1.Ubuntu.orig.tar.xz
mkdir -p /root/xtreamui-php_7.4.33-1.Ubuntu/debian/source
mkdir -p /root/xtreamui-php_7.4.33-1.Ubuntu/debian/patches
wget -O /root/xtreamui-php_7.4.33-1.Ubuntu/debian/source/format https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-php-1/debian/source/format
wget -O /root/xtreamui-php_7.4.33-1.Ubuntu/debian/patches/0049-Add-minimal-OpenSSL-3.0-patch.patch https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-php-1/debian/patches/0049-Add-minimal-OpenSSL-3.0-patch.patch
wget -O /root/xtreamui-php_7.4.33-1.Ubuntu/debian/patches/series https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-php-1/debian/patches/series
wget -O /root/xtreamui-php_7.4.33-1.Ubuntu/debian/README.Debian https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-php-1/debian/README.Debian
wget -O /root/xtreamui-php_7.4.33-1.Ubuntu/debian/README.source https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-php-1/debian/README.source
wget -O /root/xtreamui-php_7.4.33-1.Ubuntu/debian/changelog https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-php-1/debian/changelog
wget -O /root/xtreamui-php_7.4.33-1.Ubuntu/debian/compat https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-php-1/debian/compat
wget -O /root/xtreamui-php_7.4.33-1.Ubuntu/debian/control https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-php-1/debian/control
wget -O /root/xtreamui-php_7.4.33-1.Ubuntu/debian/copyright https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-php-1/debian/copyright
wget -O /root/xtreamui-php_7.4.33-1.Ubuntu/debian/freetype-docs.docs https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-php-1/debian/freetype-docs.docs
wget -O /root/xtreamui-php_7.4.33-1.Ubuntu/debian/rules https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-php-1/debian/rules
debuild
cd /root
#dpkg -i /root/xtreamui-freetype2_2.12.0-2_amd64.deb
rm -rf /root/xtreamui-php_7.4.33-1.Ubuntu
rm -rf /root/xtreamui-freetype2-dbgsym_2.12.0-2_amd64.ddeb
rm -rf /root/xtreamui-freetype2_2.12.0-2.debian.tar.xz
rm -rf /root/xtreamui-freetype2_2.12.0-2.dsc
rm -rf /root/xtreamui-freetype2_2.12.0-2_amd64.build
rm -rf /root/xtreamui-freetype2_2.12.0-2_amd64.buildinfo
rm -rf /root/xtreamui-freetype2_2.12.0-2_amd64.changes
rm -rf /root/xtreamui-freetype2_2.12.0.orig.tar.xz
