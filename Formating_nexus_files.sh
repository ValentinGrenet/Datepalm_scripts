#!/bin/bash
# Script used to generate and formate nexus alignements files for MrBayes

cd /home/valentin-grenet/Bureau/Données/TE_sequences

fasta_file="complete_trimmed.fasta"
nexus_file="complete_trimmed.nex"

for consensus in consensus*
do
	cd $consensus/Repeat_TEs/test_complete

	mamba activate tools
	seqmagick convert --output-format nexus --alphabet dna \
	$consensus.$fasta_file $consensus.$nexus_file

	sed -i '/TITLE Taxa;/d' $consensus.$nexus_file
	sed -i '/TITLE  Character_Matrix;/d' $consensus.$nexus_file
	sed -i "s/ntax=/ntax= /g; s/nchar=/nchar= /g" $consensus.$nexus_file
	sed -i "s/#LTR:Gypsy//g; s/#LTR:Copia//g; s/'//g; s/(+)//g; s/(-)//g" $consensus.$nexus_file
	cd ../../..
done
