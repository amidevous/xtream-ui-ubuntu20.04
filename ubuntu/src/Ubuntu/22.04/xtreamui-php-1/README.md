`cd $HOME`

`sudo mkdir -p /usr/lib/pbuilder/hooks`

`sudo wget -O /usr/lib/pbuilder/hooks/pbuilderhooks https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/src/Ubuntu/22.04/xtreamui-php-1/pbuilderhooks`

`sudo yum -y remove rpmdevtools`

`sudo yum -y install devscripts pbuilder wget ca-certificates`

`sudo apt-get -y install pbuilder debhelper cdbs lintian build-essential fakeroot devscripts dh-make dput wget ca-certificates`

`sudo wget -O /etc/pbuilder/ubuntu-jammy-amd64 https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/src/pbuilder/ubuntu-jammy-amd64-xtreamui-php`

`sudo pbuilder create --configfile /etc/pbuilder/ubuntu-jammy-amd64`

`sudo pbuilder update --override-config --configfile /etc/pbuilder/ubuntu-jammy-amd64`

`wget -O $HOME/build-php.sh https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/src/Ubuntu/22.04/xtreamui-php-1/build.sh`

`sudo bash $HOME/build-php.sh`

`rm -f $HOME/build-php.sh`