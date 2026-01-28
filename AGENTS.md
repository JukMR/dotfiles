# AGENTS.md

## Purpose

This repository provides a modular, idempotent dotfiles setup that works across multiple Linux distributions (Arch/Manjaro, Ubuntu/Debian, and others supported by the package manager abstraction). The goal is safe, repeatable setup runs with clear logging and minimal distro-specific branching.

## Entry Points

- `setup.sh`: Lean orchestrator that runs the main program installer.
- `legacy_full_setup.sh`: Full orchestrator for complete setup + extra configuration steps.
- `programs/install_all_programs.sh`: Primary program installation flow.

## Repo Structure

- `lib/`: Shared utilities
  - `detect.sh`: Distro/package manager detection (`DISTRO`, `PKG_MANAGER`, `AUR_HELPER`)
  - `logging.sh`: Structured logging and helpers (`log_info`, `run_logged`, etc.)
  - `pkg_manager.sh`: Package manager abstraction (`pkg_install`, `pkg_map`, `aur_install`, `snap_install`)
- `programs/`: One folder per program
  - `install.sh`: Installation logic
  - `apply_config.sh`: Configuration logic (copy configs, update files)
- `rcFiles/`: Shell and editor configuration files
- `scripts/`: Standalone helper scripts

## Execution Flow

```
setup.sh
  -> programs/install_all_programs.sh
     -> programs/*/install.sh
     -> programs/*/apply_config.sh

legacy_full_setup.sh
  -> programs/install_all_programs.sh
  -> extra system/user configuration (zshrc, Git, Awesome WM, etc.)
```

## Shell Script Standards

Use these patterns in all scripts:

- Strict mode: `set -euo pipefail`
- Library sourcing:
  - `source "$DOTDIR/lib/detect.sh"`
  - `source "$DOTDIR/lib/logging.sh"`
  - `source "$DOTDIR/lib/pkg_manager.sh"`
- Logging: prefer `log_info`, `log_warn`, `log_skip`, `log_success`, `log_error`
- Commands: wrap with `run_logged "Description" command ...`
- Variables:
  - Constants uppercase (`DOTDIR`, `SCRIPT_DIR`)
  - Locals lowercase (`pkg_name`, `tmp_dir`)
- Headers:
  - `#!/bin/bash`
  - brief purpose and last update line

## Package Management Rules

Never call `apt`, `pacman`, `dnf`, or `zypper` directly in program scripts.
Use the abstraction in `lib/pkg_manager.sh`:

- `pkg_install <pkg...>`
- `pkg_is_installed <pkg>`
- `pkg_map <generic-name>`
- `aur_install <pkg...>` (Arch only)
- `snap_install <pkg...>` (Ubuntu/Debian only)

## Idempotency Rules

Scripts must be safe to run multiple times.
Follow these rules:

- Check installation state before installing.
- Avoid duplicate config lines (use `grep -q` before appending).
- If replacing config files, back up the existing file and only overwrite when content differs.
- Use `log_skip` when skipping work.

## Do / Don't Checklist

Do:

- Use `run_logged` for command execution.
- Use `pkg_install` for packages.
- Add config in `apply_config.sh` (not in `install.sh`).
- Use `log_warn` for non-critical failures and continue when safe.
- Create timestamped backups when replacing configs.

Don't:

- Hardcode distro-specific package names without `pkg_map`.
- Re-run `curl | sh` installers without checking if already installed.
- Append to shell rc files without checking for existing lines.
- Use `echo` for progress where `log_*` is available.

## Logging and Diagnostics

Logging is written to:

- `~/dotfiles_setup.log` (full run log)
- `~/dotfiles_installed.log` (install/skip summary)

## Adding a New Program

1. Create `programs/<name>/install.sh` and `programs/<name>/apply_config.sh`.
2. Use `pkg_install` and `run_logged`.
3. Ensure idempotency checks at the start.
4. Add the program to `programs/install_all_programs.sh`.
5. Document any distro-specific logic with `case "$DISTRO" in ...`.

## Testing

Recommended checks:

- Run `./setup.sh` twice to validate idempotency.
- Review `~/dotfiles_setup.log` for failures.
- Verify per-program scripts run independently.
