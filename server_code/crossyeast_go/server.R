require(shiny)
require(RMySQL)
require(knitr)

goNum2Char <- function(go) {
    paste('GO: ', 
          sapply(go, function(n) 
              paste(rep('0', 6 - floor(log10(n))),
                    collapse = '')),
          go, sep = '')
}

shinyServer(function(input, output, session) {
    
    # set logfile
    sink(paste('~/shinylog/gene_ontology/', Sys.Date(), sep = ''),
         append = T, type = 'output')
    
    # set connection to db
    con <- dbConnect(MySQL(),
                     username = 'Rmysql',
                     password = readLines('~/rmysql_pw')[[1]],
                     dbname = 'gene_ontology')
    cat('connection: OK\n\n')

    # clear output pages when navbar is reactivated
    observeEvent(input$nav, {
        output$q_go_out <- renderText('')
        output$q_og_out <- renderText('')
        output$q_gg_out <- renderText('')
    })
    
    # response gene-ontology query
    observeEvent(input$q_go_submit, {
        # get input
        gene_list <- strsplit(input$q_go_gene_list, '[,\\ \n\t]+')[[1]]
        species <- ifelse(input$q_go_taxi == 'Sz. pombe',
                          'sz_pombe', 's_cerevisiae')
        go_type <- input$q_go_namespace
        go_signif <- input$q_go_evidence
        operation <- input$q_go_operation
        
        # output log
        cat('Gene->Ontology Query Reseived:\n')
        cat('gene list:', paste(gene_list, collapse = ', '), '\n')
        cat('species:', species, '\n')
        cat('go namespace:', paste(go_type, collapse = ', '), '\n')
        cat('go evidence:', go_signif, '\n')
        cat('operation:', operation, '\n\n')
        
        # format query elements
        db_desc <- paste(species, '_desc', sep = '')
        db_onto <- paste(species, '_go', sep = '')
        gene_list <- paste('("',
                           paste(gene_list, collapse = '", "'),
                           '")', sep = '')
        go_signif <- ifelse(go_signif == 'experimental only',
                            'where\n      go_signif in ("EXP", "IDA", "IPI", "IMP", "IGI", "IEP")\n',
                            '')
        revert <- c('B', 'M', 'C')
        names(revert) <- c('biological process', 'molecular function', 'cellular component')
        go_type <- paste('("',
                         paste(revert[go_type], collapse = '", "'),
                         '")', sep = '')
        
        # knit up query
        qry_text <- paste(unlist(readLines('query_g_o.sql')), collapse = '\n')
        qry_text <- gsub('\\{db_desc\\}', db_desc, qry_text)
        qry_text <- gsub('\\{db_onto\\}', db_onto, qry_text)
        qry_text <- gsub('\\{gene_list\\}', gene_list, qry_text)
        qry_text <- gsub('\\{go_signif\\}', go_signif, qry_text)
        qry_text <- gsub('\\{go_type\\}', go_type, qry_text)
        cat('formated query:\n', qry_text, '\n\n', sep = '')
        
        qry <- dbGetQuery(con, qry_text)
        qry$go_type <- sapply(qry$go_type, switch,
                              B = 'Biological Process',
                              M = 'Molecular Function',
                              C = 'Cellular Component')
        labels <- qry$gene_label
        labels <- labels[!duplicated(labels)]
        
        # knit up output html
        if (nrow(qry)) {
            if (operation == 'list separately') {
                text <- character(length(labels))
                for (i in 1:length(labels)) {
                    g <- labels[i]
                    
                    sub <- qry[qry$gene_label == g, ]
                    if (nrow(sub)) {
                        g_desc <- sub$gene_desc[1]
                        text[i] <- paste(text[i],
                                      '<p><span style="font-size:130%;"><strong><i>', g, '</i></strong><br></span>\n',
                                      '<strong>Gene Desciption:</strong> ', g_desc, '</p>\n',
                                      sep = '')
                        dup <- duplicated(sub$go)
                        evi <- tapply(sub$go_signif, sub$go, paste, collapse = ' | ')
                        sub <- sub[!dup, ]
                        sub$go <- goNum2Char(sub$go)
                        sublist <- paste('<li><strong>', sub$go, '</strong>',
                                         '<br>Ontology Name: ', sub$go_name,
                                         '<br>Type: ', sub$go_type,
                                         '<br>Evidence: ', evi,
                                         '</li>', sep = '')
                        sublist <- paste('<ul>', paste(sublist, collapse = ''), '</ul>')
                        text[i] <- paste(text[i], sublist, sep = '')
                    }
                }
                text <- paste(text, collapse = '<hr>')
            } else if (operation == 'intersection') {
                gene_info <- qry[1:2]
                gene_info <- gene_info[!duplicated(gene_info), ]
                gene_info <- paste('<strong><i>', gene_info[[1]], ': </i></strong>',
                                   gene_info[[2]], sep = '')
                text <- paste('<p><span style="font-size:130%;"><strong>Queried List:</strong></span><br>',
                              paste(gene_info, collapse = '<br>'), '<hr>', sep = '')
                
                all_go <- levels(factor(qry$go))
                mat <- sapply(labels, function(g) {
                    all_go %in% qry$go[qry$gene_label == g]
                })
                inter <- all_go[apply(mat, 1, all)]
                if (length(inter)) {
                    evi <- sapply(inter, function(go) {
                        sig <- qry$go_signif[ qry$go == go ]
                        sig <- sig[!duplicated(sig)]
                        paste(sig, collapse = ' | ')
                    })
                    sub <- qry[ qry$go %in% inter, ]
                    sub <- sub[!duplicated(sub$go), ]
                    sub$go <- goNum2Char(sub$go)
                    sublist <- paste('<li><strong>', sub$go, '</strong>',
                                     '<br>Ontology Name: ', sub$go_name,
                                     '<br>Type: ', sub$go_type,
                                     '<br>Evidence: ', evi,
                                     '</li>', sep = '')
                    sublist <- paste('<ul>', paste(sublist, collapse = ''), '</ul>')
                    text <- paste(text, sublist, sep = '')
                } else text <- paste(text, '<p>Intercection GO Term Not Found</p>')
            } else {
                gene_info <- qry[1:2]
                gene_info <- gene_info[!duplicated(gene_info), ]
                gene_info <- paste('<strong><i>', gene_info[[1]], ': </i></strong>',
                                   gene_info[[2]], sep = '')
                text <- paste('<p><span style="font-size:130%;"><strong>Queried List:</strong></span><br>',
                              paste(gene_info, collapse = '<br>'), '<hr>', sep = '')
                
                all_go <- levels(factor(qry$go))
                mat <- sapply(labels, function(g) {
                    all_go %in% qry$go[qry$gene_label == g]
                })
                inter <- all_go[apply(mat, 1, any)]
                if (length(inter)) {
                    evi <- sapply(inter, function(go) {
                        sig <- qry$go_signif[ qry$go == go ]
                        sig <- sig[!duplicated(sig)]
                        paste(sig, collapse = ' | ')
                    })
                    sub <- qry[ qry$go %in% inter, ]
                    sub <- sub[!duplicated(sub$go), ]
                    sub$go <- goNum2Char(sub$go)
                    sublist <- paste('<li><strong>', sub$go, '</strong>',
                                     '<br>Ontology Name: ', sub$go_name,
                                     '<br>Type: ', sub$go_type,
                                     '<br>Evidence: ', evi,
                                     '</li>', sep = '')
                    sublist <- paste('<ul>', paste(sublist, collapse = ''), '</ul>')
                    text <- paste(text, sublist, sep = '')
                } else text <- paste(text, '<p>Union GO Term Not Found</p>')
            } 
        } else text = '<p><strong>Query No Result</strong></p>'
        
        output$q_go_out <- renderText(text)
    })
    
    # response ontology-gene query
    observeEvent(input$q_og_submit, {
        # get input
        go_list <- as.numeric(
            strsplit(gsub('GO:(\\ )*', '', input$q_og_onto_list), '[,\\ \n\t]+')[[1]])
        species <- ifelse(input$q_og_taxi == 'Sz. pombe',
                          'sz_pombe', 's_cerevisiae')
        
        # output log
        cat('Ontology->Gene Query Reseived:\n')
        cat('ontology list:', paste(go_list, collapse = ', '), '\n')
        cat('from species:', species, '\n')
        
        # format query elements
        taxi <- species
        lengthgo <- length(go_list)
        go_list <- paste(go_list, collapse = ', ')
        
        # knit up query
        qry_text <- paste(unlist(readLines('query_o_g.sql')), collapse = '\n')
        qry_text <- gsub('\\{taxi\\}', taxi, qry_text)
        qry_text <- gsub('\\{lengthgo\\}', lengthgo, qry_text)
        qry_text <- gsub('\\{go_list\\}', go_list, qry_text)
        cat('formated query:\n', qry_text, '\n\n', sep = '')
        
        qry <- dbGetQuery(con, qry_text)
        
        # output
        output$q_og_out <- renderTable(qry)
    })
    
    # response homology query
    observeEvent(input$q_gg_submit, {
        # get input
        gene_list <- strsplit(input$q_gg_gene_list, '[,\\ \n\t]+')[[1]]
        species <- ifelse(input$q_gg_taxi == 'Sz. pombe',
                          'sz_pombe', 's_cerevisiae')
        
        # output log
        cat('Yeast Homology Query Reseived:\n')
        cat('gene list:', paste(gene_list, collapse = ', '), '\n')
        cat('from species:', species, '\n')
        
        # format query elements
        fromyeast <- paste(species, '_desc', sep = '')
        taxi <- gsub('^(.)+_', '', species)
        restrain <- paste('where gene_label in ("',
                          paste(gene_list, collapse = '", "'), '") or id in ("',
                          paste(gene_list, collapse = '", "'), '")', sep = '')
        prestrain <- ifelse(species == 'sz_pombe', restrain, '')
        crestrain <- ifelse(species == 's_cerevisiae', restrain, '')
        
        # knit up query
        qry_text <- paste(unlist(readLines('query_g_g.sql')), collapse = '\n')
        qry_text <- gsub('\\{fromyeast\\}', fromyeast, qry_text)
        qry_text <- gsub('\\{taxi\\}', taxi, qry_text)
        qry_text <- gsub('\\{restrain\\}', restrain, qry_text)
        qry_text <- gsub('\\{prestrain\\}', prestrain, qry_text)
        qry_text <- gsub('\\{crestrain\\}', crestrain, qry_text)
        cat('formated query:\n', qry_text, '\n\n', sep = '')
        
        qry <- dbGetQuery(con, qry_text)
        
        output$q_gg_out <- renderTable(qry)
    })
    
    # close db connection when stop app
    cancel.onSessionEnded <- session$onSessionEnded(function() {
        dbDisconnect(con)
        cat('disconnection: OK\n\n')
    })
    
})
