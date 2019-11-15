Wifi for LinuxKit & Docker For Mac
==================================
by @singe from @sensepost

Testing wifi requires certain kernel capabilities. Docker-CE for MacOS does not have these. This necessitates building a wifi capable kernel. 

### Prerequisites

* [Docker for Mac](https://www.docker.com/docker-mac)
* [Linuxkit](https://github.com/linuxkit/linuxkit) 
  * Go
```
go get -u github.com/linuxkit/linuxkit/src/cmd/linuxkit
```
  * cloned from source
```
git clone https://github.com/linuxkit/linuxkit
cd linuxkit
make
export PATH=$PATH:$(pwd)/bin

```
  * installed with [homebrew](https://brew.sh/):
```
brew tap linuxkit/linuxkit
brew install --HEAD linuxkit
```

### Instructions

You need to build a LinuxKit-based ISO to run as your host Docker. This can be done with:

Fetch this repo
```
git clone https://github.com/singe/linuxkit-for-mac
cd linuxkit-for-mac
```

Build the ISO
```
cd ../linuxkit
linuxkit build --disable-content-trust --format iso-efi docker-for-mac-wifi.yml
```

Run your new Docker host:
```
./run-host.sh
```
This is a wrapper for the commands listed in [linuxkit](https://github.com/linuxkit/linuxkit/blob/master/examples/docker-for-mac.md)'s own docs.

Interact with your Docker host (using normal docker commands):
```
./run-client.sh info
```

### Details

* [Building LinuxKit Wifi Kernels](https://github.com/singe/linuxkit-for-mac/tree/master/linuxkit). This has a write up on how to build your own LinuxKit wifi kernel. Using the YAML files is detailed above.
