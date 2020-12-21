#!/usr/bin/env bash

_spotify(){
    local N
    N="$(swaymsg -t get_tree | jq -r 'recurse(.nodes[]?)|recurse(.floating_nodes[]?)|select(.window_properties.class=="Spotify").name')"
    [ "$N" == "Spotify Premium" ] || echo "$N"
}

_bat() {
    local STATUS CAPACITY CHARGE CURRENT
    STATUS="$(cat /sys/class/power_supply/BAT0/status)"
    CAPACITY="$(cat /sys/class/power_supply/BAT0/capacity)"
    if [ "$1" = "color" ]; then
        if [ "$STATUS" = "Discharging" ] && ((CAPACITY < 5))
        then echo "#ee1111"
        else echo "11ee11"
        fi
    else
        CHARGE="$(cat /sys/class/power_supply/BAT0/charge_now)"
        CURRENT="$(cat /sys/class/power_supply/BAT0/current_now)"
        [ "$CURRENT" -ne 0 ] && [ "$STATUS" != "Full" ] && TIME="($(((60*CHARGE)/CURRENT))min)"
        echo "${STATUS}[${CAPACITY}%${TIME:-""}]"
    fi
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
_color() {
    echo "#11ee11"
}

_bar() {
    printf '[{"full_text": "%s"}' "$(_spotify)"
    printf ',{"full_text": "%s"}' "$(_net)"
    printf ',{"full_text": "%s"}' "$(_ping)ms"
    printf ',{"full_text": "%s"}' "$(_cpu)%"
    printf ',{"full_text": "%s", "color":"'"$(_bat color)"'"}' "$(_bat)"
    printf ',{"full_text": "%s"}' "$(_date)"
    printf ',{"full_text": "%s"}' "$(_time)"
    echo "],"
}

echo '{"version": 1}'
echo "["
echo "[],"
while sleep 2
do _bar
done
