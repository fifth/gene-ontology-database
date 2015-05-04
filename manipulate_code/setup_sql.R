# Set up connection to gene_ontology database
require(RMySQL)
con <- dbConnect(MySQL(),
                 username = 'Rmysql',
                 password = readLines('~/rmysql_pw')[[1]],
                 dbname = 'gene_ontology')

# Set working directory to flat data location
# Read tables and manipulated them into tidy formats
# Load tables into sql databases
setwd('~/Documents/Courses/zju_bioinfomatics_II/biological_databases/flat_data/')

## GO Reference
go_ref <- readLines('go_terms.obo')
new_term <- go_ref == '[Term]'
start <- which(new_term)[1] - 1
go_ref <- go_ref[-1:-start]
new_term <- new_term[-1:-start]
new_term <- cumsum(new_term)
go_ref <- tapply(go_ref, new_term, function(term) term[c(2, 4, 3, 5)])
go_ref <- matrix(unlist(go_ref), byrow = T, ncol = 4)
go_ref <- as.data.frame(go_ref, stringsAsFactors = F)
names(go_ref) <- c('go', 'go_type', 'go_name', 'go_desc')
go_ref$go <- as.numeric(gsub('[^0-9]', '', go_ref$go))
go_ref$go_type <- factor(go_ref$go_type)
go_ref$go_type <- c('B', 'C', 'M')[go_ref$go_type]
go_ref$go_name <- gsub('name:\\ ', '', go_ref$go_name)
go_ref$go_desc <- gsub('def:\\ "', '', go_ref$go_desc)
go_ref$go_desc <- gsub('\\."(.)+$', '', go_ref$go_desc)
dbWriteTable(con, 'go_term_desc', go_ref, row.names = F, append = T)

## S. cerivisiae
ceriv <- read.table('cerevisea_go.txt', header = F, sep = '\t',
                    quote = '"', comment.char = '!', as.is = T)
desc <- ceriv[, c(11, 3, 10)]
desc[, 1] <- gsub('\\|(.)+$', '', desc[, 1])
desc <- desc[!duplicated(desc), ]
names(desc) <- dbListFields(con, 's_cerevisiae_desc')
dbWriteTable(con, 's_cerevisiae_desc', desc, row.names = F, append = T)
c_id <- desc$id
go <- ceriv[, c(11, 5, 7)]
go[, 1] <- gsub('\\|(.)+$', '', go[, 1])
go <- go[!duplicated(go), ]
names(go) <- dbListFields(con, "s_cerevisiae_go")
go$go <- as.numeric(gsub('[^0-9]', '', go$go))
dbWriteTable(con, 's_cerevisiae_go', go, row.names = F, append = T)

## Sz. pombe
pombe <- read.table('pombe_go.txt', header = F, sep = '\t',
                    quote = '"', comment.char = '!', as.is = T)
desc <- pombe[, c(2, 3, 10)]
desc <- desc[!duplicated(desc), ]
names(desc) <- dbListFields(con, 'sz_pombe_desc')
dbWriteTable(con, 'sz_pombe_desc', desc, row.names = F, append = T)
p_id <- desc$id
go <- pombe[, c(2, 5, 7)]
go <- go[!duplicated(go), ]
names(go) <- dbListFields(con, "sz_pombe_go")
go$go <- as.numeric(gsub('[^0-9]', '', go$go))
dbWriteTable(con, 'sz_pombe_go', go, row.names = F, append = T)


## Yeast Homology
homology <- read.table('pombe>cerevisiae_orthologs.txt', header = F, sep = '\t',
                       comment.char = '#', as.is = T)
names(homology) <- dbListFields(con, 'yeast_homology')
homology <- homology[ homology$cerevisiae_id != 'NONE', ]
count <- stringr::str_count(homology$cerevisiae_id, '\\|') + 1
homology <- data.frame(
    pombe_id = rep(homology$pombe_id, times = count),
    cerevisiae_id = unlist(strsplit(homology$cerevisiae_id, '\\|'))
)
homology <- homology[ homology$pombe_id %in% p_id & homology$cerevisiae_id %in% c_id, ]
dbWriteTable(con, 'yeast_homology', homology, row.names = F, append = T)
