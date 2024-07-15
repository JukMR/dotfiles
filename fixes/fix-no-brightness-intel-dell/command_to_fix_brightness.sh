#!/bin/bash

# Pass a number to set brightness
# 7500 is the max
echo "$1 "| sudo tee /sys/class/backlight/intel_backlight/brightness

