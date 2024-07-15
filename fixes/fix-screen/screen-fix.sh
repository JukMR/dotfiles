#!/bin/bash

xrandr --output HDMI-1 --set underscan on
xrandr --output HDMI-1 --set "underscan hborder" 33 --set "underscan vborder" 21

# xrandr --output HDMI-0 --panning 1280x720 --transform 1.05,0,-30,0,1.05,-20,0,0,1
