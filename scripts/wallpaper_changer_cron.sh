#!/bin/bash
# script name: wallpaper_rotation
# Author: julianmr97 at gmail.com


export DISPLAY=":0"
# function randomize_wallpaper(){
#     display="${1}"
#     folder="${2}"
#     nitrogen --random --set-scaled --head=$display $folder
# }

# This option was setted because the X server reported bad drawing
#export QT_X11_NO_MITSHM=1


MONITORS=$( xrandr -q | grep ' connected' | wc -l )

for (( i=0; i <= $MONITORS -1 ; i++ )); do
  nitrogen --random --set-scaled --head=$i $HOME/Pictures/wallpapers/
done

exit
