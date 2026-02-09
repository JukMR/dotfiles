# Logitech Mouse libinput Configuration

This repository installs a permanent libinput configuration for a Logitech mouse
(using the USB Receiver) on **Xorg** systems.

The goal is to avoid using `xinput` (runtime-only) and make the settings persist
across reboots and replugging.

---

## Files

### `install_config_files.sh`

Installs the mouse configuration into the system Xorg configuration directory:

- Creates `/etc/X11/xorg.conf.d/` if it does not exist
- Copies `mouse_config` to:
  `/etc/X11/xorg.conf.d/90-logitech-mouse.conf`

This script is safe to run multiple times.

Usage:
```bash
./install_config_files.sh
```

A logout or reboot is required for changes to apply.

# mouse_config

Xorg InputClass configuration for libinput.

It matches the Logitech USB Receiver by product name and USB ID and applies the
following settings:

- Flat mouse acceleration
- Reduced acceleration speed (-0.8)
- Normal wheel scrolling
- Button scrolling while holding mouse button 2
- Natural scrolling disabled
- Middle-click emulation disabled
- Horizontal scrolling enabled

These settings are applied automatically by Xorg at startup.

# Notes

- This configuration only works on Xorg
- It is ignored on Wayland sessions
- Logitech firmware-level acceleration is not affected (libinput only)

To check if you are on Xorg:

```bash
echo $XDG_SESSION_TYPE
```

# Verification

After logging back in, you can verify the settings with:


```bash
xinput list-props "Logitech USB Receiver"
```
