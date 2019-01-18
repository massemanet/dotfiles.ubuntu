#!/bin/bash

xrandr --fb 7000x4000 \
       --output eDP-1 --scale 0.4x0.4 --pos 0x1200 \
       --output DP-1-1 --auto --rotate left --pos 1280x0 \
       --output DP-1-2-8 --auto --pos 2360x840

# use `xinput` to find the right device ids
xinput set-prop 17 288 1
xinput set-prop 11 288 1
xinput set-prop 11 280 1
