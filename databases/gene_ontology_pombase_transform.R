# load Pombase GO data and save as .RData

pombe.go <- read.table('./GO.pombase',
                       header = F,
                       sep = '\t',
                       quote = '"',
                       comment.char = '!')
pombe.go <- subset(pombe.go, select = c(-V1, -V4, -V13, -V14, -V17))
names(pombe.go) <- c('Gene_ID', 'Gene_Name',
                     'GO_ID', 'GO_Reference', 'GO_Evidence', 'GO_WithFrom',
                     'GO_Type', 'Gene_Product', 'Gene_Synonyms', 'Gene_Coding',
                     'Info_Sourse', 'GO_Annotation')
pombe.go[pombe.go == ''] <- NA
save.image("./gene_ontology_pombase.RData")