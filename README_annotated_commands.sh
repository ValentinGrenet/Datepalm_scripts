#########Github linkto INPACTOR2 : https://github.com/simonorozcoarias/Inpactor2

#######Part I: Bash script to run INPACTOR on reference genome (extremely fast). Note that INPACTOR2 is installed with a conda environment (see installation instructions)

#!/bin/bash
#SBATCH --mem=64GB
#SBATCH --job-name=repmod
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --output=repmod.%J.out	
#SBATCH --error=repmod.%J.err
conda activate Inpactor2
python3 Inpactor2.py -f /scratch/yb24/Datepalm/GCF_009389715.1_palm_55x_up_171113_PBpolish2nd_filt_p_genomic.fna -i yes -d yes -o Datepalm_TSD_TGCA

####Important options below (presence of TG_CA in start-end) :
-i TG_CA or --tg-ca TG_CA: Keep only elements with TG-CA-LTRs? [yes or no]. Default: no.
-d TSD or --tsd TSD: Keep only elements with TDS? [yes or no]. Default: no.
####


######Part II: Check with cd-hit which TEs are the same copy

#!/bin/bash
#SBATCH --mem=32GB
#SBATCH --job-name=repmod
#SBATCH --time=06:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --output=repmod.%J.out
#SBATCH --error=repmod.%J.err
module load cdhit/intel/4.8.1 ###specific to NYUAD cluster
cd-hit-est -i Inpactor2_library.fasta -T 0 -M 0 -o reduced_Inpactor2_library.fasta -d 0 -aS 0.8 -c 0.8 -G 0 -g 1 -b 500

###### Part III We can then use MAFFT and cons in EMBOSS to generate clean consensus sequences for the most abundant families. To identify the most abundant, I parse the cd hit results with the following: 
# grep -v excludes of the research the lines respecting the pattern specified, so beginning ("^") by ">"
# sed is used to replace a pattern identified with the pattern specified ("s:pattern:replacement")
grep -v "^>" reduced_Inpactor2_library_highmem.fasta.clstr  | sed "s:nt,:\t:" | sed "s:... at :\t:" | sed "s:/-/:\t-\t:" | sed "s:/+/:\t+\t:"| sed "s:%::" | sed "s:#:_:" | sed "s:... \*:\tNA\tNA\tNA:" > Results_clustering.txt 

####This gives a table for which the names, length and classification of each TE is listed, as well as their index in each cluster in column 1.
####We can use R to import these results
table=read.table("Results_clustering.txt")

####We create a cluster vector to reassign each TE to its cluster.
cluster=rep(0,nrow(table))
for (x in 1:nrow(table)) {
  if (table[x,1]==0){cluster[x:nrow(table)]=cluster[x:nrow(table)]+1}  ###We just add 1 to the cluster counter every time we hit a 0 in the first column.
}
table$cluster=cluster-1 ###So it is zero indexed (could have been coded before, just realized afterwards)

length(subset(table(table$cluster),table(table$cluster)>=10))
####71 putative families with more than 10 full length copies with TSD and TG-CA extremities after LTR
####43 with more than 20 full length copies
####8 with more than 100 full length copies (below)
#### "0"   "24"  "34"  "53"  "163" "184" "204" "256"

abundant=subset(table,table$cluster %in% names(subset(table(table$cluster),table(table$cluster)>=10)) & table$V2<15000)  ####We remove very long sequences corresponding to likely nested LTRs, and generate a list of 71 possible families that are abundant in the genome
write.table(abundant[,c(3,7)],file="correspondance_abundant_71_families.txt",quote=F,col.names=F,row.names=F,sep=" ")


#######End of R script

###The following script takes our correspondance table above and turns it into a bash script that will assign the sequences of each cluster to a separate file
sed "s: : Inpactor2_library.fasta >> Cluster_:" correspondance_abundant_71_families.txt | sed -e "s:>:grep -A1 :" | sed "s:_LTR:#LTR:"  > splitter.sh
bash splitter.sh


##########Part IV: Alignment of clusters with MAFFT. Script below to generate a file to submit an array job on the cluster
ls Cluster_* -d | nl -w2 > list_alignments.txt ###generates the list with a column with task ids and a column with the files to align.

#!/bin/bash
#SBATCH --mem=64GB
#SBATCH --job-name=repmod
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --array=1-71           
#SBATCH --output=repmod.%J.out
#SBATCH --error=repmod.%J.err
module load cdhit/intel/4.8.1  ####Unique to NYU cluster, to remove if not needed, or replace by local relevant module.
config=list_alignments.txt
SAMPLE=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)
mafft $SAMPLE > aligned_${SAMPLE}.fasta



#########Part V: manual curation
####At that stage comes the manual curation and reclustering of putative subfamilies (based on visual alignments of blocks). Jalview in Ubuntu is convenient since it is possible to order sequences by similarity.
####I used revseq from EMBOSS to put all sequences in the same direction.
####Then mafft if the family was split into subfamilies, then removing gaps, then consensus (general script below).
####Files are in a new folder and their names start with Cluster_... plus info about whether they come from a subfamily.

for i in Cluster*
do
mafft $i > realigned_$i  ###realigning
t_coffee -other_pg seq_reformat -in realigned_$i -action +rm_gap 80 > realigned_wo_gaps_$i   ###removing gaps
cons -sequence realigned_wo_gaps_$i -outseq consensus_${i}.fasta    ####generate consensi
done
###Note: cons might be a tad conservative, setting Ns where there are deletions + conserved sequences. Could play with -plurality.
###Maybe better to have the longest version of the TE than setting Ns where deletions are. Possible to start over from alignments.


####Using BBTools/BBMaps scripts to get an idea of the amount of Ns and rewrite files as one line fastas.
for i in consensus*;do bbstats.sh in=$i out=stats_${i};done
for i in consensus*;do reformat.sh in=$i out=oneline_${i} fastawrap=20000; done


####Now we can use TE-Aid to do a final check of abundance and quality. See https://github.com/clemgoub/TE-Aid
####Looks like there is a bug for some elements for which TE aid does not recover the full length. When it works, shows nice consensi with long repeats, protein hits in the middle.



#########Part VI: Figuring the direction of TEs (position of GAG and POL ORFs).
####Using online tool DANTE to determine the protein domains of all consensuses
##https://repeatexplorer-elixir.cerit-sc.cz/galaxy

####script takes the GFF outputted by DANTE and summarizes the direction of ORFs (+ or -)
cut -f1,7,9 DANTE_classif_TEs.gff3 | grep -v "#" | cut -f1 -d ";" > summary_structure_TEs_consensuses.txt

####This script summarizes for each consensus whether it is oriented + or -
cut -f1,7 DANTE_classif_TEs.gff3  | grep -v "#" | sort | uniq -c 

####This script takes DANTE classification into lineages. Careful, one consensus can have two classifications (they all are redundant)
grep -v "#" DANTE_classif_TEs.gff3 | cut -f1,9 | sed "s:;:\t:g" | cut -f1,3 | sort -k1 | uniq > classification_simplied_DANTE.txt

####If needed I used revseq to orientate the consensus correctly. For example:
revseq -sequence consensus_Cluster_100_subfam_1.fasta -out consensus_Cluster_100_subfam_1_RC.fasta


######Done! This gives 111 consensuses, all oriented from GAG to POL, complete and abundant in the genome.
######Next steps: RepeatMasker, MEGAnE/MELT, and GraffiTE. After GraffiTE, look at whether we retrieve a lot of elements, which ones, and maybe run INPACTOR2 on all indels detected in PacBio.



####We need then to split into subfamilies (80-80-80 rule clearly grouping distinct lineages)

###The two commands below confirm that each sequence is distant enough to be considered a subfamily
cd-hit-est -i Library_LTR-RTs_INPACTOR_2.fasta  -T 0 -M 0 -o INPACTOR_comparison_subfam.fasta -d 0 -aS 0.98 -c 0.95 -G 0 -g 1
cd-hit-est -i Library_LTR-RTs_INPACTOR_2.fasta  -T 0 -M 0 -o INPACTOR_comparison_subfam.fasta -d 0 -aS 0.9 -c 0.8 -G 0 -g 1

###We can nevertheless regroup sequences into 56 families (56 clusters). Note that we have even less than when we started. For algorithms like MELT/MEGAnE, and based on visual inspection, I would rather keep the subfamily level.
cd-hit-est -i Library_LTR-RTs_INPACTOR_2.fasta -T 0 -M 0 -o INPACTOR_comparison_fam.fasta -d 0 -aS 0.8 -c 0.8 -G 0 -g 1 -b 500



Rare elements with conflicts at the LTRs, not a big deal:
consensus_Cluster_19_subfam_2.fasta
consensus_Cluster_157_subfam_1.fasta

A lot of Ns in LTRs for the following one:
consensus_subfam12_Cluster_112







