These scripts reproduce the experiments described in the article:

Rosenzweig S, Holme HCM, Uecker M, Simple Auto-Calibrated Gradient Delay Estimation From Few Spokes Using Radial Intersections (RING), Magn. Reson. Med. 2018, 10.1002/mrm.27506. [1,2]

For reconstruction we provide an adapted version of the Berkeley Advanced Reconstruction Toolbox (BART) [3] (commit 94ae49b).

In each folder the *.sh shell-scripts must be started. These scripts require BART [3].

The data can be viewed e.g. with 'view'[4] or be loaded into Matlab or Python using the wrappers provided in BART subdirectories './matlab' and './python'

For the plots python [5] is used.

If you need further help to run the scripts, I am happy to help you: sebastian.rosenzweig@med.uni-goettingen.de

November 5, 2018 - Sebastian Rosenzweig

[1] https://onlinelibrary.wiley.com/doi/10.1002/mrm.27506
[2] https://arxiv.org/abs/1805.04334v3
[3] https://mrirecon.github.io/bart
[4] https://github.com/mrirecon/view
[5] https://www.python.org
