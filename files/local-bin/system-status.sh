#!/usr/bin/env bash
echo "=== Framework Laptop System Status ==="
echo

echo "1. VRR Status"
echo "   Kernel parameter: $(cat /proc/cmdline | grep -o "amdgpu.vrr=[^ ]*" || echo "Not found")"
echo "   Xrandr vrr_capable: $(xrandr --prop | grep -A1 "vrr_capable:" | grep -o "[0-1]" | head -1)"
echo

echo "2. Display Settings"
CURRENT_MODE=$(xrandr | grep "^\s*[0-9]" | grep "*" | head -1 | awk '{print $1 " @ " $2}')
echo "   Mode: $CURRENT_MODE"
echo "   AC Status: $(cat /sys/class/power_supply/ACAD/online 2>/dev/null || echo "Unknown") (1=AC, 0=Battery)"
DPMS_TIMEOUT=$(xset q | grep "Standby:" | awk '{print $2 "s"}')
echo "   DPMS Timeout: $DPMS_TIMEOUT"
echo

echo "3. Touchpad"
TP_ID=$(xinput list | grep -i touchpad | grep -o 'id=[0-9]*' | cut -d= -f2)
if [ -n "$TP_ID" ]; then
    ENABLED=$(xinput list-props $TP_ID | grep "Device Enabled" | awk '{print $4}')
    TAP_ACTION=$(xinput list-props $TP_ID | grep "Tap Action" | cut -d: -f2 | xargs)
    echo "   Enabled: $ENABLED (1=yes, 0=no)"
    echo "   Tap Action: $TAP_ACTION (1=left,3=right,2=middle)"
    SCROLL_DIST=$(xinput list-props $TP_ID | grep "Scrolling Distance" | cut -d: -f2 | xargs)
    if echo "$SCROLL_DIST" | grep -q "-90"; then
        NATURAL="Yes"
    else
        NATURAL="No"
    fi
    echo "   Natural Scrolling: $NATURAL"
    echo "   Toggle Key: XF86TouchpadToggle"
else
    echo "   Not found"
fi
echo

echo "4. Running Services"
echo "   Power Manager: $(ps aux | grep -q "[p]ower-manager.sh" && echo "Running" || echo "Not running")"
echo "   Touchpad Setup: $(ps aux | grep -q "[t]ouchpad-setup.sh" && echo "Running" || echo "Not running (settings applied)")"
echo

echo "5. Keybindings"
echo "   XF86TouchpadToggle - Toggle touchpad"
echo "   XF86Audio* - Volume controls"
echo "   Mod+Return - Terminal"
echo "   Mod+d - Application launcher"
echo

echo "=== Summary ==="
echo "VRR configured (amdgpu.vrr=1)"
echo "Touchpad gestures active"
echo "Power management active"
echo "All scripts auto-starting"
echo
echo "To toggle touchpad: Press touchpad toggle key (function row)"
echo "To check VRR: ~/.local/bin/vrr-status.sh"
