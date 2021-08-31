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

nitrogen --random --set-scaled --head=0 /home/julian/Pictures/wallpapers/

# If the setup has two monitors enable next line
# nitrogen --random --set-scaled --head=1 /home/julian/Pictures/wallpapers/

exit
