### Script used to calculate the methylation of each TE for each context of methylation

import os

# Directory with TE coordinates (contig, start, stop)
coordinates_dir = "/shared/projects/poly_te_datepalm/Data/TE_coordinates/"
# Directory with the output files (methylation for each TE)
TE_meth_dir = "/shared/projects/poly_te_datepalm/Data/TE_methylation/"
individual = "Zahidi"
# Directory with the methylation of the genome (one individual, every chromosomes)
genome_meth_dir = "/shared/projects/poly_te_datepalm/Data/genome_methylation/" + individual

def MeanCalculation(perc_meth, count_meth):
    '''This function is used to calculate the mean methylation of the TE.
    Percentage of methylation for each bases covered.'''
    if count_meth == 0:
        return "NA"
    else:
        return str(perc_meth/count_meth)

def DensityCalculation(count_meth, contig_start, contig_stop):
    '''This function is used to calculate the density of methylation.
    Percentage of bases covered by methylation at least once.'''
    return str(count_meth / (int(contig_stop)-int(contig_start)))

os.chdir(coordinates_dir)
headers = ["TE", "CHH_density", "CHH_mean", "CHG_density", "CHG_mean", "CpG_density", "CpG_mean"]

for list_TE in os.listdir("."):	# list_TE = a file for each lineage of TEs
    lineage = list_TE.split("_")[0]	# Angela, Tat, etc.
    meth_density = open("%s%s_%s_methylation.tsv" % (TE_meth_dir, individual, lineage), "w")
    meth_density.write("\t".join(headers) + "\n")
    for line in open(list_TE, "r"):	# a line = a TE
        infos_TE = line.split("\t")
        contig = infos_TE[0]
        contig_start = int(infos_TE[1])
        contig_stop = int(infos_TE[2])
        TE = infos_TE[3]
        os.system("echo %s %s" % (lineage, TE))
        count_CHG = count_CHH = count_CpG = perc_CHG = perc_CHH = perc_CpG = 0
	# 3 file_meth = one for each methylation context
        for file_meth in os.listdir(genome_meth_dir + "/" + contig):
	    # a base = contig, coordinate, percentage of methylation
            for base in open(genome_meth_dir + "/" + contig + "/" + file_meth, "r"):
                elements = base.split("\t")
                if int(elements[1]) > contig_stop:
                    break
                elif int(elements[2]) < contig_start:
                    continue
                elif "CHH" in file_meth:
                    count_CHH += 1
                    perc_CHH += float(elements[3])
                elif "CHG" in file_meth:
                    count_CHG += 1
                    perc_CHG += float(elements[3])
                elif "CpG" in file_meth:
                    count_CpG += 1
                    perc_CpG += float(elements[3])
        CHG_density = DensityCalculation(count_CHG, contig_start, contig_stop)
        CHH_density = DensityCalculation(count_CHH, contig_start, contig_stop)
        CpG_density = DensityCalculation(count_CpG, contig_start, contig_stop)
        CHG_mean = MeanCalculation(perc_CHG,count_CHG)
        CHH_mean = MeanCalculation(perc_CHH,count_CHH)
        CpG_mean = MeanCalculation(perc_CpG,count_CpG)
        line_written = [TE, CHH_density, CHH_mean, CHG_density, CHG_mean, CpG_density, CpG_mean]
        meth_density.write("\t".join(line_written) + "\n")
    meth_density.close()
