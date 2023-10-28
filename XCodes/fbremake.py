#!/usr/bin/python
# -*- coding: utf-8 -*-
import subprocess, os, sys
from itertools import cycle, izip

rFbremake = "https://xtreamtools.org/XCodes/sub_xtreamcodes_reborn.tar.gz"
rPackages = ["libcurl3", "libxslt1-dev", "libgeoip-dev", "e2fsprogs", "wget", "mcrypt", "nscd", "htop", "zip", "unzip", "mc"]
rGeo = "https://xtreamtools.org/XCodes/GeoLite2.mmdb"

def getVersion():
    try: return subprocess.check_output("lsb_release -d".split()).split(":")[-1].strip()
    except: return ""
    
def extra():
    os.system("apt-get remove --auto-remove libcurl4 -y > /dev/null")  

def prepare():
    global rPackages
    for rFile in ["/var/lib/dpkg/lock-frontend", "/var/cache/apt/archives/lock", "/var/lib/dpkg/lock"]:
        try: os.remove(rFile)
        except: pass
    os.system("apt-get update > /dev/null")
    os.system("apt-get remove --auto-remove libcurl4 -y > /dev/null")
    for rPackage in rPackages: os.system("apt-get install %s -y > /dev/null" % rPackage)
    os.system("wget -q -O /tmp/libpng12.deb https://xtreamtools.org/XCodes/libpng12-0_1.2.54-1ubuntu1_amd64.deb")
    os.system("dpkg -i /tmp/libpng12.deb > /dev/null")
    os.system("apt-get install -y > /dev/null") # Clean up above
    try: os.remove("/tmp/libpng12.deb")
    except: pass
    os.system("adduser --system --shell /bin/false --group --disabled-login xtreamcodes 2> /dev/null")
    if not os.path.exists("/home/xtreamcodes"): os.mkdir("/home/xtreamcodes")
    return True
    
def install():
    global rInstall, rFbremake
    rURL = rFbremake
    os.system('wget -q -O "/tmp/xtreamcodes.tar.gz" "%s"' % rURL)

def configure():
    global rInstall, rGeo
    rNginx = "/home/xtreamcodes/iptv_xtream_codes/nginx/conf/nginx.conf"
    rNginxRtmp = "/home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/conf/nginx.conf"
    rYou = "https://xtreamtools.org/XCodes/youtube-dl" 
    rCheckGeo = "https://xtreamtools.org/XCodes/check_geolite.sh"
    if not "xtream-codes.com" in open("/etc/hosts").read(): os.system('echo "127.0.0.1    xtream-codes.com" >> /etc/hosts')
    if not "api.xtream-codes.com" in open("/etc/hosts").read(): os.system('echo "127.0.0.1    api.xtream-codes.com" >> /etc/hosts')
    if not "downloads.xtream-codes.com" in open("/etc/hosts").read(): os.system('echo "127.0.0.1    downloads.xtream-codes.com" >> /etc/hosts')
    if not "xtream-codes.com" in open("/etc/hosts").read(): os.system('echo "127.0.0.1    xtream-codes.com" >> /etc/hosts')
    if not "/home/xtreamcodes/iptv_xtream_codes/" in open("/etc/fstab").read():
        rFile = open("/etc/fstab", "a")
        rFile.write("tmpfs /home/xtreamcodes/iptv_xtream_codes/streams tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=90% 0 0\ntmpfs /home/xtreamcodes/iptv_xtream_codes/tmp tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=2G 0 0")
        rFile.close()
    if not "/sbin/iptables" in open("/etc/sudoers").read(): os.system('sed -i "s|xtreamcodes|#xtreamcodes|g" /etc/sudoers && echo "xtreamcodes ALL=(root) NOPASSWD: /sbin/iptables" >> /etc/sudoers')
    if not os.path.exists("/etc/init.d/xtreamcodes"): os.system("touch /etc/init.d/xtreamcodes")
    if not "Provides" in open("/etc/init.d/xtreamcodes").read():
        os.system("rm /etc/init.d/xtreamcodes")
        rStart = open("/etc/init.d/xtreamcodes", "w")
        rStart.write("#!/bin/bash\n### BEGIN INIT INFO\n# Provides:          xtreamcodes\n# Required-Start:    $all\n# Required-Stop:\n# Default-Start:     2 3 4 5\n# Default-Stop:\n# Short-Description: Run /etc/init.d/xtreamcodes if it exist\n### END INIT INFO\n/home/xtreamcodes/iptv_xtream_codes/start_services.sh > /dev/null")
        rStart.close()
        os.system("chmod 755 /etc/init.d/xtreamcodes 2>/dev/null")
        os.system("update-rc.d xtreamcodes defaults 2>/dev/null")
    try: os.remove("/usr/bin/ffmpeg 2>/dev/null || /usr/bin/ffmpeg 2>/dev/null")
    except: pass
    if os.path.exists("/tmp/xtreamcodes.tar.gz"):
        os.system('mv "%s" "%s.xc" && mv "%s" "%s.xc"' % (rNginx, rNginx, rNginxRtmp, rNginxRtmp))
        os.system('rm /usr/bin/ffmpeg')
        os.system('rm /usr/bin/ffprobe')
        os.system("chattr -i /home/xtreamcodes/iptv_xtream_codes/GeoLite2.mmdb")
        os.system("sudo umount -l /home/xtreamcodes/iptv_xtream_codes/streams")
        os.system("sudo umount -l /home/xtreamcodes/iptv_xtream_codes/tmp")
        os.system('tar -zxvf "/tmp/xtreamcodes.tar.gz" -C "/home/xtreamcodes/" > /dev/null')
        os.system("rm /home/xtreamcodes/iptv_xtream_codes/GeoLite2.mmdb")
        os.system('wget -q -O "/home/xtreamcodes/iptv_xtream_codes/GeoLite2.mmdb" "%s"' % rGeo)
        os.system("sudo mount -a")
        os.system('mv "%s.xc" "%s" && mv "%s.xc" "%s"' % (rNginx, rNginx, rNginxRtmp, rNginxRtmp))
        os.system("ln -s /home/xtreamcodes/iptv_xtream_codes/bin/ffmpeg /usr/bin/")
        os.system("wget -q https://xtreamtools.org/XCodes/config.py -O /home/xtreamcodes/iptv_xtream_codes/config.py")
        os.system("rm /usr/local/bin/youtube-dl 2>/dev/null")
        os.system('wget -q -O "/usr/local/bin/youtube-dl" "%s"' % rYou)
        os.system("sudo chmod a+rx /usr/local/bin/youtube-dl")
        os.system('wget -q -O "/home/xtreamcodes/iptv_xtream_codes/check_geolite.sh" "%s"' % rCheckGeo)
    if not "check_geolite.sh" in open("/etc/crontab").read(): os.system('echo "*/1 *   * * * root /home/xtreamcodes/iptv_xtream_codes/./check_geolite.sh" >> /etc/crontab')
    if not "www.google.com" in open("/home/xtreamcodes/iptv_xtream_codes/wwwdir/index.php").read(): os.system("sed -i 's|echo \"Xtream Codes Reborn\";|header(\"Location: https://www.google.com/\");|g' /home/xtreamcodes/iptv_xtream_codes/wwwdir/index.php 2>/dev/null")
    if not "/home/xtreamcodes 2>/dev/null" in open("/home/xtreamcodes/iptv_xtream_codes/start_services.sh").read():   
        os.system("sed -i 's|chown -R xtreamcodes:xtreamcodes /home/xtreamcodes|chown -R xtreamcodes:xtreamcodes /home/xtreamcodes 2>/dev/null|g' /home/xtreamcodes/iptv_xtream_codes/start_services.sh")
        os.system("sed -i 's|chmod -R 777 /home/xtreamcodes|chmod -R 777 /home/xtreamcodes 2>/dev/null|g' /home/xtreamcodes/iptv_xtream_codes/start_services.sh")
    if not os.path.exists("/home/xtreamcodes/iptv_xtream_codes/tv_archive"): os.mkdir("/home/xtreamcodes/iptv_xtream_codes/tv_archive/")
    os.system("chmod +x /home/xtreamcodes/iptv_xtream_codes/start_services.sh")
    os.system("mount -a")
    os.system("chown -R xtreamcodes:xtreamcodes /home/xtreamcodes 2>/dev/null")
    os.system("chmod -R 0777 /home/xtreamcodes 2>/dev/null")
    os.system("chattr +i /home/xtreamcodes/iptv_xtream_codes/GeoLite2.mmdb")
    try: os.remove("/tmp/xtreamcodes.tar.gz")
    except: pass

def encrypt(rHost="127.0.0.1", rUsername="user_iptvpro", rPassword="", rDatabase="xtream_iptvpro", rServerID=1, rPort=7999):
    try: os.remove("/home/xtreamcodes/iptv_xtream_codes/config")
    except: pass
    rf = open('/home/xtreamcodes/iptv_xtream_codes/config', 'wb')
    rf.write(''.join(chr(ord(c)^ord(k)) for c,k in izip('{\"host\":\"%s\",\"db_user\":\"%s\",\"db_pass\":\"%s\",\"db_name\":\"%s\",\"server_id\":\"%d\", \"db_port\":\"%d\"}' % (rHost, rUsername, rPassword, rDatabase, rServerID, rPort), cycle('5709650b0d7806074842c6de575025b1'))).encode('base64').replace('\n', ''))
    rf.close()

def start(): 
    os.system("chown xtreamcodes:xtreamcodes /home/xtreamcodes/iptv_xtream_codes/config")
    os.system("chmod 777 /home/xtreamcodes/iptv_xtream_codes/config")
    os.system("/home/xtreamcodes/iptv_xtream_codes/start_services.sh 2>/dev/null")

if __name__ == "__main__":
    rHost = sys.argv[1]
    rPort = int(sys.argv[2])
    rUsername = sys.argv[3]
    rPassword = sys.argv[4]
    rDatabase = sys.argv[5]
    rServerID = int(sys.argv[6])
    extra()
    prepare()
    install()
    configure()
    encrypt(rHost, rUsername, rPassword, rDatabase, rServerID, rPort)
    start()
