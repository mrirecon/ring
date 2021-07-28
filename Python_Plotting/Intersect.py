import sys
sys.path.insert(0, '/home/srosenzweig/Programs/Python/')
from cfl import readcfl
from cfl import writecfl
import numpy as np
import matplotlib.pyplot as plt
# Font
color = ["#348ea9","#ef4846","#52ba9b","#f48b37", "#89c2d4","#ef8e8d","#a0ccc5","#f4b481"]
linestyle = ["-", "--", "-.", ":"]
marker = ["o", "^", "s", "8"]

from optparse import OptionParser
parser = OptionParser(description="Calculate error for intersection points.", usage="%prog [-options] <dst>")
parser.add_option("-S", dest="S",
                 help="S values: Sx:Sy:Sxy. (Default: %default)", default="0.3:-0.1:0.2")
parser.add_option("-C", dest="C",
                 help="Coil", default=0)
parser.add_option("-P", dest="P",
                 help="Number of Spokes", default=0)
parser.add_option("-N", dest="N",
                 help="noise", default=0)
(options, args) = parser.parse_args()
S = str(options.S)
Sx,Sy,Sxy = [float(k) for k in S.split(":")]
# fontpath
#%%
def n1(phi):
    return np.cos(phi)

def n2(phi): 
    return np.sin(phi)

def N1(phi0, phi1):
    return np.cos(phi0) - np.cos(phi1)

def N2(phi0, phi1):
    return np.sin(phi0) - np.sin(phi1)    

def offset(Sx, Sy, Sxy, phi0, phi1):
    return (1./ ((n2(phi0) * n1(phi1) / n2(phi1)) - n1(phi0))) * ( Sx * N1(phi0, phi1) + Sxy * N2(phi0, phi1) - n1(phi1)/n2(phi1) * (Sxy * N1(phi0, phi1) + Sy * N2(phi0, phi1))) 
    
#%%
suff="_C{!s}_SP{!s}_N{!s}".format(options.C, options.P, options.N)
p = np.loadtxt("projangle{}.txt".format(suff)) # from >bart estdelay tool
d = np.loadtxt("offset{}.txt".format(suff)) # from >bart estdelay tool
l = d.shape[0]
padfactor = 100

#%%
Sx  = Sx * padfactor
Sy  = Sy * padfactor 
Sxy = Sxy * padfactor 

# measured intersection point 
Sp0_meas = np.zeros(shape=(l,2))
Sp1_meas = np.zeros(shape=(l,2))

# actual intersection point
Sp0_act = np.zeros(shape=(l,2))

err0 = 0
err1 = 0


for i in range(0,l):
        phi0 = p[i,0]
        Sp0_meas[i,0] = (Sx * n1(phi0) + Sxy * n2(phi0) + d[i,0] * n1(phi0))/padfactor
        Sp0_meas[i,1] = (Sxy * n1(phi0) + Sy * n2(phi0) + d[i,0] * n2(phi0))/padfactor
        
        phi1 = p[i,1]
        Sp1_meas[i,0] = (Sx * n1(phi1) + Sxy * n2(phi1) + d[i,1] * n1(phi1))/padfactor
        Sp1_meas[i,1] = (Sxy * n1(phi1) + Sy * n2(phi1) + d[i,1] * n2(phi1))/padfactor
        
        Sp0_act[i,0] = (Sx * n1(phi0) + Sxy * n2(phi0) + offset(Sx, Sy, Sxy, phi0, phi1) * n1(phi0))/padfactor
        Sp0_act[i,1] = (Sxy * n1(phi0) + Sy * n2(phi0) + offset(Sx, Sy, Sxy, phi0, phi1) * n2(phi0))/padfactor
        

        err0 += (Sp0_act[i,0] - Sp0_meas[i,0])**2 +(Sp0_act[i,1] - Sp0_meas[i,1])**2
        err1 += (Sp0_act[i,0] - Sp1_meas[i,0])**2 +(Sp0_act[i,1] - Sp1_meas[i,1])**2

err = np.sqrt((err0 + err1)/(l*2)) # RMS error
print(err)

#%% Optional plotting
#plt.figure()
#plt.xlim(-0.4, 0.4)
#plt.ylim(-0.4, 0.4)
#plt.gca().set_aspect('equal', adjustable='box')
##plt.axis("equal")
#plt.scatter(Sp0_act[:,0],Sp0_act[:,1], marker="x", s=80, color="black")
#plt.scatter(Sp0_meas[:,0],Sp0_meas[:,1], marker="1", s=110, color=color[0])
#plt.scatter(Sp1_meas[:,0],Sp1_meas[:,1], marker="2", s=110, color=color[1])
#plt.grid()



