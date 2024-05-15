fasta = "/home/valentin-grenet/Bureau/Données/Resources_yann/Final_library.fasta"
dante = "/home/valentin-grenet/Bureau/Données/Resources_yann/classification_more_simplied_DANTE.txt"
output = "/home/valentin-grenet/Bureau/Données/Resources_yann/classification_with_length_DANTE.txt"

dico_lines = {}
for line in open(dante, "r"):
    elements = line.split("\t")
    dico_lines[elements[0]] = {"lineage":elements[1][:-1], "length":0}

for line in open(fasta, "r"):
    if line[0]==">":
        elements = line.split("#")
    else:
        dico_lines[elements[0][1:]]["length"] = len(line)-1

file = open(output, "w")
for TE in dico_lines:
    file.write("%s\t%s\t%s\n" % (TE, dico_lines[TE]["lineage"], dico_lines[TE]["length"]))