# dotfiles

This is my personal dotfiles repository, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Installation

Run the install script to symlink all config files to your home directory:

```bash
./install.sh
```

## Usage

After installation, config files are symlinked from your home directory to this repository. You can edit any config file in `~/dotfiles/` or `~/.config/` and changes will apply immediately—no copy-paste needed.

### Packages

- **zsh** - `.zshrc`
- **bash** - `.bashrc`
- **vim** - `.vimrc`
- **git** - `.gitconfig`
- **xfce4** - XFCE keyboard shortcuts
- **kitty** - `~/.config/kitty/kitty.conf`
- **awesome** - `~/.config/awesome/rc.lua`

### Managing Packages

```bash
# Link a specific package
stow -t ~ -S <package> -d stow

# Unlink a specific package
stow -t ~ -D <package> -d stow

# Re-link all packages
stow -t ~ -R . -d stow
```

## Other Files

The `scripts/` and `programs/` directories contain installation scripts and are not symlinked.
