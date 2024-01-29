#!/bin/bash


echo "The default mime type for opening folder is: "
echo $(xdg-mime query default inode/directory)

echo "Setting thunar as default"
# xdg-mime default thunar.desktop inode/directory
