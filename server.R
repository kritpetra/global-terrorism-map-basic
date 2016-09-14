# Code may need to be optimized -- is it possible to create the content in the
# popups only when the user clicks on it?

# Idea to improve performance:
# http://stackoverflow.com/questions/29173336/how-to-display-advanced-customed-popups-for-leaflet-in-shiny

if ( !require(shiny) ) install.packages('shiny')
library('shiny')

shinyServer(function(input, output) {

     # Checks if data is already loaded, and initializes data with a progress bar otherwise
     if(!(exists('regionData') & exists('regionInfo'))) source("initialize.R")

     ##########################################################################
     ############################ Creating the Maps ###########################
     ##########################################################################

     # Main functions

     updateMarkers <- function(){

         regionName <- regionInfo[input$region, ]$Name

         regionEvents <- terrorismData[terrorismData$iyear == input$year &
                                terrorismData$region2 == regionName,]

         mapshapes <- worldshapes[worldshapes$region_wb == regionName,]

         mapdata <- regionData[regionData$Year == input$year &
                            regionData$Country %in% mapshapes$admin,]

             # Checks if there are any events for that year and breaks if there aren't any
             if(nrow(regionEvents) == 0) return()

             # Renders markers if there are
			 leafletProxy('Map') %>% clearMarkers()
             leafletProxy('Map') %>% addCircleMarkers(
                 lng=regionEvents$longitude, lat=regionEvents$latitude,
                 color = "red", opacity = .2, weight = 7,
                 fillColor = "yellow", fillOpacity = .7,
                 radius = regionEvents$severity,
                 popup = regionEvents$info
             )

     }
     updateRegion <- function(){
         region <- regionInfo[input$region,]

         regionName <- regionInfo[input$region, ]$Name
         mapshapes <- worldshapes[worldshapes$region_wb == regionName,]

         leafletProxy('Map') %>%
             clearShapes %>%
             clearControls %>%
             clearMarkers %>%
             setView(region$X, region$Y, zoom = region$Z) %>%
             addPolygons(
                 data = mapshapes, layerId = ~admin,
                 weight = 2, fillColor = "#12AFFF",
                 color = "black", fillOpacity = 0.3)
     }

     # Create blank map
     output$Map <- renderLeaflet({
         leaflet()  %>%
             addProviderTiles("CartoDB.Positron")
	})

     #    Updates polygons and markers whenever year changes
     observeEvent({input$year}, {
          updateMarkers()
     })

     #    Reloads everything when new region selected
     observeEvent({input$region}, {
          updateRegion()
          updateMarkers()
     })



     ###############################################################################
     ##################### Creating the Information Box ############################
     ###############################################################################



     # Text to be displayed in the side bar
     output$sidebarText <- renderText({"
          <div style='padding:1em'>
               Click on an incident for more details, or
               search the <a href='http://www.start.umd.edu/gtd/search/BrowseBy.aspx'>
               Global Terrorism database</a>.
          </div>

          <div style='padding:1em'>
               <b>Note:</b> The locations of some incidents had to be estimated
               with the <a href='http://www.geonames.org/'>GeoNames database</a>.
               As a result, a few markers may appear in weird places!
          </div>

          <div style='padding:1em'>
               More resources for instructors: <a href=''>Stats2Labs</a>.
		  </div>
          "})

})

