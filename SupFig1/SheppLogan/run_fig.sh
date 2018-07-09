#!/usr/bin/env bash

python3 ../../Python_Plotting/Intersect_plot.py -S 0.3:-0.1:0.2 -t "" "GDest_C1_SP159.txt" "GDest_C2_SP159.txt" "GDest_C3_SP159.txt" "GDest_C4_SP159.txt" "GDest_C5_SP159.txt" "GDest_C6_SP159.txt" "GDest_C7_SP159.txt" "GDest_C8_SP159.txt" SheppLogan_GDest.png
python3 ../../Python_Plotting/Intersect_plot2.py -S 0.3:-0.1:0.2 -t ""  "AvgErr_C1_SP159.txt" "AvgErr_C2_SP159.txt" "AvgErr_C3_SP159.txt" "AvgErr_C4_SP159.txt" "AvgErr_C5_SP159.txt" "AvgErr_C6_SP159.txt" "AvgErr_C7_SP159.txt" "AvgErr_C8_SP159.txt" SheppLogan_err.png
convert SheppLogan_err.png -trim _SheppLogan_err.png # Image Magick!
convert SheppLogan_GDest.png -trim _SheppLogan_GDest.png # Image Magick!

python3 ../../Python_Plotting/figcreator.py --tile "2x1" r_noise0.png r_noiseP.png phan.png
python3 ../../Python_Plotting/figcreator.py --tile "1x3" phan.png _SheppLogan_err.png _SheppLogan_GDest.png _a.png
python3 ../../Python_Plotting/figcreator.py --fontsize 100 -t"LTh:a)" _a.png a.png

