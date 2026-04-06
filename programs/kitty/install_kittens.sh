#!/bin/bash

mkdir -p "$HOME/.config/kitty/"

# Copy save kitten
if [ -d "kittens" ] && [ -f "kittens/kitten_save_session.py" ]; then
    KITTEN_DEST="$HOME/.config/kitty/kitten_save_session.py"
    if [ ! -f "$KITTEN_DEST" ] || ! cmp -s kittens/kitten_save_session.py "$KITTEN_DEST"; then
        cp kittens/kitten_save_session.py "$KITTEN_DEST"
        echo "kitten_save_session.py has been copied to $HOME/.config/kitty/"
    fi
fi

# Copy load kitten
if [ -d "kittens" ] && [ -f "kittens/kitten_load_session.py" ]; then
    KITTEN_DEST="$HOME/.config/kitty/kitten_load_session.py"
    if [ ! -f "$KITTEN_DEST" ] || ! cmp -s kittens/kitten_load_session.py "$KITTEN_DEST"; then
        cp kittens/kitten_load_session.py "$KITTEN_DEST"
        echo "kitten_load_session.py has been copied to $HOME/.config/kitty/"
    fi
fi
