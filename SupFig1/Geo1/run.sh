#!/bin/bash
set -euo pipefail

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH

export BART_COMPAT_VERSION="v0.4.00"


source opts.sh

# Noise and kspace energies
(
	cd noise
	bash run_noiseCalc.sh
	rm *cfl *hdr
)


#--- Config ---
RO=160
SP=159

#--- Sim ---

# No delays
bart traj -x$RO -y$SP -r -D -G -c t
bart scale 0.5 t tov
bart phantom -t tov $POPTS -s1 k

# Delays
GD=0.3:-0.1:0.2
bart traj -x$RO -y$SP -r -D -G -c -q$GD -O tGD
bart scale 0.5 tGD tGDov


for c in {1..8}; do
	echo "Coil" $c

	truncate -s0 GDest_C${c}_SP${SP}.txt

	if [ $c -eq 1 ]; then
		bart phantom -t tGDov $POPTS -s2 _kGD
		bart slice 3 0 _kGD kGD
	else
		bart phantom -t tGDov $POPTS -s$c kGD
	fi

	count=1
	for ((noise=100; noise<=50100; noise+=2000)); do
		echo "Count" $count "Noise" $noise
		bart noise -n$noise kGD kGDn$noise

		noise_ratio=$(sed -n ${count}p noise/noise_ratio_C${c}.txt)

		ESTOUT=$(DEBUG_LEVEL=0 RING_PAPER=1 bart estdelay -R t kGDn${noise})

		set +eu
		DELAY=$(echo "$ESTOUT" | grep -v -e "offset:" -e "projangle:")
		PROJ=$(echo "$ESTOUT" | grep "projangle:" | cut -d ":" -f 2 )
		OFFS=$(echo "$ESTOUT" | grep "offset:" | cut -d ":" -f 2)

		if [ -z "$PROJ" ] || [ -t "$OFFS" ] ; then
			printf "%s\n" \
				"Cannot find projection angle and offset in estdelay output." \
				"You are probably running an older version of BART!" \
				"Aborting...." >&2
			exit 1
		fi

		set -eu

		printf "%s\t%s\n" "${noise_ratio}" "${DELAY}" >> GDest_C${c}_SP${SP}.txt

		echo "$PROJ" > projangle_C${c}_SP${SP}_N${noise}.txt
		echo "$OFFS" > offset_C${c}_SP${SP}_N${noise}.txt
		# now called in run_fig.sh:
		#echo $(echo -e $noise_ratio"\t";  python3 ../../Python_Plotting/Intersect.py -S ${GD}) >> AvgErr_C${c}_SP${SP}.txt
		count=$(($count + 1))
	done
done

######################
# NUFFT reco

if bart version -t v0.6.00 >/dev/null 2>&1 ; then
	FORMAT="%+.6f%+.6fi"
else
	FORMAT="%+f%+fi"
fi


bart phantom -t tov $POPTS -s 1 k
bart rss $(bart bitmask 1 2 3) k res
k_energy=$(echo -e $c "\t" $(bart show -f "$FORMAT" res | sed -e "s/+//" | sed -e "s/+0.000000i//"))
echo $k_energy >> xk_energy.txt

noise=0.000005
bart zeros 4 1 $RO $SP 1 empty
bart noise -n$noise empty noise
bart rss $(bart bitmask 1 2 3) noise res
echo $(echo -e $noise "\t" $(echo -e $k_energy "\t" $(bart show -f "$FORMAT"  res | sed -e "s/+//" | sed -e "s/+0.000000i//"))) >> xnoise_energy.txt # output: Noise Stv | Coils | k_energy | noise_energy

bart nufft -i  t k rec_noise0
bart noise -n$noise k kn
bart nufft -i t kn rec_noise$noise

bart resize -c 0 100 1 100 rec_noise0 r_noise0
bart resize -c 0 100 1 100 rec_noise$noise r_noise$noise
