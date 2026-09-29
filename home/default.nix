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
    ./i3.nix
    ./desktop.nix
    ./shell.nix
    ./scripts.nix
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

    XDG_SESSION_TYPE = "x11";
    XDG_SESSION_DESKTOP = "i3";
    XDG_CURRENT_DESKTOP = "i3";
    GDK_BACKEND = "x11";
  };
}
