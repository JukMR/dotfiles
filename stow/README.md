# Dotfiles Stow Management

Organizes dotfiles into profiles for different machines using GNU Stow.

## Structure

```
stow/
├── profiles/
│   ├── base/          # Machine-agnostic packages (kitty, vim, lazygit)
│   ├── manjaro/       # Manjaro-specific packages (awesome, zsh)
│   ├── ubuntu/        # Ubuntu-specific packages (awesome, zsh)
│   └── personal/      # Optional personal packages (git-personal)
├── install_stow.py    # PEP 723 script - dependencies managed by uv
└── README.md
```

## Usage

All commands below are run from the `stow/` directory.

```bash
# Using uv with PEP 723 script (recommended - handles on-demand deps)
uv run --script install_stow.py manjaro       # Install base + manjaro
uv run --script install_stow.py ubuntu        # Install base + ubuntu
uv run --script install_stow.py               # Interactive profile selection

# Alternative shorthand (-s for --script)
uv run -s install_stow.py manjaro
uv run -s install_stow.py ubuntu
uv run -s install_stow.py

# Adopt existing files into stow packages (use with caution)
uv run -s install_stow.py --adopt manjaro

# Dry run - validate layout and show managed targets
uv run -s install_stow.py --dry-run manjaro

# Verbose output - log what is being executed
uv run -s install_stow.py -v manjaro
uv run -s install_stow.py --verbose manjaro

# Combine flags
uv run -s install_stow.py --dry-run -v manjaro
```

Dependencies are auto-managed via the PEP 723 `# /// script` header. When running with `uv run --script`, uv automatically installs the declared dependencies (`inquirer`) on-demand into a cached environment.

The `--adopt` flag now passes GNU Stow's native `--adopt` behavior through directly. Existing target files are imported into the package before the symlink is created, so use it only when you want the target content to become the new source of truth.

The `--dry-run` flag validates package layout and prints the target paths each package would manage without making filesystem changes.

The `-v`/`--verbose` flag enables verbose output, logging the exact commands being executed.

## Adding New Packages

1. Create package directory in appropriate profile: `profiles/<profile>/<package>/`
2. Mirror the home directory structure inside the package
3. Run the install script

Example: `profiles/base/lazygit/.config/lazygit/config.yml` → `~/.config/lazygit/config.yml`

## Migration Notes

Migrated from tag-based naming (`zsh-manjaro`, `awesome-ubuntu`) to folder-based profiles.
Old hyphenated packages are replaced by organized profile directories.
The nested `stow/stow/` directory has been flattened into `profiles/`.
All package dependencies are managed on-demand via uv's PEP 723 script mechanism.
The `lazygit` source of truth is `profiles/base/lazygit/.config/lazygit/config.yml`; if an older install left a stray `~/.config/config.yml`, remove or migrate it before reinstalling.
