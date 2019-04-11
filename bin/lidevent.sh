#!/bin/bash

echo "user - $(whoami) - 1:$1 2:$2 3:$3" >> /tmp/liduevent.log
DISPLAY=:0 xrandr | grep " conn" >> /tmp/liduevent.log

if [ "$3" == "close" ]; then
    echo -n "turning off eDP-1... " >> /tmp/liduevent.log
    DISPLAY=:0 xrandr --output eDP-1 --off
    echo $? >> /tmp/liduevent.log
else
    echo -n "turning on eDP-1... " >> /tmp/liduevent.log
    DISPLAY=:0 xrandr --output eDP-1 --auto
    echo $? >> /tmp/liduevent.log
    echo -n "running 3screens.sh... " >> /tmp/liduevent.log
    DISPLAY=:0 ~/bin/3screens.sh
    echo $? >> /tmp/liduevent.log >> /tmp/liduevent.log
fi
