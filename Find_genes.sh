#!/bin/bash

# Directories
general_dir="/home/valentin-grenet/Bureau/Données/TE_sequences"
data_dir="Repeat_TEs"

# Files
Coordinates_file="TE_coordinates.bed"
Coordinates_sorted="TE_coord_sorted.bed"
Result_file="TE_closest_genes.bed"
Genes_file="$general_dir/Genes_coord_sorted.bed"

cd $general_dir

mamba activate tools
for consensus in consensus*
do
	cd $consensus/$data_dir
    sed -i 's/^/chr/; s/chrchr/chr/g' $consensus.TE_coordinates.bed         # add chr at the beginning of each contig

	sort-bed $consensus.$Coordinates_file > $consensus.$Coordinates_sorted
    bedtools closest -a $consensus.$Coordinates_sorted \
                     -b $Genes_file -D ref > $consensus.$Result_file

	cd ../..
done
mamba deactivate