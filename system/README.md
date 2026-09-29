# System-level bits

Home Manager only manages files inside a user's home directory, so the
following files must be installed by hand (as root) on the target machine.

## Xorg configuration

Copy the files in `system/xorg/` to `/etc/X11/xorg.conf.d/`:

```
sudo install -Dm644 system/xorg/00-keyboard.conf        /etc/X11/xorg.conf.d/00-keyboard.conf
sudo install -Dm644 system/xorg/20-amdgpu.conf          /etc/X11/xorg.conf.d/20-amdgpu.conf
sudo install -Dm644 system/xorg/80-touchpad-libinput.conf /etc/X11/xorg.conf.d/80-touchpad-libinput.conf
```

- `00-keyboard.conf`  - US layout, Caps Lock remapped to Ctrl.
- `20-amdgpu.conf`    - AMD GPU driver, VariableRefresh (VRR), 2560x1600 eDP.
- `80-touchpad-libinput.conf` - Framework 16 touchpad (tap-to-click, natural
  scrolling, gestures, clickfinger).

## Kernel command line

The Framework 16 benefits from the `amd_pstate=active` CPU scaling driver.
Edit `/etc/default/grub`:

```
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4 amd_pstate=active"
```

then regenerate the GRUB config and reboot.

## Services (distribution dependent)

These are system services used by the desktop; enable them with the target
distribution's own tooling:

- NetworkManager          (`nm-applet` / `nmcli` are provided by Home Manager)
- elogind / seat management (provides XDG_RUNTIME_DIR and session tracking)
- dbus
- tlp                     (battery/power management)
- pipewire + wireplumber  (or pulseaudio, which the i3 config starts)
- fwupd                   (firmware updates)

On NixOS these are declarative (`services.xserver`, `networking.networkmanager`,
`services.tlp`, `services.pipewire`, ...); see the README for a minimal host
module.
