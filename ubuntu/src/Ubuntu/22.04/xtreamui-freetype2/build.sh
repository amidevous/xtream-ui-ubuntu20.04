#!/bin/bash
apt-get update
apt-get -y install debhelper cdbs lintian build-essential fakeroot devscripts dh-make dput
cd /root
wget -O /root/xtreamui-freetype2_2.12.0.orig.tar.xz https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-freetype2/xtreamui-freetype2_2.12.0.orig.tar.xz
tar -xf /root/xtreamui-freetype2_2.12.0.orig.tar.xz
cd /root/freetype-2.12.0/
mkdir -p /root/freetype-2.12.0/debian/source
wget -O /root/freetype-2.12.0/debian/source/format https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-freetype2/debian/source/format
wget -O /root/freetype-2.12.0/debian/
