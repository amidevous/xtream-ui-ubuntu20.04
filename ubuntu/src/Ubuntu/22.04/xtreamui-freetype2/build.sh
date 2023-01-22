#!/bin/bash
cd /root
wget -O /root/xtreamui-freetype2_2.12.0.orig.tar.xz https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-freetype2/xtreamui-freetype2_2.12.0.orig.tar.xz
tar -xf /root/xtreamui-freetype2_2.12.0.orig.tar.xz
cd /root/freetype-2.12.0/
mkdir -p /root/freetype-2.12.0/debian/source
wget -O /root/freetype-2.12.0/debian/source/format https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-freetype2/debian/source/format
wget -O /root/freetype-2.12.0/debian/README.Debian https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-freetype2/debian/README.Debian
wget -O /root/freetype-2.12.0/debian/README.source https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-freetype2/debian/README.source
wget -O /root/freetype-2.12.0/debian/changelog https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-freetype2/debian/changelog
wget -O /root/freetype-2.12.0/debian/compat https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-freetype2/debian/compat
wget -O /root/freetype-2.12.0/debian/control https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-freetype2/debian/control
wget -O /root/freetype-2.12.0/debian/copyright https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-freetype2/debian/copyright
wget -O /root/freetype-2.12.0/debian/freetype-docs.docs https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-freetype2/debian/freetype-docs.docs
wget -O /root/freetype-2.12.0/debian/rules https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-freetype2/debian/rules
debuild -S -sa -d
cd /root
pbuilder build --configfile /etc/pbuilder/ubuntu-jammy-amd64 /root/xtreamui-freetype2_2.12.0-2.dsc
cp /var/cache/pbuilder/result/xtreamui-freetype2_2.12.0-2_amd64.deb /root/
rm -rf /root/xtreamui-freetype2_2.12.0-2.debian.tar.xz /root/xtreamui-freetype2_2.12.0-2.dsc /root/xtreamui-freetype2_2.12.0.orig.tar.xz
rm -rf /root/xtreamui-freetype2_2.12.0-2_source.build xtreamui-freetype2_2.12.0-2_source.buildinfo xtreamui-freetype2_2.12.0-2_source.changes
