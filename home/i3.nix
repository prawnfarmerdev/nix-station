{
  ...
}:
{
  # ---- i3 window manager ----
  xdg.configFile."i3/config".source = ../files/i3/config;

  # ---- i3status (bottom bar) ----
  xdg.configFile."i3status/config".source = ../files/i3status/config;
  xdg.configFile."i3status/scripts" = {
    source = ../files/i3status/scripts;
    recursive = true;
  };

  # ---- Touchpad gestures ----
  xdg.configFile."libinput-gestures.conf".source = ../files/libinput-gestures.conf;

  # Launched by dex from the XDG autostart directory.
  xdg.configFile."autostart/libinput-gestures.desktop".source =
    ../files/autostart/libinput-gestures.desktop;

  # ---- Session entry points (for `startx` on non-NixOS) ----
  home.file.".xinitrc".source = ../files/xinitrc;
  home.file.".xprofile".source = ../files/xprofile;
}
