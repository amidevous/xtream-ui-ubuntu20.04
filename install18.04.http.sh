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
apt-get update
sleep 1s
DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade
sleep 1s
apt-get install net-tools curl -y
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

read -p "${txtgreen}...... Enter Your Desired Admin Login Access: " adminn
echo " "
read -p "${txtgreen}...... Enter Your Desired Admin Password Access: " adminpass
echo " "
read -p "${txtgreen}...... Enter Your Desired Admin Port Access: " ACCESPORT
echo " "
read -p "${txtgreen}...... Enter Your Desired Client Port Access: " CLIENTACCESPORT
echo " "
read -p "${txtgreen}...... Enter Your Desired Apache Port Access: " APACHEACCESPORT
echo " "
read -p "${txtgreen}...... Enter Your Email Addres: " EMAIL
echo " "
read -p "${txtgreen}...... Enter Your Desired MYSQL Password: " PASSMYSQL
echo " "
PORTSSH=22
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


#### suprime des fichiers avant l'installation
rm -r /var/lib/dpkg/lock-frontend
sleep 1s
rm -r /var/cache/apt/archives/lock
sleep 1s
rm -r /var/lib/dpkg/lock
sleep 1s
##################


#### installation des essentiels
apt-get install software-properties-common dirmngr --install-recommends -y
sleep 1s
add-apt-repository ppa:andykimpe/curl -y -s
sleep 1s
apt-get update
sleep 1s
DEBIAN_FRONTEND=noninteractive apt-get purge libcurl3 -y
sleep 1s
DEBIAN_FRONTEND=noninteractive apt-get install libcurl4 libxslt1-dev libgeoip-dev e2fsprogs wget python mcrypt nscd htop unzip ufw apache2 -y
sleep 1s
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
sleep 1s
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sleep 1s
add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://mirrors.nxthost.com/mariadb/repo/10.5/ubuntu/ bionic main'
sleep 1s
apt-get update
sleep 1s
debconf-set-selections <<< "mariadb-server-10.5 mysql-server/root_password password $PASSMYSQL"
sleep 1s
debconf-set-selections <<< "mariadb-server-10.5 mysql-server/root_password_again password $PASSMYSQL"
sleep 1s
apt-get -y install mariadb-server-10.5 mariadb-server
sleep 1s
systemctl restart mariadb
sleep 1s
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$PASSMYSQL'; flush privileges;"
sleep 1s
echo "postfix postfix/mailname string postfixmessage" | debconf-set-selections
sleep 1s
echo "postfix postfix/main_mailer_type string 'Local only'" | debconf-set-selections
sleep 1s
apt install -y postfix
sleep 1s
wget -q -O /tmp/libpng12.deb https://github.com/amidevous/xtream-ui-ubuntu20.04/releases/download/start/libpng12-0_1.2.54-1ubuntu1_amd64.deb
sleep 1s
dpkg -i /tmp/libpng12.deb
sleep 1s
apt-get install -y
sleep 1s
rm -r /tmp/libpng12.deb
sleep 1s
##################
echo -e "\\r${CHECK_MARK} Installation Of Packages Done"
sleep 1s
echo -n "[+] Installation Of XtreamCodes..."
sleep 1s



#### installation de xtream codes
adduser --system --shell /bin/false --group --disabled-login xtreamcodes
sleep 1s
wget -q -O /tmp/xtreamcodes.tar.gz https://github.com/amidevous/xtream-ui-ubuntu20.04/releases/download/start/main_xtreamcodes_reborn.tar.gz
sleep 1s
tar -zxvf "/tmp/xtreamcodes.tar.gz" -C "/home/xtreamcodes/"
sleep 1s
rm -r /tmp/xtreamcodes.tar.gz
sleep 1s
mv /etc/mysql/my.cnf /etc/mysql/my.cnf.xc
sleep 1s
echo IyBYdHJlYW0gQ29kZXMNCg0KW2NsaWVudF0NCnBvcnQgICAgICAgICAgICA9IDMzMDYNCg0KW215c3FsZF9zYWZlXQ0KbmljZSAgICAgICAgICAgID0gMA0KDQpbbXlzcWxkXQ0KdXNlciAgICAgICAgICAgID0gbXlzcWwNCnBvcnQgICAgICAgICAgICA9IDc5OTkNCmJhc2VkaXIgICAgICAgICA9IC91c3INCmRhdGFkaXIgICAgICAgICA9IC92YXIvbGliL215c3FsDQp0bXBkaXIgICAgICAgICAgPSAvdG1wDQpsYy1tZXNzYWdlcy1kaXIgPSAvdXNyL3NoYXJlL215c3FsDQpza2lwLWV4dGVybmFsLWxvY2tpbmcNCnNraXAtbmFtZS1yZXNvbHZlPTENCg0KYmluZC1hZGRyZXNzICAgICAgICAgICAgPSAqDQprZXlfYnVmZmVyX3NpemUgPSAxMjhNDQoNCm15aXNhbV9zb3J0X2J1ZmZlcl9zaXplID0gNE0NCm1heF9hbGxvd2VkX3BhY2tldCAgICAgID0gNjRNDQpteWlzYW0tcmVjb3Zlci1vcHRpb25zID0gQkFDS1VQDQptYXhfbGVuZ3RoX2Zvcl9zb3J0X2RhdGEgPSA4MTkyDQpxdWVyeV9jYWNoZV9saW1pdCAgICAgICA9IDRNDQpxdWVyeV9jYWNoZV9zaXplICAgICAgICA9IDI1Nk0NCg0KDQpleHBpcmVfbG9nc19kYXlzICAgICAgICA9IDEwDQptYXhfYmlubG9nX3NpemUgICAgICAgICA9IDEwME0NCg0KbWF4X2Nvbm5lY3Rpb25zICA9IDIwMDAwDQpiYWNrX2xvZyA9IDQwOTYNCm9wZW5fZmlsZXNfbGltaXQgPSAyMDI0MA0KaW5ub2RiX29wZW5fZmlsZXMgPSAyMDI0MA0KbWF4X2Nvbm5lY3RfZXJyb3JzID0gMzA3Mg0KdGFibGVfb3Blbl9jYWNoZSA9IDQwOTYNCnRhYmxlX2RlZmluaXRpb25fY2FjaGUgPSA0MDk2DQoNCg0KdG1wX3RhYmxlX3NpemUgPSAxRw0KbWF4X2hlYXBfdGFibGVfc2l6ZSA9IDFHDQoNCmlubm9kYl9idWZmZXJfcG9vbF9zaXplID0gMTBHDQppbm5vZGJfYnVmZmVyX3Bvb2xfaW5zdGFuY2VzID0gMTANCmlubm9kYl9yZWFkX2lvX3RocmVhZHMgPSA2NA0KaW5ub2RiX3dyaXRlX2lvX3RocmVhZHMgPSA2NA0KaW5ub2RiX3RocmVhZF9jb25jdXJyZW5jeSA9IDANCmlubm9kYl9mbHVzaF9sb2dfYXRfdHJ4X2NvbW1pdCA9IDANCmlubm9kYl9mbHVzaF9tZXRob2QgPSBPX0RJUkVDVA0KcGVyZm9ybWFuY2Vfc2NoZW1hID0gMA0KaW5ub2RiLWZpbGUtcGVyLXRhYmxlID0gMQ0KaW5ub2RiX2lvX2NhcGFjaXR5PTIwMDAwDQppbm5vZGJfdGFibGVfbG9ja3MgPSAwDQppbm5vZGJfbG9ja193YWl0X3RpbWVvdXQgPSAwDQppbm5vZGJfZGVhZGxvY2tfZGV0ZWN0ID0gMA0KDQoNCnNxbC1tb2RlPSJOT19FTkdJTkVfU1VCU1RJVFVUSU9OIg0KDQpbbXlzcWxkdW1wXQ0KcXVpY2sNCnF1b3RlLW5hbWVzDQptYXhfYWxsb3dlZF9wYWNrZXQgICAgICA9IDE2TQ0KDQpbbXlzcWxdDQoNCltpc2FtY2hrXQ0Ka2V5X2J1ZmZlcl9zaXplICAgICAgICAgICAgICA9IDE2TQ0K | base64 --decode > /etc/mysql/my.cnf
sleep 1s
systemctl restart mariadb
sleep 1s
##################

echo -e "\\r${CHECK_MARK} Installation Of XtreamCodes Done"
sleep 1s
echo -n "[+] Configuration Of Mysql & Nginx..."
sleep 1s

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
    if not "api.xtream-codes.com" in open("/etc/hosts").read(): os.system('echo "127.0.0.1    api.xtream-codes.com" >> /etc/hosts')
    if not "downloads.xtream-codes.com" in open("/etc/hosts").read(): os.system('echo "127.0.0.1    downloads.xtream-codes.com" >> /etc/hosts')
    if not " xtream-codes.com" in open("/etc/hosts").read(): os.system('echo "127.0.0.1    xtream-codes.com" >> /etc/hosts')
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
wget -qO update.sql https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/update.sql
sleep 1s
sed -i "s|adminn|$adminn|g" update.sql
sleep 1s
sed -i "s|kkkk|$kkkk|g" update.sql
sleep 1s
sed -i "s|EMAIL|$EMAIL|g" update.sql
sleep 1s
mysql -u root -p$PASSMYSQL xtream_iptvpro < update.sql
sleep 1s
rm -f update.sql
sleep 1s
#########################################


echo -e "\\r${CHECK_MARK} Configuration Of Mysql & Nginx Done"
sleep 1s
echo -n "[+] Configuration Of Crons & Autorisations..."
sleep 1s

#### modif de fichiers et autre config xtream : nginx, ffmpeg,.....
rm -r /home/xtreamcodes/iptv_xtream_codes/database.sql
sleep 1s
echo "xtreamcodes ALL=(root) NOPASSWD: /sbin/iptables, /usr/bin/chattr" >> /etc/sudoers
sleep 1s
ln -s /home/xtreamcodes/iptv_xtream_codes/bin/ffmpeg /usr/bin/
sleep 1s
echo "tmpfs /home/xtreamcodes/iptv_xtream_codes/streams tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=90% 0 0" >> /etc/fstab
sleep 1s
echo "tmpfs /home/xtreamcodes/iptv_xtream_codes/tmp tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=2G 0 0" >> /etc/fstab
sleep 1s
chmod -R 0777 /home/xtreamcodes
sleep 1s
cat > /home/xtreamcodes/iptv_xtream_codes/nginx/conf/nginx.conf <<EOR
user  xtreamcodes;
worker_processes  auto;

worker_rlimit_nofile 300000;
events {
    worker_connections  16000;
    use epoll;
	accept_mutex on;
	multi_accept on;
}
thread_pool pool_xtream threads=32 max_queue=0;
http {

    include       mime.types;
    default_type  application/octet-stream;

    sendfile           on;
    tcp_nopush         on;
    tcp_nodelay        on;
	reset_timedout_connection on;
    gzip off;
    fastcgi_read_timeout 200;
	access_log off;
	keepalive_timeout 10;
	include balance.conf;
	send_timeout 20m;	
	sendfile_max_chunk 512k;
	lingering_close off;
	aio threads=pool_xtream;
	client_body_timeout 13s;
	client_header_timeout 13s;
	client_max_body_size 3m;

	limit_req_zone \$binary_remote_addr zone=one:30m rate=20r/s;
    server {
        listen $CLIENTACCESPORT;listen 25463 ssl;ssl_certificate server.crt;ssl_certificate_key server.key; ssl_protocols SSLv3 TLSv1.1 TLSv1.2;
        index index.php index.html index.htm;
        root /home/xtreamcodes/iptv_xtream_codes/wwwdir/;
        server_tokens off;
        chunked_transfer_encoding off;

		if ( \$request_method !~ ^(GET|POST)\$ ) {
			return 200;
		}

        rewrite_log on;
        rewrite ^/live/(.*)/(.*)/(.*)\.(.*)\$ /streaming/clients_live.php?username=\$1&password=\$2&stream=\$3&extension=\$4 break;
        rewrite ^/movie/(.*)/(.*)/(.*)\$ /streaming/clients_movie.php?username=\$1&password=\$2&stream=\$3&type=movie break;
		rewrite ^/series/(.*)/(.*)/(.*)\$ /streaming/clients_movie.php?username=\$1&password=\$2&stream=\$3&type=series break;
        rewrite ^/(.*)/(.*)/(.*).ch\$ /streaming/clients_live.php?username=\$1&password=\$2&stream=\$3&extension=ts break;
        rewrite ^/(.*)\.ch\$ /streaming/clients_live.php?extension=ts&stream=\$1&qs=\$query_string break;
        rewrite ^/ch(.*)\.m3u8\$ /streaming/clients_live.php?extension=m3u8&stream=\$1&qs=\$query_string break;
		rewrite ^/hls/(.*)/(.*)/(.*)/(.*)/(.*)\$ /streaming/clients_live.php?extension=m3u8&username=\$1&password=\$2&stream=\$3&type=hls&segment=\$5&token=$4 break;
		rewrite ^/hlsr/(.*)/(.*)/(.*)/(.*)/(.*)/(.*)\$ /streaming/clients_live.php?token=\$1&username=\$2&password=\$3&segment=\$6&stream=\$4&key_seg=\$5 break;
		rewrite ^/timeshift/(.*)/(.*)/(.*)/(.*)/(.*)\.(.*)\$ /streaming/timeshift.php?username=\$1&password=\$2&stream=\$5&extension=\$6&duration=\$3&start=\$4 break;
		rewrite ^/timeshifts/(.*)/(.*)/(.*)/(.*)/(.*)\.(.*)\$ /streaming/timeshift.php?username=\$1&password=\$2&stream=\$4&extension=\$6&duration=\$3&start=\$5 break;
		
		rewrite ^/(.*)/(.*)/(\d+)\$ /streaming/clients_live.php?username=\$1&password=\$2&stream=\$3&extension=ts break;
		#add pvr support
		rewrite ^/server/load.php\$ /portal.php break;
		
		location /stalker_portal/c {
			alias /home/xtreamcodes/iptv_xtream_codes/wwwdir/c;
		}
		
		#FFmpeg Report Progress
		location = /progress.php {
		    allow 127.0.0.1;
			deny all;
			fastcgi_pass php;
			include fastcgi_params;
			fastcgi_ignore_client_abort on;
			fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
			fastcgi_param SCRIPT_NAME \$fastcgi_script_name;
		}


        location ~ \.php\$ {
			limit_req zone=one burst=8;
            try_files \$uri =404;
			fastcgi_index index.php;
			fastcgi_pass php;
			include fastcgi_params;
			fastcgi_buffering on;
			fastcgi_buffers 96 32k;
			fastcgi_buffer_size 32k;
			fastcgi_max_temp_file_size 0;
			fastcgi_keep_conn on;
			fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
			fastcgi_param SCRIPT_NAME \$fastcgi_script_name;
        }
    }
    server {
        listen $ACCESPORT;
        index index.php index.html index.htm;
        root /home/xtreamcodes/iptv_xtream_codes/admin/;

        location ~ \.php\$ {
			limit_req zone=one burst=8;
            try_files \$uri =404;
			fastcgi_index index.php;
			fastcgi_pass php;
			include fastcgi_params;
			fastcgi_buffering on;
			fastcgi_buffers 96 32k;
			fastcgi_buffer_size 32k;
			fastcgi_max_temp_file_size 0;
			fastcgi_keep_conn on;
			fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
			fastcgi_param SCRIPT_NAME \$fastcgi_script_name;
        }
    }
    #ISP CONFIGURATION

    server {
         listen 8805;
         root /home/xtreamcodes/iptv_xtream_codes/isp/;
         location / {
                      allow 127.0.0.1;
                      deny all;
         }
         location ~ \.php\$ {
                             limit_req zone=one burst=8;
                             try_files \$uri =404;
                             fastcgi_index index.php;
                             fastcgi_pass php;
                             include fastcgi_params;
                             fastcgi_buffering on;
                             fastcgi_buffers 96 32k;
                             fastcgi_buffer_size 32k;
                             fastcgi_max_temp_file_size 0;
                             fastcgi_keep_conn on;
                             fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                             fastcgi_param SCRIPT_NAME \$fastcgi_script_name;
         }
    }
}
EOR
sleep 1s
mysql -u root -p$PASSMYSQL xtream_iptvpro -e "UPDATE streaming_servers SET http_broadcast_port = '$CLIENTACCESPORT' WHERE streaming_servers.id = 1;"
##################


echo -e "\\r${CHECK_MARK} Configuration Of Crons & Autorisations Done"
sleep 1s
echo -n "[+] installation Of Admin Web Access..."
sleep 1s
apt-get install e2fsprogs python-paramiko -y
sleep 1s
#### update xtream cr 41
# backup R41
#wget -q -O /tmp/update.zip https://github.com/amidevous/xtream-ui-ubuntu20.04/releases/download/start/update.zip
#xcversion=41
#install latest
wget -q -O /tmp/update.zip http://xcodes.mine.nu/XCodes/update.zip
sleep 1s
unzip -o /tmp/update.zip -d /tmp/update/
sleep 1s
chattr -i /home/xtreamcodes/iptv_xtream_codes/GeoLite2.mmdb
sleep 1s
rm -rf /tmp/update/XtreamUI-master/php
sleep 1s
rm -rf /tmp/update/XtreamUI-master/GeoLite2.mmdb
sleep 1s
cp -rf /tmp/update/XtreamUI-master/* /home/xtreamcodes/iptv_xtream_codes/
sleep 1s
rm -rf /tmp/update/XtreamUI-master
sleep 1s
rm /tmp/update.zip
sleep 1s
rm -rf /tmp/update
sleep 1s
apt-get -y install jq
sleep 1s
xcversion=$(wget -qO- http://xcodes.mine.nu/XCodes/current.json | jq -r ".version")
sleep 1s
mysql -u root -p$PASSMYSQL xtream_iptvpro -e "UPDATE admin_settings SET value = '$xcversion' WHERE admin_settings.type = 'panel_version'; "
sleep 1s
chattr -i /home/xtreamcodes/iptv_xtream_codes/GeoLite2.mmdb
sleep 1s
wget -O /home/xtreamcodes/iptv_xtream_codes/GeoLite2.mmdb http://xcodes.mine.nu/XCodes/GeoLite2.mmdb
sleep 1s
chattr +i /home/xtreamcodes/iptv_xtream_codes/GeoLite2.mmdb
sleep 1s
geoliteversion=$(wget -qO- http://xcodes.mine.nu/XCodes/status.json | jq -r ".version")
mysql -u root -p$PASSMYSQL xtream_iptvpro -e "UPDATE admin_settings SET value = '$geoliteversion' WHERE admin_settings.type = 'geolite2_version'; "
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


echo -e "\\r${CHECK_MARK} installation Of Admin Web Access Done"
sleep 1s
echo -n "[+] installation Of PhpMyAdmin..."
sleep 1s
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
sudo apt-get purge libcurl3 -y
sleep 1s
sudo apt-get install libcurl4 -y
sleep 1s
##################

echo -e "\\r${CHECK_MARK} Installation Of PhpMyAdmin Done"
sleep 1s
echo -n "[+] Configuration Auto Start..."
sleep 1s


#### demarre xtream au redemarage du server
echo "@reboot root sudo /home/xtreamcodes/iptv_xtream_codes/start_services.sh" >> /etc/crontab
sleep 1s
#### demarage de xtreamcodes
sed -i "s/Listen 80/Listen $APACHEACCESPORT/g" /etc/apache2/ports.conf
sleep 1s
sed -i "s/Listen 443/Listen 70/g" /etc/apache2/ports.conf
sleep 1s
sed -i "s/80/$APACHEACCESPORT/g" /etc/apache2/sites-available/000-default.conf
sleep 1s
sed -i "s/443/70/g" /etc/apache2/sites-available/default-ssl.conf
sleep 1s
service apache2 restart
sleep 1s
/home/xtreamcodes/iptv_xtream_codes/nginx/sbin/nginx -s reload
sleep 1s
sudo ufw disable
sleep 1s
/home/xtreamcodes/iptv_xtream_codes/permissions.sh
sleep 1s
/home/xtreamcodes/iptv_xtream_codes/start_services.sh
sleep 5s
##################

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
