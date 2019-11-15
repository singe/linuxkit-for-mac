Wifi for LinuxKit & Docker For Mac
==================================
by @singe from @sensepost

Testing wifi requires certain kernel capabilities. Docker Desktop for MacOS does not have these. This necessitates installing a wifi capable kernel. 

This approach will modify the .iso used for the interstitial LinuxKit HyperKit VM to use a new wifi-capable kernel.

### Prerequisites

* [Docker for Mac](https://www.docker.com/docker-mac)

### Instructions

Merely clone this repository, and run `./build.sh`
