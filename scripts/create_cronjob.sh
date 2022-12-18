#!/bin/bash


OUT="$(mktemp /tmp/output.XXXXXXXXXX)" || { echo "Failed to create temp file"; exit 1; }

crontab -l > $OUT

echo "*/10 * * * *  $HOME/dotfiles/scripts/wallpaper_changer_cron.sh" >> $OUT

crontab $OUT