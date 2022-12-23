#!/bin/bash
apt-get -y install libcurl4 curl
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/xcphp_7.3.33-1_amd64.deb -O xcphp_7.3.33-1_amd64.deb
dpkg -i xcphp_7.3.33-1_amd64.deb
rm -f xcphp_7.3.33-1_amd64.deb
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/xcphp-mcrypt_1.0.5-1_amd64.deb -O xcphp-mcrypt_1.0.5-1_amd64.deb
dpkg -i xcphp-mcrypt_1.0.5-1_amd64.deb
rm -f xcphp-mcrypt_1.0.5-1_amd64.deb
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/xcphpgeoip_1.1.1-1_amd64.deb -O xcphpgeoip_1.1.1-1_amd64.deb
dpkg -i xcphpgeoip_1.1.1-1_amd64.deb
rm -f xcphpgeoip_1.1.1-1_amd64.deb
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20170718/
wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -O ioncube_loaders_lin_x86-64.tar.gz
tar -zxvf ioncube_loaders_lin_x86*
cp ioncube/ioncube_loader_lin_7.3.so /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20180731/
rm -f ioncube*
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/php.ini -O /home/xtreamcodes/iptv_xtream_codes/php/lib/php.ini
rm -f /home/xtreamcodes/iptv_xtream_codes/php/VaiIb8.pid /home/xtreamcodes/iptv_xtream_codes/php/JdlJXm.pid /home/xtreamcodes/iptv_xtream_codes/php/CWcfSP.pid.bk
