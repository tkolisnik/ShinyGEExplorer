# global.R code for the app ShinyGEExplorer by Tyler Kolisnik

# Load Libraries
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

# Version
app_version <- "11.7" 

# Load data

data_path<-"./data/demo_expression_data.RData" # Replace with the correct file path

load(data_path)


# Preprocess data
training_set <- analysis_set$expression_data
target_categories <- analysis_set$target_categories

common_identifiers <- inner_join(training_set, target_categories, by = "identifier")$identifier

training_set <- training_set %>%
  filter(identifier %in% common_identifiers)

target_categories <- target_categories  %>%
  filter(identifier %in% common_identifiers)

# Identify binary categories (necessary for certain plots)
binary_categories <- names(target_categories)[sapply(target_categories, function(x) length(unique(x)) == 2)]


# Define the footer text
footer_text <- HTML(paste(
  "App designed by Tyler Kolisnik &nbsp;&nbsp;|&nbsp;&nbsp;",
  "Last Updated January 23, 2023 &nbsp;&nbsp;|&nbsp;&nbsp;",
  "Licensed under the <a href='https://opensource.org/licenses/MIT' target='_blank'>MIT License</a>"
))