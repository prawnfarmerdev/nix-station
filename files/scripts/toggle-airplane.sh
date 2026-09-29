#!/bin/sh
# Toggle airplane mode (block/unblock all wireless and manage NetworkManager)

if rfkill list | grep -q "Soft blocked: yes"; then
    # Unblock all wireless
    rfkill unblock all
    # Enable NetworkManager WiFi radio
    nmcli radio wifi on 2>/dev/null || true
    # Try to reconnect to previous WiFi
    nmcli connection up --ask 2>/dev/null || true
    notify-send "Airplane mode" "Wireless enabled - attempting reconnect"
else
    # Block all wireless
    rfkill block all
    # Disable NetworkManager WiFi radio
    nmcli radio wifi off 2>/dev/null || true
    notify-send "Airplane mode" "Wireless disabled"
fi
