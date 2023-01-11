#!/bin/bash

# Do a xinput list-props first to see which devices are available
# Use the numbers that appear there to check which devices to talk with
xinput set-prop 11 293 --type=float -1
