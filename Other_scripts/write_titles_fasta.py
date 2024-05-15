import os

os.chdir("/home/valentin-grenet/Bureau/Données")

id = []
seq = []

file_titles = open("Gypsy_mrbayes/RT_Gypsy_library.fasta", "r")
for line in file_titles:
    if line[0]==">":
        id.append(line[:-1])
print(id)
file_titles.close()

file_sequences = open("Gypsy_aa/RT_Gypsy_aa.fasta", "r")
for line in file_sequences:
    if line[0]!=">":
        seq.append(line[:-1])
print(seq)
file_sequences.close()

if len(id)==len(seq):
    file_RT = open("Gypsy_aa/RT_Gypsy_aa.fasta", "w")
    for i in range(len(id)):
        file_RT.write(id[i] + "\n")
        file_RT.write(seq[i] + "\n")
file_RT.close()