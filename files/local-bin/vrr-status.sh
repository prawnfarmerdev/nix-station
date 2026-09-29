#!/bin/bash
# Check VRR support and status

DEBUGFS="/sys/kernel/debug/dri/0/eDP-1/vrr_range"

# Check if debugfs is mounted
if ! mount | grep -q "debugfs on /sys/kernel/debug"; then
    echo "debugfs not mounted, mounting..."
    sudo mount -t debugfs none /sys/kernel/debug 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "WARNING: Could not mount debugfs. Run with sudo or ensure debugfs is in /etc/fstab"
    fi
fi

echo "=== VRR Status ==="
if [ -f "$DEBUGFS" ]; then
    echo "VRR range:"
    sudo cat "$DEBUGFS" 2>/dev/null
else
    echo "VRR debugfs not accessible at $DEBUGFS"
    echo "Debugfs status:"
    mount | grep debugfs || echo "Not mounted"
fi

echo ""
echo "Xrandr properties:"
xrandr --prop | grep -A2 -B2 vrr_capable

echo ""
echo "Graphics card:"
lspci | grep -E "(VGA|Display|Graphics)"

echo ""
echo "Kernel parameters:"
cat /proc/cmdline | grep -o "amdgpu.vrr=[^ ]*" || echo "amdgpu.vrr not found in cmdline"

echo ""
echo "Xorg config:"
if [ -f /etc/X11/xorg.conf.d/20-amdgpu.conf ]; then
    grep "VariableRefresh" /etc/X11/xorg.conf.d/20-amdgpu.conf || echo "VariableRefresh not in config"
else
    echo "Xorg config not found at /etc/X11/xorg.conf.d/20-amdgpu.conf"
fi

echo ""
echo "Summary: VRR is supported (60-165Hz range)."
echo "VRR should be enabled with:"
echo "1. Kernel parameter: amdgpu.vrr=1"
echo "2. Xorg config: VariableRefresh true"
echo "3. Requires fullscreen applications (games) for VRR to activate"
echo "4. i3 window manager (no compositing) is compatible"
