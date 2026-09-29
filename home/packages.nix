{
  pkgs,
  lib,
  ...
}:
let
  # Apps that need unfree (Steam, Zoom) or are large.
  graphical = with pkgs; [
    # Browsers
    brave
    firefox
    chromium

    # Communication
    vesktop
    zoom-us
    proton-vpn

    # Media / downloads
    mpv
    qbittorrent
    deluge

    # Gaming
    steam
    gamescope
  ];

  # Nerd Fonts are provided as an attribute set in nixpkgs.
  fonts = with pkgs.nerd-fonts; [
    inconsolata
    lekton
    symbols-only
  ];
in
{
  home.packages =
    with pkgs;
    [
      # ---- Window manager / desktop shell (i3 on X11) ----
      i3
      i3status
      i3blocks
      i3lock
      xss-lock
      dex
      dmenu
      rofi
      dunst
      libnotify
      feh
      networkmanagerapplet
      polkit_gnome
      gnome-keyring
      xdg-utils
      xdg-desktop-portal
      xdg-desktop-portal-gtk

      # ---- X11 plumbing ----
      xorg.xorgserver
      xorg.xinit
      xorg.xauth
      xorg.xrandr
      xorg.xrdb
      xorg.xset
      xorg.xinput
      xorg.xprop
      xorg.setxkbmap
      xorg.xev
      xorg.xmodmap
      xorg.xhost
      xorg.xkill
      xorg.xdpyinfo
      xorg.xwininfo
      xclip
      xdotool
      xprintidle
      maim

      # ---- Input / power / audio ----
      libinput
      libinput-gestures
      brightnessctl
      playerctl
      upower
      tlp
      powertop
      pipewire
      wireplumber
      pulseaudio
      pavucontrol
      alsa-utils

      # ---- Session bus / system helpers used by the i3 config ----
      dbus
      util-linux
      networkmanager
      polkit

      # ---- Terminals / editors ----
      kitty
      wezterm
      xterm
      emacs
      neovim

      # ---- CLI / dev tooling ----
      git
      gh
      jq
      curl
      wget
      openssl
      sshpass
      kubernetes
      kubernetes-helm
      tmux
      btop
      htop
      fastfetch
      cmatrix
      yazi
      ripgrep
      fd
      fzf
      file
      unzip
      p7zip

      # ---- Theming / fonts ----
      gtk3
      gtk4
      adwaita-icon-theme
      papirus-icon-theme
      liberation_ttf
      dejavu_fonts
      noto-fonts
      noto-fonts-emoji
    ]
    ++ fonts
    ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 graphical;
}
