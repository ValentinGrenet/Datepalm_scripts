#!/bin/bash

cd /home/valentin-grenet/Bureau/Données/TE_sequences

for consensus in consensus*
do
	cd $consensus/Repeat_TEs

	mamba activate tools
	seqmagick convert --output-format nexus --alphabet dna \
	$consensus.LTR_trimmed.fasta $consensus.LTR_trimmed.nex

	sed -i '/TITLE Taxa;/d' $consensus.LTR_trimmed.nex
	sed -i '/TITLE  Character_Matrix;/d' $consensus.LTR_trimmed.nex
	sed -i "s/ntax=/ntax= /g; s/nchar=/nchar= /g" $consensus.LTR_trimmed.nex
	sed -i "s/#LTR:Gypsy//g; s/#LTR:Copia//g; s/'//g; s/(+)//g; s/(-)//g" $consensus.LTR_trimmed.nex
	cd ../..
done
