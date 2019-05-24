#!/bin/sh
docker -H unix://$(pwd)/docker-for-mac-wifi-efi-state/guest.00000948 $@
