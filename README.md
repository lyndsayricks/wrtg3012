This repository contains all of the code for my WRTG3012 final project, including the R code for the statistical analysis and figure generation as well as the LaTeX source for the paper itself. The provided shell script (run_all.sh) will do all of this, provided that the following prerequisites are installed:

* A Unix-like operating system (macOS, Linux, BSD) with basic shell utilities, including `wget` and `unzip`
* R with the packages `dplyr`, `raster`, `ggplot2`, `ggpubr` and all of their dependencies installed
* A XeLaTeX distribution
* BibLaTeX

The shell script will automatically download all of the necessary data apart from the above software prerequisites - if they are installed, then all you need to do is clone the repository and run it from within the root folder of this distribution:

    git clone https://www.github.com/lyndsayricks/wrtg3012
    cd wrtg3012
    /bin/sh run_all.sh

The results will be then be located in the ./out subdirectory.

If you are using Windows, then the R and TeX-related dependencies will be the same, but you will not be able to use the provided shell script unless you have a Unix shell installed (e.g., a MinGW environment). You'll need to examine the script and perform the same tasks manually.
