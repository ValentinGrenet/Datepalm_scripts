#!/bin/bash

cd /home/valentin-grenet/Bureau/Données/TE_sequences

for consensus in consensus_Cluster_103_subfam_2
do
	cd $consensus/Repeat_TEs
	sed -i '/TITLE Taxa;/d' $consensus.LTR_trimmed.nex
	sed -i '/TITLE  Character_Matrix;/d' $consensus.LTR_trimmed.nex
	sed -i "s/NTAX=/NTAX= /g" $consensus.LTR_trimmed.nex
	sed -i "s/#LTR:Gypsy//g; s/#LTR:Copia//g; s/NCHAR=/NCHAR= /g; s/'//g; s/(+)//g; s/(-)//g" $consensus.LTR_trimmed.nex
	cd ../..
done
