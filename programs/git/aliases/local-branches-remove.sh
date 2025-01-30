#!/bin/bash
git config --global alias.local-branches-remove "!git branch -v | grep '\\[gone\\]' | awk '{print \$1}' | xargs git branch -D"
