#!/bin/bash

# Test script to begin to write the possible command use for the first step
# of the analysis

# Directories
general_path="/home/valentin-grenet/Bureau/Données"
resources="Resources_yann"

# Scripts
write_library="/home/valentin-grenet/Bureau/Scripts/write_library.py"

# Files
LTR_annotations="DANTE_full_output.gff3"
Coordinates="list_GAG_coordinates.gff3"
Library="GAG_library.fasta"


# Environments
# write command here if a conda or mamba environment needs to be activated

cd $general_path
cd $resources

# Step 1 : Make an RT library document
grep -v "^#" $LTR_annotations | grep "Name=GAG" | cut -f1,4,5 > $Coordinates
python3 $write_library

# Line to only keep the consensus title
sed -i "s:#LTR/Gypsy::" $Library
sed -i "s:#LTR/Copia::" $Library	

# Step 3 : Nex files from the fasta files were needed and were generated with Mesquite

# Step 4 : the lines used in MrBayes command prompt to make the phylogenetic analysis
# execute RT_Gypsy_library.nex
# prset brlenspr=clock:uniform
# lset nst=2 rates=invgamma
# mcmc ngen=500000 samplefreq=100 printfreq=100 diagnfreq=1000
# sump
# sumt

# execute RT_Gypsy_library.nex
# prset aamodelpr=mixed
# mcmc ngen=500000 samplefreq=100 printfreq=100 diagnfreq=1000
# sump
# sumt

# Finally opened FigTree to visualize con.tre files 
