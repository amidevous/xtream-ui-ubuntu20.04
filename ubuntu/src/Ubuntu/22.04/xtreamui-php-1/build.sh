#!/bin/bash
apt-get update
apt-get -y install debhelper cdbs lintian build-essential fakeroot devscripts dh-make dput
apt-get -y install zlib1g-dev
apt-get -y install libz-dev
apt-get -y install libpng-dev
apt-get -y install autotools-dev
apt-get -y install libc6-dev
apt-get -y install libc-dev
cd /root
wget -O /root/xtreamui-php_7.4.33-1.Ubuntu.orig.tar.xz https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-php-1/xtreamui-php_7.4.33-1.Ubuntu.orig.tar.xz
mkdir -p /root/xtreamui-php_7.4.33-1.Ubuntu/
cd /root/xtreamui-php_7.4.33-1.Ubuntu/
tar -xf /root/xtreamui-php_7.4.33-1.Ubuntu.orig.tar.xz
mkdir -p /root/xtreamui-php_7.4.33-1.Ubuntu/debian/source
wget -O /root/xtreamui-php_7.4.33-1.Ubuntu/debian/source/format https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-php-1/debian/source/format
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
