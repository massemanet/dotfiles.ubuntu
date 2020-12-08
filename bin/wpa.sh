#!/usr/bin/env bash

INTERFACE="$(iw dev | grep Interface  | cut -f2 -d" ")"
CFG="/etc/wpa_supplicant/wpa_supplicant-$INTERFACE.conf"

if [ ! -f "$CFG" ]; then
    cat > "$CFG" <<HERE
ctrl_interface=/run/wpa_supplicant
update_config=1
HERE
fi

read -r -p"ssid: " SSID
read -r -p"key: " -s KEY
CONF=$(wpa_passphrase "$SSID" "$KEY" | grep -v "\#")

echo "$CONF"
read -r -p"looks good? (y/n):" KEEP
[ "$KEEP" = "y" ] || exit 0
echo "$CONF" >> /etc/wpa_supplicant/wpa_supplicant.conf

wpa_supplicant -B -i "$INTERFACE" -c "$CFG"
