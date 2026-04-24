# Dotfiles Stow Management

Organizes dotfiles into profiles for different machines using GNU Stow.

## Structure

```
stow/
├── profiles/
│   ├── base/          # Machine-agnostic packages (kitty, vim)
│   ├── manjaro/       # Manjaro-specific packages (awesome, zsh)
│   ├── ubuntu/        # Ubuntu-specific packages (awesome, zsh)
│   └── personal/      # Optional personal packages
└── install_stow.py    # Installation script
```

## Usage

```bash
# Using uv (recommended - handles dependencies)
uv run python3 install_stow.py manjaro    # Install base + manjaro
uv run python3 install_stow.py ubuntu     # Install base + ubuntu
uv run python3 install_stow.py basic      # Install base only
uv run python3 install_stow.py            # Interactive profile selection

# Adopt existing files into stow packages (use with caution)
uv run python3 install_stow.py --adopt manjaro

# Dry run - print commands without executing
uv run python3 install_stow.py --dry-run manjaro

# Verbose output - log what is being executed
uv run python3 install_stow.py -v manjaro
uv run python3 install_stow.py --verbose manjaro

# Combine flags
uv run python3 install_stow.py --dry-run -v manjaro
```

The `--adopt` flag moves existing conflicting files from your home directory into the stow package directories, then creates symlinks. Use this when you have existing dotfiles that you want to bring under stow management.

The `--dry-run` flag prints the stow commands that would be run without actually executing them.

The `-v`/`--verbose` flag enables verbose output, logging the exact commands being executed.

## Adding New Packages

1. Create package directory in appropriate profile: `profiles/<profile>/<package>/`
2. Mirror the home directory structure inside the package
3. Run the install script

Example: `profiles/base/git/.gitconfig` → `~/.gitconfig`

## Migration Notes

Migrated from tag-based naming (`zsh-manjaro`, `awesome-ubuntu`) to folder-based profiles.
Old hyphenated packages are replaced by organized profile directories.
