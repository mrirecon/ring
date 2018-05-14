#!/usr/bin/env python3

import sys
import os
sys.path.insert(0, '/home/srosenzweig/Programs/Python/')
import re

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

# Font
color = ["#348ea9","#ef4846","#52ba9b","#f48b37", "#89c2d4","#ef8e8d","#a0ccc5","#f4b481"]
linestyle = ["-", "--", "-.", ":"]
marker = ["o", "^", "s", "8"]

# fontpath
import matplotlib.font_manager as font_manager
from matplotlib import rcParams
mpl.rcParams.update({'font.size': 22})
path = '/usr/share/fonts/opentype/linux-libertine/LinBiolinum_R.otf'
prop = font_manager.FontProperties(fname=path)
mpl.rcParams['font.family'] = prop.get_name()
from optparse import OptionParser
#%%

# Option Parsing
parser = OptionParser(description="Plotting.", usage="%prog [-options] <dst>")
parser.add_option("-S", dest="S",
                 help="S values: Sx:Sy:Sxy. (Default: %default)", default="0:0:0")
parser.add_option("-n", dest="no",
                 help="Number of spokes (Default: %default)", default="5")
parser.add_option("--SA", dest="SA", action="store_true",
			help="Single Angle", default=False)
(options, args) = parser.parse_args()
S = str(options.S)
Sx,Sy,Sxy = [float(k) for k in S.split(":")]
no_sp = int(options.no)
single_angle = int(options.SA)

#%%
def projdir(phi):
    n = np.array((np.cos(phi), np.sin(phi)))
    return n

#%% Quadratic form
S=np.array(((Sx, Sxy),(Sxy,Sy)))

doubleAngle = 1 - single_angle

#%% Samples for quadratic form plot
theta = np.linspace(0,2*np.pi,100, endpoint=False)
n_tot = np.array((np.cos(theta), np.sin(theta)))
elipse = S@n_tot

#%% Stuff for trajectory plot
samples = 100
alpha = np.linspace(-1.5,1.5,samples,endpoint=False)          

#%%
fig = plt.figure()
a = fig.add_subplot(111)
    
angles = np.zeros(shape=(no_sp))
for i in range(0,no_sp):
    angles[i] = (1 + doubleAngle) * np.pi / no_sp * i

title = "$\mathregular{S_x}$=" + str(Sx) + ", $\mathregular{S_y}$=" + str(Sy) + ", $\mathregular{S_{xy}}$=" + str(Sxy)
for i in range(0,no_sp):
    a.set_title(title)
    col = i % 8
    # Elipse
    a.plot(elipse[0],elipse[1], color="grey", linestyle=linestyle[3])

    phi = angles[i]
    n = projdir(phi)
    tr0 =np.add( (S@n)[:,np.newaxis], n[:,np.newaxis] @ alpha[np.newaxis,:])
        
    # Center highlight
    center = S@projdir(phi)
    a.scatter(center[0],center[1], marker=marker[0], color=color[col])
    
    # Arrow
    a.arrow(tr0[0,-1], tr0[1,-1], tr0[0,-1]*1e-3, tr0[1,-1]*1e-3, head_width=0.05, head_length=0.08, fc=color[col], ec=color[col])
    
    # Line
    a.plot(tr0[0],tr0[1], color=color[col])
    
a.grid()
a.set_aspect('equal')
a.axis([-2.5, 2.5, -2.5, 2.5])
fig.savefig(str(args[-1]))
