#!/bin/bash

set -eu

echo "*/10 * * * *  $HOME/dotfiles/scripts/wallpaper_changer_cron.sh" > wallpaper_set.cron

crontab wallpaper_set.cron

echo "Cronjob started correctly:"
crontab -l

echo "Create $HOME/Pictures/wallpapers folder. Put wallpapers there"
mkdir -p "$HOME/Pictures/wallpapers"
