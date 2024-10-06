#!/bin/sh

set -eu
echo "Enter email"

read EMAIL
ssh-keygen -t ed25519 -C "$EMAIL"

