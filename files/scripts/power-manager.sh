#!/usr/bin/env bash
# Power manager for Sway/Wayland
# Switches the panel refresh rate based on AC/battery, like the old xrandr
# version did, and notifies on change.
# --- CONFIGURATION ---
MONITOR="$(swaymsg -t get_outputs -r 2>/dev/null | jq -r '.[] | select(.focused == true) | .name' | head -1)"
MONITOR="${MONITOR:-eDP-1}"
PERFRES="2560x1600"
PERFREFRESH="120"
BATREFRESH="60"
AC_PATH=""
for _ac in /sys/class/power_supply/AC*/online /sys/class/power_supply/ACAD/online; do
    [ -f "$_ac" ] && AC_PATH="$_ac" && break
done
AC_PATH="${AC_PATH:-/sys/class/power_supply/AC0/online}"
STATE_FILE="/tmp/power_state_last"
LOCK_FILE="/tmp/power-manager.lock"
# --- LOGGING ---
LOG_FILE="${LOG_FILE:-/tmp/power-manager.log}"
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"
    if [ -t 0 ]; then
        echo "$(date '+%H:%M:%S') $*"
    fi
}
# Check if AC path exists
if [ ! -f "$AC_PATH" ]; then
    notify-send -u critical "Power Manager" "Error: $AC_PATH not found"
    exit 1
fi
# Prevent multiple instances
if [ -f "$LOCK_FILE" ]; then
    OLD_PID=$(cat "$LOCK_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "Power manager already running (PID: $OLD_PID)"
        exit 0
    fi
fi
# Create lock file with our PID
echo $$ > "$LOCK_FILE"
log "Power manager started (PID: $$)"
# Cleanup on exit
cleanup() {
    rm -f "$STATE_FILE" "$LOCK_FILE"
}
trap cleanup EXIT INT TERM
# Function to apply settings
apply_power_settings() {
    local status=$1
    if [ "$status" = "1" ]; then
        # --- PLUGGED IN ---
        swaymsg output "$MONITOR" mode "${PERFRES}@${PERFREFRESH}Hz" > /dev/null 2>&1
        log "AC: plugged in, set $PERFRES @ ${PERFREFRESH}Hz"
        notify-send -r 999 "Power Manager" "AC: $PERFRES @ ${PERFREFRESH}Hz"
    else
        # --- ON BATTERY ---
        swaymsg output "$MONITOR" mode "${PERFRES}@${BATREFRESH}Hz" > /dev/null 2>&1
        log "AC: on battery, set $PERFRES @ ${BATREFRESH}Hz"
        notify-send -r 999 "Power Manager" "Battery: $PERFRES @ ${BATREFRESH}Hz"
    fi
}
# Initialize state file
echo "none" > "$STATE_FILE"
# Run once on startup
CURRENT_STATUS=$(cat "$AC_PATH")
apply_power_settings "$CURRENT_STATUS"
echo "$CURRENT_STATUS" > "$STATE_FILE"
# Watch for AC changes (polling method)
while true; do
    sleep 10
    CURRENT_STATUS=$(cat "$AC_PATH")
    LAST_STATUS=$(cat "$STATE_FILE" 2>/dev/null || echo "none")
    if [ "$CURRENT_STATUS" != "$LAST_STATUS" ]; then
        log "AC status changed: $LAST_STATUS -> $CURRENT_STATUS"
        apply_power_settings "$CURRENT_STATUS"
        echo "$CURRENT_STATUS" > "$STATE_FILE"
    fi
done
