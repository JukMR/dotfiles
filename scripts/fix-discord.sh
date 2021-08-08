pactl load-module module-null-sink sink_name=my_sink
pactl load-module module-loopback sink=my_sink latency_msec=1
pactl load-module module-loopback sink=my_sink latency_msec=1

# To reset pavucontrol
#  systemctl --user restart pulseaudio
