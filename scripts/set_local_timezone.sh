#!/bin/bash

# This option is useful when dual-booting on linux and windows.
# This makes linux use local time

timedatectl set-local-rtc 1 --adjust-system-clock
