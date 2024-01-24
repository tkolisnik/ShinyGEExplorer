# UI Code for the app ShinyGEExplorer by Tyler Kolisnik

ui <- dashboardPage(
  dashboardHeader(title = "Shiny GE Explorer"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("App Introduction", tabName = "app_intro", icon = icon("list-alt")),
      menuItem("Data Overview", tabName = "data_overview", icon = icon("table")),
      menuItem("Distribution Plot", tabName = "distribution_plot", icon = icon("chart-bar")),
      menuItem("Variance Plot", tabName = "variance_plot", icon = icon("chart-line")),
      menuItem("Heatmap", tabName = "heatmap", icon = icon("th")),
      menuItem("PCA Analysis", tabName = "pca_plot", icon = icon("project-diagram")),
      menuItem("Volcano Plot", tabName = "volcano_plot", icon = icon("project-diagram")),
      menuItem("Individual Gene plots", tabName = "gene_plots", icon = icon("box"))
    )
  ),
  dashboardBody(
    tabItems(
      
      tabItem(tabName = "data_overview",
              fluidRow(
                box(title = "Data Overview", width = 12, status = "primary", solidHeader = TRUE, background = "light-blue")
              ),
              fluidRow(
                column(12,
                       textAreaInput("columnVisibility", "Enter Columns to Display:",
                                     value = "", rows = 5),
                       actionButton("updateColumns", "Update Columns"),
                       actionButton("resetColumns", "Reset Columns"),
                       downloadButton("downloadData", "Download Data")
                )
              ),
              fluidRow(
                column(12,
                       DT::dataTableOutput("data_table")
                )
              )
      ),
      tabItem(tabName = "distribution_plot",
              fluidRow(
                box(title = "Distribution Plot", width = 12, status = "primary", solidHeader = TRUE, background = "light-blue")
              ),
              fluidRow(
                column(4,
                       selectInput("distScale", "Scale:",
                                   choices = c("Linear", "Log"),
                                   selected = "Linear"),
                       selectInput("distPlotType", "Plot Type:",
                                   choices = c("Histogram", "Density", "Violin"),
                                   selected = "Histogram")
                ),
                column(12,
                       plotOutput("dist_plot", width = "1200px", height = "900px"),
                       uiOutput("dist_plot_desc")
                )
              )),
      tabItem(tabName = "variance_plot",
              fluidRow(
                box(title = "Variance Plot", width = 12, status = "primary", solidHeader = TRUE, background = "light-blue")
              ),
              fluidRow(
                column(4,
                       sliderInput("numGenes", "Number of Top Variance Genes:",
                                   min = 1, max = 100, value = 10, step = 1),
                       checkboxInput("varLogScale", "Log scale", value = FALSE)
                )
              ),
              fluidRow(
                column(12,
                       plotOutput("variance_plot", width = "1200px", height = "900px")
                )
              ),
              fluidRow(
                column(12,
                       HTML("<p><strong>Variance Plot Description:</strong> This plot shows the variance in gene expression levels for each gene across the dataset. It highlights genes with high variability, which might be key candidates for further analysis.</p>")
                )
              )
      ),
      # UI part for the Heatmap tab
      tabItem(tabName = "heatmap",
              fluidRow(
                box(title = "Heatmap", width = 12, status = "primary", solidHeader = TRUE, background = "light-blue")
              ),
              fluidRow(
                column(4,
                       selectInput("heatmapClustering", "Clustering Method:",
                                   choices = c("Complete", "Average", "Single"),
                                   selected = "Complete"),
                       textOutput("clusteringDescription"),
                       hr(),
                       selectInput("heatmapScale", "Scale:",
                                   choices = c("None", "Row", "Column"),
                                   selected = "None"),
                       textOutput("scaleDescription"),
                       hr(), 
                       selectInput("heatmapColor", "Color Palette:",
                                   choices = c("Reds", "Blues", "Greens"),
                                   selected = "Reds"),
                       hr(),
                       textAreaInput("sampleIDs", "Enter Sample IDs:", 
                                     value = paste(training_set$identifier, collapse = ", "),
                                     rows = 3),
                       hr(),
                       actionButton("generateHeatmap", "Generate Heatmap"),
                       actionButton("resetSamples", "Reset Sample IDs")
                )
              ),
              fluidRow(
                column(12,
                       plotOutput("heatmap_plot", width = "1200px", height = "900px"),
                       uiOutput("heatmap_loading_message")
                )
              ),
              HTML("<p><strong>Heatmap Description:</strong> The heatmap visualizes the expression levels of genes across selected samples. 
      <br>It's an effective tool for observing patterns, such as the clustering of samples or genes, which might indicate similar expression profiles or shared biological functions. 
      <br><br><strong>Legend Interpretation:</strong> 
      <ul>
        <li>If scaling is set to <em>None</em>, the legend represents raw data values.</li>
        <li>If scaling is <em>Row</em> or <em>Column</em>, the legend represents z-scores, which are the number of standard deviations from the mean of its row or column.</li>
      </ul>
      </p>")
      ),
      tabItem(tabName = "pca_plot",
              fluidRow(
                box(title = "Principal Component Analysis Plot", width = 12, status = "primary", solidHeader = TRUE, background = "light-blue")
              ),
              fluidRow(
                column(4,
                       selectInput("pcaGrouping", "Group Data By:",
                                   choices = colnames(target_categories)[-1]),
                       selectInput("pcaXAxis", "PCA X-Axis:",
                                   choices = c("PC1", "PC2", "PC3", "PC4"),
                                   selected = "PC1"),
                       selectInput("pcaYAxis", "PCA Y-Axis:",
                                   choices = c("PC1", "PC2", "PC3", "PC4"),
                                   selected = "PC2")
                ),
                column(12,
                       plotOutput("pca_plot", width = "1200px", height = "900px"),
                       HTML("<p><strong>PCA Plot Description:</strong> This PCA plot represents a reduced-dimensional view of the dataset, where each point corresponds to a sample. The plot helps in identifying overarching patterns and clusters in the data, which might be indicative of underlying biological processes or sample relationships.</p>")
                )
              )),
      
      tabItem(
        tabName = "volcano_plot",
        fluidRow(
          box(title = "Volcano Plot for Differential Gene Expression Between Two Groups", width = 12, status = "primary", solidHeader = TRUE, background = "light-blue")
        ),
        fluidRow(
          column(4,
                 tags$p(
                   tags$strong(tags$em("Magnitude of Difference"))
                 ),
                 sliderInput("logFCThreshold", "Log2 Fold Change Threshold:",
                             min = 0, max = 3, value = 1, step = 0.1),
                 tags$p("Adjust the Log2 Fold Change Threshold to highlight genes with significant fold changes. Genes with a fold change greater than this threshold will be considered 'Upregulated,' while those with a fold change smaller than the negative threshold will be considered 'Downregulated.' Genes in between will be labeled as 'Not significant.'"),
                 
                 hr(),
                 tags$p(
                   tags$strong(tags$em("Significance of Difference"))
                 ),
                 sliderInput("pValueThreshold", "-Log10 P-value Threshold:",
                             min = 0, max = 10, value = 1.3, step = 0.1),
                 tags$p("Adjust the -Log10 P-value Threshold to control the significance level of genes. Genes with a -Log10 p-value greater than this threshold will be considered 'Upregulated' or 'Downregulated' based on their fold change, while genes below this threshold will be labeled as 'Not significant.'
                        Default threshold of 1.3 corresponds to a p-value < 0.05."),
                 
                 hr(),
                 selectInput("volcanoCategory", "Select Category for Comparison:",
                             choices = binary_categories, selected = binary_categories[1])
          ),
          column(12,
                 plotlyOutput("volcano_plot", width = "1500px", height = "700px")
          )
        ),
        fluidRow(
          column(12,
                 HTML("<p><strong>Volcano Plot Description:</strong><br>This plot visualizes differential gene expression.<br>Points represent genes, plotted by log2 fold change (x-axis) and -Log10 p-value (y-axis).<br>Genes beyond the threshold lines are considered significantly differentially expressed.<br>The legend indicates significant upregulated (red) and downregulated (blue) genes, as well as non-significant genes (grey).</p>")
          )
        )
      ),
      tabItem(tabName = "gene_plots",
              fluidRow(
                box(title = "Individual Gene Expression Plots", width = 12, status = "primary", solidHeader = TRUE, background = "light-blue")
              ),
              fluidRow(
                column(4,
                       selectInput("geneSelection", "Select Gene:",
                                   choices = colnames(training_set[, 3:ncol(training_set)]),
                                   selected = colnames(training_set[, 3])[1]),
                       selectInput("categorySelection", "Select Category:",
                                   choices = colnames(target_categories)[-1]), 
                       checkboxInput("logScale", "Log Transform Data", TRUE),
                       radioButtons("plotType", "Choose Plot Type:",
                                    choices = c("Boxplot" = "box", "Ridgeline Plot" = "ridge"),
                                    selected = "ridge"),
                       textAreaInput("sampleIDsPlot", "Enter Sample IDs:", 
                                     value = paste(training_set$identifier, collapse = ", "),
                                     rows = 3),
                       actionButton("generatePlot", "Generate Plot"),
                       actionButton("resetSamplesPlot", "Reset Sample IDs")
                ),
                column(12,
                       plotOutput("genePlot", width = "1200px", height = "900px")
                )
              ),
              HTML("<p><strong>Plot Description:</strong><br>This plot provides a visual summary of the expression levels of individual genes across different categories.<br>Depending on the selected plot type, it shows either the distribution (Ridgeline) or the summary statistics (Boxplot) of gene expressions.</p>")
      
    ),
      tabItem(tabName = "app_intro",
              fluidRow(
                box(title = "Welcome to Shiny GE Explorer", status = "primary", width = 12, solidHeader = TRUE,
                    HTML("<p>Shiny GE (Gene Expression) Explorer, is comprehensive tool designed for bioinformatics professionals and researchers. This application facilitates the preliminary exploration, quality control, and statistical analysis of gene expression data derived from NGS platforms. <br> It encompasses several key functionalities:</p>
           <ul>
             <li><strong>Data Overview:</strong> Browse, subset, and download the merged gene expression dataset.</li>
             <li><strong>Distribution Plot:</strong> Visualize gene expression distributions with histogram, density, or violin plots.</li>
             <li><strong>Variance Plot:</strong> Identify genes with high variability in expression levels.</li>
             <li><strong>Heatmap:</strong> Explore gene expression patterns and clustering across samples.</li>
             <li><strong>PCA Analysis:</strong> View Principal Component Analysis plots for data clustering visualization.</li>
             <li><strong>Volcano Plot:</strong> Examine differential gene expression by categories with interactive volcano plots.</li>
             <li><strong>Individual Gene Plots:</strong> Generate focused plots for individual genes, such as boxplots or ridgeline plots, aiding in targeted gene expression analysis.</li>
           </ul>
           <p>Each feature is designed to provide in-depth insights and aid in hypothesis generation, ensuring a robust analysis of your NGS data.</p>")
                ),
                box(title = "Getting Started", status = "primary", width = 12, solidHeader = TRUE,
                    HTML("<p>To get started, please use the loaded demo data or place your own data in the <code>/data/</code> folder of this app, and update the <code>data_path</code> variable in the script <code>global.R</code> with the correct data path. <br> 
                    Data should be structured as an .RData file containing a list variable named <code>analysis_set</code> which itself contains two tibbles, named :</p>
           <ul>
             <li><strong>expression_data:</strong> This tibble should have the first column named 'identifier' (with sample identifiers) and subsequent columns representing gene names.</li>
             <li><strong>target_categories:</strong> The metadata or grouping tibble, featuring the first column called 'identifier' (matching identifiers in 'expression_data') and subsequent columns of metadata.</li>
           </ul>
           <p>Please see below for examples:</p>
           <p><i>Recall: .RData files are saved via the command 
            <code>save(analysis_set, file=\"path/to/shinyGEExplorer/data/mydata.RData\")</code></i></p>"
                         )
                ),
                box(title = "Expression Data Preview", status = "primary", width = 12, solidHeader = TRUE, collapsible = TRUE,
                    fluidRow(
                      column(6, DT::dataTableOutput("rnaseqPreview")),
                    )
                ),
                box(title = "Target Categories Data Preview", status = "primary", width = 12, solidHeader = TRUE, collapsible = TRUE,
                    fluidRow(
                      column(12, DT::dataTableOutput("targetCatPreview"))
                    )
                )
              )
    
  )),
    
    # Footer content
    tags$footer(
      style = "background-color: #f0f0f0; text-align: center; padding: 10px;",
      HTML(paste(
        "App created by Tyler Kolisnik &nbsp;&nbsp;|&nbsp;&nbsp;",
        "Last Updated January 23, 2024 &nbsp;&nbsp;|&nbsp;&nbsp;",
        "Version ", app_version, " &nbsp;&nbsp;|&nbsp;&nbsp;",
        "Licensed under the <a href='https://creativecommons.org/licenses/by/4.0/' target='_blank'>CC BY 4.0 License</a>")
      )
    )
  )
)
