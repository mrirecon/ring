#!/bin/bash
set -e


if [ ! -e $TOOLBOX_PATH/bart ] ; then
        echo "\$TOOLBOX_PATH is not set correctly!" >&2
        exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.4.00"


# Spokes for GD estimation
SP=(3 15 159)
REC=(39 159)
TYPE=("ACadapt" "RING")

# GD corrected
for i in ${SP[*]}; do
for j in ${REC[*]}; do
bart resize -c 0 170 1 170 rec_ACadapt_GDsp${i}_RECsp$j _tmp
cfl2png -C V -u0.36 _tmp _rec_ACadapt_GDsp${i}_RECsp$j
bart resize -c 0 170 1 170 rec_RING_GDsp${i}_RECsp$j _tmp
cfl2png -C V -u0.36 _tmp _rec_RING_GDsp${i}_RECsp$j
done
done

t="RING"
for i in ${SP[*]}; do
for j in ${REC[*]}; do
	if [[ $i == "${SP[0]}" ]]; then
	python3 ../Python_Plotting/figcreator.py -t"BCh:Nₛₚ=${i}, LCv:RING" _rec_${t}_GDsp${i}_RECsp${j}.png _ltmp_GDsp${i}_RECsp${j}.png
	else
	python3 ../Python_Plotting/figcreator.py -t"BCh:Nₛₚ=${i}" _rec_${t}_GDsp${i}_RECsp${j}.png _ltmp_GDsp${i}_RECsp${j}.png
	fi
done
done


for j in ${REC[*]}; do
python3 ../Python_Plotting/figcreator.py --tile "1x3" $(for i in ${SP[*]}; do echo _ltmp_GDsp${i}_RECsp${j}.png; done) _bottom_RECsp${j}.png
done


t="ACadapt"
for i in ${SP[*]}; do
for j in ${REC[*]}; do

	if [[ $i == "${SP[0]}" ]]; then
	python3 ../Python_Plotting/figcreator.py -t"LCv:AC-Adaptive" _rec_${t}_GDsp${i}_RECsp${j}.png _tmp_GDsp${i}_RECsp${j}.png
	else
	cp _rec_${t}_GDsp${i}_RECsp${j}.png _tmp_GDsp${i}_RECsp${j}.png
	fi
done
done

for j in ${REC[*]}; do
python3 ../Python_Plotting/figcreator.py --tile "1x3" $(for i in ${SP[*]}; do echo _tmp_GDsp${i}_RECsp${j}.png; done) _top_RECsp${j}.png
done

for j in ${REC[*]}; do
python3 ../Python_Plotting/figcreator.py --tile "2x1" _top_RECsp${j}.png _bottom_RECsp${j}.png _res_RECsp${j}.png
done


python3 ../Python_Plotting/figcreator.py -t"LTh:a)" _res_RECsp${REC[0]}.png _resa.png
python3 ../Python_Plotting/figcreator.py -t"LTh:b)" _res_RECsp${REC[1]}.png _resb.png
python3 ../Python_Plotting/figcreator.py --tile "2x1" _resa.png _resb.png _res.png

convert _res.png -trim SupFig2.png # Image Magick!


rm _*.png

