library(hash)

setwd(dir = "/home/valentin-grenet/Bureau/Données/TE_sequences/")
pwd <- getwd()
consensi <- list.files(path = "./", pattern = "consensus")

## Get trees in a hash object
trees <- hash()         # equivalent to dictionnary
for (consensus in consensi) {
  wd <- paste("./", consensus, sep = "")      # concatenate str
  setwd(wd)
  treename <- paste(consensus, ".LTR_alignment.nex.con.tre", sep = "")
  trees[[consensus]] <- ape::read.nexus(treename)
  setwd(pwd)
}

## Begin ages extraction
branch_lengths <- hash()
id_LTRs <- hash()
for (consensus in consensi) {
  tree <- trees[[consensus]]
  id_LTRs[[consensus]] <- tree$tip.label
  ## first get the node numbers of the tips
  nodes<-sapply(tree$tip.label, function(x,y) which(y==x),y=tree$tip.label)
  ## then get the edge lengths for those nodes
  branch_lengths[[consensus]]<-setNames(tree$edge.length[sapply(nodes,
    function(x,y) which(y==x),y=tree$edge[,2])],names(nodes))
}

## Write ages in tsv files
table <- data.frame()
for (consensus in consensi) {
  for (LTR in id_LTRs[[consensus]]) {
    line <- data.frame(consensus, LTR, branch_lengths[[consensus]][[LTR]])
    table <- rbind(table, line)
  }
}
colnames(table) <- c("consensus","id LTR", "branch length")
namefile <- paste("Phoenix_dactylifera.LTR_ages.csv", sep = "")
write.csv(table, file = namefile, row.names = FALSE)
