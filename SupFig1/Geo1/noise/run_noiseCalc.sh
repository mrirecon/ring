#!/usr/bin/env bash
set -e

#--- Config ---
RO=160
SP=159

#--- Calculate energies of noise and of pure k-space---

# Delays
GD=0.3:-0.1:0.2
bart traj -x$RO -y$SP -r -D -G -c -q$GD -O tGD
bart scale 0.5 tGD tGDov

for c in {1..8}; do
echo "Coil" $c

if [ $c -eq 1 ]; then
bart phantom -t tGDov -G 1 -s2 _kGD
bart slice 3 0 _kGD kGD
else
bart phantom -t tGDov -G 1 -s$c kGD
fi

bart rss $(bart bitmask 1 2 3) kGD res
k_energy=$(echo -e $c "\t" $(bart show -f "%+f%+fi" res | sed -e "s/+//" | sed -e "s/+0.000000i//"))
echo $k_energy >> k_energy.txt

for ((noise=100; noise<=50100; noise+=2000)); do
echo "Noise" $noise
bart zeros 4 1 $RO $SP $c empty
bart noise -n$noise empty noise
bart rss $(bart bitmask 1 2 3) noise res
echo $(echo -e $noise "\t" $(echo -e $k_energy "\t" $(bart show -f "%+f%+fi"  res | sed -e "s/+//" | sed -e "s/+0.000000i//"))) >> noise_energy_C${c}.txt # output: Noise Stv | Coils | k_energy | noise_energy
done

python3 ../../../Python_Plotting/calc.py noise_energy_C${c}.txt noise_ratio_C${c}.txt
done
