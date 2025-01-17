import os
import subprocess
import Bio
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord

# Directories
general_path="/home/valentin-grenet/Bureau/Thèse/Données"
TE_path = "TE_sequences"

# Files
inpactor_file = "Inpactor_run/inpactor2_library.fasta"
blast_file = "TE_sequences/blast_results_filtered.tsv"
summary_file="Cdhit_run/results_clustering.txt"

def ExtractLengths(file, dico_length):
    '''Extract the length of a sequence from a fasta file to a dictionnary of consensus names as keys.
    The consensus name as to be provided with an existing dictionnary'''
    i = -1
    for line in open(file, "r"):
        elements = line.split("\t")
        if elements[0] == "0":
            i += 1
            cluster = "Cluster_" + str(i)
            dico_length[cluster] = {}
        TE = elements[2].split("_LTR")[0][2:]
        dico_length[cluster][TE] = int(elements[1])
    return dico_length

def blastn(query, subject, outfile=False):
  '''Execute a blastn query and return the results'''
  cmd = ['blastn', \
         '-query', query, \
         '-subject', subject, \
         '-outfmt', '6 length pident qseqid qstart qend sseqid sstrand sstart send sseq evalue' \
        ]

  proc = subprocess.Popen(cmd, stdout=subprocess.PIPE)
  output = proc.stdout.read()
  blast_out = output.splitlines()
    
  if outfile:
    with open(outfile, 'w') as f:
      for line in blast_out:
        f.write(line + '\n')
    
  return [line.split(b'\t') for line in output.splitlines()]          # added a b in line.split to turn in bytes object



os.chdir(general_path)
dico_length = ExtractLengths(summary_file, {})

TEs = {seq_record.id.split("#")[0]: seq_record for seq_record in SeqIO.parse(inpactor_file, "fasta")}
TE_info = {}
count_TE = 0

# os.mkdir(TE_path)
# blast_list = open(blast_file, "w")
headers = ["aln_len", "%_id", "TE", "query_start", "query_stop","target_consensus","strand","target_start","target_stop","sequence","e-value"]
# blast_list.write('\t'.join(headers) + '\n')
os.chdir(TE_path)
cluster = ""
for cluster in dico_length:
    cluster = "Cluster_443"
    os.mkdir(cluster)
    os.chdir(cluster)
    for TE in dico_length[cluster]:
        print('Annotating ' + TE + ', sequence length : ' + str(len(TEs[TE])))
        count_TE += 1
        SeqIO.write(TEs[TE], TE + '.fasta', 'fasta')# fichier fasta pour chaque séquence
        selfblast = blastn(TE + '.fasta', TE + '.fasta')# selfblast sur la séquence consensus
        selfblast.sort(key=lambda x: (int(x[7])))
        i=0
        for result in selfblast:
            result.pop(2)
            print(i)
            print(result)
            i+=1
        print("end of blast")
        input("Test " + str(count_TE))
        LTR = input(TE)
        # blast_list.write(str(b'\t'.join(selfblast[int(LTR)]) + b'\n', encoding="utf-8"))
    os.chdir('..')
# blast_list.close()