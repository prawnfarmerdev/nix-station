#!/bin/sh
# Toggle mirroring between two connected displays (Sway/Wayland).

outputs_json="$(swaymsg -t get_outputs -r 2>/dev/null)"
connected="$(echo "$outputs_json" | jq -r '.[] | select(.active == true) | .name')"
count="$(echo "$connected" | sed '/^$/d' | wc -l)"

if [ "$count" -lt 2 ]; then
    notify-send "Mirror toggle" "Need at least 2 connected displays"
    exit 0
fi

# Primary output (first connected), secondary (last connected).
primary="$(echo "$connected" | head -1)"
secondary="$(echo "$connected" | tail -1)"

primary_geom="$(echo "$outputs_json" | jq -r --arg n "$primary" '.[] | select(.name == $n) | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"')"
secondary_geom="$(echo "$outputs_json" | jq -r --arg n "$secondary" '.[] | select(.name == $n) | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"')"

if [ "$primary_geom" = "$secondary_geom" ]; then
    # Currently mirrored -> extend to the right of the primary.
    width="$(echo "$outputs_json" | jq -r --arg n "$primary" '.[] | select(.name == $n) | .rect.width')"
    swaymsg output "$secondary" position "$width" 0 > /dev/null
    notify-send "Mirror toggle" "Extended mode: $secondary right of $primary"
else
    # Currently extended -> mirror on top of the primary.
    swaymsg output "$secondary" position 0 0 > /dev/null
    notify-send "Mirror toggle" "Mirroring enabled: $secondary same as $primary"
fi
