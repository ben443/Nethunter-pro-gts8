#!/bin/bash

. funcs.sh

set -e
cd `dirname $0`

# Creating blank image, make partitions and mount for rootfs
mkimg phosh_pp.img 5

echo '[*]Stage 1: Debootstrap'
[ -e $ROOTFS/etc/passwd ] && echo -e "[*]Debootstrap already done.b\nSkipping Debootstrap..." || debootstrap --foreign --arch $ARCH kali-rolling $ROOTFS http://kali.download/kali

echo '[*]Stage 2: Debootstrap Second Stage'
rsync -rl third_stage $ROOTFS/
[ -e $ROOTFS/debootstrap/debootstrap ] && nspawn-exec /third_stage/second_stage || echo '[*]Second Stage already done'

cat << EOF > ${ROOTFS}/etc/fstab
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
UUID=`blkid -s UUID -o value $ROOT_P`	/	ext4	defaults	0	1
UUID=`blkid -s UUID -o value $BOOT_P`	/boot	ext4	defaults	0	2
EOF

echo '[*]Stage 3: Installing Extra Packages'
nspawn-exec /third_stage/third_stage

# Cleanup
rm -rf $ROOTFS/third_stage

