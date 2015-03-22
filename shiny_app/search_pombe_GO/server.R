require(shiny)
require(knitr)

shinyServer(function(input, output) {
    
    # name_list <- input$name_list
    
    load('../../databases/gene_ontology_pombase.RData')
    
    # latter makes it reactive
    extract <- c('GO_ID', 'GO_Evidence', 'GO_Type', 'GO_Annotation')
    
    
    name_list <- reactive({
        raw_list <- input$name_list
        gsub(' ', '', strsplit(raw_list, split = ',')[[1]])
    })
    
    output$confirm_name_list <- renderText({
        paste('<p>Your gene list:', 
              paste(
                  paste('<i>', head(name_list()), '</i>'),
                  collapse = ' '),
              '</p>')
    })
    
    output$result <- renderText({
        ret <- NULL;
        for (name in name_list()) {
            if (name %in% levels(pombe.go$Gene_Name)) {
                ind <- which(pombe.go$Gene_Name == name)
                
                gID <- as.character(pombe.go$Gene_ID[ind[1]])
                gDe <- as.character(pombe.go$Gene_Product[ind[1]])
                
                lis <- pombe.go[ind, extract]
                lis <- as.matrix(lis[!duplicated(lis), ])
                row.names(lis) <- NULL
                
                ret <- paste(ret, 'Query: ', gID, ' | ', name,
                            ifelse(
                                is.na(gDe),
                                '',
                                paste(' | ', gDe, sep = '')
                            ),
                            '\n',
                            sep = '')
                if (input$sep == 3) {
                    ret <- paste(ret,
                                 paste(kable(lis), collapse = '\n'),
                                 sep = '')
                } else {
                    sep <- c('\t', ', ')[as.integer(input$sep)]
                    lis <- rbind(extract, lis)
                    ret <- paste(ret,
                                 paste(apply(lis, 1, paste, collapse = sep),
                                       collapse = '\n'),
                                 '\n',
                                 sep = '')
                }
                
                ret <- paste(ret, '\n', sep = '')
            }
            
        }
        ret
    })
    
})