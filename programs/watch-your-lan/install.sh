#!/bin/bash

docker run --name wyl \
	-e "IFACES=$YOURIFACE" \
	-e "TZ=$YOURTIMEZONE" \
	--network="host" \
	-v $DOCKERDATAPATH/wyl:/data/WatchYourLAN \
    aceberg/watchyourlan
