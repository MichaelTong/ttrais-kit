#!/bin/bash

ALTER=$1
VAL=$2
WORKLOAD=$3
TRACE=$4
INTERFACE=$5
RRESIZE=$6
WRESIZE=$7
RRERATE=$8
WRERATE=$9

if [[ $INTERFACE == "nvme" ]]; then
    VSSIM=$VSSIM_RUN_DIR_NVME/
else
    VSSIM=$VSSIM_RUN_DIR_VIRTIO/
fi


function startVM() {
    interface=$1
    cd $VSSIM
    ./my_run_$interface.sh > /dev/null 2>&1
}

function postVM() {
    trace=$1
    mode=$2
    sn=$3
    cd $VSSIM
    ./csvf.sh $trace $mode $sn
    mkdir -p ~/share/ttrais/vssimlogs/$trace-$mode-$sn/
    mv $trace-$mode-$sn-vssd*.csv ~/share/ttrais/vssimlogs/$trace-$mode-$sn/
}

function controlVM() {
    trace=$1
    policy_num=$2
    interface=$3
    outputdir=$4
    outputlog=$5
    workload=$6
    rresize=$7
    wresize=$8
    rrerate=$9
    wrerate=$10

    ssh -T -p 8888 huaicheng@localhost\
        trace=$trace \
        policy_num=$policy_num \
        interface=$interface \
        outputdir=$outputdir \
        outputlog=$outputlog \
        workload=$workload \
        rresize=$rresize \
        wresize=$wresize \
        rrerate=$rrerate \
        wrerate=$wrerate \
    '/bin/bash -s' << "ENDSSH"

function edit_trace() {
    workload=$1
    rresize=$2
    wresize=$3
    rrerate=$4
    wrerate=$5
    newtrace=$workload-rresize-$rresize-wresize-$wresize-rrerate-$rrerate-wrerate-$wrerate
    if [[ ! -e ~/trace-edit/in/$workload ]]; then
        echo "cannot find trace $workload"
        exit -1
    fi
    if [[ ! -e ~/trace-edit/out/$newtrace ]]; then
        echo "Creating trace $newtrace"
        cd ~/trace-edit/
        python trace-editor.py -file $workload -rresize $rresize -wresize $wresize -rrerate $rrerate -wrerate $wrerate
        mv out/$workload-modified.trace out/$newtrace
    else
        echo "Trace $newtrace exists"
    fi
}


echo ""
echo "......................................................................."
echo ""
echo "I'm inside the VM now"
~/mount-virtfs.sh
sleep 1

echo "Starting RAID"
echo ""
~/mkraid5-$interface.sh
sleep 1

echo "Changing readPolicy"
echo ""
~/bin/resetcnt
~/bin/changeReadPolicy $policy_num
sudo tail -n 1 /var/log/kern.log
echo ""
sleep 1

echo "Creating running trace"
echo ""
edit_trace $workload $rresize $wresize $rrerate $wrerate
cp ~/trace-edit/out/$trace ~/replayer/
sleep 1

echo "Running trace $trace"
echo ""
cd ~/replayer
sudo ./replayer /dev/md0 $trace
echo ""

~/bin/getcnt | tee /tmp/kern.cnt.log

mv replay_metrics.txt rst-mike/$outputlog.log
./filter_rd_log.sh rst-mike/$outputlog.log

mkdir -p ~/share/ttrais/kernellogs/$outputlog/
cp /tmp/kern.cnt.log ~/share/ttrais/kernellogs/$outputlog/

mkdir -p ~/share/ttrais/rtk/raw/$outputdir/
cp rst-mike/$outputlog-rd.log ~/share/ttrais/rtk/raw/$outputdir/
echo ""
echo "Shutting down VM"
echo "......................................................................."
echo ""
sudo shutdown -h now
ENDSSH

}

SN=`date +%Y%m%d_%H%M`

echo ""

echo "========================================================================"
echo "SN $SN"
for policy in def gct ebusy nogc
do
    if [[ $policy == "def" ]]; then
        policy_num=0
    elif [[ $policy == "gct" ]]; then
        policy_num=5
    elif [[ $policy == "ebusy" ]]; then
        policy_num=4
    elif [[ $policy == "nogc" ]]; then
        policy_num=0
        /home/michaelht/share/ttrais-kit/scripts-set/setblocking.sh none
    fi
    echo ""
    echo "************************************************************************"
    echo "ALTER $ALTER | VAL $VAL | WORKLOAD $WORKLOAD | INTERFACE $INTERFACE"
    echo "POLICY $policy"
    startVM $INTERFACE &
    echo ""
    echo "waiting for VM to start"
    while [ 1 ]
    do
        ssh -p 8888 -q huaicheng@localhost exit
        if [[ $? -ne 0 ]]; then
          sleep 5
        else
          break
        fi
    done
    outputdir=$SN-$ALTER-$VAL
    outputlog=$WORKLOAD-$policy-$SN
    controlVM $TRACE $policy_num $INTERFACE $outputdir $outputlog $WORKLOAD $RRESIZE $WRESIZE $RRERATE $WRERATE
    echo ""
    echo "waiting for VM to stop"
    echo ""
    sleep 15
    echo "post process stats"
    postVM $WORKLOAD $policy $SN
    echo "************************************************************************"
done

echo "========================================================================"
echo ""

