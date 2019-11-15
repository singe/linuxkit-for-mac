#!/bin/sh
dir=$(dirname $0)
docker -H unix://$dir/docker-for-mac-wifi-efi-state/guest.00000948 $@
