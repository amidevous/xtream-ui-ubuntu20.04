`cd /root/`

`wget -O /root/xtreamui-freetype2_2.12.0-2.debian.tar.xz https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-freetype2/xtreamui-freetype2_2.12.0-2.debian.tar.xz`

`wget -O /root/xtreamui-freetype2_2.12.0-2.dsc https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-freetype2/xtreamui-freetype2_2.12.0-2.dsc`

`wget -O /root/xtreamui-freetype2_2.12.0.orig.tar.xz https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-freetype2/xtreamui-freetype2_2.12.0.orig.tar.xz`

`pbuilder build --configfile /etc/pbuilder/ubuntu-jammy-amd64 /root/xtreamui-freetype2_2.12.0-2.dsc`

`cp /var/cache/pbuilder/result/xtreamui-freetype2_2.12.0-2_amd64.deb /root/`

`rm -rf /root/xtreamui-freetype2_2.12.0-2.debian.tar.xz /root/xtreamui-freetype2_2.12.0-2.dsc /root/xtreamui-freetype2_2.12.0.orig.tar.xz`

