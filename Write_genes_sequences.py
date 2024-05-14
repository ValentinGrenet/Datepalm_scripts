import os
import Bio
from Bio import SeqIO                           # Used to have a uniform interface for input and output sequence file formats
from Bio.Seq import Seq

def WriteGenes(gene):
    Initial_dir = "/home/valentin-grenet/Bureau/Données/Resources_yann"
    Sequences_dir = '/home/valentin-grenet/Bureau/Données/LTR_cdhit_sequences'
    
    os.chdir(Initial_dir)
    WriteLibrary(gene)

    tes = {seq_record.id: seq_record for seq_record in SeqIO.parse(gene + "_library.fasta", "fasta")}            # dictionnaire des séquences consensus des TEs
    os.chdir(Sequences_dir)
    WriteConsensus(gene, tes)

def WriteLibrary(gene):
    file_coordinates = open(gene + "_coordinates.gff3", "r")
    file_sequences = open("Final_library.fasta", "r")
    file_prot = open(gene + "_library.fasta", "w")

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

def WriteConsensus(gene, tes):
    for te in tes:
        basename = te.split('#')[0]
        # os.mkdir(basename)
        os.chdir(basename)
        headers = [basename, gene, "fasta"]
        SeqIO.write(tes[te], '.'.join(headers), 'fasta')
        os.chdir('..')

WriteGenes("RT"); WriteGenes("RH"); WriteGenes("INT"); WriteGenes("PROT"); WriteGenes("GAG")