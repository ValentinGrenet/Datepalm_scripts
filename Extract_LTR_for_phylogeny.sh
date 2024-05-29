#!/bin/bash

# Directories
sequences_dir="/home/valentin-grenet/Bureau/Données/TE_sequences"

# Files
LTR_coordinates="LTR_coordinates.bed"
LTR_sequences="LTR_sequences.fasta"
LTR_alignment="LTR_alignment.fasta"
genome_file="/home/valentin-grenet/Bureau/Données/Resources_yann/GCF_009389715.1_palm_55x_up_171113_PBpolish2nd_filt_p_genomic.fna"

# Environment
bedtools="activate tools"
mafft="activate pfam"

cd $sequences_dir
for consensus in consensus*
do
	echo $consensus
	cd $consensus
	
	mamba $bedtools
	bedtools getfasta -fi $genome_file \
					  -fo $consensus.$LTR_sequences \
					  -bed $consensus.$LTR_coordinates \
					  -nameOnly	\
					  -s
	# -nameOnly : use the 4th column (id) as the head of the fasta sequence
	# -s : extract the sequence of the requested strand in 6th column
	mamba deactivate
	
	mamba $mafft
	mafft $consensus.$LTR_sequences > $consensus.$LTR_alignment
	mamba deactivate
	cd ..
done

