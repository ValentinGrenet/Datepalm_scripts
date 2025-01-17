file = open("/home/valentin-grenet/Bureau/Données/Flank_regions_test/All_TEs.bed", "r")
size = 0
TEs = ["Angela","Tat/Retand","SIRE"]
for line in file:
    elements = line.split("\t")
    if elements[6][:-1] in TEs:
        size += int(elements[2]) - int(elements[1])
print(size)