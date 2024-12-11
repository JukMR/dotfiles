#!/bin/bash
git config --global alias.final-branches '!git for-each-ref --format="%(objectname)^{commit}" | git cat-file --batch-check="%(objectname)^!" | grep -v missing | git log --oneline --stdin'

