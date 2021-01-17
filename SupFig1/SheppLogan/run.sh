#!/bin/bash
set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	        echo "\$TOOLBOX_PATH is not set correctly!" >&2
		        exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH

export BART_COMPAT_VERSION="v0.5.00"



# Noise and kspace energies
cd noise
bash run_noiseCalc.sh
mv *ratio*.txt ../
rm *cfl *hdr
rm *txt
cd -


#--- Config ---
RO=160
SP=159

#--- Sim ---

# No delays
bart traj -x$RO -y$SP -r -D -G -c t
bart scale 0.5 t tov
bart phantom -t tov -s1 k

# Delays
GD=0.3:-0.1:0.2
bart traj -x$RO -y$SP -r -D -G -c -q$GD -O tGD
bart scale 0.5 tGD tGDov


for c in {1..8}; do
echo "Coil" $c

touch AvgErr_C${c}_SP${SP}.txt
touch GDest_C${c}_SP${SP}.txt

if [ $c -eq 1 ]; then
bart phantom -t tGDov -s2 _kGD
bart slice 3 0 _kGD kGD
else
bart phantom -t tGDov -s$c kGD
fi

count=1
for ((noise=100; noise<=50100; noise+=2000)); do
echo "Count" $count "Noise" $noise
bart noise -n$noise kGD kGDn$noise

noise_ratio=$(sed -n ${count}p noise_ratio_C${c}.txt)

echo $(echo -e $noise_ratio"\t"; bart estdelay -R t kGDn${noise}) >> GDest_C${c}_SP${SP}.txt
echo $(echo -e $noise_ratio"\t";  python3 ../../Python_Plotting/Intersect.py -S ${GD}) >> AvgErr_C${c}_SP${SP}.txt
count=$(($count + 1))
done
done

######################
# NUFFT reco


bart phantom -t tov -s 1 k
bart rss $(bart bitmask 1 2 3) k res
k_energy=$(echo -e $c "\t" $(bart show -f "%+f%+fi" res | sed -e "s/+//" | sed -e "s/+0.000000i//"))
echo $k_energy >> xk_energy.txt

noise=0.000005
bart zeros 4 1 $RO $SP 1 empty
bart noise -n$noise empty noise
bart rss $(bart bitmask 1 2 3) noise res
echo $(echo -e $noise "\t" $(echo -e $k_energy "\t" $(bart show -f "%+f%+fi"  res | sed -e "s/+//" | sed -e "s/+0.000000i//"))) >> xnoise_energy.txt # output: Noise Stv | Coils | k_energy | noise_energy

bart nufft -i  t k rec_noise0
bart noise -n$noise k kn
bart nufft -i t kn rec_noise$noise

bart resize -c 0 100 1 100 rec_noise0 r_noise0
bart resize -c 0 100 1 100 rec_noise$noise r_noise$noise
cfl2png -z9 -CV r_noise0 r_noise0
cfl2png -z9 -CV r_noise$noise r_noiseP


rm _*{cfl,hdr} empty*{cfl,hdr} k*{cfl,hdr} noise*{cfl,hdr} rec*{cfl,hdr} t*{cfl,hdr}


