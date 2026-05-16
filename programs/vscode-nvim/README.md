# vscode-nvim

Minimal config for vscode-neovim extension that bypasses AstroNvim.

## Setup

1. Run stow:
   ```bash
   stow vscode-nvim -t ~ -d ~/dotfiles/stow/profiles/base
   ```

2. Add to VSCode `settings.json`:
   ```json
   "vscode-neovim.neovimInitVimPaths.linux": "/home/julian/.config/nvim-vscode/init.lua"
   ```

3. Restart VSCode