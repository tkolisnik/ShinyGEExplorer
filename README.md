# ShinyGEExplorer

1. This is the ShinyGEExplorer R package for Gene Expression Data analysis and exploration created by Tyler Kolisnik.

2. Please load the package using RStudio by pressing the Run App button or via the command

shiny::runApp('path/ShinyGEExplorer')

3. There is demonstration data that will auto-load. 

4. There are instructions in the first tab of the App on how to format your data in the same style as the demo data and how to use it with the package.

5. The demonstration data is located in the file demo_expression_data.RData in the /data/ folder, this is the same folder you should place your data at.

6. Requirements:
R version 4.2.3 (2023-03-15 ucrt) -- "Shortstop Beagle"
Rstudio (2023.09.01 or later)

# R Libraries Required:
# Note: When you open up the package in RStudio it should prompt you to install any required packages for this App that you don't already have. 

library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(pheatmap)
library(plotly)
library(dplyr)
library(tidyr)
library(RColorBrewer)
library(tibble)

7. See LICENSE.txt for Licensing and Distribution Information
8. Thank you for using my app, please address questions, comments, feedback to tkolisnik@gmail.com or submit a pull request or issue on github. 
