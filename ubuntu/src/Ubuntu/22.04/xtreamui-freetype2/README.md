`cd /root/`

`yum -y remove rpmdevtools`

`yum -y install devscripts pbuilder wget ca-certificates`

`apt-get -y install pbuilder debhelper cdbs lintian build-essential fakeroot devscripts dh-make dput wget ca-certificates`

`wget -O /etc/pbuilder/ubuntu-jammy-amd64 https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/pbuilder/ubuntu-jammy-amd64`

`pbuilder build --configfile /etc/pbuilder/ubuntu-jammy-amd64 /root/xtreamui-freetype2_2.12.0-2.dsc`

`wget -O /root/build-freetype.sh https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/ubuntu/src/Ubuntu/22.04/xtreamui-freetype2/build.sh`

`bash /root/build-freetype.sh`

