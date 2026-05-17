# Python Orchestrator Plan

## Goal
Migrate `manjaro_essentials.sh` to a modular, OS-independent Python orchestrator supporting Manjaro and Ubuntu, with logging, idempotency, stow package integration, and unit tests.

## Constraints & Preferences
- **OS-independent**: Target Manjaro & Ubuntu
- **Modular/orchestrator architecture**: Reduce/reuse code
- **Idempotent execution**: Safe to re-run
- **Comprehensive logging**: Record successes/failures
- **Stow package integration**: Install via existing profiles
- **Unit tests**: Cover all major components

## Progress
### Done
- Analyzed source script `manjaro_essentials.sh` (270 lines, bash, relies on `pacman`, `yay`, `sudo`, `systemd`, `crontab`)
- Reviewed existing stow setup: `stow/install_stow.py` (Python, `inquirer`, `dataclasses`) and `stow/profiles/` (`base/`, `manjaro/`, `ubuntu/`, `personal/`)
- Inspected dependency scripts in `programs/` (`kitty/install.sh`, `atuin/install.sh`, `zoxide/install.sh`, `neovim/`, `oh-my-zsh/`, `ssh-agent/apply_service.sh`, `clipboard/install.sh`, etc.)
- Reviewed `programs/vscode-nvim/` — minimal config for vscode-neovim extension that bypasses AstroNvim (stowed via stow)
- Implemented full Python orchestrator (`setup/` package) with loguru logging and uv dependency management
- Created 14 modules: kitty, pacman_config, zsh_ohmyzsh, git, neovim, dotfiles, awesome, picom, ssh, atuin, zoxide, clipboard, cronjob, git_diff_image
- CLI with --dry-run, --skip, --list, --verbose, --os, --profile, --log-file options
- 51 unit tests (all mocked, no system changes) — all passing
- `pyproject.toml` for uv with loguru + pytest dependencies

## Key Decisions
- **No shell subprocesses for install logic**: Use `subprocess.run()` directly in Python instead of calling `.sh` scripts. The `.sh` scripts become the source of truth to port, not runtime dependencies.
- **Reuse `install_stow.py`**: The stow module is already well-structured Python. Import it from the setup module.
- **Profile-based config**: Leverage existing `stow/profiles/{base,manjaro,ubuntu,personal}` structure.
- **Neovim 0.9.5 build deprecated**: We can now run with latest nvim config. Skip the 0.9.5 build script. Install latest nvim, clone `JuKMR/astronvim-configuration`. The `vscode-nvim` stow package handles the nvim-vscode init config.
- **Keyboard config excluded**: `keyboard-us-altgr-variant.sh` is useful but not integrated into the orchestrator. Leave the script for future manual usage if needed.

## Architecture

### Directory Structure

```
dotfiles/
├── setup/                                    # NEW Python package
│   ├── __init__.py
│   ├── __main__.py                           # entry: python -m setup
│   ├── orchestrator.py                       # Main conductor
│   ├── os_detector.py                        # Detect distro from /etc/os-release
│   ├── installer.py                          # ABC for package managers
│   ├── installer_pacman.py                   # pacman + yay
│   ├── installer_apt.py                      # apt + snap/flatpak
│   ├── logging_config.py                     # Structured logging
│   ├── utils.py                              # Shared helpers
│   └── modules/                              # Reusable install modules
│       ├── __init__.py
│       ├── base.py                           # Module ABC
│       ├── kitty.py
│       ├── zsh_ohmyzsh.py
│       ├── git.py
│       ├── neovim.py
│       ├── dotfiles.py                       # Stow + config file management
│       ├── awesome.py
│       ├── picom.py
│       ├── ssh.py
│       ├── atuin.py
│       ├── zoxide.py
│       ├── clipboard.py
│       ├── cronjob.py
│       └── pacman_config.py                  # configure_pacman.sh equivalent
│
├── tests/
│   ├── conftest.py                           # Shared fixtures/mocks
│   ├── test_os_detector.py
│   ├── test_installer.py
│   ├── test_orchestrator.py
│   └── test_modules/
│       ├── test_kitty.py
│       ├── test_zsh_ohmyzsh.py
│       ├── test_git.py
│       ├── test_neovim.py
│       ├── test_dotfiles.py
│       ├── test_awesome.py
│       └── test_pacman_config.py
│
└── manjaro_essentials.sh                     # KEPT for reference, TODO: remove in future
```

### Core Components

#### `os_detector.py` — detect OS
- Read `/etc/os-release` to determine distro
- Return normalized distro name: `manjaro`, `ubuntu`, `arch`, `debian`, `other`
- Returns the appropriate installer class

#### `installer.py` (ABC) — package manager abstraction
```python
class BaseInstaller(ABC):
    @abstractmethod
    def install(self, packages: list[str]) -> bool: ...
    @abstractmethod
    def is_installed(self, package: str) -> bool: ...
    @abstractmethod
    def install_aur(self, package: str) -> bool: ...  # optional, not all OSes
```

#### `installer_pacman.py` — Manjaro/Arch
- `install()`: `sudo pacman -S --noconfirm --needed`
- `is_installed()`: `pacman -Qi`
- `install_aur()`: `yay -S --noconfirm` (for VS Code, CopyQ)

#### `installer_apt.py` — Ubuntu/Debian
- `install()`: `sudo apt install -y`
- `is_installed()`: `dpkg -s`
- `install_aur()`: delegate to snap/flatpak or skip (VS Code via `sudo apt install code`, CopyQ via `sudo apt install copyq`)

#### `modules/base.py` — module ABC
```python
class BaseModule(ABC):
    @property
    @abstractmethod
    def name(self) -> str: ...
    def should_run(self) -> bool: ...       # idempotency check
    def run(self, installer: BaseInstaller) -> bool: ...  # returns success
```

### Execution Flow

```
python -m setup --profile manjaro --dry-run
```

1. **OS detection**: Read `/etc/os-release` → `manjaro` / `ubuntu` / `other`
2. **Installer selection**: Map OS to installer class
3. **Module loading**: Load all modules, filter by `--skip`
4. **Execute**: Run each module, collect results (success/skip/fail)
5. **Summary**: Print report, exit code 0 (all good) or 1 (any failure)

### CLI Interface

```
python -m setup [OPTIONS]

Options:
  --profile      Profile to use: base, manjaro, ubuntu, personal (default: base)
  --os           Override auto-detect: auto, manjaro, ubuntu (default: auto)
  --dry-run      Show what would be done without executing
  --skip         Comma-separated list of modules to skip (e.g. "kitty,awesome")
  --verbose      Enable verbose output
  --list         List available modules and their status
  --apply        Actually apply (default action, opposite of --dry-run)
```

### Module Mapping from Shell Script

| Shell Script | Python Module | Notes |
|---|---|---|
| `programs/kitty/install.sh` | `kitty.py` | curl installer + config copy |
| `programs/pacman/configure_pacman.sh` | `pacman_config.py` | sed pacman.conf edits (Manjaro only) |
| `programs/oh-my-zsh/*.sh` | `zsh_ohmyzsh.py` | zsh + omz + plugins |
| `programs/git/aliases/*.sh` | `git.py` | git config + aliases |
| `programs/neovim/astronvim/*.sh` | `neovim.py` | Install nvim, clone astronvim config |
| `programs/awesome/` + git clones | `awesome.py` | Copy rc.lua + clone widgets |
| `programs/ssh-agent/apply_service.sh` | `ssh.py` | systemd user service |
| `programs/atuin/*.sh` | `atuin.py` | Install + config |
| `programs/picom/picom.conf` | `picom.py` | Copy config |
| `programs/zoxide/install.sh` | `zoxide.py` | Install + zshrc hook |
| `programs/Clipboard/install.sh` | `clipboard.py` | curl installer |
| `scripts/create_cronjob.sh` | `cronjob.py` | Crontab setup |
| stow operations | `dotfiles.py` | Reuse `stow/install_stow.py` |

### Package Name Mapping (Distro-Specific)

```python
PACKAGE_MAP = {
    "brave-browser": {"manjaro": "brave-bin", "ubuntu": "brave-browser"},
    "vscode": {"manjaro": "visual-studio-code-bin", "ubuntu": "code"},
    "copyq": {"manjaro": "copyq", "ubuntu": "copyq"},
    # ... all packages from the main script
}
```

### Idempotency Strategy
- Every module's `should_run()` checks existence conditions (same as the shell `if ! command -v` / `[ ! -d ]` checks)
- Already-installed = skip with log message, no error

### Error Handling
- Non-fatal failures log a warning but don't abort the whole run
- Collect all failures and report at the end

### Unit Tests
- `test_os_detector.py`: mock `/etc/os-release`, verify distro detection
- `test_installer.py`: mock `subprocess.run`, verify correct commands for pacman vs apt
- `test_modules/`: test each module's `should_run()` and `run()` with mocked subprocess
- `test_orchestrator.py`: test dry-run, skip, failure collection, exit codes
- Use `unittest.mock.patch` throughout, no real system changes

## TODO: Remove `.sh` Scripts (Future)

After the Python orchestrator is verified working, the following `.sh` scripts can be removed:

- `manjaro_essentials.sh` (fully replaced)
- All files under `programs/*/` that have Python equivalents:
  - `programs/kitty/install.sh`
  - `programs/pacman/configure_pacman.sh`
  - `programs/oh-my-zsh/zsh.sh`
  - `programs/oh-my-zsh/oh-my-zsh-unattended.sh`
  - `programs/oh-my-zsh/autosuggestion.sh`
  - `programs/oh-my-zsh/vim-like-mode/vim-like-mode.sh`
  - `programs/git/aliases/gitlola.sh`
  - `programs/git/aliases/final_branches.sh`
  - `programs/git/aliases/list_all_aliases.sh`
  - `programs/git/aliases/undo.sh`
  - `programs/git/aliases/local-branch-remove.sh`
  - `programs/git/aliases/local-branch-show.sh`
  - `programs/neovim/astronvim/setup_custom_configuration.sh`
  - `programs/neovim/install_0.9.5_version.sh` (deprecated)
  - `programs/neovim/astronvim/install_neovim_default_config_template.sh` (deprecated)
  - `programs/ssh-agent/apply_service.sh`
  - `programs/atuin/install.sh`
  - `programs/atuin/apply_config.sh`
  - `programs/zoxide/install.sh`
  - `programs/Clipboard/install.sh`
  - `programs/git-diff-image/install.sh`
  - `scripts/create_cronjob.sh`

**Note**: `programs/neovim/astronvim/install_neovim.sh` — verify if this file exists in the repo (it did not appear in glob results). If it exists, it should also be removed.

**Note**: `keyboard-us-altgr-variant.sh` is intentionally excluded — useful but not part of the orchestrator scope.
