#!/bin/bash

# Copy the kitten file if it exists
if [ -d "kittens" ] && [ -f "kittens/kitten_save_session.py" ]; then
    mkdir -p "$HOME/.config/kitty/"
    KITTEN_DEST="$HOME/.config/kitty/kitten_save_session.py"
    if [ ! -f "$KITTEN_DEST" ] || ! cmp -s kittens/kitten_save_session.py "$KITTEN_DEST"; then
        cp kittens/kitten_save_session.py "$KITTEN_DEST"
        echo "kitten_save_session.py has been copied to $HOME/.config/kitty/"
    fi
fi
