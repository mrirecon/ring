#!/bin/bash
set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	        echo "\$TOOLBOX_PATH is not set correctly!" >&2
		        exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH


# Spokes for GD estimation
SP=(3 15 75)
TYPE=("ACadapt" "RING")

# GD corrected
for i in ${SP[*]}; do
bart resize -c 0 170 1 170 rec_ACadapt_SPGDest$i _tmp
cfl2png -C V -u0.390 _tmp _rec_ACadapt$i
bart resize -c 0 170 1 170 rec_RING_SPGDest$i _tmp
cfl2png -C V -u0.390 _tmp _rec_RING$i
done

t="RING"
for i in ${SP[*]}; do
	if [[ $i == "${SP[0]}" ]]; then
	python3 ../Python_Plotting/figcreator.py -t"BCh:Nₛₚ=${i}, LCv:RING" _rec_${t}${i}.png _ltmp${i}.png
	else
	python3 ../Python_Plotting/figcreator.py -t"BCh:Nₛₚ=${i}" _rec_${t}${i}.png _ltmp${i}.png
	fi
done
python3 ../Python_Plotting/figcreator.py --tile "1x3" $(for i in ${SP[*]}; do echo _ltmp${i}.png; done) _bottom.png

t="ACadapt"
for i in ${SP[*]}; do
	if [[ $i == "${SP[0]}" ]]; then
	python3 ../Python_Plotting/figcreator.py -t"LCv:AC-Adaptive" _rec_${t}${i}.png _tmp${i}.png
	else
	cp _rec_${t}${i}.png _tmp${i}.png
	fi
done
python3 ../Python_Plotting/figcreator.py --tile "1x3" $(for i in ${SP[*]}; do echo _tmp${i}.png; done) _top.png

python3 ../Python_Plotting/figcreator.py --tile "2x1" _top.png _bottom.png _res.png
convert _res.png -trim SupFig3.png # Image Magick!



rm _*.png

