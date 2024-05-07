#!/bin/bash

grep "^c" classification_simplied_DANTE.txt | sed "s:Final_Classification=Class_I|LTR|::" > DANTE_more_simplied.txt
