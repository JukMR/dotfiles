If ethernet connection is failing after suspend try this command:

sudo modprobe -r alx
sudo modprobe -i alx

where alx is the name of the driver shown in the ethernet part of the command

sudo lshw -C network

after the tag 'driver='.

If this doesn't work try putting this script

'''
#!/bin/bash

PROGNAME=$(basename "$0")
state=$1
action=$2

function log {
    logger -i -t "$PROGNAME" "$*"
}

log "Running $action $state"

if [[ $state == post ]]; then
    modprobe -r r8169 \
    && log "Removed r8169" \
    && modprobe -i r8169 \
    && log "Inserted r8169"
fi
'''

in /lib/systemd/system-sleep/alx-refresh

and remember to make it executable by

chmod +x /lib/systemd/system-sleep/alx-refresh.

You can check it worked by the command

grep alx-refresh /var/log/syslog

