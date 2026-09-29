#!/bin/sh
# Toggle touchpad enabled/disabled

TP_ID=$(xinput list | grep -i touchpad | grep -o 'id=[0-9]*' | cut -d= -f2)

if [ -z "$TP_ID" ]; then
    echo "Touchpad not found"
    exit 1
fi

# Get current enabled state
ENABLED=$(xinput list-props $TP_ID | grep "Device Enabled" | awk '{print $4}')

if [ "$ENABLED" = "1" ]; then
    xinput disable $TP_ID
    echo "Touchpad disabled"
else
    xinput enable $TP_ID
    echo "Touchpad enabled"
fi
