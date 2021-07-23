#!/bin/bash
set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
        echo "\$TOOLBOX_PATH is not set correctly!" >&2
        exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.5.00"

# Spokes for GD estimation
SP=(3 15 159)
TYPE=("ACadapt" "RING")

# GD corrected
for i in ${SP[*]}; do
bart resize -c 0 170 1 170 rec_ACadapt$i _tmp
cfl2png -C V -u0.46 _tmp _rec_ACadapt$i
bart resize -c 0 170 1 170 rec_RING$i _tmp
cfl2png -C V -u0.46 _tmp _rec_RING$i
done

t="RING"
for i in ${SP[*]}; do
	if [[ $i == "${SP[0]}" ]]; then
	python3 ../../Python_Plotting/figcreator.py -t"BCh:Nₛₚ=${i}, LCv:RING" _rec_${t}${i}.png _ltmp${i}.png
	else
	python3 ../../Python_Plotting/figcreator.py -t"BCh:Nₛₚ=${i}" _rec_${t}${i}.png _ltmp${i}.png
	fi
done
python3 ../../Python_Plotting/figcreator.py --tile "1x3" $(for i in ${SP[*]}; do echo _ltmp${i}.png; done) _bottom.png

convert _bottom.png -trim _bottom.png # Image Magick
convert -fill 'white' -colorize 100% _bottom.png _top.png
python3 ../../Python_Plotting/figcreator.py --resize y:173:crop _top.png _top.png
python3 ../../Python_Plotting/figcreator.py --tile "3x1" --spacing 0 _top.png _bottom.png _top.png _res.png
python3 ../../Python_Plotting/figcreator.py -t"LTh:b)" _res.png _resb.png


# Python
python3 ../../Python_Plotting/GD_evaluation2.py --yres 760 RING.txt '' _plot.png
convert _plot.png -trim _plot.png
python3 ../../Python_Plotting/figcreator.py --resize y:760:iso _plot.png _rsplot.png

# Join
python3 ../../Python_Plotting/figcreator.py --tile "1x2" --spacing 40  _resb.png _rsplot.png Final.png
convert Final.png -trim Final.png

rm _*.png

