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
parser = OptionParser(description="Gradient Delay Evaluation", usage="usage: %prog [-options] <src> ... <dst>")
parser.add_option("-t", dest="t",
                 help="Title. (Default: %default)", default="")
parser.add_option("-S", dest="S",
                 help="Actual Gradient Delays. (Default: %default)", default="0.3:-0.1:0.2")
(options, args) = parser.parse_args()
t = str(options.t)
S = str(options.S)

# Actual gradient delays
Sx,Sy,Sxy = [float(k) for k in S.split(":")]

#%%
#args = ["GDest_C1_SP159.txt", "GDest_C2_SP159.txt", "GDest_C3_SP159.txt", "GDest_C4_SP159.txt", "GDest_C5_SP159.txt", "GDest_C6_SP159.txt", "GDest_C7_SP159.txt", "GDest_C8_SP159.txt"]
src = [None] * 8 # Input txtfiles
label = [None] * 8 # Labels

#%%
for i in range(8):
    src[i] = str(args[i])
    label[i] = str(i+1) + " coils"
label[0] = str(1) + " coil"



#%% Function to calculate the L2 error
def calc(name):
    fname = name
    file = open(fname, 'r')
    lines=file.readlines()
    noise =[]
    qx=[]
    qy=[]
    qxy=[]
    for x in lines:          
        noise.append(x.split(' ')[0])
        qx.append(x.split(' ')[1].split(':')[0])
        qy.append(x.split(' ')[1].split(':')[1])
        qxy.append(x.split(' ')[1].split(':')[2])
    file.close()
    noise=list(map(float,noise))

    qx=list(map(float,qx))
    qy=list(map(float,qy))
    qxy=list(map(float,qxy))

    dist=np.zeros(shape=(len(noise)))

    for i in range(0,len(noise)):
        	dist[i]=np.sqrt((qx[i]-Sx)**2 + (qy[i]-Sy)**2 + (qxy[i]-Sxy)**2)
    return noise, dist

#%% Open figure
fig = plt.figure(figsize=(9,7))
a = fig.add_subplot(111)
a.set_title(t)
a.set_xlabel				('SNRₖ')
a.set_ylabel				("Gradient delay error " + r"$\mathcal{E}$")
a.grid ()
fig.tight_layout		    (pad=1.5)
a.set_xlim                  (0,100)
a.set_ylim                  (0,0.32)


ms=4
matplotlib.rcParams['font.size'] =  20 # Font size
for i in range(8):        
    ls = linestyle[0]
    co = color[i]
    noise, dist = calc(src[i])         
    a.plot(noise, dist, linestyle=ls, color = co, label=label[i], linewidth=2)

a.legend				(fontsize=15)
fig.savefig			(str(args[-1]), dpi=300)

