#!/usr/bin/python

import sys
import os
from shutil import copy
alter = sys.argv[1]
folders = sys.argv[2:]

cnt = len(folders)
width = 1.0/cnt

for f in folders:
  os.system("cd ~/share/ttrais/rtk/; ./all-kit.sh " + f);

epsdir = "/home/michaelht/share/ttrais-kit/tex-output/" + alter
if not os.path.exists(epsdir):
  os.makedirs(epsdir)

tex = "\\begin{figure}[t]\n"
for f in folders:
  copy("/home/michaelht/share/ttrais/rtk/eps/{}.eps".format(f), epsdir)
  epspath = "{{{}/{}.eps}}".format(alter, f)
  tex += "\\includegraphics[width={:.2f}\\textwidth]{}\n".format(width, epspath)
cap_label = "{{alter:{}}}".format(alter[2:])
cap_cap = "{{X: {}}}".format(alter[2:])
cap_text = "{{\\textbf{blocking}: ; \\textbf{warmup}: ; \\textbf{workload}: ; \\textbf{interface}: nvme; \\textbf{resize}: ; \\textbf{rerate}: ; \\textbf{numchann}: }}" 
tex += "\\mycaption{}{}{}\n".format(cap_label, cap_cap, cap_text)
tex += "\\end{figure}"

texfile = "tex-output/" + alter + ".tex"
texfp = open(texfile, "w")
texfp.write(tex)

