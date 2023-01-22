#!/bin/bash
if test -f "/etc/ensureos.sh"; then
  source /etc/ensureos.sh
else
  wget -qO /etc/ensureos.sh https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/config/ensureos.sh
  chmod +x /etc/ensureos.sh
  source /etc/ensureos.sh
fi
echo "Detected : $OS  $VER  $ARCH"
if [[ "$OS" = "Ubuntu" && ("$VER" = "18.04" || "$VER" = "20.04" || "$VER" = "22.04" ) && "$ARCH" == "x86_64" ||
"$OS" = "debian" && ("$VER" = "10" || "$VER" = "11" ) && "$ARCH" == "x86_64" ]] ; then
    echo "Ok."
else
    echo "Sorry, this OS is not supported by Xtream UI."
    exit 1
fi


mkdir -p /root/xtream-ui-ubuntu20.04/package/Ubuntu/
mkdir -p /root/xtream-ui-ubuntu20.04/package/debian/
mkdir -p /root/xtream-ui-ubuntu20.04/package/Ubuntu/conf
mkdir -p /root/xtream-ui-ubuntu20.04/package/debian/conf
mkdir -p /root/xtream-ui-ubuntu20.04/package/Ubuntu/incoming
mkdir -p /root/xtream-ui-ubuntu20.04/package/debian/incoming
cat > /root/xtream-ui-ubuntu20.04/package/Ubuntu/conf/distributions <<EOF
Origin: local
Label: local
Suite: bionic
Codename: bionic
Version: 18.04
Architectures: amd64
Components: main
Description: local repo for php build
Origin: local
Label: local
Suite: focal
Codename: focal
Version: 20.04
Architectures: amd64
Components: main
Description: local repo for php build
Origin: local
Label: local
Suite: jammy
Codename: jammy
Version: 22.04
Architectures: amd64
Components: main
Description: local repo for php build
EOF
cat > /root/xtream-ui-ubuntu20.04/package/debian/conf/distributions <<EOF
Origin: local
Label: local
Suite: buster
Codename: buster
Version: 10
Architectures: amd64
Components: main
Description: local repo for php build
Origin: local
Label: local
Suite: bullseye
Codename: bullseye
Version: 11
Architectures: amd64
Components: main
Description: local repo for php build
EOF
mkdir -p /root/xtream-ui-ubuntu20.04/package/Ubuntu/18.04/x86_64/
mkdir -p /root/xtream-ui-ubuntu20.04/package/Ubuntu/20.04/x86_64/
mkdir -p /root/xtream-ui-ubuntu20.04/package/Ubuntu/22.04/x86_64/
mkdir -p /root/xtream-ui-ubuntu20.04/package/debian/10/x86_64/
mkdir -p /root/xtream-ui-ubuntu20.04/package/debian/11/x86_64/
mkdir -p /root/xtream-ui-ubuntu20.04/package/CentOs/7/x86_64/
mkdir -p /root/xtream-ui-ubuntu20.04/package/CentOS-Stream/8/x86_64/
mkdir -p /root/xtream-ui-ubuntu20.04/package/CentOS-Stream/9/x86_64/
mkdir -p /root/xtream-ui-ubuntu20.04/package/Fedora/35/x86_64/
mkdir -p /root/xtream-ui-ubuntu20.04/package/Fedora/36/x86_64/
mkdir -p /root/xtream-ui-ubuntu20.04/package/Fedora/37/x86_64/



cat > /root/xtream-ui-ubuntu20.04/package/Ubuntu/18.04/x86_64/repoadd <<EOF
#!/bin/bash
reprepro --keepunreferencedfiles -Vb /root/xtream-ui-ubuntu20.04/package/Ubuntu/ includedeb bionic \$1
cp /root/xtream-ui-ubuntu20.04/package/Ubuntu/dists/bionic/Release /root/xtream-ui-ubuntu20.04/package/Ubuntu/dists/bionic/InRelease
chown -R _apt:root /root/xtream-ui-ubuntu20.04/package/Ubuntu/
chown -R _apt:root /root/xtream-ui-ubuntu20.04/package/Ubuntu/*
chmod -R 700 /root/xtream-ui-ubuntu20.04/package/Ubuntu/
chmod -R 700 /root/xtream-ui-ubuntu20.04/package/Ubuntu/*
EOF
chmod +x /root/xtream-ui-ubuntu20.04/package/Ubuntu/18.04/x86_64/repoadd



cat > /root/xtream-ui-ubuntu20.04/package/$OS/$VER/$ARCH/repoadd <<EOF
#!/bin/bash
reprepro --keepunreferencedfiles -Vb /root/xtream-ui-ubuntu20.04/package/$OS/ includedeb $(lsb_release -sc) \$1
cp /root/xtream-ui-ubuntu20.04/package/$OS/dists/$(lsb_release -sc)/Release /root/xtream-ui-ubuntu20.04/package/$OS/dists/$(lsb_release -sc)/InRelease
chown -R _apt:root /root/xtream-ui-ubuntu20.04/package/$OS/
chown -R _apt:root /root/xtream-ui-ubuntu20.04/package/$OS/*
chmod -R 700 /root/xtream-ui-ubuntu20.04/package/$OS/
chmod -R 700 /root/xtream-ui-ubuntu20.04/package/$OS/*
EOF
chmod +x /root/xtream-ui-ubuntu20.04/package/$OS/$VER/$ARCH/repoadd



cat > /root/xtream-ui-ubuntu20.04/package/$OS/$VER/$ARCH/repoadd <<EOF
#!/bin/bash
reprepro --keepunreferencedfiles -Vb /root/xtream-ui-ubuntu20.04/package/$OS/ includedeb $(lsb_release -sc) \$1
cp /root/xtream-ui-ubuntu20.04/package/$OS/dists/$(lsb_release -sc)/Release /root/xtream-ui-ubuntu20.04/package/$OS/dists/$(lsb_release -sc)/InRelease
chown -R _apt:root /root/xtream-ui-ubuntu20.04/package/$OS/
chown -R _apt:root /root/xtream-ui-ubuntu20.04/package/$OS/*
chmod -R 700 /root/xtream-ui-ubuntu20.04/package/$OS/
chmod -R 700 /root/xtream-ui-ubuntu20.04/package/$OS/*
EOF
chmod +x /root/xtream-ui-ubuntu20.04/package/$OS/$VER/$ARCH/repoadd


cat > /root/xtream-ui-ubuntu20.04/package/$OS/$VER/$ARCH/repoadd <<EOF
#!/bin/bash
reprepro --keepunreferencedfiles -Vb /root/xtream-ui-ubuntu20.04/package/$OS/ includedeb $(lsb_release -sc) \$1
cp /root/xtream-ui-ubuntu20.04/package/$OS/dists/$(lsb_release -sc)/Release /root/xtream-ui-ubuntu20.04/package/$OS/dists/$(lsb_release -sc)/InRelease
chown -R _apt:root /root/xtream-ui-ubuntu20.04/package/$OS/
chown -R _apt:root /root/xtream-ui-ubuntu20.04/package/$OS/*
chmod -R 700 /root/xtream-ui-ubuntu20.04/package/$OS/
chmod -R 700 /root/xtream-ui-ubuntu20.04/package/$OS/*
EOF
chmod +x /root/xtream-ui-ubuntu20.04/package/$OS/$VER/$ARCH/repoadd










cat > /etc/apt/sources.list.d/local.list <<EOF
deb [trusted=yes] https://github.com/amidevous/xtream-ui-ubuntu20.04/raw/master/package/$OS $(lsb_release -sc) main
EOF
#find ./ -name '*.deb' -exec /root/package/$OS/$VER/$ARCH/repoadd {} \;
