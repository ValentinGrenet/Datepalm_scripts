# Charger les bibliothèques nécessaires
library(ggplot2)
library(dplyr)
library(tidyr)

# Charger les données
file_path <- "/home/valentin-grenet/Bureau/Données/Phoenix_dactylifera.all_summary_classif.tsv"
te_data <- read.delim(file_path, header = TRUE, sep = "\t", dec = ".", na.strings = "NA")

# Prétraitement des données
te_data$distance_gene <- abs(te_data$distance_gene)
te_data <- te_data %>% mutate(distance_gene = if_else(strand_gene == ".", NA_real_, distance_gene))
te_data <- te_data %>% filter(!(!(is.na(percentage_id)) & overlapping == "VRAI"))
te_data <- te_data %>% select(-percentage_id)
# Filtrer les données pour enlever les lignes avec une classification donnée
te_data <- te_data %>% filter(type != "shrunked")
te_data <- te_data %>% filter(type != "fragmented")
te_data <- te_data %>% filter(type != "paired")
te_data <- te_data %>% filter(type != "single")

te_data_gypsy <- te_data %>% filter(superfamily == "Gypsy")
te_data_copia <- te_data %>% filter(superfamily == "Copia")
te_data_complete <- te_data %>% filter(type == "complete")
te_data_solo <- te_data %>% filter(type == "solo")
te_data_gypsy_complete <- te_data_gypsy %>% filter(type == "complete")
te_data_copia_complete <- te_data_copia %>% filter(type == "complete")

te_data_abundant <- te_data %>% filter(family == "SIRE_A" | family == "SIRE_B" | family == "Angela_A" | family == "Angela_B" | family == "Angela_C" | family == "Angela_D" | family == "Angela_E")
# te_data_abundant <- te_data %>% filter(family == "Retand_A" | family == "Retand_B" | family == "Retand_C")
# te_data_abundant <- te_data %>% filter(family == "SIRE" | family == "Angela" | family == "Tat/Retand" | family == "CRM" | family == "Tork")
# te_data_abundant <- te_data %>% filter(family == "Athila" | family == "CRM" | family == "Galadriel" | family == "Ikeros" | family == "Ivana" | family == "Reina" | family == "TAR" | family == "Tekay" | family == "Tork")
# te_data_abundant <- te_data %>% filter(family == "Angela" | family == "SIRE")
te_data_abundant_complete <- te_data_abundant %>% filter(type == "complete")

# Get the list of families
families <- unique(te_data$family)
# Get the comparison based on solo vs complets
classifications <- unique(te_data$type)

for (family_test in families) {
  print(family_test)
  group_data <- te_data_solo %>% filter(family == family_test)
  print(summary(group_data$insertion_age))
}

# Variables quantitatives à analyser en violin plots
violinplot_vars <- c("length", "insertion_age", "GC_content", "CHH_mean", "CHH_density", "CHG_mean",  "CHG_density", "CpG_mean", "CpG_density", "distance_gene")


### Comparaison classique : Copia vs Gypsy et solo vs complets

# Créer les barplots pour chaque variable quantitative
create_barplot <- function(var_name, data_name) {
  ggplot(data_name, aes_string(x = "type", y = var_name, fill = "superfamily")) +
    geom_boxplot() +
    labs(title = paste("Variation de", var_name),
         x = "Famille d'éléments transposables", y = var_name, fill = "Superfamille") +
    facet_wrap(~ superfamily, scales = "free_x") +
    theme(
      panel.background = element_rect(fill = "white"),
      panel.grid.major.y = element_line(color = "grey40"),
      panel.grid.minor.y = element_line(color = "grey40", linetype = "dashed"),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      axis.line = element_line(color = "black"),
      axis.text = element_text(size = 20), # Taille du texte des axes
      axis.title = element_text(size = 20), # Taille du texte des axes
      strip.text = element_text(size = 30)
    )}

# Fonction pour créer des violin plots
create_violinplot <- function(var_name, data_name) {
  ggplot(data_name, aes_string(x = "type", y = var_name, fill = "superfamily")) +
    geom_violin(trim = FALSE) +
    scale_y_log10() +  # Appliquer l'échelle logarithmique à l'axe des ordonnées
    labs(title = paste("Variation de", var_name),
         x = "Famille d'éléments transposables", y = var_name, fill = "Superfamille") +
    facet_wrap(~ superfamily, scales = "free_x") +
    theme(
      panel.background = element_rect(fill = "white"),
      panel.grid.major.y = element_line(color = "grey40"),
      panel.grid.minor.y = element_line(color = "grey40", linetype = "dashed"),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      axis.line = element_line(color = "black"),
      axis.text = element_text(size = 20), # Taille du texte des axes
      axis.title = element_text(size = 20), # Taille du texte des axes
      strip.text = element_text(size = 30)
    )
}

# Créer les violin plots pour chaque variable quantitative
for (var in violinplot_vars) {
  print(create_barplot(var, te_data))
  print(create_violinplot(var, te_data))
}
print(create_violinplot("insertion_age", te_data))
print(create_violinplot("distance_gene", te_data_distance))
print(create_violinplot("insertion_age", te_data_copia))
print(create_violinplot("insertion_age", te_data_gypsy))
print(create_violinplot("GC_content", te_data))
print(create_violinplot("GC_content", te_data))



### 2e comparaison : les valeurs de Gyspsy sont assez étendues, donc comparaison entre les familles Gypsy avec solo vs complet


# Créer les barplots pour chaque variable quantitative
create_barplot <- function(var_name, data_name) {
  ggplot(data_name, aes_string(x = "type", y = var_name, fill = "family")) +
    geom_boxplot() +
    scale_y_log10() +  # Appliquer l'échelle logarithmique à l'axe des ordonnées
    labs(title = paste("Variation de", var_name, "pour Gypsy"),
         x = "Type d'éléments transposables", y = var_name, fill = "Famille") +
    facet_wrap(~ family, scales = "free_x") +
    theme(
      panel.background = element_rect(fill = "white"),
      panel.grid.major.y = element_line(color = "grey40"),
      panel.grid.minor.y = element_line(color = "grey40", linetype = "dashed"),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      axis.line = element_line(color = "black"),
      axis.text = element_text(size = 20), # Taille du texte des axes
      axis.title = element_text(size = 20), # Taille du texte des axes
      strip.text = element_text(size = 30)
    )}

# Fonction pour créer des violin plots
create_violinplot <- function(var_name, data_name) {
  ggplot(data_name, aes_string(x = "type", y = var_name, fill = "family")) +
    geom_violin(trim = FALSE) +
    scale_y_log10() +  # Appliquer l'échelle logarithmique à l'axe des ordonnées
    labs(title = paste("Variation de", var_name, "pour Gypsy"),
         x = "Type d'éléments transposables", y = var_name, fill = "Famille") +
    facet_wrap(~ family, scales = "free_x") +
    theme(
      panel.background = element_rect(fill = "white"),
      panel.grid.major.y = element_line(color = "grey40"),
      panel.grid.minor.y = element_line(color = "grey40", linetype = "dashed"),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      axis.line = element_line(color = "black"),
      axis.text = element_text(size = 20), # Taille du texte des axes
      axis.title = element_text(size = 20), # Taille du texte des axes
      strip.text = element_text(size = 30)
    )
}

# Créer les violin plots pour chaque variable quantitative
for (var in violinplot_vars) {
  print(create_barplot(var, te_data_gypsy))
  print(create_violinplot(var, te_data_gypsy))
}
print(create_barplot("insertion_age", te_data_gypsy))
print(create_violinplot("distance_gene", te_data_distance_gypsy))
print(create_barplot("GC_content", te_data_copia))
print(create_barplot("GC_content", te_data_gypsy))

# Effectuer l'ANOVA
result <- aov(Score ~ Groupe, data = data)

# Résumer les résultats
summary(result)

### 3e comparaison : identifier si la différence Tat_Retand se fait sur tous les TEs, ou si une tendance s'observe avec l'âge par ex

te_data_gypsy_complete <- te_data_gypsy %>% filter(type == "complete")
te_data_distance_gypsy_complete <- te_data_distance_gypsy %>% filter(type == "complete")

# Variables quantitatives à analyser en barplots
scatterplot_vars <- c("length", "GC_content", "CHH_mean", "CHH_density", "CHG_mean",  "CHG_density", "CpG_mean", "CpG_density", "distance_gene")

# Créer le scatter plot
create_scatterplot <- function(var_name, data_name) {
  ggplot(data_name, aes_string(x = "insertion_age", y = var_name, color = "family")) +
  geom_point(size = 3, alpha = 0.7) +
  labs(title = paste("Scatter plot de l'âge d'insertion en fonction de ",var_name, "pour Gypsy"),
       x = "Âge d'insertion",
       y = var_name,
       color = "Classification") +
  theme_minimal() +
  theme(
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 14),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12)
  ) }

for (var in scatterplot_vars) {
  print(create_scatterplot(var, te_data_gypsy_complete))
}
print(create_scatterplot("GC_content", te_data_complete))



# # Effectuer les tests de Wilcoxon pour comparer les classifications
# wilcoxon_test <- function(group1, group2) {
#   group1_data <- te_data_10 %>% filter(type == group1)
#   group2_data <- te_data_10 %>% filter(type == group2)
#   test_result <- wilcox.test(group1_data$distance_gene, group2_data$distance_gene)
#   return(test_result)
# }
# 
# # Comparer les classifications "complete", "solo" et "single"
# complet_vs_solo <- wilcoxon_test("complete", "solo")
# complet_vs_single <- wilcoxon_test("complete", "single")
# solo_vs_single <- wilcoxon_test("solo", "single")
# 
# # Afficher les résultats des tests
# cat("Résultat du test de Wilcoxon entre 'complet' et 'solo':\n")
# print(complet_vs_solo)
# cat("\nRésultat du test de Wilcoxon entre 'complet' et 'single':\n")
# print(complet_vs_single)
# cat("\nRésultat du test de Wilcoxon entre 'solo' et 'single':\n")
# print(solo_vs_single)


### 4e comparaison : tester la significativité des différences entre Tat/Retand et le reste des Gypsy

wilcoxon_test <- function(family_test) {
  data_test <- te_data %>% filter(type == "complete")
  group1_data <- data_test %>% filter(family != family_test)
  group2_data <- data_test %>% filter(family == family_test)
  summary(group2_data$CHG_mean)
  test_result <- wilcox.test(group1_data$CHG_mean, group2_data$CHG_mean)
  return(test_result)
}

wilcoxon_test <- function(family_test) {
  data_test <- te_data %>% filter(type == "complete")
  group1_data <- data_test %>% filter(superfamily != family_test)
  group2_data <- data_test %>% filter(superfamily == family_test)
  summary(group2_data$CpG_mean)
  test_result <- wilcox.test(group1_data$CpG_mean, group2_data$CpG_mean)
  return(test_result)
}

for (family in unique(te_data$family)) {
  print(family)
  print(wilcoxon_test(family)) }
print(wilcoxon_test("Tat/Retand"))
print(wilcoxon_test("Gypsy"))

summary(te_data$CHG_mean)

anova_result <- aov(GC_content ~ superfamily, data = te_data_complete)
print(anova_result)
summary(anova_result)
ks.test(te_data_gypsy_complete$GC_content, "pnorm", 
        mean = mean(te_data_gypsy_complete$GC_content, na.rm = TRUE), 
        sd = sd(te_data_gypsy_complete$GC_content, na.rm = TRUE))

### Cinquième comparaison

te_data_gypsy_retand <- te_data_gypsy %>% filter(family == "Tat/Retand")

cor_test <- function(family_test) {
  data_test <- te_data_distance_gypsy %>% filter(type == "complete")
  group_data <- data_test %>% filter(family == family_test)
  test_result <- cor.test(group_data$insertion_age, group_data$distance_gene)
  return(test_result)
}

for (family in unique(te_data_distance_gypsy$family)) {
  print(family)
  print(cor_test(family)) }



### Sixième comparaison

te_data_gypsy_complete <- te_data_distance_gypsy %>% filter(type == "complete")

# Variables quantitatives à analyser en barplots
scatterplot_vars <- c("length", "insertion_age", "CHH_mean", "CHH_density", "CHG_mean",  "CHG_density", "CpG_mean", "CpG_density", "distance_gene")

# Créer le scatter plot
create_scatterplot <- function(var_name, data_name) {
  ggplot(data_name, aes_string(x = "GC_content", y = var_name, color = "family")) +
    geom_point(size = 3, alpha = 0.7) +
    labs(title = paste("Scatter plot du contenu GC en fonction de ",var_name, "pour Gypsy"),
         x = "GC content",
         y = var_name,
         color = "Classification") +
    theme_minimal() +
    theme(
      axis.text = element_text(size = 12),
      axis.title = element_text(size = 14),
      legend.title = element_text(size = 14),
      legend.text = element_text(size = 12)
    ) }

for (var in scatterplot_vars) {
  print(create_scatterplot(var, te_data_gypsy_complete))
}

cor_test <- function() {
  data_test <- te_data_gypsy %>% filter(type == "complete")
  test_result <- cor.test(data_test$insertion_age, data_test$distance_gene)
  return(test_result)
}

print(cor_test())



### 7e comparaison : Comparaison entre Copia

# Créer les barplots pour chaque variable quantitative
create_barplot <- function(var_name, data_name) {
  ggplot(data_name, aes_string(x = "family", y = var_name, fill = "superfamily")) +
    geom_boxplot() +
    scale_y_log10() +  # Appliquer l'échelle logarithmique à l'axe des ordonnées
    labs(title = paste("Variation de", var_name),
         x = "Famille", y = var_name, fill = "Superfamille") +
    facet_wrap(~ superfamily, scales = "free_x") +
    theme(
      panel.background = element_rect(fill = "white"),
      panel.grid.major.y = element_line(color = "grey40"),
      panel.grid.minor.y = element_line(color = "grey40", linetype = "dashed"),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      axis.line = element_line(color = "black"),
      axis.text = element_text(size = 20), # Taille du texte des axes
      axis.title = element_text(size = 20), # Taille du texte des axes
      strip.text = element_text(size = 30)
    )}

# Fonction pour créer des violin plots
create_violinplot <- function(var_name, data_name) {
  ggplot(data_name, aes_string(x = "family", y = var_name, fill = "superfamily")) +
    geom_violin(trim = FALSE) +
    # scale_y_log10() +  # Appliquer l'échelle logarithmique à l'axe des ordonnées
    labs(title = paste("Variation de", var_name, "pour Gypsy"),
         x = "Famille d'éléments transposables", y = var_name, fill = "Famille") +
    facet_wrap(~ superfamily, scales = "free_x") +
    theme(
      panel.background = element_rect(fill = "white"),
      panel.grid.major.y = element_line(color = "grey40"),
      panel.grid.minor.y = element_line(color = "grey40", linetype = "dashed"),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      axis.line = element_line(color = "black"),
      axis.text = element_text(size = 20), # Taille du texte des axes
      axis.title = element_text(size = 20), # Taille du texte des axes
      strip.text = element_text(size = 30)
    )
}

# Créer les violin plots pour chaque variable quantitative
for (var in violinplot_vars) {
  print(create_violinplot(var, te_data))
}
print(create_barplot("GC_content", te_data))
print(create_violinplot("GC_content", te_data_complete))
print(create_violinplot("CpG_mean", te_data_complete))


### Scatterplots pour Copia

te_data_copia_complete <- te_data_copia %>% filter(type == "complete")
# Variables quantitatives à analyser en barplots
scatterplot_vars <- c("length", "GC_content", "CHH_mean", "CHH_density", "CHG_mean",  "CHG_density", "CpG_mean", "CpG_density", "distance_gene")

# Créer le scatter plot
create_scatterplot <- function(var_name, data_name) {
  ggplot(data_name, aes_string(x = "insertion_age", y = var_name, color = "family")) +
    geom_point(size = 3, alpha = 0.7) +
    labs(title = paste("Scatter plot de l'âge d'insertion en fonction de ",var_name, "pour Copia"),
         x = "Âge d'insertion",
         y = var_name,
         color = "Classification") +
    theme_minimal() +
    theme(
      axis.text = element_text(size = 12),
      axis.title = element_text(size = 14),
      legend.title = element_text(size = 14),
      legend.text = element_text(size = 12)
    ) }

for (var in scatterplot_vars) {
  print(create_scatterplot(var, te_data_copia_complete))
}




# Variables quantitatives à analyser en barplots
scatterplot_vars <- c("length", "insertion_age", "CHH_mean", "CHH_density", "CHG_mean",  "CHG_density", "CpG_mean", "CpG_density", "distance_gene")

# Créer le scatter plot
create_scatterplot <- function(var_name, data_name) {
  ggplot(data_name, aes_string(x = "GC_content", y = var_name, color = "family")) +
    geom_point(size = 3, alpha = 0.7) +
    labs(title = paste("Scatter plot du contenu GC en fonction de ",var_name, "pour Copia"),
         x = "GC content",
         y = var_name,
         color = "Classification") +
    theme_minimal() +
    theme(
      axis.text = element_text(size = 12),
      axis.title = element_text(size = 14),
      legend.title = element_text(size = 14),
      legend.text = element_text(size = 12)
    ) }

for (var in scatterplot_vars) {
  print(create_scatterplot(var, te_data_copia_complete))
}



te_data_complete <- te_data %>% filter(type == "complete")
# Variables quantitatives à analyser en barplots
scatterplot_vars <- c("length", "insertion_age", "CHH_mean", "CHH_density", "CHG_mean",  "CHG_density", "CpG_mean", "CpG_density", "distance_gene")

# Créer le scatter plot
create_scatterplot <- function(var_name, data_name) {
  ggplot(data_name, aes_string(x = "GC_content", y = var_name, color = "family")) +
    geom_point(size = 3, alpha = 0.7) +
    labs(title = paste("Scatter plot du contenu GC en fonction de ",var_name),
         x = "GC content",
         y = var_name,
         color = "Classification") +
    theme_minimal() +
    theme(
      axis.text = element_text(size = 12),
      axis.title = element_text(size = 14),
      legend.title = element_text(size = 14),
      legend.text = element_text(size = 12)
    ) }

for (var in scatterplot_vars) {
  print(create_scatterplot(var, te_data_complete))
}



cor_test <- function(family_test) {
  data_test <- te_data_gypsy %>% filter(type == "complete")
  group_data <- data_test %>% filter(family == family_test)
  test_result <- cor.test(group_data$insertion_age, group_data$distance_gene)
  return(test_result)
}

for (family in unique(te_data_gypsy$family)) {
  print(family)
  print(cor_test(family)) }







#### Nouvelles classifications : subdivisions des Tat/Retand

# Charger les bibliothèques nécessaires
library(ggplot2)
library(dplyr)
library(tidyr)
library(ggpubr)

# Charger les données
file_path <- "/home/valentin-grenet/Bureau/Données/Phoenix_dactylifera.all_summary_Retand.tsv"
te_data <- read.delim(file_path, header = TRUE, sep = "\t", dec = ".", na.strings = "NA")

# Prétraitement des données
te_data$distance_gene <- abs(te_data$distance_gene)
te_data <- te_data %>% mutate(distance_gene = if_else(strand_gene == ".", NA_real_, distance_gene))
te_data <- te_data %>% filter(!(!(is.na(percentage_id)) & overlapping == "VRAI"))
te_data <- te_data %>% select(-percentage_id)
# Filtrer les données pour enlever les lignes avec une classification donnée
te_data <- te_data %>% filter(type != "shrunked")
te_data <- te_data %>% filter(type != "fragmented")
te_data <- te_data %>% filter(type != "paired")

te_data_gypsy <- te_data %>% filter(superfamily == "Gypsy")
te_data_copia <- te_data %>% filter(superfamily == "Copia")
te_data_complete <- te_data %>% filter(type == "complete")
te_data_gypsy_complete <- te_data_gypsy %>% filter(type == "complete")
te_data_copia_complete <- te_data_copia %>% filter(type == "complete")


# Variables quantitatives à analyser en barplots
scatterplot_vars <- c("GC_content", "CHH_mean", "CHG_mean", "CpG_mean")

# Créer le scatter plot
create_scatterplot <- function(var_name, data_name) {
  p <- ggplot(data_name, aes_string(x = "insertion_age", y = var_name, color = "family")) +
    geom_point(size = 3, alpha = 0.7) +
    geom_smooth(method = "lm", se = FALSE, aes(group = type), colour = "black") +  # Droites de régression sans intervalle de confiance
    geom_smooth(method = "lm", se = FALSE, aes(group = family)) +
    labs(title = paste("Scatter plot de l'âge d'insertion en fonction de ",var_name),
         x = "Insertion_age",
         y = var_name,
         color = "Classification") +
    theme_minimal() +
    theme(
      axis.text = element_text(size = 20),
      axis.title = element_text(size = 20),
      legend.title = element_text(size = 20),
      legend.text = element_text(size = 20)
    )
  print(p)
  }

for (var in scatterplot_vars) {
  create_scatterplot(var, te_data_abundant_complete)
}
create_scatterplot("GC_content", te_data_abundant_complete)


cor_test <- function(family_test) {
  data_test <- te_data_complete
  group_data <- data_test %>% filter(family == family_test)
  test_result <- cor.test(group_data$insertion_age, group_data$GC_content)
  return(test_result)
}

for (family in unique(families)) {
  print(family)
  print(cor_test(family)) }




# regarder par consensus chez tat/Retand




# corrélation CHH avec âge



# regarder la position chromosomique par comptage




# Créer un histogramme pour chaque chromosome
chromosomes <- c("chr1", "chr2", "chr3", "chr4", "chr5", "chr6", "chr7", "chr8", "chr9", "chr10", "chr11", "chr12", "chr13", "chr14", "chr15", "chr16", "chr17", "chr18")
families_coverage = c("CRM", "Angela", "Tork", "SIRE", "Retand", "Reina", "Tekay", "Galadriel", "Athila", "Ivana", "TAR", "Ikeros")

for (family in families_coverage) {
  # Lire les données de couverture
  data_coverage <- read.table(paste("/home/valentin-grenet/Bureau/Données/Families_coverage/", family, ".bed", sep = ""), sep="\t", header=FALSE, col.names=c("chr", "start", "end", "coverage"))
  # Ajouter une colonne pour la position centrale de chaque fenêtre
  data_coverage$midpoint <- (data_coverage$start + data_coverage$end) / 2
  
  for (chrom in c("chr1")) {
    chr_data <- subset(data_coverage, chr == chrom)
    
    # Créer la courbe
    p <- ggplot(chr_data, aes(x=midpoint, y=coverage)) +
      geom_line(color="blue") +
      labs(title=paste("Courbe de la couverture", family, "pour", chrom),
           x="Position dans le génome",
           y="Pourcentage de couverture") +
      theme_minimal()
    
    # Sauvegarder l'histogramme dans un fichier
    print(p)
  } 
}

data_coverage <- read.table("/home/valentin-grenet/Bureau/Données/Families_coverage/All_coordinates.bed", sep="\t", header=FALSE, col.names=c("chr", "start", "end", "coverage"))
data_coverage$midpoint <- (data_coverage$start + data_coverage$end) / 2

for (chrom in c("chr2")) {
  chr_data <- subset(data_coverage, chr == chrom)
  
  # Créer la courbe
  p_global <- ggplot(chr_data, aes(x=midpoint, y=coverage)) +
    geom_line(color="blue") +
    labs(title=paste("Courbe de la couverture pour", chrom),
         x="Position dans le génome",
         y="Pourcentage de couverture") +
    theme_minimal()
  
  # Sauvegarder l'histogramme dans un fichier
  print(p_global)
} 

print("Histogrammes créés et sauvegardés.")



# faire un scatter plot CG / age d'insertion
# comparer distance gene vs age
# essayer des courbes avec l'âge vs autre chose
# violin plot ou echelle log pour les ages

# 2 sections : propriétés intrinsèques et différences de niches
# relire stirtt