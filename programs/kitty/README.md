# Kitty Configuration

This directory contains the kitty terminal emulator configuration and associated files.

## Files

- `kitty.conf` - Main configuration file
- `kittens/kitten_save_session.py` - Custom kitten for saving sessions
- `apply_kitty_conf` - Script to apply configuration to `~/.config/kitty/`
- `install.sh` - Installation script
- `upgrade.sh` - Upgrade script

## Usage

Run the apply script to copy the configuration to your local kitty config:

```bash
./apply_kitty_conf
```

## Idempotent Behaviour

The `apply_kitty_conf` script is idempotent:

- **First run**: Copies both `kitty.conf` and `kitten_save_session.py` to `~/.config/kitty/`
- **Subsequent runs**: Only copies files if they have changed (detected via `cmp`)
- **Backups**: If `kitty.conf` exists and differs, a timestamped backup is created before overwriting

This means you can safely run `./apply_kitty_conf` multiple times without side effects.
