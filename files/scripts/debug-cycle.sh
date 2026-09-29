#!/bin/sh
# Debug version of cycle-audio.sh

set -x

# Get current default sink
current_sink=$(pactl info | grep "Default Sink:" | cut -d' ' -f3)
echo "Current sink: '$current_sink'"

# Get list of all sinks
sinks=$(pactl list short sinks | awk '{print $2}')
echo "Sinks: '$sinks'"
echo "Sink count: $(echo "$sinks" | wc -l)"

# Find current index and next sink
index=1
next_sink=""
for sink in $sinks; do
    echo "Checking sink $index: '$sink' vs '$current_sink'"
    if [ "$sink" = "$current_sink" ]; then
        echo "Match at index $index"
        # Calculate next index (wrap around)
        next_index=$((index % sink_count + 1))
        echo "Next index: $next_index"
        next_sink=$(echo "$sinks" | sed -n "${next_index}p")
        break
    fi
    index=$((index + 1))
done

echo "Next sink: '$next_sink'"
if [ -n "$next_sink" ]; then
    echo "Would switch to: $next_sink"
else
    echo "No next sink found"
fi
