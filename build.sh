#!/bin/sh

export PATH=/sbin:/usr/sbin:$PATH
DEBOS_CMD=debos
if [ -z ${ARGS+x} ]; then
    ARGS=""
fi

device="sm8450|tab8"
image="image"
partitiontable="gpt"
filesystem="ext4"
environment="phosh"
hostname=
arch=
do_compress=
family=
image_only=
installer=
zram=
memory=
password=
use_docker=
username=
no_blockmap=
ssh=
debian_suite="kali-rolling"
suite="trixie"
contrib="true"
sign=
miniramfs=
release=
verbose=
esp="false"

while getopts "dDvizobsZCrx:S:e:H:f:g:h:m:p:t:u:F:R:" opt
do
 case "$opt" in
    d ) use_docker=1 ;;
    D ) debug=1 ;;
    v ) verbose=1 ;;
    e ) environment="$OPTARG" ;;
    H ) hostname="$OPTARG" ;;
    i ) image_only=1 ;;
    z ) do_compress=1 ;;
    b ) no_blockmap=1 ;;
    s ) ssh=1 ;;
    o ) installer=1 ;;
    Z ) zram=1 ;;
    f ) ftp_proxy="$OPTARG" ;;
    h ) http_proxy="$OPTARG" ;;
    g ) sign="$OPTARG" ;;
    m ) memory="$OPTARG" ;;
    p ) password="$OPTARG" ;;
    t ) device="$OPTARG" ;;
    u ) username="$OPTARG" ;;
    F ) filesystem="$OPTARG" ;;
    x ) debian_suite="$OPTARG" ;;
    S ) suite="$OPTARG" ;;
    C ) contrib=1 ;;
    r ) miniramfs=1 ;;
    R ) release="$OPTARG" ;;
 esac
done

case "$device" in
 "pinephone" )
    arch="arm64"
    family="sunxi"
    ARGS="$ARGS -t nonfree:true"
    ;;
 "pinephonepro" )
    arch="arm64"
    family="rockchip"
    suite="staging"
    ARGS="$ARGS -t nonfree:true"
    # Encrypted / on PPP requires miniramfs
    if [ "${installer}" ]; then
        miniramfs=1
    fi
    ;;
 "pinetab" )
    arch="arm64"
    family="sunxi"
    ARGS="$ARGS -t nonfree:true"
    ;;
 "sm8450" )
    arch="arm64"
    family="samsung"
    ARGS="$ARGS -t nonfree:true"
    ;;
esac

case "$family" in
 "sunxi" )
    case "$partitiontable" in
      "mbr" )
        ARGS="$ARGS -p sunxi_mbr"
        ;;
      "gpt" )
        ARGS="$ARGS -p sunxi_gpt"
        ;;
    esac
    ;;
 "rockchip" )
    case "$partitiontable" in
      "mbr" )
        ARGS="$ARGS -p rockchip_mbr"
        ;;
      "gpt" )
        ARGS="$ARGS -p rockchip_gpt"
        ;;
    esac
    ;;
 "samsung" )
    case "$partitiontable" in
      "mbr" )
        ARGS="$ARGS -p samsung_mbr"
        ;;
      "gpt" )
        ARGS="$ARGS -p samsung_gpt"
        ;;
    esac
    ;;
esac

case "$filesystem" in
 "ext4" )
    ARGS="$ARGS -f ext4"
    ;;
 "btrfs" )
    ARGS="$ARGS -f btrfs
