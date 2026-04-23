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
```

The `--adopt` flag moves existing conflicting files from your home directory into the stow package directories, then creates symlinks. Use this when you have existing dotfiles that you want to bring under stow management.

## Adding New Packages

1. Create package directory in appropriate profile: `profiles/<profile>/<package>/`
2. Mirror the home directory structure inside the package
3. Run the install script

Example: `profiles/base/git/.gitconfig` → `~/.gitconfig`

## Migration Notes

Migrated from tag-based naming (`zsh-manjaro`, `awesome-ubuntu`) to folder-based profiles.
Old hyphenated packages are replaced by organized profile directories.
