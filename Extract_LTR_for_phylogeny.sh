#!/bin/bash

# Directories
sequences_dir="/home/valentin-grenet/Bureau/Données/TE_sequences"

# Files
LTR_consensus="5LTR.fasta"
LTR_coordinates="complete_coordinates.bed"
LTR_sequences="complete_sequences.fasta"
LTR_alignment="complete_alignment.fasta"
genome_file="/home/valentin-grenet/Bureau/Données/Resources_yann/GCF_009389715.1_palm_55x_up_171113_PBpolish2nd_filt_p_genomic.fna"

# Environment
bedtools="activate tools"
mafft="activate pfam"

cd $sequences_dir
for consensus in consensus*
do
	echo $consensus
	cd $consensus/Repeat_TEs
	
	mamba $bedtools
	bedtools getfasta -fi $genome_file \
					  -fo $consensus.$LTR_sequences.fasta \
					  -bed $consensus.$LTR_coordinates \
					  -nameOnly	\
					  -s
	# -nameOnly : use the 4th column (id) as the head of the fasta sequence
	# -s : extract the sequence of the requested strand in 6th column
	awk 'NR==1{print $0} NR>1{printf "%s", $0} END{print ""}' ../$consensus.$LTR_consensus > $consensus.$LTR_sequences
	cat $consensus.$LTR_sequences.fasta >> $consensus.$LTR_sequences
	rm $consensus.$LTR_sequences.fasta
	mamba deactivate
	
	mamba $mafft
	mafft $consensus.$LTR_sequences > $consensus.$LTR_alignment
	mamba deactivate
	cd ../..
done

