#!/bin/bash

set -eu

FOLDER_PATH="$HOME/.config/systemd/user/"

if [[ ! -d "$FOLDER_PATH" ]]; then
  echo "Folder not found, creating it"
  mkdir -pv "$FOLDER_PATH"
else
  echo "Folder already exists"
fi

echo 'Copying service file'
cp -v ssh-agent.service "$FOLDER_PATH"

echo 'Creating and enabling service'
systemctl --user enable ssh-agent
systemctl --user start ssh-agent

echo 'Checking if SSH_AUTH_SOCK is exported in zshrc'
if ! grep -q "SSH_AUTH_SOCK" ~/.zshrc; then
  echo 'Adding SSH_AUTH_SOCK to zshrc'
  # shellcheck disable=SC2016
  echo 'export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"' >>~/.zshrc
else
  echo 'SSH_AUTH_SOCK already exported in zshrc'
fi
