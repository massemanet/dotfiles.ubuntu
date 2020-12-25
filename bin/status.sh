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

_cpu_color() {
    echo "#eeeeee"
}

_uptime() {
    tr -d "." < /proc/uptime
}

_cpu(){
    local CPUS="$1" IDLE0="$2" UP0="$3" IDLE1="$4" UP1="$5"
    echo "$(( (100*(CPUS*(IDLE0-IDLE1)-UP0+UP1))/(IDLE0-IDLE1) ))"
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
    LOAD="$(_cpu "$1")%"
    printf '[{"full_text": "%s"}' "$(_spotify)"
    printf ',{"full_text": "%s"}' "$(_net)"
    printf ',{"full_text": "%s"}' "$(_ping)ms"
    printf ',{"full_text": "%s", "color":"'"$(_cpu_color "$LOAD")"'"}' "$LOAD"
    printf ',{"full_text": "%s", "color":"'"$(_bat color)"'"}' "$(_bat)"
    printf ',{"full_text": "%s"}' "$(_date)"
    printf ',{"full_text": "%s"}' "$(_time)"
    echo "],"
}

CPUS="$(grep siblings /proc/cpuinfo | head -n1 | cut -f2 -d":" | tr -d " ")"
echo '{"version": 1}'
echo "["
echo "[],"
while sleep 2
do U1="$(_uptime)"; _bar "$CPUS" $U0 $U1; U0="$U1"
done
