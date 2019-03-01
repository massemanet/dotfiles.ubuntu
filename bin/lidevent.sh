#!/bin/bash

echo "user - $(whoami) - 1:$1 2:$2 3:$3" >> /tmp/liduevent.log
echo "$(DISPLAY=:0 xrandr | grep " conn")" >> /tmp/liduevent.log

if [ "$3" == "close" ]
then DISPLAY=:0 xrandr --output eDP-1 --off ; echo $? >> /tmp/liduevent.log
else DISPLAY=:0 xrandr --output eDP-1 --auto  --scale 0.4x0.4; echo $? >> /tmp/liduevent.log
fi
