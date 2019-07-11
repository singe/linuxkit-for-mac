Wifi for LinuxKit & Docker For Mac
==================================
by @singe from @sensepost

Testing wifi requires certain kernel capabilities. Docker-CE for MacOS does not have these. This necessitates building a wifi capable kernel. But the docker-for-mac LinuxKit example is missing some important functionality that needs to be extracted and re-added and is legally non-redistributable, hence this convoluted approach is required.

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

### Old Instructions

These instructions are deprecated. They relied on attempting to reverse engineer parts of Docker-CE that Docker want to keep private (not all the batteries are swappable).

If you're just here to make it work, do this:
```
#Fetch this repo
git clone https://github.com/singe/linuxkit-for-mac
cd linuxkit-for-mac

#Build your FakeCE image
docker pull singelet/get-dockerce:1.0
cd docker-fakece
docker run -it --rm -v /:/host -v $(pwd):/macos singelet/get-dockerce:1.0 /host /macos
docker build -t docker-fakece:1.0 .

# Build the LinuxKit ISO
cd ../linuxkit
linuxkit build --disable-content-trust --format iso-efi docker-for-mac-wifi.yml

# Replace the Docker for Mac ISO. Remember to first stop Docker.
mv /Applications/Docker.app/Contents/Resources/linuxkit/docker-for-mac.iso /Applications/Docker.app/Contents/Resources/linuxkit/docker-for-mac.iso.orig
cp docker-for-mac-wifi-efi.iso /Applications/Docker.app/Contents/Resources/linuxkit/docker-for-mac.iso
# Now restart docker

# If you'd like to watch it boot
screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty
```

### Details

* [Docker-FakeCE](https://github.com/singe/linuxkit-for-mac/tree/master/docker-fakece). Create a local image with binaries exracted from the non-redistributal Docker CE tools.
* [Get Docker-CE](https://github.com/singe/linuxkit-for-mac/tree/master/get-dockerce). Fetch the Docker CE tools from your current Docker CE LinuxKit VM.
* [Building LinuxKit Wifi Kernels](https://github.com/singe/linuxkit-for-mac/tree/master/linuxkit). This has a write up on how to build your own LinuxKit wifi kernel. Using the YAML files is detailed above.
