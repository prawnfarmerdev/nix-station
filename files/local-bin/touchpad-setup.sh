#!/bin/bash
# Touchpad setup script for libinput driver
# Configures libinput properties and starts libinput-gestures
# Called from i3 config at startup

set -e

echo "Starting touchpad setup..."

# Wait for X and touchpad to be ready
sleep 2

# Try for up to 15 seconds to find touchpad
TP_ID=""
for i in $(seq 1 15); do
    TP_ID=$(xinput list | grep -i "PIXA3854:00 093A:0274 Touchpad" | grep -o 'id=[0-9]*' | cut -d= -f2)
    if [ -n "$TP_ID" ]; then
        echo "Found touchpad with ID: $TP_ID"
        break
    fi
    sleep 1
done

if [ -z "$TP_ID" ]; then
    echo "Error: Touchpad not found after 15 seconds"
    exit 1
fi

# Check if driver is libinput
if xinput list-props "$TP_ID" | grep -q "libinput"; then
    echo "Touchpad driver: libinput"

    # Configure libinput properties (if not already set by Xorg config)
    echo "Configuring libinput properties..."

    # Enable tap-to-click
    xinput set-prop "$TP_ID" "libinput Tapping Enabled" 1

    # Set tap button mapping: 1 finger = left, 2 fingers = right, 3 fingers = middle
    xinput set-prop "$TP_ID" "libinput Tapping Button Mapping Enabled" 1 0

    # Enable natural scrolling
    xinput set-prop "$TP_ID" "libinput Natural Scrolling Enabled" 1

    # Enable horizontal scrolling
    xinput set-prop "$TP_ID" "libinput Horizontal Scroll Enabled" 1

    # Set scroll method to two-finger
    xinput set-prop "$TP_ID" "libinput Scroll Method Enabled" 1 0 0

    # Set click method to clickfinger (two-finger tap for right click)
    xinput set-prop "$TP_ID" "libinput Click Method Enabled" 0 1

    # Enable middle emulation (three-finger tap for middle click)
    xinput set-prop "$TP_ID" "libinput Middle Emulation Enabled" 1

    # Enable tap-and-drag
    xinput set-prop "$TP_ID" "libinput Tapping Drag Enabled" 1

    # Disable while typing
    xinput set-prop "$TP_ID" "libinput Disable While Typing Enabled" 1

    echo "Libinput properties configured"
else
    echo "Warning: Touchpad not using libinput driver. Gestures may not work correctly."
    echo "Consider installing libinput Xorg configuration."
fi

# Start libinput-gestures if not already running
if ! pgrep -f "libinput-gestures" > /dev/null; then
    echo "Starting libinput-gestures..."
    # Start in background
    libinput-gestures &
    sleep 2
    if pgrep -f "libinput-gestures" > /dev/null; then
        echo "libinput-gestures started successfully (PID: $(pgrep -f libinput-gestures | head -1))"
    else
        echo "Warning: Failed to start libinput-gestures"
        echo "Check that ~/.config/libinput-gestures.conf exists and is valid"
    fi
else
    echo "libinput-gestures is already running (PID: $(pgrep -f libinput-gestures | head -1))"
fi

echo "Touchpad setup complete"
exit 0
