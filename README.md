# nix-station

Declarative reproduction of this Framework 16 laptop's desktop, built on
[Home Manager](https://github.com/nix-community/home-manager). It installs the
apps and manages the dotfiles for an **i3 / X11** desktop, and it works on any
Linux distribution that has Nix installed (currently Void Linux), as well as on
NixOS.

The reference machine: Framework Laptop 16, AMD Ryzen 7 7840HS (Radeon 780M),
2560x1600 165 Hz, i3 + i3status on Xorg.

## Layout

```
flake.nix                  # inputs + homeConfigurations (one per machine/user)
home/
  default.nix              # entry module: identity, session vars, imports
  packages.nix             # every application / CLI / font
  i3.nix                   # i3, i3status, libinput-gestures, session entry points
  desktop.nix              # dunst, rofi, kitty, wezterm, btop, GTK/Xresources
  shell.nix                # bash (prompt, aliases, PATH)
  scripts.nix              # ~/.config/scripts and ~/.local/bin helpers
files/                     # the actual config files (tracked, portable)
system/                    # root-owned configs Home Manager cannot own
```

All paths inside `files/` use `~` / `$HOME`, so the repo works for a user other
than `labanos`.

## What gets installed

- **Desktop / WM:** i3, i3status, i3blocks, i3lock, xss-lock, dex, dmenu, rofi,
  dunst, feh, network-manager-applet, polkit-gnome, gnome-keyring
- **Browsers:** Brave, Firefox, Chromium
- **Comms:** Vesktop, Zoom, Proton VPN
- **Media:** mpv, qBittorrent, Deluge
- **Gaming:** Steam, gamescope
- **Terminals / editors:** kitty, WezTerm, xterm, Emacs, Neovim
- **CLI:** git, gh, jq, curl, wget, kubernetes, helm, tmux, btop, htop,
  fastfetch, cmatrix, yazi, ripgrep, fd, fzf, ...
- **Audio / input / power:** pipewire, wireplumber, pulseaudio, pavucontrol,
  playerctl, brightnessctl, libinput-gestures, tlp, powertop, upower
- **Fonts:** Inconsolata, Lekton and Symbols Nerd Fonts, Liberation, DejaVu,
  Noto.

## Fresh install on another machine

1. **Install Nix** (with flakes enabled).

   ```sh
   sh <(curl -L https://nixos.org/nix/install) --daemon
   # ensure experimental-features includes nix-command flakes in /etc/nix/nix.conf
   ```

2. **Clone this repo.**

   ```sh
   git clone <your-remote> ~/projects/nix-station
   cd ~/projects/nix-station
   ```

3. **Adjust the username** (only if it is not `labanos`). Either edit the
   `username` default in `flake.nix`, or add a new entry:

   ```nix
   homeConfigurations."alice" = mkHome {
     username = "alice";
     homeDirectory = "/home/alice";
     hostname = "desk";
   };
   ```

4. **Activate Home Manager.**

   ```sh
   nix run home-manager/master -- switch --flake .#labanos
   ```

   `.#labanos` is the attribute name in `homeConfigurations` (the key), not the
   Linux username.

5. **Install the system-level files** (requires root) - see `system/README.md`:

   ```sh
   sudo install -Dm644 system/xorg/*.conf /etc/X11/xorg.conf.d/
   ```

6. **Start the desktop.**

   ```sh
   startx          # uses ~/.xinitrc -> dbus-run-session i3
   ```

   Or point a display manager at the i3 session.

## Day-to-day

```sh
home-manager switch --flake ~/projects/nix-station#labanos   # apply changes
home-manager generations                                      # rollback list
nix flake update                                              # bump inputs
```

## Migration caveats

Home Manager refuses to overwrite files it does not already manage. When
switching on a machine that already has these dotfiles, back them up first:

```sh
home-manager switch --flake .#labanos -b backup
```

or remove the old files (`~/.config/i3`, `~/.config/scripts`, `~/.local/bin`,
`~/.Xresources`, `~/.bashrc`, ...) before the first switch.

A few things stay machine/distribution specific and are intentionally **not**
managed here:

- `~/.gitconfig` (contains your credentials helper / identity)
- browser/app profiles (`~/.mozilla`, `~/.config/chromium`, Steam data)
- any Flatpak installs (now replaced by native nixpkgs apps)

## Notes

- **No Flatpak.** Brave, Proton VPN, Vesktop and Zoom are installed from
  nixpkgs; the old Flatpak wrappers were removed so the native binaries win.
- **Steam** is unfree and, on a non-NixOS host, may need extra set-up (the
  `steam` package plus `nixpkgs.config.allowUnfree`, already set here). On NixOS
  prefer `programs.steam.enable = true`.
- **Audio warm-up:** the i3 config runs `pulseaudio --start`. If you switch to
  PipeWire, remove that line and let `wireplumber` own the session.
- The bar reads `/tmp/{weather,audio_output,mic_status}.txt`, written by the
  daemons under `~/.config/i3status/scripts/`.
- `i3status` currently uses a hardware-specific battery path
  (`/sys/class/power_supply/BAT%d/uevent`) and a Toronto timezone; edit
  `files/i3status/config` for other hardware/regions.

## Reusing on NixOS

Add the Home Manager module to a NixOS host:

```nix
{
  inputs.nix-station.url = "github:<you>/nix-station";

  # in the host configuration:
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inputs = inputs;
      username = "labanos";
      homeDirectory = "/home/labanos";
      hostname = "framework16";
    };
    users.labanos = {
      imports = [ "${inputs.nix-station}/home" ];
      targets.genericLinux.enable = false;
    };
  };
}
```
