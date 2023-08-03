#!/bin/bash

appdir="/Applications/Docker.app/Contents/Resources/linuxkit/"
dockerrepo="singelet/linuxkit-kernel-wifi"
platform="arm64"

echo "[.] Working out docker host kernel version"
kernelseries=$(docker run -it --rm --platform linux/$platform alpine:latest uname -r | grep -o "^[0-9]*\.[0-9]*").x
echo $kernelseries | grep "^[0-9]*\.[0-9]*\.x" > /dev/null #should look something like 5.15.x
if [[ $? -eq 1 ]]; then
  echo "[!] Kernel series extracted from docker doesn't look correct: $kernelseries"
  exit 1
fi
echo "[.] Extracted kernel series is: $kernelseries"

dockerimage="$dockerrepo:$kernelseries-wifi"
echo "[.] Fetch latest linuxkit wifi kernel: $dockerimage"
docker pull --platform linux/$platform $dockerimage

numimages=$(docker images -f=reference="$dockerimage"|wc -l|awk '{print $1}')
if [[ ! $numimages > 1 ]]; then
  echo "[!] The docker $dockerimage image was not fetched successfull."
  exit 1
fi

tmp=$(mktemp -d /tmp/linuxkitiso.XXXXX)
echo "[.] Temporary directory is at: $tmp"

if [ ! -d $tmp ]; then
  echo "[!] Temporary directory $tmp not created"
  exit 1
fi

echo "[.] Extracting Kernel from Docker image"
docker image save $dockerimage > $tmp/docker.tar
if [ ! -f $tmp/docker.tar ]; then
  echo "[!] $tmp/docker.tar not found, image extraction failed"
  exit 1
fi
tar -C $tmp --strip-components 1 -xvf $tmp/docker.tar */layer.tar
tar -C $tmp -xvf $tmp/layer.tar kernel kernel.tar

if [ ! -f $tmp/kernel ]; then
  echo "[!] $tmp/kernel (from $tmp/docker.tar -> $tmp/layer.tar) not found, image extraction failed"
  exit 1
fi

echo "[.] Check if the kernel is compressed"
tar -C $tmp -xvf $tmp/kernel.tar
file $tmp/kernel | grep "gzip compressed data" > /dev/null
if [[ $? -eq 0 ]]; then
  echo "[.] Decompressing kernel"
  mv $tmp/kernel $tmp/kernel.gz
  gunzip $tmp/kernel.gz
fi

file $tmp/kernel | grep "Linux kernel" > /dev/null
if [[ $? -eq 1 ]]; then
  echo "[!] The kernel doesn't look like a Linux kernel boot executable"
  exit 1
fi

echo "[.] Extracting original initrd.img - this will require sudo creds to preserve ACLs and special files"
mkdir $tmp/initrd
cd $tmp/initrd
sudo cpio -id < $appdir/initrd.img
if [ ! -f $tmp/initrd/init ]; then
  echo "[!] $tmp/initrd/init not found, there was a problem with initrd extraction"
  exit 1
fi

echo "[.] Copying the new kernel into the extracted initrd image - required sudo"
sudo cp -R $tmp/boot $tmp/lib $tmp/initrd/
echo "[.] Creating the new initrd.img - requires sudo"
sudo find . | sudo cpio -oz -H newc -F ../initrd.img
file $tmp/initrd.img | grep "gzip compressed data" > /dev/null
if [[ $? -eq 1 ]]; then
  echo "[!] There was a problem creating the new $tmp/initrd.img"
  exit 1
fi
cd -

shainitrd=$(shasum $tmp/initrd.img|awk '{print $1}')
shakernel=$(shasum $tmp/kernel|awk '{print $1}')

echo "[.] Replacing existing Docker images (backed up at $appdir/kernel.bak and $appdir/initrd.bak)"
if [ -f $appdir/initrd.img.bak ]; then
  echo "[!] $appdir/initrd.img.bak already exists, cowardly refusing to overwrite it"
  exit 1
fi
mv $appdir/initrd.img $appdir/initrd.img.bak
mv $appdir/kernel $appdir/kernel.bak
mv $tmp/initrd.img $appdir/initrd.img
mv $tmp/kernel $appdir/kernel

shasum $appdir/initrd.img | grep $shainitrd > /dev/null
if [[ $? -eq 1 ]]; then
  echo "[!] $appdir/initrd.img was not replaced with the new image (SHA mismatch)"
  exit 1
fi

echo "[.] Deleting the $tmp directory - needs sudo to remove the root owned files"
rm -rf $tmp
sudo rm -rf $tmp

echo "[+] Done. Please restart Docker Desktop."
