#!/usr/bin/env bash

# Use this command to see in which commands does a command got stuck

PID="$1"

if [[ -z "$PID" ]]; then
    echo "Usage: $0 <PID>"
    exit 1
fi

strace -p "$PID" -e trace=read,write,open
