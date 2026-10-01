{
  config,
  lib,
  pkgs,
  inputs,
  username,
  homeDirectory,
  hostname,
  ...
}:
{
  imports = [
    ./packages.nix
    ./sway.nix
    ./power.nix
    ./desktop.nix
    ./shell.nix
    ./scripts.nix
    ./webcam.nix
  ];

  home = {
    inherit username homeDirectory;
    stateVersion = "25.05";
  };

  # Makes Home Manager behave nicely on non-NixOS distributions (Void, Arch,
  # Debian, ...). On a NixOS host you would set this to false from the system
  # configuration instead.
  targets.genericLinux.enable = lib.mkDefault true;

  xdg.enable = true;

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.opencode/bin"
  ];

  home.sessionVariables = {
    TERMINAL = "kitty";
    RADV_PERFTEST = "aco";
    MESA_SHADER_CACHE_DIR = "${config.xdg.cacheHome}/mesa-shaders";

    # Run Wayland-native where possible.
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Cursor theme/size for Wayland (matches the old GTK/Xresources value).
  home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 36;
    gtk.enable = true;
  };
}
