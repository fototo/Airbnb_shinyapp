webss <- data.frame(name=c("Web1", "Web2"), w=c('Inside Airbnb','Airbnb Business Model'))

shinyServer(function(input, output, session) {

  ## Overview ###########################
  #
  ## NYC Interactive Map ##############################
  # reactivate map info
  mapdf <- reactive({
    nycmap %>%
        filter(boro %in% input$select_boro & 
               room_type %in% input$select_room & 
               price >= input$slider_price[1] &
               price <= input$slider_price[2] &
               review_scores_rating >= input$slider_rating[1] &
               review_scores_rating <= input$slider_rating[2] &
               number_of_reviews >= input$slider_review[1] &
               number_of_reviews <= input$slider_review[2]) 
  })
  
  # create the map
  output$map <- renderLeaflet({
    leaflet() %>% 
      addProviderTiles("Esri.WorldStreetMap") %>%
      #addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
               #attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>% 
      addLegend(position = "bottomleft", pal = groupColors, values = room, opacity = 1,title = "Room Type") %>% 
      setView(lng = -73.9772, lat = 40.7527, zoom = 12)
  })
  
  observe({
    proxy <- leafletProxy("map",data = mapdf()) %>% #dont forget ()
      clearMarkerClusters() %>% 
      clearMarkers() %>%
      addCircleMarkers(~longitude,~latitude,radius=2,color = ~groupColors(room_type),
                 group = "CIRCLE",
                 popup = ~paste('<b><font color="Black">','Listing Information','</font></b><br/>',
                                'Room Type:', room_type,'<br/>',
                                'Price:', price,'<br/>',
                                'Rating Score:', review_scores_rating, '<br/>',
                                'Number of Reviews:',number_of_reviews,'<br/>')
                 # popup = ~paste("Room Type:", room_type,
                 #                "Price:", price,
                 #                "Rating Score:", review_scores_rating,
                 #                "Number of Reviews:",number_of_reviews,
                 #                 sep = "<br/>")
                 ) %>% 
      addCircleMarkers(~longitude,~latitude,clusterOptions = markerClusterOptions(), group = "CLUSTER" ) %>% 
      addLayersControl(
       baseGroups = c("CIRCLE","CLUSTER"),
       options = layersControlOptions(collapsed = FALSE)
     ) 
    })
  
  ## reactivate count info
  countdf <- reactive({
    mapdf() %>%
      group_by(., room_type) %>%
      summarise(., count_type=n())
  })
  
  #map graph1
  output$count_room <- renderPlotly({
    plot_ly(data = countdf(), x= ~room_type, y=~count_type, type="bar", color=~room_type,
            colors = c('#E03A3C','#009DDC','#62BB47'),
            hoverinfo = 'text',
            text = ~count_type) %>%
      layout(xaxis = list(title="", showticklabels = FALSE),
             yaxis = list(title = "count"), showlegend = FALSE,
             annotations = list(x = ~room_type, y = ~count_type, text = ~paste(round(count_type/sum(count_type),2)*100,'%'),
                                xanchor = 'center', yanchor = 'bottom',
                                showarrow = FALSE)) %>% 
      config(displayModeBar = FALSE)
  })
  
  # reactivate price info
  pricedf <- reactive({
    mapdf() %>% 
      group_by(., room_type) %>% 
      summarise(.,avg_price=round(mean(price),2))
  })
  
  #map graph2 avgprice
  output$avgprice <- renderPlotly({
    plot_ly(data = pricedf(),x=~room_type,y=~avg_price, type="bar", color=~room_type,
                  colors = c('#E03A3C','#009DDC','#62BB47'),
                  hoverinfo = 'text',
                  text = ~avg_price) %>% 
      layout(xaxis = list(title="", showticklabels = FALSE), 
             yaxis = list(title = "price"),showlegend = FALSE,
             annotations = list(x = ~room_type, y = ~avg_price, text = ~paste('$',avg_price),
                                xanchor = 'center', yanchor = 'bottom', 
                                showarrow = FALSE)) %>% 
      config(displayModeBar = FALSE)
  })
  
  
  ## Listings, Boroughs and Price Changes #######################
  graph1df <- reactive({
    nycmap %>%
      select(boro,room_type,price,review_scores_rating) %>% 
      filter(price >= input$tab2_price[1] &
             price <= input$tab2_price[2] &
             review_scores_rating >= input$tab2_rating[1] &
             review_scores_rating <= input$tab2_rating[2]) %>% 
      group_by(boro,room_type) %>% 
      summarise(n=n())
  })
  
  output$graph1 <- renderPlotly({
    t <- list(size = 9)
    plot_ly(data = graph1df(), x=~n, y=~room_type, type="bar", color=~boro,
            colors=c('#800080','#009DDC','#E03A3C','#62BB47','#FFA500'),
            orientation = 'h', showlegend = TRUE) %>%
      layout(xaxis = list(title = "count"),
             yaxis = list(title = ""), 
             barmode = 'dodge', font = t)
  })
  
  
  output$tab_price <- renderPlotly({
    if(input$price_option=='Year'){
      m <- list(size=8)
      plot_ly(data = overall, x=~year, y=~avg_pricemo, type = 'scatter', mode='markers', linetype = I('solid')) %>% 
        layout(xaxis = list(title = "", showticklabels = TRUE),
               yaxis = list(title = "price"),showlegend = FALSE, font=m)} else{
                 
      plot_ly(data = timedf, x=~month, y=~avg_pricemo, type='scatter', mode='markers',
              color=~year, colors = c('#009DDC','#E03A3C','#62BB47','#FFA500')) %>%
        add_trace(y=~avgyrmo_price, type='scatter', mode='markers+lines', name='average',evaluate = TRUE) %>% 
        layout(xaxis = list(title = "month", showticklabels = TRUE),
               yaxis = list(title = "price"),showlegend = TRUE)}
 })

  ## References ###########
  
  # loadframe <- reactive({
  #   if(input$web == "Inside Airbnb"){
  #     a(href="http://insideairbnb.com/get-the-data.html")
  #   }
  #   if(input$web == "Airbnb Business Model"){
  #     a(href="http://bmtoolbox.net/stories/airbnb/")
  #   }
  # })
  # 
  # output$frame <- renderUI({
  #   input$web
  #   indi <- tags$iframe(src=loadframe(), height=700, width=900)
  #   print(indi)
  #   # indi
  # })
  


})#function