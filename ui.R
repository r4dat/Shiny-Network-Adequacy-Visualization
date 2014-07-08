library(shiny)

## Assume Provider_Types and Facility_Types
## exist in the working direcotry. Needed for 
## UI creation so we're reading them in here.

Provider_Types = read.csv("Provider_Types.csv", stringsAsFactors=FALSE,encoding="unknown")
Facility_Types = read.csv("Facility_Types.csv",stringsAsFactors=FALSE)

# Define UI for application that draws a histogram
shinyUI(
  fluidPage(
    
    # Application title
    title = "Provider and Facility Maps",
    plotOutput('plot',width="100%"),
    verbatimTextOutput("radval"),
    #plotOutput('table'),
    
    # Sidebar with a slider input for the number of bins
    fluidRow(
      column(3,
             radioButtons("radioType",label=h3("Type of Review"),
                          choices=list("Provider" = 1, "Facility" = 2),selected = 1),
             checkboxInput("compCheck",label="Compare 2 files?",value = FALSE)),
      column(3,
             selectInput("state_selector", label = "Select State:",
                         choices = state.name, selected = "Kansas")
             ,
             
             conditionalPanel(
               condition = "input.radioType==1",
               selectInput("prov_selected",label = "Select Provider Type",
                           Provider_Types$Individual_Provider_Types, selected = "001 General Practice")
             ),
             conditionalPanel(
               condition = "input.radioType==2",
               selectInput("fac_selected",label = "Select Facility Type",
                           Facility_Types$Facility_Types, selected = "Pharmacy")
             )
      )
      # Show a plot of the generated distribution
      
    ),
    fluidRow(
      column(3,
             fileInput("file_selected",label=h4("Select Provider or Facility File")),
             conditionalPanel(
               condition="input.compCheck==1",
               fileInput("file_comp",label="Select 2nd File to Compare")
             )
      ))
  )    
)