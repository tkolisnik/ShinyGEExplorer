# ShinyGEExplorer

1. This is the ShinyGEExplorer R Shiny App for Gene Expression Data analysis and exploration created by Tyler Kolisnik.

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
9. Please see the below screenshots for a preview of the App's functionality.

![Screenshot 1 - App Introduction Tab](https://github.com/tkolisnik/ShinyGEExplorer/assets/8935420/e97c8148-b564-48e1-8c3b-0cf196e11b2a)
![Screenshot 2 - Input Data Format Instructions](https://github.com/tkolisnik/ShinyGEExplorer/assets/8935420/e3dea4c7-7f85-4b9f-ad04-4fadb6f56717)
![Screenshot 3 - Data Overview Tab](https://github.com/tkolisnik/ShinyGEExplorer/assets/8935420/0d1c79ce-3d15-4101-8711-36e78661a11e)
![Screenshot 4 - Distribution Plot Tab](https://github.com/tkolisnik/ShinyGEExplorer/assets/8935420/a6d9484b-0c75-4852-bdda-772d4047e0a2)
![Screenshot 5 - Variance Plot Tab](https://github.com/tkolisnik/ShinyGEExplorer/assets/8935420/dd612c23-0619-4d69-8a79-ddc0d7c69bfe)
![Screenshot 6 - Heatmap Tab](https://github.com/tkolisnik/ShinyGEExplorer/assets/8935420/f9235cfc-6823-447e-a011-1cb3ad99cfcf)
![Screenshot 7 - PCA Tab](https://github.com/tkolisnik/ShinyGEExplorer/assets/8935420/3ef6f541-915d-49ea-a629-f160680944b1)
![Screenshot 8 - Volcano Plot Tab](https://github.com/tkolisnik/ShinyGEExplorer/assets/8935420/cdfea298-3d80-466d-93c2-7cc76165d97d)
![Screenshot 9 - Individual Gene plots Tab](https://github.com/tkolisnik/ShinyGEExplorer/assets/8935420/d1a95479-adf5-4de7-add6-1df70d06d5ad)
