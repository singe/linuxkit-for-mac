#!/bin/sh

echo "Starting docker-ce"

/sendtohost -setdockerstate="running"
/usr/bin/transfused
