#!/bin/bash

echo 'Creating ncdu config directory'
mkdir -p "$HOME/.config/ncdu"

echo 'Copying configuration file'
cp -v config "$HOME/.config/ncdu"

