library(shiny)
library(zipcode)
library(plyr)
library(ggplot2)
data(zipcode)
data(state)
## Set locale?
Sys.setlocale(category="LC_ALL",locale="English_United States.1252")

## Increase max upload file size! Currently 7 MB.
options(shiny.maxRequestSize=7*1024^2)

# Define server logic required to plot various variables against mpg
shinyServer(function(input, output) {
  
  carrier_file = reactive({
#     validate(
#       need(input$file_selected == "", "Please upload a Provider or Facility file for analysis.")
#     )
    
    read.delim(input$file_selected$datapath,dec=","
               ,stringsAsFactors = FALSE)
  })
  
  state_select_abbrev = reactive({
    state.abb[grep(input$state_selector,state.name)]
  })
  
  
  ## Do subsets based on inputs.
  
  loc_geo = reactive({
    
    subzipcode= zipcode[zipcode$state==state_select_abbrev(),]
    
    
    subzipcode$zip = as.integer(subzipcode$zip)
    colnames(subzipcode)[1]="Zip"
    
    tmp = join(x = carrier_file(),y=subzipcode,by = "Zip",type='inner')
    
    return(tmp)
  })
  
  
  output$plot = renderPlot({
    
    state_var = tolower(input$state_selector)
    
    
    county_df <- map_data('county')  #mappings of counties by state
    state_sub <- subset(county_df, region==state_var)   #subset just for NYS
    state_sub$county <- state_sub$subregion
    
    ## p <- ggplot(state_sub, aes(long, lat, group=group)) +  geom_polygon(colour='black', fill=NA)
    
    ## Do subsetting based on provider/facility code
    ## Cut provider down to digit code if not Dental or Pharmacy...
    
    ## Create temporary var so we don't have to worry about closures.
    tmp_geo = loc_geo()
    if(input$radioType==1){
      search_string = input$prov_selected
      if(!grepl(pattern = "Dental",x = input$prov_selected ,ignore.case = TRUE)){
        search_string = substr(x = input$prov_selected,start = 1,stop = 3)  
      }
      loc_geo_sub = tmp_geo[grepl(pattern = search_string,x = tmp_geo$Specialty.Type...area.of.medicine.,ignore.case=TRUE),]
    }
    
    ## Subset if searching for facilities.
    if(input$radioType==2){
      search_string = input$fac_selected
      if(!grepl(pattern = "Pharmacy",x = input$fac_selected ,ignore.case = TRUE)){
        search_string = substr(x = input$fac_selected,start = 1,stop = 3)  
      }
      loc_geo_sub = tmp_geo[grepl(pattern = search_string,x = tmp_geo$Facility.Type.,ignore.case=TRUE),]
    }
    
    ###############################################
    ## Should probably seperate this out as function. but we'll just run procedurally
    ## eg IF compare checkbox true, re-run for secondary file.
    if(input$compCheck==TRUE){
    carrier_file_two = reactive({
      read.delim(input$file_comp$datapath,dec=","
                 ,stringsAsFactors = FALSE)
    })
    
    loc_geo_two = reactive({
      
      subzipcode= zipcode[zipcode$state==state_select_abbrev(),]
      
      
      subzipcode$zip = as.integer(subzipcode$zip)
      colnames(subzipcode)[1]="Zip"
      
      tmp = join(x = carrier_file_two(),y=subzipcode,by = "Zip",type='inner')
      
      return(tmp)
    })
    
    loc_geo_sub_two=NULL
    tmp_geo_two = loc_geo_two()
    if(input$radioType==1){
      search_string = input$prov_selected
      if(!grepl(pattern = "Dental",x = input$prov_selected ,ignore.case = TRUE)){
        search_string = substr(x = input$prov_selected,start = 1,stop = 3)  
      }
      loc_geo_sub_two = tmp_geo_two[grepl(pattern = search_string,x = tmp_geo_two$Specialty.Type...area.of.medicine.,ignore.case=TRUE),]
    }
    
    ## Subset if searching for facilities.
    if(input$radioType==2){
      search_string = input$fac_selected
      if(!grepl(pattern = "Pharmacy",x = input$fac_selected ,ignore.case = TRUE)){
        search_string = substr(x = input$fac_selected,start = 1,stop = 3)  
      }
      loc_geo_sub_two = tmp_geo_two[grepl(pattern = search_string,x = tmp_geo_two$Facility.Type.,ignore.case=TRUE),]
    }
    
    
    }
    
    
    ## Set Title string!
    ## Subset if Searching for providers
    if(input$radioType==1){
      title_string = paste("Zip map of",input$state_selector,input$prov_selected,sep=" ")
    }
    
    if(input$radioType==2){
      title_string = paste("Zip map of",input$state_selector,input$fac_selected,sep=" ")
    }
    
    
    p = ggplot(state_sub, aes(long, lat)) + geom_polygon(aes(group=group), colour='black', fill=NA) + geom_point(data = loc_geo_sub,aes(x=longitude,y=latitude),
                                                                                                                 size=5,shape=20,color="black",alpha=1)+ 
      coord_map() + ggtitle(title_string) 
    
    if(input$compCheck==TRUE){
      ## Create and add additional ggplot points.
      p = p + geom_point(data = loc_geo_sub_two,aes(x=longitude,y=latitude),size=3,shape=1,color="blue",alpha=1)
    }
    
    print(p)
  })
  
  
  
  
  
  
})