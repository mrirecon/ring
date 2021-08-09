#!/bin/bash
set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
        echo "\$TOOLBOX_PATH is not set correctly!" >&2
        exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.4.00"



#--- Config ---
RO=320
SP=1
FR=159


# Output sizes to match reference reconstruction
declare -A OSIZE
# Fill with default:
for SP_reco in 39 159; do
	for i in 3 15 159; do
		for T in AC RING; do
			OSIZE[${T}_${i}_${SP_reco}]="320:320:1"
		done
	done
done
OSIZE[AC_3_159]="320:322:1"
OSIZE[AC_3_39]="320:322:1"

#--- Traj ---
bart traj -x$RO -y$(($SP * $FR)) -r -G -c t

#--- Extract SP_reco spokes ---

for SP_reco in 39 159; do
	bart extract 2 0 $SP_reco k k_SP_reco
	bart extract 2 0 $SP_reco t t_SP_reco
	for i in 3 15 159; do
		#--- Extract SP_GDest spokes ---
		SP_GDest=$i
		bart extract 2 0 $SP_GDest k k_SP_GDest
		bart extract 2 0 $SP_GDest t t_SP_GDest

		#--- GD RING ---
		GDring=$(DEBUG_LEVEL=0 bart estdelay -R t_SP_GDest k_SP_GDest); echo -e $i "\t" $GDring >> RING.txt
		bart traj -x$RO -y$(($SP * $FR)) -r -G -c -O -q$GDring _tGDring
		bart extract 2 0 $SP_reco _tGDring tGDring_SP_reco
		bart nufft -i -d${OSIZE[RING_${i}_${SP_reco}]} tGDring_SP_reco k_SP_reco _tmp
		bart rss 8 _tmp rec_RING_GDsp${i}_RECsp${SP_reco}

		#--- GD AC-Adaptive ---
		bart extract 1 1 $RO k_SP_GDest kACadapt
		bart extract 1 1 $RO t_SP_GDest tACadapt
		GDACadapt=$(DEBUG_LEVEL=0 bart estdelay tACadapt kACadapt); echo -e $i "\t" $GDACadapt >> ACadapt.txt
		bart traj -x$RO -y$(($SP * $FR)) -r -G -c -O -q$GDACadapt _tGDACadapt
		bart extract 2 0 $SP_reco _tGDACadapt tGDACadapt_SP_reco
		bart nufft -i -d${OSIZE[AC_${i}_${SP_reco}]} tGDACadapt_SP_reco k_SP_reco _tmp
		bart rss 8 _tmp rec_ACadapt_GDsp${i}_RECsp${SP_reco}
	done
done


rm t*cfl t*hdr _*cfl _*hdr kA*cfl kA*hdr k_*cfl k_*hdr
