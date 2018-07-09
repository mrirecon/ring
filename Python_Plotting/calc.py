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
parser = OptionParser(description="Gradient Delay Evaluation", usage="usage: %prog <E> <out: E_level")
(options, args) = parser.parse_args()
#%%
src = np.loadtxt(str(args[0]))
dst = src[:,2] / src[:,3]
np.savetxt(str(args[1]), dst, fmt='%5.8f')
