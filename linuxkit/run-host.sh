#!/bin/sh
linuxkit run hyperkit -networking=vpnkit -vsock-ports=2376 -disk size=4096M -data-file ./metadata.json -iso -uefi docker-for-mac-wifi-efi
