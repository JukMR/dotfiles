Instruction to limit battery charge level:

Create file in:
/etc/systemd/system/battery-charge-threshold.service

with this content:

[Unit]
Description=Set the battery charge threshold
After=multi-user.target
StartLimitBurst=0

[Service]
Type=oneshot
Restart=on-failure
ExecStart=/bin/bash -c 'echo 60 > /sys/class/power_supply/BAT0/charge_control_end_threshold'

[Install]
WantedBy=multi-user.target



Then do 

sudo systemctl enable battery-charge-threshold.service
sudo systemctl start battery-charge-threshold.service

