#!/bin/bash
set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	        echo "\$TOOLBOX_PATH is not set correctly!" >&2
		        exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH

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
	bart nufft -d480:480:1 -a $TRJ $SRC __tmp0
	bart fft -u 3 __tmp0 $DST
}

#--- Config ---
RO=320
SP=1
FR=159

#--- Traj ---
bart traj -x$RO -y$(($SP * $FR)) -r -H -c t

#--- Extract SP_reco spokes ---
SP_reco=39
bart extract 2 0 $SP_reco k k_SP_reco
bart extract 2 0 $SP_reco t t_SP_reco

for (( i=3; i<=$FR; i++ )); do
#--- Extract SP_GDest spokes ---
SP_GDest=$i
bart extract 2 0 $SP_GDest k k_SP_GDest
bart extract 2 0 $SP_GDest t t_SP_GDest

#--- GD RING ---
GDring=$(bart estdelay -R t_SP_GDest k_SP_GDest); echo -e $i "\t" $GDring >> RING.txt
bart traj -x$RO -y$(($SP * $FR)) -r -H -c -O -q$GDring _tGDring
bart extract 2 0 $SP_reco _tGDring tGDring_SP_reco
# Gridding
bart scale 1.5 tGDring_SP_reco tGDring_SP_reco_os
grid tGDring_SP_reco_os k_SP_reco gk_SP_reco
bart ones 16 1 $RO $SP_reco 1 1 1 1 1 1 1 1 1 1 1 1 1 _ones
grid tGDring_SP_reco_os _ones _psf_tGDring_SP_reco
bart scale 0.025641025641 _psf_tGDring_SP_reco psf_tGDring_SP_reco # scale with inverse of number of spokes
if [ $i -eq 3 ] || [ $i -eq 15 ] || [ $i -eq 159 ] ; then
bart nlinv $NONCART_FLAG -d5 -p psf_tGDring_SP_reco gk_SP_reco rec_RING$i
fi


#--- GD AC-Adaptive ---
bart extract 1 1 $RO k_SP_GDest kACadapt
bart extract 1 1 $RO t_SP_GDest tACadapt
GDACadapt=$(bart estdelay tACadapt kACadapt); echo -e $i "\t" $GDACadapt >> ACadapt.txt
bart traj -x$RO -y$(($SP * $FR)) -r -H -c -O -q$GDACadapt _tGDACadapt
bart extract 2 0 $SP_reco _tGDACadapt tGDACadapt_SP_reco
# Gridding
bart scale 1.5 tGDACadapt_SP_reco tGDACadapt_SP_reco_os
grid tGDACadapt_SP_reco_os k_SP_reco gk_SP_reco
bart ones 16 1 $RO $SP_reco 1 1 1 1 1 1 1 1 1 1 1 1 1 _ones
grid tGDACadapt_SP_reco_os _ones _psf_tGDACadapt_SP_reco
bart scale 0.025641025641 _psf_tGDACadapt_SP_reco psf_tGDACadapt_SP_reco # scale with inverse of number of spokes
if [ $i -eq 3 ] || [ $i -eq 15 ] || [ $i -eq 159 ] ; then
bart nlinv $NONCART_FLAG -d5 -p psf_tGDACadapt_SP_reco gk_SP_reco rec_ACadapt$i
fi
done

rm t*cfl t*hdr _*cfl _*hdr psf*cfl psf*hdr gk*cfl gk*hdr kA*cfl kA*hdr k_*cfl k_*hdr
