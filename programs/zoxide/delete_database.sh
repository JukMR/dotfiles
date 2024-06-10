#!/bin/bash

# This command was used once my database file got corrupted. The following error was shown:
# zoxide: unsupported version (got 0, supports 3)
#
# Fix taken from https://github.com/ajeetdsouza/zoxide/issues/550
rm ~/.local/share/zoxide/db.zo
