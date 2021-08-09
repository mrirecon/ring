#!/bin/bash
set -euo pipefail

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH

export BART_COMPAT_VERSION="v0.4.00"


source opts.sh

SP=159

# Delays
GD=0.3:-0.1:0.2

for c in {1..8}; do
	echo "Coil" $c

	truncate -s0 AvgErr_C${c}_SP${SP}.txt
	count=1
	for ((noise=100; noise<=50100; noise+=2000)); do
		echo "Count" $count "Noise" $noise
		noise_ratio=$(sed -n ${count}p noise/noise_ratio_C${c}.txt)

		echo $(echo -e $noise_ratio"\t";  python3 ../../Python_Plotting/Intersect.py -C${c} -P${SP} -N${noise} -S ${GD}) >> AvgErr_C${c}_SP${SP}.txt
		count=$(($count + 1))
	done
done


noise=0.000005

cfl2png -z 9 -CV r_noise0 r_noise0
cfl2png -z 9 -CV r_noise$noise r_noiseP




python3 ../../Python_Plotting/Intersect_plot.py -S 0.3:-0.1:0.2 -t "" "GDest_C1_SP159.txt" "GDest_C2_SP159.txt" "GDest_C3_SP159.txt" "GDest_C4_SP159.txt" "GDest_C5_SP159.txt" "GDest_C6_SP159.txt" "GDest_C7_SP159.txt" "GDest_C8_SP159.txt" ${NAME}_GDest.png
python3 ../../Python_Plotting/Intersect_plot2.py -S 0.3:-0.1:0.2 -t ""  "AvgErr_C1_SP159.txt" "AvgErr_C2_SP159.txt" "AvgErr_C3_SP159.txt" "AvgErr_C4_SP159.txt" "AvgErr_C5_SP159.txt" "AvgErr_C6_SP159.txt" "AvgErr_C7_SP159.txt" "AvgErr_C8_SP159.txt" ${NAME}_err.png
convert ${NAME}_err.png -trim _${NAME}_err.png # Image Magick!
convert ${NAME}_GDest.png -trim _${NAME}_GDest.png # Image Magick!

python3 ../../Python_Plotting/figcreator.py --tile "2x1" r_noise0.png r_noiseP.png phan.png
python3 ../../Python_Plotting/figcreator.py --tile "1x3" phan.png _${NAME}_err.png _${NAME}_GDest.png _${OUT}.png
python3 ../../Python_Plotting/figcreator.py --fontsize 100 -t"LTh:b)" _${OUT}.png ${OUT}.png

rm *txt phan.png _${OUT}*.png r*.png ${NAME}*png _${NAME}*png
rm _*{cfl,hdr} empty*{cfl,hdr} k*{cfl,hdr} noise*{cfl,hdr} rec*{cfl,hdr} t*{cfl,hdr}
