#!/usr/bin/env bash

# Python
python3 ../Python_Plotting/GD_evaluation_sim.py FullCirc _full_plot.png
convert _full_plot.png -trim _full_plot.png # Image Magick!

python3 ../Python_Plotting/GD_evaluation_sim.py HalfCirc _half_plot.png
convert _half_plot.png -trim _half_plot.png

python3 ../Python_Plotting/figcreator.py --tile "1x2" --spacing 40 _full_plot.png _half_plot.png _Final.png
python3 ../Python_Plotting/figcreator.py --tile "1x2" --resize "y:766:iso" _Final.png Final.png


rm _*png

