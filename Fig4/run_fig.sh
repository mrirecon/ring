#!/usr/bin/env bash

# Spokes for GD estimation
SP=(3 15 75)
TYPE=("ACadapt" "RING")

# GD corrected
for i in ${SP[*]}; do
bart resize -c 0 170 1 170 rec_ACadapt$i _tmp
cfl2png -C V -u0.555 _tmp _rec_ACadapt$i
bart resize -c 0 170 1 170 rec_RING$i _tmp
cfl2png -C V -u0.555 _tmp _rec_RING$i
done

t="RING"
for i in ${SP[*]}; do
	if [[ $i == "${SP[0]}" ]]; then
	figcreator.py -t"BCh:Nₛₚ=${i}, LCv:RING" _rec_${t}${i}.png _ltmp${i}.png
	else
	figcreator.py -t"BCh:Nₛₚ=${i}" _rec_${t}${i}.png _ltmp${i}.png
	fi
done
figcreator.py --tile "1x3" $(for i in ${SP[*]}; do echo _ltmp${i}.png; done) _bottom.png

t="ACadapt"
for i in ${SP[*]}; do
	if [[ $i == "${SP[0]}" ]]; then
	figcreator.py -t"LCv:AC-Adaptive" _rec_${t}${i}.png _tmp${i}.png
	else
	cp _rec_${t}${i}.png _tmp${i}.png
	fi
done
figcreator.py --tile "1x3" $(for i in ${SP[*]}; do echo _tmp${i}.png; done) _top.png

figcreator.py --tile "2x1" _top.png _bottom.png _res.png
convert _res.png -trim _res.png


# Python
python3 ../Python_Plotting/GD_evaluation.py --yres 760 ACadapt.txt RING.txt '' _plot.png
convert _plot.png -trim _plot.png
figcreator.py --resize y:760:iso _plot.png _rsplot.png

# Join
figcreator.py --tile "1x2" --spacing 40  _res.png _rsplot.png Final.png


rm _*.png

