#!/bin/bash

# script name: volume
# Author: glaudistong at gmail.com
# depends on: yad, coreutils, pulseaudio

# This script controls pulseaudio commands

# Taken from https://askubuntu.com/a/1163416 on question
# https://askubuntu.com/questions/26068/how-do-you-mute-from-the-command-line

ps -ef | grep "yad" | grep -E "Volume [^+\-]" | tr -s " " | cut -d " " -f2 | xargs -i kill "{}" 2>/dev/null
DEFAULT_SINK=$(pactl info | grep "Default Sink" | cut -d " " -f3)
DEFAULT_SOURCE=$(pactl info | grep "Default Source" | cut -d " " -f3)
case "$1" in
init)
    {
        ps -fe | grep yad | grep -q volume ||
            {
                yad --notification --command "volume up" --text "+ Volume +" --image ~/Pictures/volume-up-dark.png &
                yad --notification --command "volume down" --text "- Volume -" --image ~/Pictures/volume-down-dark.png &
            }
    }
    ;;
up)
    {
        pactl set-sink-volume "$DEFAULT_SINK" +5%
        P=$(pactl list | grep -E "Name: $DEFAULT_SINK$|Volume" | grep "Name:" -A1 | tail -1 | cut -d% -f1 | cut -d/ -f2 | tr -d " ")
        iconl="$(echo -ne "\U1F50A")"
        iconr="$(echo -ne "\U1F56A")"
        timeout .6 yad --progress --percentage "$P" --timeout 1 --no-buttons --undecorated --text="$iconl Volume $P% $iconr" --no-focus --center --skip-taskbar --on-top &
    }
    ;;
down)
    {
        pactl set-sink-volume "$DEFAULT_SINK" -5%
        P=$(pactl list | grep -E "Name: $DEFAULT_SINK$|Volume" | grep "Name:" -A1 | tail -1 | cut -d% -f1 | cut -d/ -f2 | tr -d " ")
        iconl="$(echo -ne "\U1F509")"
        iconr="$(echo -ne "\U1F569")"
        timeout .6 yad --progress --percentage "$P" --timeout 1 --no-buttons --undecorated --text="$iconl Volume $P% $iconr" --no-focus --center --skip-taskbar --on-top &
    }
    ;;
mute)
    {
        ismute=$(pactl list | grep -E "Name: $DEFAULT_SINK$|Mute" | grep "Name:" -A1 | tail -1 | cut -d: -f2 | tr -d " ")
        if [ "$ismute" == no ]; then
            s=1
            P=0
            icon="$(echo -ne "\U1F507")"
        else
            P=$(pactl list | grep -E "Name: $DEFAULT_SINK$|Volume" | grep "Name:" -A1 | tail -1 | cut -d% -f1 | cut -d/ -f2 | tr -d " ")
            icon="🔊"
            s=0
        fi
        pactl set-sink-mute "$DEFAULT_SINK" "$s"
        echo $s >/sys/devices/platform/thinkpad_acpi/leds/platform::mute/brightness
        timeout .6 yad --progress --percentage "$P" --timeout 1 --no-buttons --undecorated --text="$icon Volume $P%" --no-focus --center --skip-taskbar --on-top &
    }
    ;;
mic-up)
    {
        pactl set-source-volume "$DEFAULT_SOURCE" +5%
        P=$(pactl list | grep -E "Name: $DEFAULT_SOURCE$|Volume" | grep "Name:" -A1 | tail -1 | cut -d% -f1 | cut -d/ -f2 | tr -d " ")
        icon="$(echo -en "\U1F3A4")"
        timeout .6 yad --progress --percentage "$P" --timeout 1 --no-buttons --undecorated --text="$icon Volume Mic $P%" --no-focus --center --skip-taskbar --on-top &
    }
    ;;
mic-down)
    {
        pactl set-source-volume "$DEFAULT_SOURCE" -5%
        icon="$(echo -en "\U1F3A4")"
        P=$(pactl list | grep -E "Name: $DEFAULT_SOURCE$|Volume" | grep "Name:" -A1 | tail -1 | cut -d% -f1 | cut -d/ -f2 | tr -d " ")
        timeout .6 yad --progress --percentage "$P" --timeout 1 --no-buttons --undecorated --text="$icon Volume Mic $P%" --no-focus --center --skip-taskbar --on-top &
    }
    ;;
mic-mute)
    {
        ismute=$(pactl list | grep -E "Name: $DEFAULT_SOURCE$|Mute" | grep "Name:" -A1 | tail -1 | cut -d: -f2 | tr -d " ")
        if [ "$ismute" == no ]; then
            s=1
            P=0
            icon="$(echo -en "\U1F507\U1F3A4")"
        else
            P=$(pactl list | grep -E "Name: $DEFAULT_SOURCE$|Volume" | grep "Name:" -A1 | tail -1 | cut -d% -f1 | cut -d/ -f2 | tr -d " ")
            s=0
            icon="$(echo -en "\U1F3A4")"
        fi
        pactl set-source-mute "$DEFAULT_SOURCE" "$s"
        echo $s >/sys/devices/platform/thinkpad_acpi/leds/platform::micmute/brightness
        timeout .6 yad --progress --percentage "$P" --timeout 1 --no-buttons --undecorated --text="$icon Volume Mic $P%" --no-focus --center --skip-taskbar --on-top &
    }
    ;;
*)
    echo invalid option
    ;;
esac
