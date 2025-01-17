#!/usr/bin/python3
# -*- coding: utf-8 -*- 

import sys
import os

os.chdir("/home/valentin-grenet/Bureau/Données/Resources_Valentin_FDA_LTR_all/Methylation_contigs")

namefile = sys.argv[1]
chr = namefile.split("_")[-1]

def WriteBed(list, namefile):
    file = open(namefile, "w")
    for line in list:
        file.write(line)
    file.close()

if "CHH" in namefile:
    i = 0
    CHH = []
    CHG = []
    for line in open(namefile, "r"):
        i += 1
        if i % 1000 == 0:
            print(i)
        
        elements = line.split("\t")
        if float(elements[10]) >= 20:
            if "CHH" in elements[3]:
                CHH.append("%s\t%s\t%s\n" % (elements[0], elements[1], elements[2]))
            elif "CHG" in elements[3]:
                CHG.append("%s\t%s\t%s\n" % (elements[0], elements[1], elements[2]))
    
    CHH_namefile = "../Bed_methylations/CHH_%s" % chr
    CHG_namefile = "../Bed_methylations/CHG_%s" % chr
    WriteBed(CHH, CHH_namefile)
    WriteBed(CHG, CHG_namefile)

elif "CpG" in namefile:
    i = 0
    CpG = []
    for line in open(namefile, "r"):
        i += 1
        if i % 1000 == 0:
            print(i)
        
        elements = line.split("\t")
        if float(elements[10]) >= 20:
            CpG.append("%s\t%s\t%s\n" % (elements[0], elements[1], elements[2]))

    CpG_namefile = "../Bed_methylations/CpG_%s.bed" % chr
    WriteBed(CpG, CpG_namefile)