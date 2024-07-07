#!/bin/bash

echo "Doing backup of user.lua file"
cp -v /home/mrjulian/.config/nvim/lua/plugins/user.lua /home/mrjulian/.config/nvim/lua/plugins/user.lua.bkp

echo "Copying new user.lua file"
cp -v user.lua /home/mrjulian/.config/nvim/lua/plugins/user.lua


