#!/bin/bash

. funcs.sh

set -e
cd `dirname $0`
arch='arm64'
rootfs='rootfs'
qemu_bin='/usr/bin/qemu-aarch64-static'
machine='debian'

echo '[*]Stage 1: Debootstrap'
[ -d $rootfs ] && echo -e "[*]$(basename rootfs) already exist\nSkipping Debootstrap..." || debootstrap --foreign --arch $arch kali-rolling $rootfs http://kali.download/kali

echo '[*]Stage 2: Debootstrap Second Stage'
sec="$rootfs/second_stage"
cat << 'EOF' > $sec
/debootstrap/debootstrap --second-stage
EOF
chmod +x $sec
nspawn-exec /`basename $sec`

echo '[*]Stage 3: Installing Extra Packages'
rsync -r third_stage $rootfs/
nspawn-exec /third_stage/install

# Cleanup
rm -rf $sec $rootfs/third_stage

