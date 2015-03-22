require(shiny)

shinyUI(fluidPage(
    titlePanel("Search the Pombe GO Database"),
    
    sidebarLayout(
        sidebarPanel(
            textInput('name_list',
                      label = 'Give a list of gene name: separated by comma',
                      value = ''),
            radioButtons("sep", 
                         label = "Select output separator:",
                         choices = list("Tab" = 1,
                                        "Comma" = 2,
                                        "Markdown Table" = 3),
                         selected = 1),
            submitButton('Search GO'),
            htmlOutput('confirm_name_list')
        ),
        mainPanel(
            h3('Result:'),
            verbatimTextOutput('result')
        )
    )
))