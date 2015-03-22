The Gene Ontology Database Web Server System
============================================

# Introduction

This is the course project for __Biological Databases and Lab__ in __Zhejiang Univ. the College of Life Sciences__

The project aims to build a gene ontology database with some analytical functionalities, with a web query interface.

Programmers:

* _**Yu Jiechao (Fifth)**_ is a web developer, familier with js and PHP, visit: [my page](http://fifth26.com)
* _**Li Yutze (Lytze)**_ uses R as main language and good at data analysis, visit: [my page](http://lytzeworkshop.com)

# Current Functionality

Now the application is set up at [lytze's server](http://lytzeworkshop.com:3838/playground/shiny_app/search_pombe_GO)

Currently this application is not mature, with following functionalities:

* Using gene name to query _Schizosaccharomyces pombe_'s GO database
* Select separator used in the output

The raw GO database was obtained from [Pombase.org](http://www.pombase.org/downloads/datasets), and was processed into a data frame then packed into the `.RData` file in the 	`./databases` folder. The script do this transformation is also located in that foder

# What Next

* Build the main GO clustering functionality
* Build file IO
* Rebuild the database in SQL database system (as is required by the coures)
* Write the system in __PHP__

# References and Linkouts

* The R base web application uses the `shiny` package in R and the Shiny-server provided by __RStudio Inc.__, visit the repo: [shiny](https://github.com/rstudio/shiny)
* The Pombe's GO database is obtained from [Pombase.org](http://www.pombase.org/downloads/datasets)