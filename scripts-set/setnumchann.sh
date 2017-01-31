#!/bin/bash

function setChannNum() {
    num=$1
    echo "VSSIM channel num: $num"
    for f in $VSSIM_RUN_DIR_NVME/vssd*.conf
    do
        sed -i -- "s/^CHANNEL_NB.*/CHANNEL_NB      $num/g" $f
    done
    for f in $VSSIM_RUN_DIR_VIRTIO/vssd*.conf
    do
        sed -i -- "s/^CHANNEL_NB.*/CHANNEL_NB      $num/g" $f
    done
}

setChannNum $1
