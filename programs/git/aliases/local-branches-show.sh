#!/bin/bash
git config --global alias.local-branches-show "!git branch -v | grep '\\[gone\\]' | awk '{print \$1}'"
