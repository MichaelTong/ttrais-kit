#!/bin/bash

function setBlockingMode() {
    mode=$1
    if [[ $mode == "chip" ]]; then
        a=3
    elif [[ $mode == "channel" ]]; then
        a=2
    elif [[ $mode == "whole" ]]; then
        a=1
    elif [[ $mode == "none" ]]; then
        a=0
    else
        echo "unknown blocking mode"
        exit -1
    fi
    echo "VSSIM switched to $mode-blocking"
    for f in $VSSIM_RUN_DIR_NVME/vssd*.conf
    do
        sed -i -- "s/^GC_MODE.*/GC_MODE      $a/g" $f
    done
    for f in $VSSIM_RUN_DIR_VIRTIO/vssd*.conf
    do
        sed -i -- "s/^GC_MODE.*/GC_MODE      $a/g" $f
    done
}

setBlockingMode $1
