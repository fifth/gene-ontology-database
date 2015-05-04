require(shiny)

shinyUI(
    
    navbarPage(title = 'CrossYeast GO', id = 'nav',
               position = 'static-top',
               tabPanel('About', value = 'about',
                        icon = icon(name = 'info', lib = 'font-awesome'),
                        helpText('help info')
               ),
               
               navbarMenu(title = 'Query',
                          icon = icon(name = 'filter', lib = 'font-awesome'),
                   tabPanel('Gene-Ontology', value = 'query_go',
                            sidebarLayout(
                                sidebarPanel(
                                    textInput(inputId = 'q_go_gene_list',
                                              label = 'Use Gene List to Query Ontologies'),
                                    helpText('Use comma, white space or newline to separate genes.\
Gene name and ID are both supported'),
                                    hr(),
                                    selectInput(inputId = 'q_go_taxi',
                                                label = 'Yeast Species',
                                                choices = c('S. cerevisiae',
                                                            'Sz. pombe')),
                                    checkboxGroupInput(inputId = 'q_go_namespace',
                                                       label = 'Use GO Namespace',
                                                       choices = c('biological process',
                                                                   'molecular function',
                                                                   'cellular component'),
                                                       selected = 'biological process'),
                                    radioButtons(inputId = 'q_go_evidence',
                                                 label = 'GO Evidence Level',
                                                 choices = c('experimental only',
                                                             'use all'),
                                                 inline = T),
                                    radioButtons(inputId = 'q_go_operation',
                                                 label = 'Operation',
                                                 choices = c('list separately',
                                                             'intersection',
                                                             'union'),
                                                 inline = T),
                                    hr(),
                                    actionButton(inputId = 'q_go_submit',
                                                 label = 'Send Query',
                                                 icon = icon('check-circle-o'))
                                ),
                                mainPanel(
                                    htmlOutput('q_go_out')
                                )
                            )
                   ),
                   
                   tabPanel('Ontology-Gene', value = 'query_og',
                            sidebarLayout(
                                sidebarPanel(
                                    textInput(inputId = 'q_og_onto_list',
                                              label = 'Use Ontology list to Query Genes'),
                                    helpText('Use comma, white space or newline to separate GO terms.\
You can both input terms with/without "GO:"'),
                                    hr(),
                                    selectInput(inputId = 'q_og_taxi',
                                                label = 'Yeast Species',
                                                choices = c('S. cerevisiae',
                                                            'Sz. pombe')),
                                    radioButtons(inputId = 'q_og_evidence',
                                                 label = 'GO Evidence Level',
                                                 choices = c('experimental only',
                                                             'use all'), 
                                                 inline = T),
                                    hr(),
                                    actionButton(inputId = 'q_og_submit',
                                                 label = 'Query',
                                                 icon = icon('check-circle-o'))
                                ),
                                mainPanel(
                                    tableOutput('q_og_out')
                                )
                            )
                   ),
                   
                   tabPanel('Pombe-Cerevisiae', value = 'query_gg',
                            sidebarLayout(
                                sidebarPanel(
                                    textInput(inputId = 'q_gg_gene_list',
                                              label = 'Search Yeast Homologous Genes Cross Yeast Species\
Gene name and ID are both supported'),
                                    hr(),
                                    helpText('Use comma, white space or newline to separate genes'),
                                    selectInput(inputId = 'q_gg_taxi',
                                                label = 'From Species',
                                                choices = c('S. cerevisiae',
                                                            'Sz. pombe')),
                                    hr(),
                                    actionButton(inputId = 'q_gg_submit',
                                                 label = 'Query',
                                                 icon = icon('check-circle-o'))
                                ),
                                mainPanel(
                                    tableOutput('q_gg_out')
                                )
                            )
                   )
               ),
                   
               tabPanel('GO Cluster', value = 'go_cluster',
                        icon = icon(name = 'th-large', lib = 'font-awesome'),
                        h1('this')
               ),
               
               tabPanel('Search Record', value = 'search_record',
                        icon = icon(name = 'archive', lib = 'font-awesome'),
                        h2('that')
               )
    )
)