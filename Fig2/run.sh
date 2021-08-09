#!/bin/bash
set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.4.00"

#--- Double Angle Sx != Sy != Sxy ---
RO=128
GD=0.3:-0.1:0.2
#
touch DA_Sx_Sy_Sxy_RING.txt
touch DA_Sx_Sy_Sxy_ACadaptive.txt
for (( SP=3; $SP<$RO; SP++ )); do
bart traj -x$RO -y$SP -r -G -c tnom # nominal
bart traj -x$RO -y$SP -r -G -q$GD -c -O tGD # parallel + orthogonal shift
bart scale 0.5 tGD tGDov # increase FOV
bart phantom -k -s8 -t tGDov kGD
# RING method
echo -e $SP "\t" $(bart estdelay -R tnom kGD) >> DA_Sx_Sy_Sxy_RING.txt

# AC-Adaptive method
bart extract 1 1 $RO kGD kGD1
bart extract 1 1 $RO tnom tnom1
echo -e $SP "\t" $(bart estdelay tnom1 kGD1) >> DA_Sx_Sy_Sxy_ACadaptive.txt
done

#--- Single Angle Sx != Sy != Sxy ---
RO=128
GD=0.3:-0.1:0.2

touch SA_Sx_Sy_Sxy_RING.txt
touch SA_Sx_Sy_Sxy_ACadaptive.txt
for (( SP=3; $SP<$RO; SP++ )); do
bart traj -x$RO -y$SP -r -H -c tnom # nominal
bart traj -x$RO -y$SP -r -H -q$GD -c -O tGD # parallel + orthogonal shift
bart scale 0.5 tGD tGDov
bart phantom -k -s8 -t tGDov kGD
# RING method
echo -e $SP "\t" $(bart estdelay -R tnom kGD) >> SA_Sx_Sy_Sxy_RING.txt

# AC-Adaptive method
bart extract 1 1 $RO kGD kGD1
bart extract 1 1 $RO tnom tnom1
echo -e $SP "\t" $(bart estdelay tnom1 kGD1) >> SA_Sx_Sy_Sxy_ACadaptive.txt
done



#--- Double Angle Sx != Sy, Sxy=0 ---
RO=128
GD=0.3:-0.1:0

touch DA_Sx_Sy_RING.txt
touch DA_Sx_Sy_ACadaptive.txt
for (( SP=3; $SP<$RO; SP++ )); do
bart traj -x$RO -y$SP -r -G -c tnom # nominal
bart traj -x$RO -y$SP -r -G -q$GD -c -O tGD # parallel + orthogonal shift
bart scale 0.5 tGD tGDov
bart phantom -k -s8 -t tGDov kGD
# RING method
echo -e $SP "\t" $(bart estdelay -R tnom kGD) >> DA_Sx_Sy_RING.txt

# AC-Adaptive method
bart extract 1 1 $RO kGD kGD1
bart extract 1 1 $RO tnom tnom1
echo -e $SP "\t" $(bart estdelay tnom1 kGD1) >> DA_Sx_Sy_ACadaptive.txt
done

#--- Single Angle Sx != Sy, Sxy=0 ---
RO=128
GD=0.3:-0.1:0

touch SA_Sx_Sy_RING.txt
touch SA_Sx_Sy_ACadaptive.txt
for (( SP=3; $SP<$RO; SP++ )); do
bart traj -x$RO -y$SP -r -H -c tnom # nominal
bart traj -x$RO -y$SP -r -H -q$GD -c -O tGD # parallel + orthogonal shift
bart scale 0.5 tGD tGDov
bart phantom -k -s8 -t tGDov kGD
# RING method
echo -e $SP "\t" $(bart estdelay -R tnom kGD) >> SA_Sx_Sy_RING.txt

# AC-Adaptive method
bart extract 1 1 $RO kGD kGD1
bart extract 1 1 $RO tnom tnom1
echo -e $SP "\t" $(bart estdelay tnom1 kGD1) >> SA_Sx_Sy_ACadaptive.txt
done

#--- Double Angle Sx == Sy, Sxy=0 ---
RO=128
GD=0.3:0.3:0

touch DA_Sx_RING.txt
touch DA_Sx_ACadaptive.txt
for (( SP=3; $SP<$RO; SP++ )); do
bart traj -x$RO -y$SP -r -G -c tnom # nominal
bart traj -x$RO -y$SP -r -G -q$GD -c -O tGD # parallel + orthogonal shift
bart scale 0.5 tGD tGDov
bart phantom -k -s8 -t tGDov kGD
# RING method
echo -e $SP "\t" $(bart estdelay -R tnom kGD) >> DA_Sx_RING.txt

# AC-Adaptive method
bart extract 1 1 $RO kGD kGD1
bart extract 1 1 $RO tnom tnom1
echo -e $SP "\t" $(bart estdelay tnom1 kGD1) >> DA_Sx_ACadaptive.txt
done

#--- Single Angle Sx != Sy, Sxy=0 ---
RO=128
GD=0.3:0.3:0

touch SA_Sx_RING.txt
touch SA_Sx_ACadaptive.txt
for (( SP=3; $SP<$RO; SP++ )); do
bart traj -x$RO -y$SP -r -H -c tnom # nominal
bart traj -x$RO -y$SP -r -H -q$GD -c -O tGD # parallel + orthogonal shift
bart scale 0.5 tGD tGDov
bart phantom -k -s8 -t tGDov kGD
# RING method
echo -e $SP "\t" $(bart estdelay -R tnom kGD) >> SA_Sx_RING.txt

# AC-Adaptive method
bart extract 1 1 $RO kGD kGD1
bart extract 1 1 $RO tnom tnom1
echo -e $SP "\t" $(bart estdelay tnom1 kGD1) >> SA_Sx_ACadaptive.txt
done

rm k*cfl  k*hdr t*cfl t*hdr
