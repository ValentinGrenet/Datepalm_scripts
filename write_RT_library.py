import os

os.chdir("/home/valentin-grenet/Bureau/Données/Resources_yann")
file_coordinates = open("list_RT_coordinates.gff3", "r")
file_sequences = open("Final_library.fasta", "r")
file_RT = open("RT_library.fasta", "w")

dico = {}

for line in file_coordinates:
    elements = line.split("\t")
    dico[elements[0]] = {"start":elements[1], "stop":elements[2][:-1]}
file_coordinates.close()
print(dico)

for line in file_sequences:
    print(line)
    if line[0]==">":
        seq = line[1:line.find("#")]
        if seq in dico:
            file_RT.write(line)
    else:
        if seq in dico:
            file_RT.write(line[int(dico[seq]["start"]):int(dico[seq]["stop"])+1] + "\n")
file_sequences.close()
file_RT.close()
