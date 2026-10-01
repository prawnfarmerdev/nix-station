#!/usr/bin/env bash

# Mic status daemon for i3status
# Updates /tmp/mic_status.txt with current mic mute status

while true; do
    mute_status=$(pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | awk '{print $2}')

    if [ "$mute_status" = "yes" ]; then
        echo "Mic: Off" > /tmp/mic_status.txt
    else
        echo "Mic: On" > /tmp/mic_status.txt
    fi

    sleep 1
done
