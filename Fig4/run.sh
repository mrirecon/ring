#!/bin/bash
set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
        echo "\$TOOLBOX_PATH is not set correctly!" >&2
        exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.4.00"


NONCART_FLAG=""
if bart version -t v0.6.00 ; then
        NONCART_FLAG="-n"
fi

#--- Gridding ---
grid()
{
	TRJ=$1
	SRC=$2
	DST=$3
	bart nufft -d640:640:1 -a $TRJ $SRC __tmp0
	bart fft -u 3 __tmp0 $DST
}


#--- Config ---
RO=320
SP=1
SPF=15 # spokes per frame
RF=60 # relevant frames

# Create corresponding trajectory
bart traj -x$RO -y$(($SPF*$RF)) -c -r -G _t
bart reshape $(bart bitmask 2 10) $SPF $RF _t t




# Combine F frames: F * 15 spokes
F=5
Fstart=34
bart extract 10 $Fstart  $(($Fstart + $F)) k _kex
bart transpose 2 9 _kex _kex1
bart reshape $(bart bitmask 9 10) 1 $(($F * $SPF)) _kex1 _kex2
bart transpose 2 10 _kex2 kex

bart extract 10 $Fstart $(($Fstart + $F)) t _tex
bart reshape $(bart bitmask 2 10) $(($F * $SPF)) 1 _tex tex

# GD corrections
for (( i=3; i<=$(($F * $SPF)); i++ )); do
#--- Extract SP_GDest spokes ---
SP_GDest=$i
bart extract 2 0 $SP_GDest kex k_SP_GDest
bart extract 2 0 $SP_GDest tex t_SP_GDest

#--- GD RING tool ---
GDring=$(DEBUG_LEVEL=0 bart estdelay -R t_SP_GDest k_SP_GDest); echo -e $i "\t" $GDring >> RING.txt
bart traj -x$RO -y$(($SPF*$RF)) -c -r -G -q$GDring -O _tGDring0
bart reshape $(bart bitmask 2 10) $SPF $RF _tGDring0 _tGDring
bart extract 10 17 50 _tGDring tGDring
bart extract 10 0 $F tGDring _tGDringex
bart reshape $(bart bitmask 2 10) $(($F * $SPF)) 1 _tGDringex tGDringex

# Gridding
bart scale 2 tGDringex tGDringex_os
grid tGDringex_os kex gkex
bart ones 16 1 $RO $(($SPF*$F)) 1 1 1 1 1 1 1 1 1 1 1 1 1 _ones
grid tGDringex_os _ones _psf_tGDringex_os
bart scale 0.013333333333 _psf_tGDringex_os psf_tGDringex_os # scale with inverse of number of spokes
if [ $i -eq 3 ] || [ $i -eq 15 ] || [ $i -eq 75 ] ; then
bart nlinv $NONCART_FLAG -d5 -m2 -M0.005 -i25 -p psf_tGDringex_os gkex _rec_RING$i
bart resize -c 0 640 1 640 _rec_RING$i rec_RING$i
fi

#--- GD AC-Adaptive tool ---
bart extract 1 1 $RO k_SP_GDest kACadapt
bart extract 1 1 $RO t_SP_GDest tACadapt
GD_ACadapt=$(DEBUG_LEVEL=0 bart estdelay tACadapt kACadapt); echo -e $i "\t" $GD_ACadapt >> ACadapt.txt
bart traj -x$RO -y$(($SPF*$RF)) -c -r -G -q$GD_ACadapt -O _tGD_ACadapt0
bart reshape $(bart bitmask 2 10) $SPF $RF _tGD_ACadapt0 _tGD_ACadapt
bart extract 10 17 50 _tGD_ACadapt tGD_ACadapt
bart extract 10 0 $F tGD_ACadapt _tGD_ACadaptex
bart reshape $(bart bitmask 2 10) $(($F * $SPF)) 1 _tGD_ACadaptex tGD_ACadaptex

# Gridding
bart scale 2 tGD_ACadaptex tGD_ACadaptex_os
grid tGD_ACadaptex_os kex gkex
bart ones 16 1 $RO $(($SPF*$F)) 1 1 1 1 1 1 1 1 1 1 1 1 1 _ones
grid tGD_ACadaptex_os _ones _psf_tGDACadaptex_os
bart scale 0.013333333333 _psf_tGDACadaptex_os psf_tGDACadaptex_os # scale with inverse of number of spokes
if [ $i -eq 3 ] || [ $i -eq 15 ] || [ $i -eq 75 ] ; then
bart nlinv $NONCART_FLAG -d5 -m2 -M0.005 -i25 -p psf_tGDACadaptex_os gkex _rec_ACadapt$i
bart resize -c 0 640 1 640 _rec_ACadapt$i rec_ACadapt$i
fi
done


rm t*cfl t*hdr _*cfl _*hdr psf*cfl psf*hdr gkex*cfl gkex*hdr kA*cfl kA*hdr k_*cfl k_*hdr kex*cfl kex*hdr
