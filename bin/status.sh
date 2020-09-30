#!/usr/bin/env bash

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
    T="$(nmcli -g name,type connection show --active | grep wireless)"
    [ -n "$T" ] && echo "$T" | cut -f1 -d":"
}

_ping() {
    local T
    T=$(ping -c1 -W1 google.com | grep -Eo "time=.* " | cut -f2 -d"=")
    [ -n "$T" ] && echo "$T"
}

_date() {
    date +'%Y-%m-%d'
}

_time() {
    date +'%H:%M:%S'
}

printf "%s : " "$(_net)" "$(_ping)" "$(_bat)" "$(_date)" "$(_time)"
