#!/bin/bash

ARCH='arm64'
qemu_bin='/usr/bin/qemu-aarch64-static'
machine='debian'
ENV="RUNLEVEL=1,LANG=C,DEBIAN_FRONTEND=noninteractive,DEBCONF_NOWARNINGS=yes"
LOOP=`losetup -f`
BOOT_P=${LOOP}p1
ROOT_P=${LOOP}p2
WORK_DIR=`dirname $0`
ROOTFS=${WORK_DIR}/kali_rootfs

nspawn-exec() {
  systemd-nspawn --bind-ro $qemu_bin -M $machine --capability=cap_setfcap -E $ENV -D $ROOTFS "$@"
}

mkimg() {
  set -e
  [[ -z $2 || $2 -lt 3 ]] && echo -e "Usage:\n\tmkimg {filename} {size_in_GB}\n\nNote: Size must be more than 3GB" && return
  IMG=$1
  SIZE=$2
  [ -e $IMG ] && echo -e '[*]$IMG already exists. So, skipping mkimg' && return
  echo "[*]Creating blank Image: ${IMG} of size ${SIZE}GB..."
  dd if=/dev/zero of=$IMG bs=1M count=$((1024*$SIZE)) status=progress
  echo '[*]Partitioning Image: 256MB BOOT and rest ROOTFS...'
  sleep 1
  cat << 'EOF' | sfdisk $IMG
  label: gpt
  device: test.img
  unit: sectors
  first-lba: 2048
  sector-size: 512
  1 : start=2048, size=524288
  2 : start=526336
EOF
  echo '[*]Formatting Partitions...'
  losetup $LOOP -P $IMG
  mkfs.ext4 -L BOOT ${BOOT_P}
  mkfs.ext4 -L ROOT ${ROOT_P}

  echo '[*]Mounting Partitions...'
  mkdir -pv $ROOTFS
  mount -v ${ROOT_P} $ROOTFS
  mkdir -pv $ROOTFS/boot
  mount -v ${BOOT_P} $ROOTFS/boot
}

cleanup() {
  set -x
  echo '[*]Unounting Partitions...'
  umount $ROOTFS/boot $ROOTFS
  rm -rf $ROOTFS
  losetup -d $LOOP
}
