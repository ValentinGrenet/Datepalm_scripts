import os

os.chdir("/home/valentin-grenet/Bureau/Données/Resources_yann")
file_coordinates = open("list_GAG_coordinates.gff3", "r")
file_sequences = open("Final_library.fasta", "r")
file_prot = open("GAG_library.fasta", "w")

dico = {}

for line in file_coordinates:
    elements = line.split("\t")
    dico[elements[0]] = {"start":elements[1], "stop":elements[2][:-1]}
file_coordinates.close()
print(dico)

for line in file_sequences:
    if line[0]==">":
        id = line[1:line.find("#")]
        print(id)
        if id in dico:
            file_prot.write(line)
    else:
        if id in dico:
            file_prot.write(line[int(dico[id]["start"]):int(dico[id]["stop"])] + "\n")
file_sequences.close()
file_prot.close()
