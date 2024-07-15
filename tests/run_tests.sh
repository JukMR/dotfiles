#/bin/bash

echo 'Running shellcheck'
shellcheck -S style ../manjaro_essentials.sh

echo 'Running docker test'
docker build -t test-environment .
docker run -it test-environment
