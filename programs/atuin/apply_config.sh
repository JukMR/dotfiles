#!/bin/sh

# Check if atuin is installed
if ! [ -x "$(command -v atuin)" ]; then
    echo 'Error: atuin is not installed.' >&2
    exit 1
fi

# Check if line is already present and set ctrl_n_shortcuts to true
if grep -q "ctrl_n_shortcuts = true" ~/.config/atuin/config.toml; then
    echo "ctrl_n_shortcuts is already set to true"
else
    echo "Setting ctrl_n shortcuts to true"
    sed -i 's/ctrl_n_shortcuts = false/# ctrl_n_shortcuts = false\nctrl_n_shortcuts = true/' ~/.config/atuin/config.toml
fi

exit 0
