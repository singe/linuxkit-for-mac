#!/bin/bash

isofile="/Applications/Docker.app/Contents/Resources/linuxkit/docker-desktop.iso"
mountloc="/Volumes/ISOIMA"

echo "[.] Extracting current ISO located at $isofile"

if [ ! -f $isofile ]; then
  echo "[!] $isofile not found, do you have Docker Desktop installed to /Applications"
  exit 1
fi

echo "[.] Attaching iso"
mountloc=$(hdiutil attach $isofile|cut -f3)

if [ $? -eq 1 ]; then
  echo "[!] $isofile was not mounted"
  exit 1
fi

if [ ! -d $mountloc ]; then
  echo "[!] $mountloc not found, iso mount not found"
  exit 1
fi

echo "[.] Making temporary dir"
tmp=$(mktemp -d /tmp/linuxkitiso.XXXXX)

if [ ! -d $tmp ]; then
  echo "[!] Temporary directory $tmp not created"
  exit 1
fi

echo "[.] Creating tarball of iso"
tar -C $mountloc -cvf $tmp/iso.tar .

if [ ! -s $tmp/iso.tar ]; then
  echo "[!] Tarball $tmp/iso.tar either empty or not there."
  exit 1
fi

echo "[.] Unmounting iso"
diskutil eject $mountloc

kernelseries="4.19.x"
dockerimage="singelet/linuxkit-kernel-wifi:$kernelseries-wifi"
echo "[.] Fetch latest linuxkit wifi kernel $dockerimage"
docker pull $dockerimage

numimages=$(docker images -f=reference="$dockerimage"|wc -l|awk '{print $1}')
if [[ ! $numimages > 1 ]]; then
  echo "[!] The docker $dockerimage image was not fetched successfull."
  exit 1
fi


echo "[.] Extracting Kernel from Docker image"
docker image save $dockerimage > $tmp/docker.tar
tar -C $tmp --strip-components 1 -xvf $tmp/docker.tar */layer.tar
tar -C $tmp -xvf $tmp/layer.tar kernel kernel.tar

if [ ! -f $tmp/kernel ]; then
  echo "[!] $tmp/kernel (from $tmp/docker.tar -> $tmp/layer.tar) not found, image extraction failed"
  exit 1
fi

cmdline="BOOT_IMAGE=/boot/kernel console=ttyS0 console=ttyS1 page_poison=1 vsyscall=emulate panic=1 root=/dev/sr0 text"

echo "[.] Creating new kernel layout"
mkdir $tmp/boot && mv $tmp/kernel $tmp/boot/
tar -C $tmp -xvf $tmp/kernel.tar
echo $cmdline > $tmp/boot/cmdline

echo "[.] Adding new kernel to iso tarball"
tar -C $tmp -uvf $tmp/iso.tar ./boot ./lib

tar -C $tmp -tf $tmp/iso.tar | grep "/lib/modules/.*-linuxkit-wifi" > /dev/null
if [[ $? -eq 1 ]]; then
  echo "[!] Kernel modules not found in resulting $tmp/iso.tar, something went wrong."
  exit 1
fi

mkisoimage="linuxkit/mkimage-iso-efi:667bd641fd37062eaf9d2173c768ebfcedad3876"
echo "[.] Fetching linuxkit mkiso $mkisoimage"
docker pull $mkisoimage

numimages=$(docker images -f=reference="$mkisoimage"|wc -l|awk '{print $1}')
if [[ ! $numimages > 1 ]]; then
  echo "[!] The docker $mkisoimage image was not fetched successfull."
  exit 1
fi

echo "[.] Creating iso"
#docker run -it --rm -v $tmp:/iso --entrypoint sh $mkisoimage -c "/make-efi < iso/iso.tar 2> /dev/null" > $tmp/docker-desktop.iso
docker run --rm -v $tmp:/iso --entrypoint sh $mkisoimage -c "sed -i.bak 's/cat linuxkit-efi.iso//' /make-efi && /make-efi < iso/iso.tar > /dev/null && mv /tmp/efi/linuxkit-efi.iso /iso/docker-desktop.iso"

result=$(file $tmp/docker-desktop.iso|cut -d: -f2) 
expected="ISO 9660 CD-ROM filesystem data 'ISOIMAGE' (bootable)"
echo "$result" | grep "$expected" > /dev/null
if [[ $? -eq 1 ]]; then
  echo "[!] Created iso does not look correct. Got \"$result\" instead of \"$expected\""
  exit 1
fi

sha=$(shasum $tmp/docker-desktop.iso|awk '{print $1}')

echo "[.] Replacing existing Docker iso (backed up at $isofile.bak)"
mv $isofile $isofile.bak
mv $tmp/docker-desktop.iso $isofile

shasum $isofile | grep $sha > /dev/null
if [[ $? -eq 1 ]]; then
  echo "[!] $isofile was not replaced with the new ISO (SHA mismatch)"
  exit 1
fi

echo "[+] Done. Restart Docker Desktop."
