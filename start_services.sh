#! /bin/bash
kill $(ps aux | grep 'xtreamcodes' | grep -v grep | grep -v 'start_services.sh' | awk '{print $2}') 2>/dev/null
sleep 1
kill $(ps aux | grep 'xtreamcodes' | grep -v grep | grep -v 'start_services.sh' | awk '{print $2}') 2>/dev/null
sleep 1
kill $(ps aux | grep 'xtreamcodes' | grep -v grep | grep -v 'start_services.sh' | awk '{print $2}') 2>/dev/null
killall -9 php-fpm 2>/dev/null
sleep 1
killall -9 php-fpm 2>/dev/null
sleep 1
killall -9 php-fpm 2>/dev/null
sleep 4
sudo rm /home/xtreamcodes/iptv_xtream_codes/adtools/balancer/*.json 2>/dev/null &
echo "" > /home/xtreamcodes/iptv_xtream_codes/logs/error.log 2>/dev/null &
echo "" > /home/xtreamcodes/iptv_xtream_codes/logs/rtmp_error.log 2>/dev/null &
echo "" > /home/xtreamcodes/iptv_xtream_codes/logs/access.log 2>/dev/null &
sleep 1
sudo -u xtreamcodes /home/xtreamcodes/iptv_xtream_codes/php/bin/php /home/xtreamcodes/iptv_xtream_codes/crons/setup_cache.php
sudo -u xtreamcodes /home/xtreamcodes/iptv_xtream_codes/php/bin/php /home/xtreamcodes/iptv_xtream_codes/tools/signal_receiver.php >/dev/null 2>/dev/null &
sudo -u xtreamcodes /home/xtreamcodes/iptv_xtream_codes/php/bin/php /home/xtreamcodes/iptv_xtream_codes/tools/pipe_reader.php >/dev/null 2>/dev/null &
chown -R xtreamcodes:xtreamcodes /sys/class/net
chown -R xtreamcodes:xtreamcodes /home/xtreamcodes 2>/dev/null
sleep 4
/home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/sbin/nginx_rtmp
/home/xtreamcodes/iptv_xtream_codes/nginx/sbin/nginx
daemonize -p /home/xtreamcodes/iptv_xtream_codes/php/VaiIb8.pid /home/xtreamcodes/iptv_xtream_codes/php/sbin/php-fpm --fpm-config /home/xtreamcodes/iptv_xtream_codes/php/etc/VaiIb8.conf
daemonize -p /home/xtreamcodes/iptv_xtream_codes/php/JdlJXm.pid /home/xtreamcodes/iptv_xtream_codes/php/sbin/php-fpm --fpm-config /home/xtreamcodes/iptv_xtream_codes/php/etc/JdlJXm.conf
daemonize -p /home/xtreamcodes/iptv_xtream_codes/php/CWcfSP.pid /home/xtreamcodes/iptv_xtream_codes/php/sbin/php-fpm --fpm-config /home/xtreamcodes/iptv_xtream_codes/php/etc/CWcfSP.conf
