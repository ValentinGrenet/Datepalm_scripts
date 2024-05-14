#!/bin/bash

grep "^c" classification_simplied_DANTE.txt | sed "s:Final_Classification=Class_I|LTR|::" | sed "s:Ty1/copia|:LTR\:RLC\::" | sed "s:Ty3/gypsy|:LTR\:RLG\::" | sed "s:non-chromovirus|OTA|::" | sed "s:chromovirus|::" | sed "s:Tat|Retand:TAT:" | sed "s:Tork:TORK:" | sed "s:Ikeros:IKEROS:" | sed "s:Athila:ATHILA:" | sed "s:Tekay:TEKAY-DEL:" | sed "s:Angela:ANGELA:" | sed "s:Galadriel:GALADRIEL:" | sed "s:Reina:REINA:" | sed "s:Ivana:IVANA-ORYCO:" > classification_more_simplied_DANTE.txt

python3 length_on_dante.py
