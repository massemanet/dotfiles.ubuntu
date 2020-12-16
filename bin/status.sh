#!/usr/bin/env bash

_spotify(){
    local N
    N="$(swaymsg -t get_tree | jq -r 'recurse(.nodes[]?)|recurse(.floating_nodes[]?)|select(.window_properties.class=="Spotify").name')"
    [ "$N" == "Spotify Premium" ] || echo "$N"
}

_bat() {
    local STATUS CAPACITY ENERGY POWER
    STATUS="$(cat /sys/class/power_supply/BAT0/status)"
    CAPACITY="$(cat /sys/class/power_supply/BAT0/capacity)"
    ENERGY="$(cat /sys/class/power_supply/BAT0/charge_now)"
    POWER="$(cat /sys/class/power_supply/BAT0/current_now)"
    [ "$POWER" -ne 0 ] && [ "$STATUS" != "Full" ] && TIME="($((60*(ENERGY/10000)/(POWER/10000)))min)"
    echo "${STATUS}[${CAPACITY}%${TIME:-""}]" || echo "$STATUS"
}
_net() {
    local T
    T="$(2>/dev/null iwconfig | grep ESSID | cut -f2 -d"\"")"
    [ -n "$T" ] && echo "$T"
}

_cpu(){
    C="$(grep siblings /proc/cpuinfo | head -n1 | cut -f2 -d":" | tr -d " ")"
    [ -r /tmp/uptime ] || tr -d "." < /proc/uptime > /tmp/uptime
    tr -d "." < /proc/uptime > /tmp/uptime0
    cat /tmp/uptime0 /tmp/uptime | \
        (read -r a b; read -r c d; echo "$(( (100*(C*(a-c)-b+d))/(a-c) ))")
    mv /tmp/uptime0 /tmp/uptime
}

_ping() {
    local T
    T=$(ping -c1 -W1 google.com | grep -Eo "time=[0-9\.]+" | cut -f2 -d"=")
    [ -n "$T" ] && echo "${T}"
}

_date() {
    date +'%Y-%m-%d'
}

_time() {
    date +'%H:%M:%S'
}

printf "%s : " "$(_spotify)" "$(_net)" "$(_ping)ms" "$(_cpu)%" "$(_bat)" "$(_date)" "$(_time)"
