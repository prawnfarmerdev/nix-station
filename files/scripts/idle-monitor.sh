#!/bin/sh
# Idle monitor - suspends after 15 min on battery
# Uses xprintidle for input detection

LOCK_FILE="/tmp/idle-monitor.lock"
IDLE_TIMEOUT=600000  # 10 min in ms
CHECK_INTERVAL=30    # check every 30s
AC_PATH="/sys/class/power_supply/ACAD/online"

# Prevent multiple instances
if [ -f "$LOCK_FILE" ]; then
    OLD_PID=$(cat "$LOCK_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        exit 0
    fi
fi
echo $$ > "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT INT TERM

while true; do
    # Check if on battery
    if [ -f "$AC_PATH" ] && [ "$(cat "$AC_PATH")" = "1" ]; then
        # On AC, skip
        sleep "$CHECK_INTERVAL"
        continue
    fi

    # Check idle time
    IDLE=$(xprintidle 2>/dev/null)
    IDLE=${IDLE:-0}
    if [ "$IDLE" -ge "$IDLE_TIMEOUT" ] 2>/dev/null; then
        # Check if audio is playing via ALSA
        if grep -q 'state: RUNNING' /proc/asound/card*/pcm*/sub*/status 2>/dev/null; then
            continue
        fi
        logger "idle-monitor: ${IDLE}ms idle on battery, suspending"
        sudo /usr/bin/zzz
    fi

    sleep "$CHECK_INTERVAL"
done
