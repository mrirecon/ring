#!/usr/bin/env python3

import sys
import os
sys.path.insert(0, '/home/srosenzweig/Programs/Python/')
import re

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from optparse import OptionParser
color = ["#348ea9","#ef4846","#52ba9b","#f48b37","#89c2d4","#ef8e8d","#a0ccc5","#f4b481"]
color_light = ["#89c2d4","#ef8e8d","#a0ccc5","#f4b481"]
linestyle = ["-", "--", "-.", ":","-", "--", "-.", ":"]
marker = ["o", "^", "s", "8"]

# fontpath
import matplotlib.font_manager as font_manager
from matplotlib import rcParams
matplotlib.rcParams.update({'font.size': 22})
path = '/usr/share/fonts/opentype/linux-libertine/LinBiolinum_R.otf'
prop = font_manager.FontProperties(fname=path)
matplotlib.rcParams['font.family'] = prop.get_name()
#%%
# Option parser
parser = OptionParser(description="Intersection Plots", usage="usage: %prog [-options] <src_c0> ... <src_c7> <dst>")
parser.add_option("-t", dest="t",
                 help="Title. (Default: %default)", default="")
parser.add_option("-S", dest="S",
                 help="Actual Gradient Delays. (Default: %default)", default="0.3:-0.1:0.2")
(options, args) = parser.parse_args()
t = str(options.t)
#%%

#args = ["AvgErr_C1_SP159.txt", "AvgErr_C2_SP159.txt", "AvgErr_C3_SP159.txt", "AvgErr_C4_SP159.txt", "AvgErr_C5_SP159.txt", "AvgErr_C6_SP159.txt", "AvgErr_C7_SP159.txt", "AvgErr_C8_SP159.txt"]
src = [None] * 8 # Input text files
label = [None] * 8 # Labels

for i in range(8):
    src[i] = np.loadtxt(str(args[i]))
    label[i] = str(i+1) + " coils"
label[0] = str(1) + " coil"


#%% Open figure
fig = plt.figure(figsize=(9,7))
a = fig.add_subplot(111)
a.set_title(t)
a.set_xlabel				('SNRₖ')
a.set_ylabel				("RMS error [px]")
a.grid ()
fig.tight_layout		    (pad=1.5)
a.set_xlim                  (0,100)
a.set_ylim                  (0,0.5)

ms=4
matplotlib.rcParams['font.size'] =  20 # Font size
ls = linestyle[0]
co = color[0]
for i in range(0,8):
    co = color[i]
    ls = linestyle[0]
    a.plot(src[i][:,0], src[i][:,1], linestyle=ls, color = co, label=label[i], linewidth=2)
a.legend				(fontsize=15)
fig.savefig			(str(args[-1]), dpi=300)

