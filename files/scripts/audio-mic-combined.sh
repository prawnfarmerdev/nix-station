#!/bin/bash
# Combined audio and mic status with separator

audio_icon=$(cat /tmp/audio_output.txt 2>/dev/null || echo $'\uf128')  # question if missing
mic_icon=$(cat /tmp/mic_status.txt 2>/dev/null || echo $'\uf131')      # mic-slash if missing

# Output combined with pipe separator
echo "${audio_icon}|${mic_icon}"
