#!/bin/sh
# Toggle mirroring between two connected displays

# Get connected outputs
connected=$(xrandr | grep -w connected | awk '{print $1}')
count=$(echo "$connected" | wc -l)

if [ "$count" -lt 2 ]; then
    notify-send "Mirror toggle" "Need at least 2 connected displays"
    exit 0
fi

# Get primary output (first connected)
primary=$(echo "$connected" | head -1)
secondary=$(echo "$connected" | tail -1)

# Check if mirroring is currently enabled
mirror=$(xrandr --current | grep -A1 "$secondary" | grep -c "$primary")

if [ "$mirror" -eq 1 ]; then
    # Disable mirroring, set extended mode
    xrandr --output "$secondary" --auto --right-of "$primary"
    notify-send "Mirror toggle" "Extended mode: $secondary right of $primary"
else
    # Enable mirroring
    xrandr --output "$secondary" --same-as "$primary"
    notify-send "Mirror toggle" "Mirroring enabled: $secondary same as $primary"
fi
