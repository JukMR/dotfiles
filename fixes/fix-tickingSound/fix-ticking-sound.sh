#!/bin/bash

# If you hear a ticking sound every few seconds then try this command:

echo 0 | sudo tee /sys/module/snd_hda_intel/parameters/power_save

# Try the previous command to be sure you are suffering this problem. If this
# works for you, then you can solve it permanently by adding the following line
# above "exit 0" in "/etc/rc.local".

# echo 0 > /sys/module/snd_hda_intel/parameters/power_save

# Taken from:
# https://askubuntu.com/questions/175602/periodic-clicking-sound-from-pc-speaker
