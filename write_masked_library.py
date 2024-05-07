import os

os.chdir("/home/valentin-grenet/Bureau/Données/")
file_header = open("LTR_all_alignment/Repeat_LTR_all.out", "r")
#file_sequences = open("Resources_yann/GCF_009389715.1_palm_55x_up_171113_PBpolish2nd_filt_p_genomic.fna", "r")
file_masked = open("LTR_all_alignment/LTR_all_masking.gff", "w")

dico_LTR = {}
dico_genome = {}
id=0

for line in file_header:
    id+=1
    headers = []
    elements = line.split(" ")
    if elements[0] == "#":
        continue
    for i in range(0,len(elements)):
        if elements[i] != "":
            headers.append(elements[i])
    if headers[8] == "C":
        headers[8] = "-"
    dico_LTR[id] = {"contig":headers[4], 
                         "start":headers[5],
                         "stop":headers[6],
                         "reverse":headers[8],
                         "consensus":headers[9],
                         "class":headers[10],
                         "begin+":headers[11],
                         "end":headers[12],
                         "begin-":headers[13]}
file_header.close()

for LTR_hit in dico_LTR:
    file_masked.write("%s\t%s\t%s\t%s#%s\t.\t%s\n" % (dico_LTR[LTR_hit]["contig"],
                                          dico_LTR[LTR_hit]["start"],
                                          dico_LTR[LTR_hit]["stop"],
                                          dico_LTR[LTR_hit]["consensus"],
                                          dico_LTR[LTR_hit]["class"],
                                          dico_LTR[LTR_hit]["reverse"],))

# for LTR_hit_a in dico_LTR:
#     print(LTR_hit_a)
#     a_range = set(range(int(dico_LTR[LTR_hit_a]["start"]), int(dico_LTR[LTR_hit_a]["stop"])))
#     for LTR_hit_b in dico_LTR:
#         b_range = set(range(int(dico_LTR[LTR_hit_b]["start"]), int(dico_LTR[LTR_hit_b]["stop"])))
#         intersection = a_range & b_range
#         if len(intersection)!=0 and LTR_hit_a!=LTR_hit_b and dico_LTR[LTR_hit_a]["contig"]==dico_LTR[LTR_hit_b]["contig"]:
#             print("Intersection entre %s et %s" % (LTR_hit_a,LTR_hit_b))


# contig = ""
# for line in file_sequences:
#     if line[0]==">":
#         print(line)
#         dico_genome[line[1:-1]] = ""
#         contig = line[1:-1]
#     else:
#         dico_genome[contig] = dico_genome[contig] + line[:-1]
# print(dico_genome)
# file_sequences.close()
