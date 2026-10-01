#!/usr/bin/env bash
# Combined audio and mic status daemon
# Writes to /tmp/audio_mic.txt with pipe separator

AUDIO_MIC_FILE="/tmp/audio_mic.txt"

# Clean up on exit
cleanup() {
    rm -f "$AUDIO_MIC_FILE"
    exit 0
}
trap cleanup TERM INT

# Update loop
while true; do
    audio_icon=$(cat /tmp/audio_output.txt 2>/dev/null || echo $'\uf128')  # question if missing
    mic_icon=$(cat /tmp/mic_status.txt 2>/dev/null || echo $'\uf131')      # mic-slash if missing

    # Output combined with vertical bar separator (U+2502)
    echo "${audio_icon}"$'\u2502'"${mic_icon}" > "$AUDIO_MIC_FILE"

    sleep 2
done
