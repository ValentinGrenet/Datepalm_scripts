import os
import Bio
from Bio import SeqIO                           # Used to have a uniform interface for input and output sequence file formats
from Bio.Seq import Seq

def WriteGenes(gene):
    
    tes = {seq_record.id: seq_record for seq_record in SeqIO.parse(libraries_dir + gene + "_library.fasta", "fasta")}            # dictionnaire des séquences consensus des TEs
    os.chdir('/home/valentin-grenet/Bureau/Données/LTR_cdhit_sequences')

    for te in tes:
        basename = te.split('#')[0]
        # os.mkdir(basename)
        os.chdir(basename)
        headers = [basename, gene, "fasta"]
        SeqIO.write(tes[te], '.'.join(headers), 'fasta')
        os.chdir('..')

WriteGenes("RT"); WriteGenes("RH"); WriteGenes("INT"); WriteGenes("PROT"); WriteGenes("GAG")