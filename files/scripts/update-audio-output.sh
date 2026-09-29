#!/bin/sh
# Update audio output file for i3status

AUDIO_FILE="/tmp/audio_output.txt"

# Create file if it doesn't exist
touch "$AUDIO_FILE"

# Clean up on exit
cleanup() {
    rm -f "$AUDIO_FILE"
    exit 0
}
trap cleanup TERM INT

# Update loop
while true; do
    "$HOME/.config/scripts/current-audio.sh" > "$AUDIO_FILE"
    sleep 5
done
