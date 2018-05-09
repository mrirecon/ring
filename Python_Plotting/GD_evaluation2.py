#!/usr/bin/env python3

import sys
import os
sys.path.insert(0, '/home/srosenzweig/Programs/Python/')
import re

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from optparse import OptionParser
color = ["#348ea9","#ef4846","#52ba9b","#f48b37"]
color_light = ["#89c2d4","#ef8e8d","#a0ccc5","#f4b481"]
linestyle = ["-", "--", "-.", ":"]
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
parser = OptionParser(description="Gradient Delay Evaluation", usage="usage: %prog [-options] <src> <dst>")
parser.add_option("--yres", dest="yres",
                 help="Y resolution. (Default: %default)", default="1000")
(options, args) = parser.parse_args()
yres = int(options.yres)
DPI=yres

#q = str(options.q)
#QX,QY,qxy = [float(k) for k in q.split(":")]

#%% Function to calculate the L2 error
def calc(name):
    fname = name
    file = open(fname, 'r')
    lines=file.readlines()
    no_spokes=[]
    qx=[]
    qy=[]
    qxy=[]
    for x in lines:
        	no_spokes.append(x.split('\t')[0])
        	qx.append(x.split('\t')[1].split(':')[0])
        	qy.append(x.split('\t')[1].split(':')[1])
        	qxy.append(x.split('\t')[1].split(':')[2])
    file.close()
    no_spokes=list(map(float,no_spokes))

    qx=list(map(float,qx))
    qy=list(map(float,qy))
    qxy=list(map(float,qxy))

    dist=np.zeros(shape=(len(no_spokes)))

    for i in range(0,len(no_spokes)):
        	dist[i]=np.sqrt((qx[i]-qx[-1])**2 + (qy[i]-qy[-1])**2 + (qxy[i]-qxy[-1])**2)
    return no_spokes, dist
#%%
t= str(args[-2])
dst=str(args[-1])

label = ["RING"]
#%% Open figure
fig = plt.figure()
a = fig.add_subplot(111)
a.set_title(t)
a.set_xlabel				("Nₛₚ")
a.set_ylabel				("Gradient delay error " + r"$\mathcal{E}$")
a.grid ()
fig.tight_layout		    (pad=1.5)
a.set_ylim                  (-0.05,1)

ms=4
matplotlib.rcParams['font.size'] =  25 # Font size
for i in range(0,1):
    if (i != 0):
        ls = linestyle[1]
        mk = marker[1]
        co = color[0]
    else:
        ls = linestyle[0]
        mk = marker[0]
        co = color[1]

    no_spokes, dist = calc(args[i])
    a.plot(no_spokes, dist, linestyle=ls, color = co, label=label[i], linewidth=2)

a.legend				(fontsize=12)
fig.savefig				(dst, dpi=300)

