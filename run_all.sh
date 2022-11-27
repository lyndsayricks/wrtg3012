#!/bin/sh
# requires wget, ImageMagick, R
set -e
rm -r tmp
mkdir tmp
cp *.r contribution.tex contribution.bib tmp
cd tmp
# Get required Glottolog data
wget https://cdstar.eva.mpg.de/bitstreams/EAEA0-7EA2-D308-CD6E-0/languages_and_dialects_geo.csv # v4.6
wget https://cdstar.eva.mpg.de/bitstreams/EAEA0-7EA2-D308-CD6E-0/glottolog_languoid.csv.zip && unzip glottolog_languoid.csv.zip
# Get required PHOIBLE data
wget https://github.com/phoible/dev/blob/master/data/phoible.csv?raw=true
mv phoible.csv?raw=true phoible.csv
# Get required elevation data
wget https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/ice_surface/grid_registered/georeferenced_tiff/ETOPO1_Ice_g_geotiff.zip
unzip ETOPO1_Ice_g_geotiff.zip
# Run analysis R script
R -f ejectives.r
R -f environment.r
mkdir plots
R -f analysis.r
xelatex contribution.tex
biber contribution
xelatex contribution.tex
mkdir ../out
mv plots contribution.pdf ../out
cd ..
rm -r tmp
echo Completed without errors.
