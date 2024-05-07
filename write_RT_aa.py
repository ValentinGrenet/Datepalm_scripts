import os

os.chdir("/home/valentin-grenet/Bureau/Données/Resources_yann")
file_coordinates = open("list_RT_coordinates.gff3", "r")
file_sequences = open("Final_library.fasta", "r")
file_RT = open("RT_library_aa.fasta", "w")

dico = {}

for line in file_coordinates:
    elements = line.split("\t")
    infos = elements[3].split(";")
    dico[elements[0]] = {"start":elements[1], "stop":elements[2], "seq":infos[6][11:]}
file_coordinates.close()
print(dico)

for line in file_sequences:
    if line[0]==">":
        id = line[1:line.find("#")]
        print(id)
        if id in dico:
            file_RT.write(line)
    else:
        if id in dico:
            print(dico[id]["seq"])
            file_RT.write(dico[id]["seq"] + "\n")
file_sequences.close()
file_RT.close()