#!/bin/bash
apt-get update
apt-get -y install debhelper cdbs lintian build-essential fakeroot devscripts dh-make dput
cd /root
wget https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-freetype2/xtreamui-freetype2_2.12.0.orig.tar.xz
tar -xvf xtreamui-freetype2_2.12.0.orig.tar.xz
cd freetype-2.12.0
mkdir -p debian/source
cd debian/source
