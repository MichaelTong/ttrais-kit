#!/bin/bash

function setWarmUp() {
    setup=$1
    echo "Copying warmup setup $1"
    cat $VSSIM_RUN_DIR_NVME/warmup_setup/$1/readme
    rm $VSSIM_RUN_DIR_NVME/*.trace  $VSSIM_RUN_DIR_VIRTIO/*.trace

    cp $VSSIM_RUN_DIR_VIRTIO/warmup_setup/$1/*.trace $VSSIM_RUN_DIR_NVME/
    cp $VSSIM_RUN_DIR_VIRTIO/warmup_setup/$1/*.trace $VSSIM_RUN_DIR_VIRTIO/
}

setWarmUp $1
