#!/bin/bash
#
set -eu
sudo mhwd -i pci video-nvidia
sudo mhwd -r pci video-linux
sudo reboot
