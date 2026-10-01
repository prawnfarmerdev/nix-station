#!/bin/sh
# Toggle touchpad enabled/disabled (Sway/Wayland).

state="$(swaymsg -t get_inputs -r 2>/dev/null | jq -r '.[] | select(.type == "touchpad") | .libinput.send_events' | head -1)"

case "$state" in
    disabled|disabled_on_external_mouse)
        new="enabled"
        ;;
    *)
        new="disabled"
        ;;
esac

swaymsg input type:touchpad events "$new" > /dev/null 2>&1
notify-send "Touchpad" "Touchpad $new"
