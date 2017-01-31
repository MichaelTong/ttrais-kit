#!/bin/bash

function edit_trace() {
    trace=$1
    resize=$2
    rerate=$3
    newtrace=$trace-resize-$resize-rerate-$rerate
    if [[ ! -e $TRACE_EDIT_DIR/in/$trace ]]; then
        echo "cannot find trace $trace"
        exit -1
    fi
    if [[ ! -e $TRACE_EDIT_DIR/out/$newtrace ]]; then
        echo "Creating trace $newtrace"
        cd $TRACE_EDIT_DIR
        python trace-editor.py -file $trace -resize $resize -rerate $rerate
        mv out/$trace-modified.trace out/$trace-resize-$resize-rerate-$rerate
        cd -
    else
        echo "Trace $newtrace exists"
    fi
}

edit_trace $1 $2 $3