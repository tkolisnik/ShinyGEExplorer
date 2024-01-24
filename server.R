# Server code for the app ShinyGEExplorer by Tyler Kolisnik

server <- function(input, output, session) {

  # Overview Data Tab Code:
  overview_data <- reactive({
    merged_data <- if ("identifier" %in% colnames(training_set) && 
                       "identifier" %in% colnames(target_categories)) {
      merge(training_set, target_categories, by = "identifier", all.x = TRUE)
    } else {
      training_set
    }
    # Conditionally exclude 'target' column if it exists
    if("target" %in% colnames(merged_data)) {
      merged_data <- merged_data[, !colnames(merged_data) %in% "target"]
    }
    merged_data
  })
  
  # Populate the columns at start
  observe({
    all_columns <- colnames(overview_data())
    updateTextAreaInput(session, "columnVisibility", value = paste(all_columns, collapse = ", "))
  })
  
  # Data Overview with enhanced features
  output$data_table <- DT::renderDataTable({
    data_to_show <- overview_data()
    selected_columns <- unlist(strsplit(input$columnVisibility, ",\\s*"))
    
    if(length(selected_columns) > 0 && all(selected_columns %in% colnames(data_to_show))) {
      data_to_show <- data_to_show[, selected_columns, drop = FALSE]
    }
    
    DT::datatable(data_to_show, options = list(
      pageLength = 10,
      searchHighlight = TRUE
    ), filter = 'top')
  })
  
  # Update Columns button functionality
  observeEvent(input$updateColumns, {
    output$data_table <- DT::renderDataTable({
      data_to_show <- overview_data() # Use the reactive expression again
      selected_columns <- unlist(strsplit(input$columnVisibility, ",\\s*"))
      
      # Filter columns based on user input
      if(length(selected_columns) > 0 && all(selected_columns %in% colnames(data_to_show))) {
        data_to_show <- data_to_show[, selected_columns, drop = FALSE]
      }
      
      DT::datatable(data_to_show, options = list(
        pageLength = 10,
        searchHighlight = TRUE
      ))
    })
  })
  
  # Reset Columns button functionality
  observeEvent(input$resetColumns, {
    all_columns <- c(colnames(training_set), colnames(target_categories)[-1]) # Combine and exclude duplicate
    unique_columns <- unique(all_columns) # Ensure uniqueness
    updateTextAreaInput(session, "columnVisibility", value = paste(unique_columns, collapse = ", "))
  })
  
  # Download functionality
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("data-overview-", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(overview_data(), file, row.names = FALSE)
    }
  )
  
  # Distribution Plot Tab Code:
  output$dist_plot <- renderPlot({
    library(ggplot2)
    library(tidyr)
    training_set<-training_set[, !(colnames(training_set) %in% c('identifier', 'target'))]
    gene_expression <- gather(training_set, gene, expression)
    
    # Apply log transformation if selected
    if(input$distScale == "Log") {
      gene_expression$expression <- log1p(gene_expression$expression)
    }
    
    # Create plot based on selected plot type
    p <- ggplot(gene_expression, aes(x = expression)) +
      theme_minimal() +
      labs(title = "Gene Expression Distribution", x = "Expression Level", y = "Frequency")
    
    if(input$distPlotType == "Histogram") {
      p <- p + geom_histogram(bins = 20, fill = "lightblue", color = "white")
    } else if(input$distPlotType == "Density") {
      p <- p + geom_density(fill = "lightblue", alpha = 0.7)
    } else if(input$distPlotType == "Violin") {
      p <- p + geom_violin(aes(y = expression), fill = "lightblue", alpha = 0.7) +
        ylab("Density")
    }
    
    p
  })
  
  output$dist_plot_desc <- renderUI({
    if(input$distPlotType == "Histogram") {
      HTML("<p><strong>Histogram Description:</strong> This histogram displays the frequency distribution of gene expression levels. Each bar represents the count of gene expressions within a specific range, enabling the identification of the most common expression levels and the overall spread of data.</p>")
    } else if(input$distPlotType == "Density") {
      HTML("<p><strong>Density Plot Description:</strong> This density plot provides a smooth curve representing the distribution of gene expression levels. The curve's peak(s) denote the most frequent expression levels, offering insights into the data's overall shape, including skewness or multimodality.</p>")
    } else if(input$distPlotType == "Violin") {
      HTML("<p><strong>Violin Plot Description:</strong> The violin plot combines elements of a box plot with a kernel density plot. It shows the distribution of gene expression levels in terms of both spread and density. The wider sections of the violin plot represent a higher frequency of data points, offering a comprehensive view of the data distribution.</p>")
    }
  })
  
  # Variance Plot Tab Code
  output$variance_plot <- renderPlot({
    library(ggplot2)
    library(dplyr)
    
    # Calculate variance and sort by descending order
    var_data <- training_set %>%
      select(-identifier) %>%
      summarise_all(var) %>%
      gather(key = "gene", value = "variance") %>%
      arrange(desc(variance)) %>%
      head(input$numGenes) # Filter top genes based on slider input
    
    # Apply log scaling if selected
    if(input$varLogScale) {
      var_data$variance <- log1p(var_data$variance)
    }
    
    # Create plot
    ggplot(var_data, aes(x = reorder(gene, -variance), y = variance)) +
      geom_bar(stat = "identity", fill = "steelblue") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      labs(title = "Top Variance Genes in Gene Expression Levels", x = "Gene", y = "Variance")
  })
  
  # Heatmap
  output$clusteringDescription <- renderText({
    switch(input$heatmapClustering,
           "Complete" = "Considers maximum distance between elements of two clusters.",
           "Average" = "Uses the average distance between all pairs of elements in two clusters.",
           "Single" = "Considers the shortest distance between elements of two clusters."
    )
  })
  
  output$scaleDescription <- renderText({
    switch(input$heatmapScale,
           "None" = "No scaling applied. Directly represents raw data values.",
           "Row" = "Each row is scaled independently, highlighting patterns across columns for each row.",
           "Column" = "Each column is scaled independently, emphasizing patterns across rows for each column."
    )
  })
  
  # Heatmap Tab Code
  
  # Reactive expression for generating heatmap data
  heatmap_data_reactive <- eventReactive(input$generateHeatmap, {
    sample_list <- unlist(strsplit(input$sampleIDs, ",\\s*"))
    filtered_data <- training_set[training_set$identifier %in% sample_list, ]
    data_matrix <- as.matrix(filtered_data[, 3:ncol(filtered_data)])
    
    # Replace NA/NaN/Inf values with 0 or a small number
    data_matrix[!is.finite(data_matrix)] <- 0  # Replace Inf and NaN with 0
    
    # Ensure no column has zero variance
    variances <- apply(data_matrix, 2, var)
    data_matrix <- data_matrix[, variances > 1e-10]  # Adjust threshold as needed
    
    # Return the cleaned matrix and identifiers
    list(data = data_matrix, identifiers = filtered_data$identifier)
  }, ignoreNULL = FALSE)
  
  # Render the heatmap plot
  output$heatmap_plot <- renderPlot({
    result <- heatmap_data_reactive()
    heatmap_data <- result$data
    identifiers <- result$identifiers
    
    if(is.null(heatmap_data) || nrow(heatmap_data) == 0) {
      return(NULL) # Avoid rendering an empty plot
    }
    
    rownames(heatmap_data) <- identifiers
    
    scale_type <- switch(input$heatmapScale,
                         "None" = "none",
                         "Row" = "row",
                         "Column" = "column")
    
    color_palette <- switch(input$heatmapColor,
                            "Blues" = brewer.pal(9, "Blues"),
                            "Reds" = brewer.pal(9, "Reds"),
                            "Greens" = brewer.pal(9, "Greens"))
    
    clustering_method <- tolower(input$heatmapClustering)
    
    pheatmap(t(heatmap_data), scale = scale_type, 
             clustering_distance_rows = "euclidean", 
             clustering_distance_cols = "euclidean", 
             clustering_method = clustering_method,
             color = colorRampPalette(color_palette)(255),
             fontsize_row = 10,
             fontsize_col = 10,
             main = "Heatmap of Gene Expression Levels Across Samples"  # Heatmap title
             # Add labels_row and labels_col if you have specific names for rows and columns
    )
  })
  
  # Dynamic descriptions for clustering and scaling methods
  output$clusteringDescription <- renderText({
    switch(input$heatmapClustering,
           "Complete" = "Considers maximum distance between elements of two clusters.",
           "Average" = "Uses the average distance between all pairs of elements in two clusters.",
           "Single" = "Considers the shortest distance between elements of two clusters."
    )
  })
  
  output$scaleDescription <- renderText({
    switch(input$heatmapScale,
           "None" = "No scaling applied. Directly represents raw data values.",
           "Row" = "Each row is scaled independently, highlighting patterns across columns for each row.",
           "Column" = "Each column is scaled independently, emphasizing patterns across rows for each column."
    )
  })
  
  
  #PCA Tab Code
  output$pca_plot <- renderPlot({
    library(dplyr)
    library(ggplot2)
    
    # Preparing PCA data
    pca_data <- training_set %>%
      select(-identifier) %>%
      select_if(~length(unique(.)) > 1) %>% 
      prcomp(center = TRUE, scale. = TRUE)
    
    pca_df <- as.data.frame(pca_data$x)
    pca_df$identifier <- training_set$identifier
    
    # Merging with target categories for grouping
    pca_df <- merge(pca_df, target_categories, by = "identifier")
    
    # Determine grouping variable and principal components for axes
    grouping_var <- input$pcaGrouping
    x_axis <- input$pcaXAxis
    y_axis <- input$pcaYAxis
    
    # Creating the PCA plot
    p <- ggplot(pca_df, aes_string(x = x_axis, y = y_axis, color = grouping_var)) +
      geom_point() +
      theme_minimal() +
      labs(title = "PCA of Gene Expression", x = x_axis, y = y_axis)
    
    # Add discrete color scale if grouping is not 'None'
    if (grouping_var != "None") {
      p <- p + scale_color_discrete(name = grouping_var)
    }
    
    p
  })
  
  ## VOLCANO PLOT Tab Code
  output$volcano_plot <- renderPlotly({
    library(ggplot2)
    library(dplyr)
    library(limma)
    
    # Selected category for comparison
    category <- input$volcanoCategory
    
    # Check if the selected category is binary
    if (!(category %in% binary_categories)) {
      stop("Selected category is not binary.")
    }
    
    # Create binary factor for the selected category
    comparison_factor <- factor(target_categories[[input$volcanoCategory]])
    
    # Prepare data for differential expression analysis
    exprs_data <- t(as.matrix(training_set[, !(colnames(training_set) %in% c('identifier', 'target'))]))
    
    design <- model.matrix(~ comparison_factor)
    
    # Check dimensions match
    if (ncol(exprs_data) != nrow(design)) {
      stop("Mismatch in dimensions between expression data and design matrix.")
    }
    
    fit <- lmFit(exprs_data, design)
    fit <- eBayes(fit)
    results <- topTable(fit, coef = 2, number = Inf)
    
    volcano_data <- results %>%
      as.data.frame() %>%
      tibble::rownames_to_column(var = "gene") %>%
      mutate(foldChange = logFC, pValue = -log10(P.Value))
    
    logFCThreshold <- input$logFCThreshold
    pValueThreshold <- input$pValueThreshold
    
    # Create vertical and horizontal lines based on slider values
    vline_x <- c(-logFCThreshold, logFCThreshold)
    hline_y <- pValueThreshold
    
    # Create a custom legend with labels and colors
    custom_legend <- scale_color_manual(
      values = c("Downregulated" = "blue", "Not significant" = "grey", "Upregulated" = "red"),
      labels = c("Downregulated", "Not significant", "Upregulated")
    )
    
    # Mutate the color column based on thresholds without NAs
    volcano_data <- volcano_data %>%
      mutate(color = case_when(
        foldChange < -logFCThreshold & pValue > pValueThreshold ~ "Downregulated",
        foldChange > logFCThreshold & pValue > pValueThreshold ~ "Upregulated",
        TRUE ~ "Not significant"
      ))
    
    p <- ggplot(volcano_data, aes(x = foldChange, y = pValue, color = color, text = gene)) +
      geom_point() +
      geom_hline(yintercept = hline_y, linetype = "dashed") +
      geom_vline(xintercept = vline_x, linetype = "dashed") +
      custom_legend +  # Add custom legend
      theme_minimal() +
      labs(
        title = "Volcano Plot of Gene Expression",
        x = "Log2 Fold Change",
        y = "-Log10 p-value",
        color = "Gene Expression"
      )
    
    ggplotly(p, tooltip = "text") 
  })
  
  
  
  # Boxplots
  
  # Gene Plots with Sample ID filtering
  output$genePlot <- renderPlot({
    req(input$generatePlot)  # Make sure the plot is generated only when the button is clicked
    
    selected_gene <- input$geneSelection
    selected_category <- input$categorySelection
    log_transform <- input$logScale
    plot_type <- input$plotType
    sample_ids <- unlist(strsplit(input$sampleIDsPlot, ",\\s*"))
    
    if(is.null(selected_gene) || !selected_gene %in% colnames(training_set)) {
      return(NULL)
    }
    
    filtered_data <- training_set[training_set$identifier %in% sample_ids, ]
    merged_data <- inner_join(filtered_data, target_categories, by = "identifier")
    
    # Log transform the data if selected
    if(log_transform) {
      merged_data[[selected_gene]] <- log1p(merged_data[[selected_gene]])
    }
    
    if(plot_type == "box") {
      ggplot(merged_data, aes_string(x = selected_category, y = selected_gene, fill = selected_category)) +
        geom_boxplot() +
        theme_minimal() +
        labs(title = paste("Expression of", selected_gene, "across", selected_category), 
             x = selected_category, y = "Expression Level")
    } else if(plot_type == "ridge") {
      library(ggridges)
      ggplot(merged_data, aes_string(x = selected_gene, y = selected_category, fill = selected_category)) +
        geom_density_ridges() +
        theme_minimal() +
        labs(title = paste("Distribution of", selected_gene, "across", selected_category), 
             x = "Expression Level", y = selected_category)
    }
  })
  
  # Reset Sample IDs button
  observeEvent(input$resetSamplesPlot, {
    updateTextAreaInput(session, "sampleIDsPlot", 
                        value = paste(training_set$identifier, collapse = ", "))
  })
  
  # Render previews of demo data for app intro page
  output$rnaseqPreview <- DT::renderDataTable({
    prevdata <- head(analysis_set$expression_data)
    if (ncol(prevdata) > 10) {
      prevdata <- prevdata[, 1:10, drop = FALSE]
    }
    DT::datatable(prevdata, options = list(filter = 'none'))
  })
  
  output$targetCatPreview <- DT::renderDataTable({
    prevdata2 <- head(analysis_set$target_categories)
    if (ncol(prevdata2) > 10) {
      prevdata2 <- prevdata2[, 1:10, drop = FALSE]
    }
    DT::datatable(prevdata2, options = list(filter = 'none'))
  })
}
