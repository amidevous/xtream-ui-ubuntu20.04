#!/bin/bash
clear
#### variable couleurs ...
txtgreen=$(tput bold ; tput setaf 2) # GreenBold
txtyellow=$(tput bold ; tput setaf 3) # YellowBold
echo " "
echo -e "${txtyellow} ┌────────────────────────────────────────────┐ "
echo -e "${txtyellow} │[R]    Check Version of OS Please Wait...   │ "
echo -e "${txtyellow} └────────────────────────────────────────────┘ "
echo " "
sleep 3s
#check ubuntu 18.04 is installed 
if [[ `lsb_release -rs` == "18.04" ]] 
then
echo " "
echo -e "${txtyellow} ┌────────────────────────────────────────────┐ "
echo -e "${txtyellow} │[R]  ubuntu 18.04 is installed...proceed    │ "
echo -e "${txtyellow} └────────────────────────────────────────────┘ "
echo " "
else
echo " "
echo -e "${txtyellow} ┌────────────────────────────────────────────┐ "
echo -e "${txtyellow} │[R] ubuntu 18.04 is not installed...exiting │ "
echo -e "${txtyellow} └────────────────────────────────────────────┘ "
echo " "
exit 1
fi
sleep 3s
clear
echo " "
echo -e "${txtyellow} ┌────────────────────────────────────────────┐ "
echo -e "${txtyellow} │[R]      BRUTUS SCRIPT Please Wait...       │ "
echo -e "${txtyellow} └────────────────────────────────────────────┘ "
echo " "
apt-get update &> /dev/null
sleep 1s
apt-get install net-tools curl -y &> /dev/null
sleep 1s
clear
echo " "
echo -e "${txtyellow} ┌────────────────────────────────────────────┐ "
echo -e "${txtyellow} │[R]       STARTING BRUTUS SCRIPT...         │ "
echo -e "${txtyellow} └────────────────────────────────────────────┘ "
echo " "
#### variable pour mysql : pass, host , carte reseau ...
blofish=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 50 | head -n 1)
CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"
alg=6
salt='rounds=20000$xtreamcodes'
XPASS=$(</dev/urandom tr -dc A-Z-a-z-0-9 | head -c16)
zzz=$(</dev/urandom tr -dc A-Z-a-z-0-9 | head -c20)
eee=$(</dev/urandom tr -dc A-Z-a-z-0-9 | head -c10)
rrr=$(</dev/urandom tr -dc A-Z-a-z-0-9 | head -c20)
ipaddr=$(hostname -I | awk '{print $1}')
sleep 1s
versionn=$(lsb_release -d -s)
cartereseau=$(route | grep default | awk '{print $8}')
nginx111='$uri'
nginx222='$document_root$fastcgi_script_name'
nginx333='$fastcgi_script_name'
nginx444='$host:$server_port$request_uri'
spinner()
{
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}
##################

read -p "${txtgreen}...... Enter Your Desired Login Access: " adminn
echo " "
read -p "${txtgreen}...... Enter Your Desired Password Access: " adminpass
echo " "
read -p "${txtgreen}...... Enter Your Desired Port Access: " ACCESPORT
echo " "
read -p "${txtgreen}...... Enter Your Desired MYSQL Password: " PASSMYSQL
echo " "
read -p "${txtgreen}...... Enter Your ssh port: " PORTSSH
echo " "
kkkk=$(perl -e 'print crypt($ARGV[1], "\$" . $ARGV[0] . "\$" . $ARGV[2]), "\n";' "$alg" "$adminpass" "$salt")
sleep 1
clear
echo " "
echo -e "${txtyellow} ┌────────────────────────────────────────────┐ "
echo -e "${txtyellow} │[R]       STARTING INSTALLATION...          │ "
echo -e "${txtyellow} └────────────────────────────────────────────┘ "
sleep 3s
echo -e "\n\e[8mWelcome to XtreamCodes V2\e[0m"
echo -n "[+] Installation Of Packages..."
sleep 1

{
#### suprime des fichiers avant l'installation
rm -r /var/lib/dpkg/lock-frontend
sleep 1s
rm -r /var/cache/apt/archives/lock
sleep 1s
rm -r /var/lib/dpkg/lock
sleep 1s
##################


#### installation des essentiels
apt-get install software-properties-common -y
sleep 1s
apt-get remove --auto-remove libcurl4 -y
sleep 1s
apt-get install libcurl3 libxslt1-dev libgeoip-dev e2fsprogs wget python mcrypt nscd htop unzip ufw apache2 -y
sleep 1s
apt-get install dirmngr --install-recommends -y
sleep 1s
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sleep 1s
add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://mirrors.nxthost.com/mariadb/repo/10.3/ubuntu/ bionic main'
sleep 1s
apt-get update
sleep 1s
debconf-set-selections <<< "mariadb-server-10.3 mysql-server/root_password password $PASSMYSQL"
sleep 1s
debconf-set-selections <<< "mariadb-server-10.3 mysql-server/root_password_again password $PASSMYSQL"
sleep 1s
apt-get -y install mariadb-server-10.3
sleep 1s
echo "postfix postfix/mailname string postfixmessage" | debconf-set-selections
sleep 1s
echo "postfix postfix/main_mailer_type string 'Local only'" | debconf-set-selections
sleep 1s
apt install -y postfix
sleep 1s
wget -q -O /tmp/libpng12.deb https://xtream-brutus.com/v3/libpng12-0_1.2.54-1ubuntu1_amd64.deb
sleep 1s
dpkg -i /tmp/libpng12.deb
sleep 1s
apt-get install -y
sleep 1s
rm -r /tmp/libpng12.deb
sleep 1s
##################
} &> /dev/null & spinner $!
echo -e "\\r${CHECK_MARK} Installation Of Packages Done"
sleep 1s
echo -n "[+] Installation Of XtreamCodes..."
sleep 1s


{
#### installation de xtream codes
adduser --system --shell /bin/false --group --disabled-login xtreamcodes
sleep 1s
wget -q -O /tmp/xtreamcodes.tar.gz https://xtream-brutus.com/v3/mainbru2.tgz
sleep 1s
tar -zxvf "/tmp/xtreamcodes.tar.gz" -C "/home/xtreamcodes/"
sleep 1s
rm -r /tmp/xtreamcodes.tar.gz
sleep 1s
mv /etc/mysql/my.cnf /etc/mysql/my.cnf.xc
sleep 1s
echo IyBYdHJlYW0gQ29kZXMNCg0KW2NsaWVudF0NCnBvcnQgICAgICAgICAgICA9IDMzMDYNCg0KW215c3FsZF9zYWZlXQ0KbmljZSAgICAgICAgICAgID0gMA0KDQpbbXlzcWxkXQ0KdXNlciAgICAgICAgICAgID0gbXlzcWwNCnBvcnQgICAgICAgICAgICA9IDc5OTkNCmJhc2VkaXIgICAgICAgICA9IC91c3INCmRhdGFkaXIgICAgICAgICA9IC92YXIvbGliL215c3FsDQp0bXBkaXIgICAgICAgICAgPSAvdG1wDQpsYy1tZXNzYWdlcy1kaXIgPSAvdXNyL3NoYXJlL215c3FsDQpza2lwLWV4dGVybmFsLWxvY2tpbmcNCnNraXAtbmFtZS1yZXNvbHZlPTENCg0KYmluZC1hZGRyZXNzICAgICAgICAgICAgPSAqDQprZXlfYnVmZmVyX3NpemUgPSAxMjhNDQoNCm15aXNhbV9zb3J0X2J1ZmZlcl9zaXplID0gNE0NCm1heF9hbGxvd2VkX3BhY2tldCAgICAgID0gNjRNDQpteWlzYW0tcmVjb3Zlci1vcHRpb25zID0gQkFDS1VQDQptYXhfbGVuZ3RoX2Zvcl9zb3J0X2RhdGEgPSA4MTkyDQpxdWVyeV9jYWNoZV9saW1pdCAgICAgICA9IDRNDQpxdWVyeV9jYWNoZV9zaXplICAgICAgICA9IDI1Nk0NCg0KDQpleHBpcmVfbG9nc19kYXlzICAgICAgICA9IDEwDQptYXhfYmlubG9nX3NpemUgICAgICAgICA9IDEwME0NCg0KbWF4X2Nvbm5lY3Rpb25zICA9IDIwMDAwDQpiYWNrX2xvZyA9IDQwOTYNCm9wZW5fZmlsZXNfbGltaXQgPSAyMDI0MA0KaW5ub2RiX29wZW5fZmlsZXMgPSAyMDI0MA0KbWF4X2Nvbm5lY3RfZXJyb3JzID0gMzA3Mg0KdGFibGVfb3Blbl9jYWNoZSA9IDQwOTYNCnRhYmxlX2RlZmluaXRpb25fY2FjaGUgPSA0MDk2DQoNCg0KdG1wX3RhYmxlX3NpemUgPSAxRw0KbWF4X2hlYXBfdGFibGVfc2l6ZSA9IDFHDQoNCmlubm9kYl9idWZmZXJfcG9vbF9zaXplID0gMTBHDQppbm5vZGJfYnVmZmVyX3Bvb2xfaW5zdGFuY2VzID0gMTANCmlubm9kYl9yZWFkX2lvX3RocmVhZHMgPSA2NA0KaW5ub2RiX3dyaXRlX2lvX3RocmVhZHMgPSA2NA0KaW5ub2RiX3RocmVhZF9jb25jdXJyZW5jeSA9IDANCmlubm9kYl9mbHVzaF9sb2dfYXRfdHJ4X2NvbW1pdCA9IDANCmlubm9kYl9mbHVzaF9tZXRob2QgPSBPX0RJUkVDVA0KcGVyZm9ybWFuY2Vfc2NoZW1hID0gMA0KaW5ub2RiLWZpbGUtcGVyLXRhYmxlID0gMQ0KaW5ub2RiX2lvX2NhcGFjaXR5PTIwMDAwDQppbm5vZGJfdGFibGVfbG9ja3MgPSAwDQppbm5vZGJfbG9ja193YWl0X3RpbWVvdXQgPSAwDQppbm5vZGJfZGVhZGxvY2tfZGV0ZWN0ID0gMA0KDQoNCnNxbC1tb2RlPSJOT19FTkdJTkVfU1VCU1RJVFVUSU9OIg0KDQpbbXlzcWxkdW1wXQ0KcXVpY2sNCnF1b3RlLW5hbWVzDQptYXhfYWxsb3dlZF9wYWNrZXQgICAgICA9IDE2TQ0KDQpbbXlzcWxdDQoNCltpc2FtY2hrXQ0Ka2V5X2J1ZmZlcl9zaXplICAgICAgICAgICAgICA9IDE2TQ0K | base64 --decode > /etc/mysql/my.cnf
sleep 1s
service mysql restart
sleep 1s
##################
} &> /dev/null & spinner $!

echo -e "\\r${CHECK_MARK} Installation Of XtreamCodes Done"
sleep 1s
echo -n "[+] Configuration Of Mysql & Nginx..."
sleep 1s

{
#### config base de données
## ajout de python script
python << END
# coding: utf-8
import subprocess, os, random, string, sys, shutil, socket
from itertools import cycle, izip
class col:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
rHost = "127.0.0.1"
rPassword = "$XPASS"
rServerID = 1
rUsername = "user_iptvpro"
rDatabase = "xtream_iptvpro"
rPort = 7999
rExtra = " -p$PASSMYSQL"
reseau = "$cartereseau"
portadmin = "$ACCESPORT"
getIP = "$ipaddr"
sshssh = "$PORTSSH"
getVersion = "$versionn"
generate1 = "$zzz"
generate2 = "$eee"
generate3 = "$rrr"
def encrypt(rHost="127.0.0.1", rUsername="user_iptvpro", rPassword="", rDatabase="xtream_iptvpro", rServerID=1, rPort=7999):
    rf = open('/home/xtreamcodes/iptv_xtream_codes/config', 'wb')
    rf.write(''.join(chr(ord(c)^ord(k)) for c,k in izip('{\"host\":\"%s\",\"db_user\":\"%s\",\"db_pass\":\"%s\",\"db_name\":\"%s\",\"server_id\":\"%d\", \"db_port\":\"%d\"}' % (rHost, rUsername, rPassword, rDatabase, rServerID, rPort), cycle('5709650b0d7806074842c6de575025b1'))).encode('base64').replace('\n', ''))
    rf.close()
def modifyNginx():
    rPath = "/home/xtreamcodes/iptv_xtream_codes/nginx/conf/nginx.conf"
    rPrevData = open(rPath, "r").read()
    rData = "}".join(rPrevData.split("}")[:-1]) + "    server {\n        listen $ACCESPORT;\n        index index.php index.html index.htm;\n        root /home/xtreamcodes/iptv_xtream_codes/admin/;\n\n        location ~ \.php$ {\n			limit_req zone=one burst=8;\n            try_files ${nginx111} =404;\n			fastcgi_index index.php;\n			fastcgi_pass php;\n			include fastcgi_params;\n			fastcgi_buffering on;\n			fastcgi_buffers 96 32k;\n			fastcgi_buffer_size 32k;\n			fastcgi_max_temp_file_size 0;\n			fastcgi_keep_conn on;\n			fastcgi_param SCRIPT_FILENAME ${nginx222};\n			fastcgi_param SCRIPT_NAME ${nginx333};\n        }\n    }\n}"
    rFile = open(rPath, "w")
    rFile.write(rData)
    rFile.close()
def mysql():
    os.system('mysql -u root%s -e "DROP DATABASE IF EXISTS xtream_iptvpro; CREATE DATABASE IF NOT EXISTS xtream_iptvpro;" > /dev/null' % rExtra)
    os.system("mysql -u root%s xtream_iptvpro < /home/xtreamcodes/iptv_xtream_codes/database.sql > /dev/null" % rExtra)
    os.system('mysql -u root%s -e "USE xtream_iptvpro; UPDATE settings SET live_streaming_pass = \'%s\', unique_id = \'%s\', crypt_load_balancing = \'%s\', port_admin = \'%s\';" > /dev/null' % (rExtra, generate1, generate2, generate3, portadmin))
    os.system('mysql -u root%s -e "USE xtream_iptvpro; REPLACE INTO streaming_servers (id, server_name, domain_name, server_ip, vpn_ip, ssh_password, ssh_port, diff_time_main, http_broadcast_port, total_clients, system_os, network_interface, latency, status, enable_geoip, geoip_countries, last_check_ago, can_delete, server_hardware, total_services, persistent_connections, rtmp_port, geoip_type, isp_names, isp_type, enable_isp, boost_fpm, http_ports_add, network_guaranteed_speed, https_broadcast_port, https_ports_add, whitelist_ips, watchdog_data, timeshift_only) VALUES (1, \'Main Server\', \'\', \'%s\', \'\', NULL, \'%s\', 0, 2082, 1000, \'%s\', \'%s\', 0, 1, 0, \'\', 0, 0, \'{}\', 3, 0, 2086, \'low_priority\', \'\', \'low_priority\', 0, 0, \'\', 1000, 2083, \'\', \'[\"127.0.0.1\",\"\"]\', \'{}\', 0);" > /dev/null' % (rExtra, getIP, sshssh, getVersion, reseau))
    os.system('mysql -u root%s -e "GRANT ALL PRIVILEGES ON *.* TO \'%s\'@\'%%\' IDENTIFIED BY \'%s\' WITH GRANT OPTION; FLUSH PRIVILEGES;" > /dev/null' % (rExtra, rUsername, rPassword))
mysql()
encrypt(rHost, rUsername, rPassword, rDatabase, rServerID, rPort)
modifyNginx()
END
sleep 2s
##################

##############################
mysql --user=root --password=$PASSMYSQL xtream_iptvpro << eof
UPDATE reg_users SET username = '$adminn' WHERE id='1';
UPDATE reg_users SET password = '$kkkk' WHERE id='1';
eof
#########################################
} &> /dev/null & spinner $!

echo -e "\\r${CHECK_MARK} Configuration Of Mysql & Nginx Done"
sleep 1s
echo -n "[+] Configuration Of Crons & Autorisations..."
sleep 1s
{
#### modif de fichiers et autre config xtream : nginx, ffmpeg,.....
rm -r /home/xtreamcodes/iptv_xtream_codes/database.sql
sleep 1s
echo "xtreamcodes ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
sleep 1s
ln -s /home/xtreamcodes/iptv_xtream_codes/bin/ffmpeg /usr/bin/
sleep 1s
echo "tmpfs /home/xtreamcodes/iptv_xtream_codes/streams tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=90% 0 0" >> /etc/fstab
sleep 1s
echo "tmpfs /home/xtreamcodes/iptv_xtream_codes/tmp tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=2G 0 0" >> /etc/fstab
sleep 1s
chmod -R 0777 /home/xtreamcodes
sleep 1s
##################
} &> /dev/null & spinner $!

echo -e "\\r${CHECK_MARK} Configuration Of Crons & Autorisations Done"
sleep 1s
echo -n "[+] installation Of Admin Web Access..."
sleep 1s
{
#### update xtream r21
apt-get install e2fsprogs python-paramiko -y
sleep 1s
wget -q -O /tmp/update.zip https://xtream-brutus.com/v3/updssl/brutus_files.php?id=brutusroc
sleep 1s
unzip -o /tmp/update.zip -d /tmp/update/
sleep 1s
cp -rf /tmp/update/BRUTUS/* /home/xtreamcodes/iptv_xtream_codes/
sleep 1s
rm -rf /tmp/update/BRUTUS
sleep 1s
rm /tmp/update.zip
sleep 1s
rm -rf /tmp/update
sleep 1s
chown xtreamcodes:xtreamcodes -R /home/xtreamcodes
sleep 1s
chmod +x /home/xtreamcodes/iptv_xtream_codes/start_services.sh
sleep 1s
chmod +x /home/xtreamcodes/iptv_xtream_codes/permissions.sh
sleep 1s
chmod -R 0777 /home/xtreamcodes/iptv_xtream_codes/crons
sleep 1s
##################
} &> /dev/null & spinner $!

echo -e "\\r${CHECK_MARK} installation Of Admin Web Access Done"
sleep 1s
echo -n "[+] installation Of PhpMyAdmin..."
sleep 1s
{
#### install phpmyadmin

sudo apt-get -y install debconf-utils
sleep 1s
sudo debconf-set-selections <<<'phpmyadmin phpmyadmin/internal/skip-preseed boolean true'
sleep 1s
sudo debconf-set-selections <<<'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'
sleep 1s
sudo debconf-set-selections <<<'phpmyadmin phpmyadmin/dbconfig-install boolean false'
sleep 1s
sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y phpmyadmin
sleep 2s
##################


#### fix bug phpmyadmin
mv /usr/share/phpmyadmin/ /usr/share/phpmyadmin.bakkk
sleep 1s
wget https://xtream-brutus.com/v3/phpMyAdmin-4.9.5-all-languages.zip
sleep 1s
unzip phpMyAdmin-4.9.5-all-languages.zip
sleep 1s
mv phpMyAdmin-4.9.5-all-languages /usr/share/phpmyadmin
sleep 1s
rm -r phpMyAdmin-4.9.5-all-languages.zip
sleep 1s
sed -i "s/blowfish_secret'] = '/blowfish_secret'] = '$blofish/g" /usr/share/phpmyadmin/libraries/config.default.php
sleep 1s
##################


#### fix bug xtream a l install de phpmyadmin
sudo apt-get remove --auto-remove libcurl4-openssl-dev -y
sleep 1s
sudo apt-get install libcurl3 -y
sleep 1s
##################
} &> /dev/null & spinner $!

echo -e "\\r${CHECK_MARK} Installation Of PhpMyAdmin Done"
sleep 1s
echo -n "[+] Configuration Auto Start..."
sleep 1s

{
#### demarre xtream au redemarage du server
echo "@reboot root sudo /home/xtreamcodes/iptv_xtream_codes/start_services.sh" >> /etc/crontab
sleep 1s
#### demarage de xtreamcodes
sed -i "s/Listen 80/Listen 8443/g" /etc/apache2/ports.conf
sleep 1s
sed -i "s/Listen 443/Listen 70/g" /etc/apache2/ports.conf
sleep 1s
sed -i "s/80/8443/g" /etc/apache2/sites-available/000-default.conf
sleep 1s
sed -i "s/443/70/g" /etc/apache2/sites-available/default-ssl.conf
sleep 1s
service apache2 restart
sleep 1s
/home/xtreamcodes/iptv_xtream_codes/nginx/sbin/nginx -s reload
sleep 1s
sudo ufw default deny incoming
sleep 1s
sudo ufw default allow outgoing
sleep 1s
sudo ufw allow $PORTSSH
sleep 1s
sudo ufw allow $ACCESPORT
sleep 1s
sudo ufw allow 8443
sleep 1s
sudo ufw allow 2082
sleep 1s
sudo ufw allow 2083
sleep 1s
sudo ufw allow 2086
sleep 1s
echo y | sudo ufw enable
sleep 1s
/home/xtreamcodes/iptv_xtream_codes/permissions.sh
sleep 1s
/home/xtreamcodes/iptv_xtream_codes/start_services.sh
sleep 5s
##################
} &> /dev/null & spinner $!

echo -e "\\r${CHECK_MARK} Configuration Auto Start Done"
sleep 1s
echo " "
echo -e "${txtyellow} ┌────────────────────────────────────────────┐ "
echo -e "${txtyellow} │[R]        XtreamCodes Is Ready...          │ "
echo -e "${txtyellow} └────────────────────────────────────────────┘ "

############## info install /root/infoinstall.txt ###################
## afficher les infos sur putty 
echo "${txtyellow}
─────────────────  Saved In: /root/Xtreaminfo.txt  ─────────────────
│ PANEL ACCESS: http://$ipaddr:$ACCESPORT
│ USERNAME: $adminn
│ PASSWORD: $adminpass
│ MYSQL root PASS: $PASSMYSQL
│ MYSQL user_iptvpro PASS: $XPASS
────────────────────────────────────────────────────────────────────
${txtrst}"
######################################################################
## copier les infos dans un fichier text
echo "
───────────────────────────  INFO  ─────────────────────────────────
│
│ PANEL ACCESS: http://$ipaddr:$ACCESPORT
│ 
│ USERNAME: $adminn
│
│ PASSWORD: $adminpass
│ 
│ MYSQL root PASS: $PASSMYSQL
│
│ MYSQL user_iptvpro PASS: $XPASS
│ 
────────────────────────────────────────────────────────────────────
" >> /root/Xtreaminfo.txt
#### 
sleep 1s
##################