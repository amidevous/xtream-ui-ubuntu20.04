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
