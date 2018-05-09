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
#parser.add_option("-q", dest="q",
#                 help="Gradient Delay. (Default: %default)", default="0:0:0")
(options, args) = parser.parse_args()

#q = str(options.q)
#QX,QY,qxy = [float(k) for k in q.split(":")]

#%% Function to calculate the L2 error
def calc(name, Q):
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
        	dist[i]=np.sqrt((qx[i]-Q[0])**2 + (qy[i]-Q[1])**2 + (qxy[i]-Q[2])**2)
    return no_spokes, dist
#%%
t = str(args[0])

if (t == "FullCirc"):
    title = "Full circle acquisition"
    name = ["DA_Sx_RING.txt", \
            "DA_Sx_ACadapt.txt", \
	    "DA_Sx_Sy_RING.txt", \
            "DA_Sx_Sy_ACadapt.txt", \
	    "DA_Sx_Sy_Sxy_RING.txt", \
            "DA_Sx_Sy_Sxy_ACadapt.txt", \
            "plot.png"]
    legend = True
elif (t == "HalfCirc"):
    title = "Half circle acquisition"
    name = ["SA_Sx_RING.txt", \
            "SA_Sx_ACadapt.txt", \
	    "SA_Sx_Sy_RING.txt", \
            "SA_Sx_Sy_ACadapt.txt", \
	    "SA_Sx_Sy_Sxy_RING.txt", \
            "SA_Sx_Sy_Sxy_ACadapt.txt", \
            "plot.png"]
    legend = False
Q0 = [0.3,-0.1,0.2]
Q1 = [0.3,-0.1,0]
Q2 = [0.3,0.3,0]
dst=str(args[-1])

label = [r"${s}^{iso}$" + " RING", r"${s}^{iso}$" + " AC-Adaptive", r"${s}^{ax}$" + " RING", r"${s}^{ax}$" + " AC-Adaptive", r"${s}^{obl}$" + " RING", r"${s}^{obl}$" + " AC-Adaptive"]
#%% Open figure
fig = plt.figure()
a = fig.add_subplot(111)
a.set_title(title)
a.set_xlabel				("Nₛₚ")
a.set_ylabel				("Gradient delay error " r"$\mathcal{E}$")
a.grid ()
fig.tight_layout		    (pad=0.1)
a.set_ylim                      (-0.05,0.45)

ms=4
matplotlib.rcParams['font.size'] =  25 # Font size
for i in range(0,6):
    if (i==0 or i==1):
        Q=Q2
    elif (i==2 or i==3):
        Q=Q1
    elif (i==4 or i==5):
        Q=Q0
    
    if (i%2 ==1):
        ls = linestyle[1]
        mk = marker[1]
    else:
        ls = linestyle[0]
        mk = marker[0]
        
    if (i==0 or i==1):
        co = color[0]
    elif (i==2 or i==3):
        co = color[1]
    elif (i==4 or i==5):
        co = color[2]        
       
    no_spokes, dist = calc(name[i], Q)
    a.plot(no_spokes, dist, linestyle=ls, color = co, label=label[i], linewidth=2)

if(legend):
	a.legend				(fontsize=12)
fig.savefig				(dst, dpi=300)

