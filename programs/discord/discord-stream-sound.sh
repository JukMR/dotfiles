#!/bin/bash
pactl load-module module-null-sink sink_name=Virtual1

# add input source under this line
pactl load-module module-loopback source=alsa_input.pci-0000_0c_00.4.analog-stereo sink=Virtual1

# add output source under this line
pactl load-module module-loopback source=Virtual1.monitor sink=alsa_output.pci-0000_0c_00.4.analog-stereo


# To find which sources should you add run:
# to find input
# pactl list sources
#
# to find output
# pactl list sinks
#
# To stop streaming audio enter
# systemctl --user restart pulseaudio
