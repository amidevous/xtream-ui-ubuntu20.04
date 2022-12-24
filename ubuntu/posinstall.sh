#!/bin/bash
echo -e "\nChecking that minimal requirements are ok"
# Ensure the OS is compatible with the launcher
if [ -f /etc/centos-release ]; then
    inst() {
       rpm -q "$1" &> /dev/null
    } 
    if (inst "centos-stream-repos"); then
    OS="Centos Stream"
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
echo "Detected : $OS  $VER  $ARCH"
#if [[ "$OS" = "CentOs" && "$VER" = "7" && "$ARCH" == "x86_64" ||
#"$OS" = "Centos Stream" && "$VER" = "8" && "$ARCH" == "x86_64" ||
#"$OS" = "Fedora" && ("$VER" = "34" || "$VER" = "35" || "$VER" = "36" ) && "$ARCH" == "x86_64" ||
#"$OS" = "Ubuntu" && ("$VER" = "18.04" || "$VER" = "20.04" || "$VER" = "22.04" ) && "$ARCH" == "x86_64" ||
#"$OS" = "debian" && ("$VER" = "10" || "$VER" = "11" ) && "$ARCH" == "x86_64" ]] ; then
if [[ "$OS" = "Ubuntu" && ("$VER" = "18.04" || "$VER" = "20.04" || "$VER" = "22.04" ) && "$ARCH" == "x86_64" ||
"$OS" = "debian" && "$VER" = "10" && "$ARCH" == "x86_64" ]] ; then ]] ; then
echo "Ok."
else
    echo "Sorry, this OS is not supported by Xtream UI."
    exit 1
fi
if [[ "$OS" = "Ubuntu" ]] ; then
if [[ "$VER" = "10" ]] ; then
apt-get -y install libcurl4 curl
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/xcfreetype2_2.12-1_amd64_debian_10.deb -O xcphp_7.3.33-1_amd64.deb
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/xcphp_7.3.33-1_amd64_debian_10.deb -O xcphp_7.3.33-1_amd64.deb
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/xcphpmcrypt_1.0.5-1_amd64_debian_10.deb -O xcphp-mcrypt_1.0.5-1_amd64.deb
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/xcphpgeoip_1.1.1-1_amd64_debian_10.deb -O xcphpgeoip_1.1.1-1_amd64.deb
dpkg -i xcphp_7.3.33-1_amd64.deb
rm -f xcphp_7.3.33-1_amd64.deb
dpkg -i xcphp_7.3.33-1_amd64.deb
rm -f xcphp_7.3.33-1_amd64.deb
dpkg -i xcphp-mcrypt_1.0.5-1_amd64.deb
rm -f xcphp-mcrypt_1.0.5-1_amd64.deb
dpkg -i xcphpgeoip_1.1.1-1_amd64.deb
rm -f xcphpgeoip_1.1.1-1_amd64.deb
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20170718/
wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -O ioncube_loaders_lin_x86-64.tar.gz
tar -zxvf ioncube_loaders_lin_x86*
cp ioncube/ioncube_loader_lin_7.3.so /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20180731/
rm -f ioncube*
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/php.ini -O /home/xtreamcodes/iptv_xtream_codes/php/lib/php.ini
rm -f /home/xtreamcodes/iptv_xtream_codes/php/VaiIb8.pid /home/xtreamcodes/iptv_xtream_codes/php/JdlJXm.pid /home/xtreamcodes/iptv_xtream_codes/php/CWcfSP.pid.bk /home/xtreamcodes/iptv_xtream_codes/php/CWcfSP.pid
elif [[ "$VER" = "11" ]] ; then
echo "rien"
fi
fi
if [[ "$OS" = "Ubuntu" ]] ; then
if [[ "$VER" = "18.04" ]] ; then
apt-get -y install libcurl3
elif [[ "$VER" = "20.04" ]] ; then
apt-get -y install libcurl4 curl
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/xcphp_7.3.33-1_amd64_20.04.deb -O xcphp_7.3.33-1_amd64.deb
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/xcphp-mcrypt_1.0.5-1_amd64_20.04.deb -O xcphp-mcrypt_1.0.5-1_amd64.deb
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/xcphpgeoip_1.1.1-1_amd64_20.04.deb -O xcphpgeoip_1.1.1-1_amd64.deb
dpkg -i xcphp_7.3.33-1_amd64.deb
rm -f xcphp_7.3.33-1_amd64.deb
dpkg -i xcphp-mcrypt_1.0.5-1_amd64.deb
rm -f xcphp-mcrypt_1.0.5-1_amd64.deb
dpkg -i xcphpgeoip_1.1.1-1_amd64.deb
rm -f xcphpgeoip_1.1.1-1_amd64.deb
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20170718/
wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -O ioncube_loaders_lin_x86-64.tar.gz
tar -zxvf ioncube_loaders_lin_x86*
cp ioncube/ioncube_loader_lin_7.3.so /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20180731/
rm -f ioncube*
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/php.ini -O /home/xtreamcodes/iptv_xtream_codes/php/lib/php.ini
rm -f /home/xtreamcodes/iptv_xtream_codes/php/VaiIb8.pid /home/xtreamcodes/iptv_xtream_codes/php/JdlJXm.pid /home/xtreamcodes/iptv_xtream_codes/php/CWcfSP.pid.bk /home/xtreamcodes/iptv_xtream_codes/php/CWcfSP.pid
elif [[ "$VER" = "22.04" ]] ; then
apt-get -y install libcurl4 curl
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/xcfreetype2_2.12-1_amd64_22.04.deb -O xcphp_7.3.33-1_amd64.deb
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/xcphp_7.3.33-1_amd64_22.04.deb -O xcphp_7.3.33-1_amd64.deb
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/xcphpmcrypt_1.0.5-1_amd64_22.04.deb -O xcphp-mcrypt_1.0.5-1_amd64.deb
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/xcphpgeoip_1.1.1-1_amd64_22.04.deb -O xcphpgeoip_1.1.1-1_amd64.deb
dpkg -i xcphp_7.3.33-1_amd64.deb
rm -f xcphp_7.3.33-1_amd64.deb
dpkg -i xcphp_7.3.33-1_amd64.deb
rm -f xcphp_7.3.33-1_amd64.deb
dpkg -i xcphp-mcrypt_1.0.5-1_amd64.deb
rm -f xcphp-mcrypt_1.0.5-1_amd64.deb
dpkg -i xcphpgeoip_1.1.1-1_amd64.deb
rm -f xcphpgeoip_1.1.1-1_amd64.deb
rm -rf /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20170718/
wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -O ioncube_loaders_lin_x86-64.tar.gz
tar -zxvf ioncube_loaders_lin_x86*
cp ioncube/ioncube_loader_lin_7.3.so /home/xtreamcodes/iptv_xtream_codes/php/lib/php/extensions/no-debug-non-zts-20180731/
rm -f ioncube*
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/ubuntu/php.ini -O /home/xtreamcodes/iptv_xtream_codes/php/lib/php.ini
rm -f /home/xtreamcodes/iptv_xtream_codes/php/VaiIb8.pid /home/xtreamcodes/iptv_xtream_codes/php/JdlJXm.pid /home/xtreamcodes/iptv_xtream_codes/php/CWcfSP.pid.bk /home/xtreamcodes/iptv_xtream_codes/php/CWcfSP.pid
fi
apt-get -y install daemonize
wget https://raw.githubusercontent.com/amidevous/xtream-ui-ubuntu20.04/master/start_services.sh -O /home/xtreamcodes/iptv_xtream_codes/start_services.sh
chmod +x /home/xtreamcodes/iptv_xtream_codes/start_services.sh
fi
