if ( !require(shiny) ) install.packages('shiny')
library('shiny')

shinyServer(function(input, output) {

     #Initialize Data
     if(!(exists('regionData') & exists('regionInfo'))) source("initialize.R")

     ##########################################################################
     ############################ Creating the Maps ###########################
     ##########################################################################

     #    Main functions

     updateMarkers <- function(){

         startTime <- Sys.time()

         leafletProxy('Map') %>% clearMarkers()

         regionName <- regionInfo[input$region, ]$Name

         regionEvents <- terrorismData[terrorismData$iyear == input$year &
                                terrorismData$region2 == regionName,]

         mapshapes <- worldshapes[worldshapes$region_wb == regionName,]

         mapdata <- regionData[regionData$Year == input$year &
                            regionData$Country %in% mapshapes$admin,]
#
#          startTimePlotPoints <- Sys.time()

             #         Checks if there are any events for that year and breaks if there aren't any
             if(nrow(regionEvents) == 0) return()

             #         Renders markers if there are
             leafletProxy('Map') %>% addCircleMarkers(
                 lng=regionEvents$longitude, lat=regionEvents$latitude,
                 color = "red", opacity = .2, weight = 7,
                 fillColor = "yellow", fillOpacity = .7,
                 radius = regionEvents$severity,
                 popup=regionEvents$info
             )

#          print(paste("Time to plot markers:", Sys.time()-startTimePlotPoints))

         runTime <- Sys.time() - startTime

         numIncidents <- length(regionEvents$iyear)
#          print(paste("Number of incidents:", numIncidents))
         print(paste("Time to update markers:", runTime))
#          print(paste("Time per incident:", runTime/numIncidents))

     }
     updateRegion <- function(){

         startTime <- Sys.time()

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

         runTime <- Sys.time() - startTime
         print(paste("Time to update region:", runTime))
     }

     #    Create blank map
     output$Map <- renderLeaflet({
         leaflet()  %>%
             addProviderTiles("CartoDB.Positron")
         #                addTiles('http://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}.png')
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

