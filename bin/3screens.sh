#!/bin/bash

get_input() {
    xinput | grep "$1" | cut -f2 -d"=" | cut -f1
}

get_output() {
    xrandr | grep " conn" | cut -f1 -d" "
}

xrandr --fb 7000x4000 \
       --output eDP-1 --scale 0.4x0.4 --pos 0x1200 \
       --output DP-1-1 --auto --rotate left --pos 1280x0 \
       --output DP-1-2-8 --auto --pos 2360x840
#       --output DP-1-2 --auto --pos 1280x840 \
#       --output DP-1-1 --auto --rotate normal --pos 1280x720 \
#       --output DP-1-2 --auto --rotate normal --pos 3200x720

## set up pointing devices

TOUCHPAD="$(get_input "DLL075B:01 06CB:76AF Touchpad")"
if [ -n "$TOUCHPAD" ]; then
    xinput set-prop "$TOUCHPAD" 287 1  # Natural Scrolling
    xinput set-prop "$TOUCHPAD" 279 1  # Tapping
fi

MOUSE="$(get_input "GASIA PS2toUSB Adapter Mouse")"
if [ -n "$MOUSE" ]; then
    xinput set-prop "$MOUSE" 287 1  # Natural Scrolling
fi

## set up keyboards

KBD_XPS="$(get_input "AT Translated Set 2 keyboard")"
if [ -n "$KBD_XPS" ]; then
    setxkbmap -device "$KBD_XPS" \
              -layout us,se -option "" -option grp:shifts_toggle -option ctrl:nocaps
fi

KBD_HH="$(get_input "GASIA PS2toUSB Adapter    ")"
if [ -n "$KBD_HH" ]; then
    setxkbmap -device "$KBD_HH" \
              -layout us,se -option "" -option grp:shifts_toggle -option ctrl:nocaps \
              -option altwin:swap_lalt_lwin
fi
