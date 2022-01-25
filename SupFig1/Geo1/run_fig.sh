#!/usr/bin/env bash

python3 ../../Python_Plotting/Intersect_plot.py -S 0.3:-0.1:0.2 -t "" "GDest_C1_SP159.txt" "GDest_C2_SP159.txt" "GDest_C3_SP159.txt" "GDest_C4_SP159.txt" "GDest_C5_SP159.txt" "GDest_C6_SP159.txt" "GDest_C7_SP159.txt" "GDest_C8_SP159.txt" Geo1_GDest.png
python3 ../../Python_Plotting/Intersect_plot2.py -S 0.3:-0.1:0.2 -t ""  "AvgErr_C1_SP159.txt" "AvgErr_C2_SP159.txt" "AvgErr_C3_SP159.txt" "AvgErr_C4_SP159.txt" "AvgErr_C5_SP159.txt" "AvgErr_C6_SP159.txt" "AvgErr_C7_SP159.txt" "AvgErr_C8_SP159.txt" Geo1_err.png
convert Geo1_err.png -trim _Geo1_err.png # Image Magick!
convert Geo1_GDest.png -trim _Geo1_GDest.png # Image Magick!

python3 ../../Python_Plotting/figcreator.py --tile "2x1" r_noise0.png r_noiseP.png phan.png
python3 ../../Python_Plotting/figcreator.py --tile "1x3" phan.png _Geo1_err.png _Geo1_GDest.png _b.png
python3 ../../Python_Plotting/figcreator.py --fontsize 100 -t"LTh:b)" _b.png b.png

rm *txt phan.png _b*.png r*.png Geo*png _Geo*png
