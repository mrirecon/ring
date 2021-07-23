#!/usr/bin/env bash

# Create figures
python3 ellipse.py -S 0:0:0 -n 5 Sx0_Sy0_Sxy0_n5.png
python3 ellipse.py -S 0.5:0.5:0 -n 5 Sx0.5_Sy0.5_Sxy0_n5.png
python3 ellipse.py -S 0.5:0.3:0 -n 5 Sx0.5_Sy0.2_Sxy0_n5.png
python3 ellipse.py -S 0.5:0.3:0.1 -n 5 Sx0.5_Sy0.3_Sxy0.1_n5.png

# Trim
convert Sx0_Sy0_Sxy0_n5.png -trim Sx0_Sy0_Sxy0_n5.png
convert Sx0.5_Sy0.5_Sxy0_n5.png -trim Sx0.5_Sy0.5_Sxy0_n5.png
convert Sx0.5_Sy0.2_Sxy0_n5.png -trim Sx0.5_Sy0.2_Sxy0_n5.png
convert Sx0.5_Sy0.3_Sxy0.1_n5.png -trim Sx0.5_Sy0.3_Sxy0.1_n5.png

# Join
montage Sx0_Sy0_Sxy0_n5.png Sx0.5_Sy0.5_Sxy0_n5.png Sx0.5_Sy0.2_Sxy0_n5.png Sx0.5_Sy0.3_Sxy0.1_n5.png -tile 2x2 -geometry +7+7 Fig1.png
rm S*.png
