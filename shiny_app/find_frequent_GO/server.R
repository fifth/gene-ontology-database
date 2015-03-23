require(shiny)
require(knitr)
require(arules)

shinyServer(function(input, output) {
    
    # name_list <- input$name_list
    
    load('../../databases/gene_ontology_pombase.RData')    
    
    output$result <- renderText({
        
        raw_list <- input$name_list
        name_list <- gsub(' ', '', strsplit(raw_list, split = ',')[[1]])
        target <- c('closed frequent itemsets',
                    'maximally frequent itemsets')[as.integer(input$fr_type)]
        
        if (length(name_list) > 1) {
            go_list <- sapply(name_list,
                    function(name) {
                        go <- pombe.go$GO_ID[pombe.go$Gene_Name == name]
                        go <- as.character(go)
                        go[!duplicated(go)]
                    })
            
            tr <- as(go_list, 'transactions')
            freqp <- apriori(tr,
                             parameter = list(supp = input$min_sup,
                                              target = target))
            
            freqp <- as(freqp, 'data.frame')
            
            paste(
                paste(
                    paste(
                        paste('Set #', 1:nrow(freqp),
                              ', Support = ', round(freqp$support, 3),
                              sep = ''),
                        gsub('\\}|\\{|,', '\n', freqp$items)),
                    sep = ''),
            collapse = '\n')
        }
    })
    
})