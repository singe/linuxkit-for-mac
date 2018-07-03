#!/bin/sh
hostpath=$1
macpath=$2

help() {
  echo "Extract files from Docker-CE on MacOS"
  echo "This container assumed you've passed two bind volumes through"
  echo "e.g. docker run -it --rm -v /:/host -v $(pwd):/macos singelet/get-dockerce:lastest /host /macos"
}

if [ -x "$hostpath" ] && [ -x "$macpath" ]; then
  if [ -x "$hostpath/usr/bin/transfused" ]; then
    cp $hostpath/usr/bin/transfused $hostpath/sendtohost $macpath/
  else
    echo "Transfused doesn't exist at the host path."
    exit 1 
  fi
else
  echo "Either the LinuxKit host path or the MacOS path doesn't exist."
  exit 1
fi
