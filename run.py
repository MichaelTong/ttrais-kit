#!/usr/bin/python
"""
This script
"""
import sys
import json
import os
os.environ["HOME"] = "/home/michaelht"
os.environ["VSSIM_RUN_DIR_NVME"] = "/home/michaelht/vssim/hc-qemu-nvme/mssd"
os.environ["VSSIM_RUN_DIR_VIRTIO"] = "/home/michaelht/vssim/hc-qemu-virtio/mssd"
os.environ["VSSD_NUM"] = "4"
os.environ["TRACE_EDIT_DIR"] = "/home/michaelht/share/trace-edit"
os.environ["REPLAYER_DIR"] = "/home/michaelht/replayer"
os.environ["RTK_DIR"] = "/home/michaelht/share/ttrais/rtk"

SCRIPT_SET_DIR = "scripts-set"
SCRIPT_HANDLE = ["0-blocking", "1-warmup", "7-numchann"]
def prepare_configs(conf_fp):
    """
    This function
    """
    config = json.load(conf_fp)
    config_keys = config.keys()
    config_keys.sort()

    def_config = {}
    for k in config_keys:
        if '#' in k:
            continue
        def_config[k] = config[k][0]

    run_configs = []
    for k in config_keys:
        conf = {}
        if "#" in k:
            continue
        else:
            alters = config[k]
            if len(alters) == 1:
                continue
            for alt in alters:
                conf = dict(def_config)
                conf["#alter"] = k
                conf[k] = alt
                run_configs.append(conf)
    return run_configs

def parse_options():
    """
    This function
    """
    config_file = sys.argv[1]
    conf_fp = open(config_file, "r")
    return conf_fp

def prepare_run(conf):
    """
    This function
    """
    keys = conf.keys()
    keys.sort()
    for k in keys:
        if k in SCRIPT_HANDLE:
            option = k.split('-')[1]
            script = SCRIPT_SET_DIR + "/set" + option + ".sh"
            os.system(script + " " + conf[k])
    trace = conf["2-workload"]
    resize = conf["4-resize"]
    rerate = conf["5-rerate"]
    #script = SCRIPT_SET_DIR + "/edittrace.sh {} {} {}".format(trace, resize, rerate)
   # os.system(script)
    conf["#trace"] = "{}-resize-{}-rerate-{}".format(trace, resize, rerate)

def run(cfg):
    """
    This function
    """
    alter = cfg["#alter"]
    val = cfg[alter]
    workload = cfg["2-workload"]
    trace = cfg["#trace"]
    interface = cfg["3-interface"]
    resize = cfg["4-resize"]
    rerate = cfg["5-rerate"]
    os.system("./run-vm.sh {} {} {} {} {} {} {}".format(alter, val, workload, trace,
                                                        interface, resize, rerate))

def proceed_config(conf):
    """
    This function
    """
    for cfg in conf:
        prepare_run(cfg)
        run(cfg)
        #break


def main():
    """
    This function
    """
    conf_fp = parse_options()
    run_configs = prepare_configs(conf_fp)
    proceed_config(run_configs)




if __name__ == "__main__":
    main()
