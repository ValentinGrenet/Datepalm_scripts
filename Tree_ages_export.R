library(hash)

setwd(dir = "/home/valentin-grenet/Bureau/Données/TE_sequences/")
pwd <- getwd()
consensi <- list.files(path = "./", pattern = "consensus")

## Get trees in a hash object
trees <- hash()         # equivalent to dictionnary
for (consensus in consensi) {
  wd <- paste("./", consensus, "/Repeat_TEs", sep = "")      # concatenate str
  setwd(wd)
  treename <- paste(consensus, ".LTR_trimmed.nex.con.tre", sep = "")
  trees[[consensus]] <- ape::read.nexus(treename)
  setwd(pwd)
}

## Begin ages extraction
id_LTRs <- hash()
branch_lengths <- hash()
age_LTRs <- hash()
for (consensus in consensi) {
  tree <- trees[[consensus]]
  id_LTRs[[consensus]] <- tree$tip.label
  ## first get the node numbers of the tips
  nodes<-sapply(tree$tip.label, function(x,y) which(y==x),y=tree$tip.label)
  ## then get the edge lengths for those nodes
  branch_lengths[[consensus]] <- setNames(tree$edge.length[sapply(nodes,
    function(x,y) which(y==x),y=tree$edge[,2])],names(nodes))
  age_LTRs[[consensus]] <- branch_lengths[[consensus]] / 2.61E-3
}

## Write all ages in tsv files
final_tsv <- data.frame(consensus, lineage_table[[consensus]], family_table[[consensus]], LTR, branch_lengths[[consensus]][[LTR]], age)
colnames(final_tsv) <- c("consensus","lineage","family","LTR","median length","mean age")
namefile <- paste("Phoenix_dactilfera.LTR_ages.tsv", sep = "")
write.table(final_tsv, file = namefile, row.names = FALSE, sep = "\t", dec = ",")
for (consensus in consensi) {
  table <- data.frame()
  print(consensus)
  for (LTR in id_LTRs[[consensus]]) {
    age <- branch_lengths[[consensus]][[LTR]]/2.61E-3       # obtained with Gaut et al., 1996 : Substitution rate comparisons between grasses and palms
    line <- data.frame(consensus, lineage_table[[consensus]], family_table[[consensus]], LTR, branch_lengths[[consensus]][[LTR]], age)
    table <- rbind(table, line)
  }
  write.table(table, file = namefile, row.names = FALSE, col.names = FALSE, append = TRUE,sep = "\t", dec = ",")
}

## Write median/mean ages in tsv files
final_csv <- data.frame()
for (consensus in consensi) {
  table <- data.frame()
  for (LTR in id_LTRs[[consensus]]) {
    line <- data.frame(consensus, LTR, branch_lengths[[consensus]][[LTR]])
    table <- rbind(table, line)
  }
  mean_consensus <- mean(table$branch_lengths..consensus....LTR..)
  age_consensus <- mean_consensus/2.61E-3       # obtained with Gaut et al., 1996 : Substitution rate comparisons between grasses and palms
  new_mean <- data.frame(consensus, mean_consensus, age_consensus)
  final_csv <- rbind(final_csv, new_mean)
}
colnames(table) <- c("consensus","median length", "mean age")
namefile <- "Phoenix_dactylifera.LTR_ages_mean.tsv"
write.table(final_csv, file = namefile, row.names = FALSE, sep = "\t", dec = ",")



## Classifications
setwd(dir = "/home/valentin-grenet/Bureau/Données/")
classif_tsv <- read.table("Phoenix_dactylifera.LTR_ages_median.tsv", header = TRUE)
lineage_table <- hash()
family_table <- hash()
for (i in 1:nrow(classif_tsv)) {
  line <- classif_tsv[i,]
  print(line)
  lineage_table[[line$consensus]] = line$lineage
  family_table[[line$consensus]] = line$family
}
final_tsv <- data.frame()
for (consensus in consensi) {
  for (LTR in id_LTRs[[consensus]]) {
    new_line <- data.frame(consensus, lineage_table[[consensus]], family_table[[consensus]], 
                           branch_lengths[[consensus]][[LTR]], age_LTRs[[consensus]][[LTR]])
    final_tsv <- rbind(final_tsv, new_line)
  }
}
colnames(final_tsv) <- c("consensus","lineage","family","branch_length", "estimated_age")
namefile <- "Phoenix_dactylifera.LTR_all_ages.tsv"
write.table(final_tsv, file = namefile, row.names = FALSE, sep = "\t", dec = ",")

## Write boxplot ages
family_data <- subset(final_tsv, family == "SIRE")
boxplot(family_data$consensus~family_data$estimated_age)


## Calculate young LTRs proportion

# Lire le fichier avec les valeurs séparées par des tabulations et les nombres décimaux avec des virgules
file_path <- "Phoenix_dactilfera.LTR_ages.tsv"
data <- read.csv(file_path, sep = "\t", dec = ",", header = TRUE)

# Charger les bibliothèques nécessaires
library(dplyr)
library(ggplot2)

# Ajouter une colonne pour indiquer si mean age < 1
data <- data %>% mutate(mean_age_below_1 = ifelse(mean.age < 3, 1, 0))

# Ajouter une colonne pour les couleurs
data <- data_proportions %>% mutate(color = ifelse(lineage == "Copia", "orange", ifelse(lineage == "Gypsy", "yellow", "grey")))

# Calculer la proportion pour chaque famille et le nombre d'éléments
family_stats <- data %>% 
  group_by(family, color) %>% 
  summarise(
    proportion_below_1 = mean(mean_age_below_1),
    count = n()
  ) %>%
  arrange(count)  # Trier par nombre d'éléments

# Afficher les résultats
print(family_stats)

# Créer le graphique
ggplot(family_stats, aes(x = reorder(family, count), y = proportion_below_1, fill = color)) +
  geom_bar(stat = "identity") +
  geom_line(aes(y = count / max(count), group = 1, color = "Nombre d'éléments"), size = 1) +
  scale_y_continuous(
    name = "Proportion de LTR avec un âge d'insertion < 3 Ma",
    sec.axis = sec_axis(~ . * max(family_stats$count), name = "Nombre d'éléments")
  ) +
  scale_fill_manual(values = c("orange", "yellow", "grey")) +
  scale_color_manual(values = c("Nombre d'éléments" = "red")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(
    title = "Proportion de mean age < 1 et nombre d'éléments par famille",
    x = "Famille",
    y = "Proportion de mean age < 1"
  ) +
  theme(legend.position = "top") +
  guides(fill = "none")
