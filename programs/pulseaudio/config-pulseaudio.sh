#!/bin/bash
case $1 in
    speakers1)
        echo "Turn on speaker"
        pacmd set-sink-port alsa_output.pci-0000_00_14.2.analog-stereo analog-output-headphones

        ;;
    hdmi0)
        echo "Desactivando HDMI"
        pacmd set-card-profile alsa_card.pci-0000_01_00.1 off
        ;;
    hdmi1)
        echo "Activando HDMI"
        pacmd set-card-profile alsa_card.pci-0000_01_00.1 output:hdmi-stereo
        ;;
    speakers0)
        echo "Turn off speakers"
        pacmd set-sink-port alsa_output.pci-0000_00_14.2.analog-stereo analog-output-lineout
        ;;
    *)
        echo "Argumento incorrecto"
        ;;
esac 
