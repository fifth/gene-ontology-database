require(shiny)

shinyUI(fluidPage(
    titlePanel("Search the Pombe GO Database"),
    
    sidebarLayout(
        sidebarPanel(
            
            textInput('name_list',
                      label = 'Give a list of gene name: separated by comma',
                      value = ''),
            
            numericInput('min_sup',
                      label = 'Minimal support:',
                      value = '0.5',
                      step = 0.01),
            
            radioButtons("fr_type", 
                         label = "Select output type:",
                         choices = list("Closed Frequent Sets" = 1,
                                        "Maximal Frequent Sets" = 2),
                         selected = 1),
            
            submitButton('GO Frequent')
        ),
        
        mainPanel(
            h3('Result:'),
            verbatimTextOutput('result')
        )
    )
))