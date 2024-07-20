#!/bin/bash

# Directories
general_dir="/home/valentin-grenet/Bureau/Données/TE_sequences"
data_dir="Repeat_TEs/test_all"

# Files
Coordinates_file="all_coordinates.bed"
Coordinates_sorted="all_coord_sorted.bed"
Result_file="all_closest_genes.bed"
Genes_file="$general_dir/../Genes_coord_sorted.bed"

cd $general_dir

mamba activate tools
for consensus in consensus*
do
	cd $consensus/$data_dir
    sed -i 's/^/chr/; s/chrchr/chr/g' $consensus.all_coordinates.bed         # add chr at the beginning of each contig

	sort-bed $consensus.$Coordinates_file > $consensus.$Coordinates_sorted
    bedtools closest -a $consensus.$Coordinates_sorted \
                     -b $Genes_file -D ref > $consensus.$Result_file

	cd ../../..
done
mamba deactivate