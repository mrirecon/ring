#!/usr/bin/env bash
set -euo pipefail

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH

export BART_COMPAT_VERSION="v0.5.00"

source ../opts.sh

if [ ! -e $TOOLBOX_PATH/bart ] ; then
        echo "\$TOOLBOX_PATH is not set correctly!" >&2
        exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.5.00"

#--- Config ---
RO=160
SP=159

#--- Calculate energies of noise and of pure k-space---

# Delays
GD=0.3:-0.1:0.2
bart traj -x$RO -y$SP -r -D -G -c -q$GD -O tGD
bart scale 0.5 tGD tGDov

truncate -s0 k_energy.txt

for c in {1..8}; do
	echo "Coil" $c
	truncate -s0 noise_energy_C${c}.txt

	if [ $c -eq 1 ]; then
		bart phantom -t tGDov $POPTS -s2 _kGD
		bart slice 3 0 _kGD kGD
	else
		bart phantom -t tGDov $POPTS -s$c kGD
	fi

	if bart version -t v0.6.00 >/dev/null 2>&1 ; then
		FORMAT="%+.6f%+.6fi"
	else
		FORMAT="%+f%+fi"
	fi

	bart rss $(bart bitmask 1 2 3) kGD res
	k_energy=$(echo -e $c "\t" $(bart show -f "$FORMAT" res | sed -e "s/+//" | sed -e "s/+0.000000i//"))
	echo $k_energy >> k_energy.txt

	truncate -s0 noise_energy_C${c}.txt

	for ((noise=100; noise<=50100; noise+=2000)); do
		echo "Noise" $noise
		bart zeros 4 1 $RO $SP $c empty
		bart noise -n$noise empty noise
		bart rss $(bart bitmask 1 2 3) noise res

		echo $(echo -e $noise "\t" $(echo -e $k_energy "\t" $(bart show -f "$FORMAT"  res | sed -e "s/+//" | sed -e "s/+0.000000i//"))) >> noise_energy_C${c}.txt # output: Noise Stv | Coils | k_energy | noise_energy
	done

	../../ratio.sh noise_energy_C${c}.txt noise_ratio_C${c}.txt

done
