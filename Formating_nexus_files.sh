#!/bin/bash

cd /home/valentin-grenet/Bureau/Données/LTR_cdhit_sequences

for consensus in *
do
	cd $consensus
	sed -i '/TITLE Taxa;/d' $consensus.LTR_alignment.nex
	sed -i '/TITLE  Character_Matrix;/d' $consensus.LTR_alignment.nex
	sed -i "s/NTAX=/NTAX= /g; s/NCHAR=/NCHAR= /g; s/'//g; s/(+)//g; s/(-)//g" $consensus.LTR_alignment.nex
	cd ..
done
