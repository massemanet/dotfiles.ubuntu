export LANG=en_US.utf8
dbus-update-activation-environment --systemd DISPLAY

i3 &

I3_PID="$!"

xset r rate 250 60

gkrellm &

xautolock \
    -time 10 \
    -notify 10 \
    -locker "i3lock -ti /home/masse/hexdump.png" \
    -notifier "notify-send -u critical -t 1000 -- 'locking screen in 10 secs'" &

wait "$I3_PID"
