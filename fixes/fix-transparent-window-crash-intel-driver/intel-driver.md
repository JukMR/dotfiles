In order to fix this we need to change or create file in /etc/X11/xorg.conf.d/20-intel.conf
with the following:


Section "Device"
    Identifier "Intel Graphics"
    Driver "intel"
    Option "DRI" "2"
EndSection


Taken from https://wiki.archlinux.org/title/intel_graphics or 
https://wiki.archlinux.org/title/intel_graphics#DRI3_issues

And originally the problem was with kitty crashing:
https://github.com/kovidgoyal/kitty/issues/1681
