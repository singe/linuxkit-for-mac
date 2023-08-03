Wifi for LinuxKit & Docker For Mac
==================================
by @singe from @sensepost

Testing wifi requires certain kernel capabilities. Docker Desktop for MacOS does not have these. This necessitates installing a wifi capable kernel. 

This approach will modify the initrd.img and kernel used for the interstitial LinuxKit HyperKit VM to use a new wifi-capable kernel.

### Prerequisites

* [Docker for Mac](https://www.docker.com/docker-mac)

It needs to be running, and after the process has completed, restarted.

* A built linuxkit wifi kernel

These are usually done automatically and stored at [Docker Hub](https://hub.docker.com/repository/docker/singelet/linuxkit-kernel-wifi/general).

### Instructions

Merely clone this repository, and run `./build.sh`
