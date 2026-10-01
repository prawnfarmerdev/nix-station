#!/usr/bin/env bash
# Re-apply the laptop webcam's white balance.
#
# The "USB2.0 HD UVC WebCam" occasionally initialises its auto white balance to
# a warm/yellow calibration, which leaves the preview tinted. Toggling
# white_balance_automatic off and back on makes the camera recalculate it
# against the current room light. Run manually or from the systemd path unit.
set -euo pipefail

DEV="${WEBCAM_DEVICE:-/dev/video0}"

command -v v4l2-ctl >/dev/null 2>&1 || exit 0
[ -e "$DEV" ] || exit 0

for _ in 1 2 3 4 5; do
  if v4l2-ctl -d "$DEV" --set-ctrl=white_balance_automatic=0 >/dev/null 2>&1; then
    break
  fi
  sleep 0.5
done

v4l2-ctl -d "$DEV" --set-ctrl=white_balance_automatic=1 >/dev/null 2>&1 || true
