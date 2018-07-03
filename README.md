Wifi for LinuxKit & Docker For Mac
==================================
by @singe from @sensepost

Testing wifi requires certain kernel capabilities. Docker-CE for MacOS does not have these. This necessitates building a wifi capable kernel. But the docker-for-mac LinuxKit example is missing some important functionality that needs to be extracted and re-added and is legally non-redistributable, hence this convoluted approach is required.

### Prerequisites

* [Docker for Mac](https://www.docker.com/docker-mac)
* [Linuxkit](https://github.com/linuxkit/linuxkit) installed with [brew](https://brew.sh/):
```
brew tap linuxkit/linuxkit
brew install --HEAD linuxkit
```

### Instructions

If you're just here to make it work, do this:
```
git clone https://github.com/singe/linuxkit-for-mac
cd linuxkit-for-mac
docker pull singelet/get-dockerce:1.0
cd docker-fakece
docker run -it --rm -v /:/host -v $(pwd):/macos singelet/get-dockerce:1.0 /host /macos
docker build -t docker-fakece:1.0 .
cd ../linuxkit
linuxkit build --disable-content-trust --format iso-efi docker-for-mac-wifi.yml
#Stop Docker
mv /Applications/Docker.app/Contents/Resources/linuxkit/docker-for-mac.iso /Applications/Docker.app/Contents/Resources/linuxkit/docker-for-mac.iso.orig
cp docker-for-mac-wifi-efi.iso /Applications/Docker.app/Contents/Resources/linuxkit/docker-for-mac.iso
#Start Docker
```
