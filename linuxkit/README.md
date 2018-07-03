LinuxKit Mods
=============

If you want to know how to build LinuxKit VMs using these YAML files, see the instructions in the [parent](https://github.com/singe/linuxkit-for-mac/) directory.

If you want to know how to build your own wifi kernel, read on. You shouldn't need to do this though, just ```docker pull singelet/kernel:<latest tag>```.

### Instructions

More detail on this is available from [LinuxKit's Kernel Docs](https://github.com/linuxkit/linuxkit/blob/master/docs/kernels.md).

```
# Fetch and build LinuxKit
git clone https://github.com/linuxkit/linuxkit
cd linuxkit
make
export PATH=$PATH:$(pwd)/bin

# Build the kernel
cat config-4.14.x-x86_64 config-wifi > config-4.14.x-x86_64-wifi
make EXTRA=-wifi build_4.14.x-wifi
# These options stay fairly consistent across kernel versions, if not, read the LinuxKit kernel docs on ["Modifying the kernel config"](https://github.com/linuxkit/linuxkit/blob/master/docs/kernels.md#modifying-the-kernel-config)

# Note the resulting tagged output e.g.
# Successfully tagged linuxkit/kernel:4.14.52-wifi-ba03a8d668eb6be981e1ff71883b5e9e26274971-amd64

# Edit your LinuxKit YAML file to replace the kernel image. An e.g. diff
 kernel:
-  image: linuxkit/kernel:4.14.52
+  image: linuxkit/kernel:4.14.52-wifi-ba03a8d668eb6be981e1ff71883b5e9e26274971-amd64
   cmdline: "console=ttyS0 page_poison=1"

# Publish your kernel
docker image tag linuxkit/kernel:4.14.52-wifi-ba03a8d668eb6be981e1ff71883b5e9e26274971-amd64 <yourusername>/kernel:4.14.52-wifi-ba03a8d668eb6be981e1ff71883b5e9e26274971-amd64
docker push <yourusername>/kernel:4.14.52-wifi-ba03a8d668eb6be981e1ff71883b5e9e26274971-amd64
