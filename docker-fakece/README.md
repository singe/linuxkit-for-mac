Fake Docker-CE
==============

Overview
--------

If you want to build your own LinuxKit image for Docker for Mac, it's missing some important pieces that make it work. This adds them back.

Usage
-----

First you need to extract the files from your existing Docker CE LinuxKit image. These aren't redistributable, hence the hassle.

```
docker pull singelet/get-dockerce:1.0
docker run -it --rm -v /:/host -v $(pwd):/macos singelet/get-dockerce:1.0 /host /macos
```

You should see some extra files in the directory. Next, build the fakece image:
```
docker build -t docker-fakece:1.0 .
```

This should show up when you run ```docker images```. If it's there, you can add it to your LinuxKit build.
