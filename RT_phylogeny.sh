#!/bin/bash

# Test script to begin to write the possible command use for the first step
# of the analysis

# Directories
general_path="/home/valentin-grenet/Bureau/Données"
resources="Resources_yann"
Gypsy_dir="Gypsy_aa"
Copia_dir="Copia_aa"

# Scripts
write_RT_library="/home/valentin-grenet/Bureau/Scripts/write_RT_library.py"
write_RT_aa="/home/valentin-grenet/Bureau/Scripts/write_RT_aa.py"

# Files
LTR_annotations="DANTE_full_output.gff3"
RT_coordinates="list_RT_coordinates.gff3"
RT_library="RT_library_aa.fasta"
RT_Gypsy="RT_Gypsy_aa.fasta"
RT_Copia="RT_Copia_aa.fasta"


# Environments
# write command here if a conda or mamba environment needs to be activated

cd $general_path
mkdir $Gypsy_dir
mkdir $Copia_dir
cd $resources

# Step 1 : Make an RT library document
grep -v "^#" $LTR_annotations | grep "Name=RT" | cut -f1,4,5,9 > $RT_coordinates
python3 $write_RT_aa

# Step 2 : Create a consensus for each lineage (Copia and Gypsy)
while read -r ligne; do
    if [[ "$ligne" == *Gypsy ]]; then
    # if Gypsy in fasta title, put the sequence in Gypsy file
        echo "$ligne" >> $RT_Gypsy
        read -r sequence
        echo "$sequence" >> $RT_Gypsy
    elif [[ "$ligne" == *Copia ]]; then
    # if Copia in fasta title, put the sequence in Copia file
        echo "$ligne" >> $RT_Copia
        read -r sequence
        echo "$sequence" >> $RT_Copia
    fi
done < $RT_library
# Line to only keep the consensus title
sed -i "s:#LTR/Gypsy::" $RT_Gypsy
sed -i "s:#LTR/Copia::" $RT_Copia

cp $RT_Gypsy ../$Gypsy_dir
cp $RT_Copia ../$Copia_dir

# Step 3 : Nex files from the fasta files were needed and were generated with Mesquite

# Step 4 : the lines used in MrBayes command prompt to make the phylogenetic analysis
# execute RT_Gypsy_library.nex
# prset brlenspr=clock:uniform
# lset nst=2 rates=invgamma
# mcmc ngen=500000 samplefreq=1000 printfreq=1000 diagnfreq=10000
# sump
# sumt

# execute RT_Gypsy_library.nex
# prset aamodelpr=mixed
# mcmc ngen=500000 samplefreq=100 printfreq=100 diagnfreq=1000
# sump
# sumt

#NEXUS

# begin mrbayes;
#     set autoclose=yes nowarn=yes
#     set usebeagle=yes beagledevice=cpu
#     execute consensus_Cluster_0.LTR_alignment.nex
#     prset brlenspr=clock:uniform
#     lset nst=2 rates=invgamma
#     mcmc ngen=500000 samplefreq=1000 printfreq=1000 diagnfreq=10000
#     sump;
#     sumt;
# end;

# Finally opened FigTree to visualize con.tre files 
