#!/bin/bash
sudo pacman-mirrors --country all --api --protocols all --set-branch stable && sudo pacman -Syyu
