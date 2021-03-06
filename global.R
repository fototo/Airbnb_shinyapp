## global
library(shiny)
library(leaflet)
library(dplyr)
library(plotly)

# load data
load("nycmap.Rda")
load("tab2df.Rda")
load("timedf.Rda")
load("overall.Rda")


# variables
boro <- c("Bronx" = "Bronx",
          "Brooklyn" = "Brooklyn",
          "Manhattan"="Manhattan",
          "Queens" = "Queens",
          "Staten Island" = "Staten Island")

room <- c("Entire home/apt"= "Entire home/apt",
          "Private room" ="Private room",
          "Shared room" ="Shared room")

groupColors <- colorFactor(c("#E03A3C", "#009DDC","#62BB47"),
                           domain = c("Entire home/apt", "Private room","Shared room"))

# (Palette) http://www.codeofcolors.com/apple-colors.html
# (Airbnb) https://medium.com/airbnb-engineering

