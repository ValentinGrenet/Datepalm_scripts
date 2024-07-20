# Load necessary libraries
library(ggplot2)
library(dplyr)

# Read the data
setwd(dir = "/home/valentin-grenet/Bureau/Données/")
pwd <- getwd()
consensi <- list.files(path = "./", pattern = "consensus")
data <- read.csv("Phoenix_dactylifera.LTR_all_ages.tsv", sep="\t")

# Convert the 'estimated_age' column to numeric (replacing commas with dots)
data$estimated_age <- as.numeric(gsub(",", ".", data$estimated_age))

# Get the list of families
families <- unique(data$family)

# Generate boxplots for each family
for (family in families) {
  # Filter the data for the current family
  family_data <- data %>% filter(family == !!family)
  
  # Create the boxplot
  p <- ggplot(family_data, aes(x = consensus, y = estimated_age)) +
    geom_boxplot() +
    labs(title = paste("Boxplot for Family:", family), x = "Consensus", y = "Estimated Age") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  print(p)
  
  ## Details :
  # geom_boxplot() -> used to add a boxplot in the figure
  # labs() -> define plot labels, like the title, the x and y legends
  # theme() -> personnalise graph apparence
  
  # Save the plot
  ggsave(filename = paste0("boxplot_", family, ".png"), plot = p, width = 10, height = 6)
}

# for median ages for Copia and Gypsy

# Load necessary libraries
library(ggplot2)
library(dplyr)

# Read the data
setwd(dir = "/home/valentin-grenet/Bureau/Données")
pwd <- getwd()
consensi <- list.files(path = "./", pattern = "consensus")
data <- read.csv("Phoenix_dactylifera.LTR_ages_median.tsv", sep="\t")

# Convert the 'estimated_age' column to numeric (replacing commas with dots)
data$age_consensus <- as.numeric(gsub(",", ".", data$age_consensus))

# Get the list of families
lineage <- unique(data$family)

# Create the boxplot
p <- ggplot(data, aes(x = data$family, y = age_consensus, fill = lineage)) +
  geom_boxplot() +
  labs(y = "Estimation de l'âge médian d'insertion (en My)") +
  scale_fill_manual(values = c("Copia" = "orange", "Gypsy" = "yellow")) +
  facet_wrap(~ lineage, scales = "free_x") +
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
print(p)
  
    ## Details :
  # geom_boxplot() -> used to add a boxplot in the figure
  # labs() -> define plot labels, like the title, the x and y legends
  # theme() -> personnalise graph apparence
  
# Save the plot
ggsave(filename = paste0("boxplot_", family, ".png"), plot = p, width = 10, height = 6)
