#!/bin/bash
#

set -eu
sudo mhwd -i pci video-linux
sudo mhwd -r pci video-nvidia
sudo reboot
