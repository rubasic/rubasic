library(shiny)
library(spotifyr)
library(stringr)
library(DT)
library(tidyverse)
library(httr)
source("get_tracks_artists.R")

ui <- shinyUI(fluidPage(
  
  titlePanel("Search Spotify"),
  
  sidebarLayout(
    sidebarPanel(
      
      ## ELEMENTS RELATED TO TRACK SEARCH
      textInput("track", "Search for a track and/or an artist"),
      htmlOutput("albumImage"),
      # selectInput("selectTrack", label = "3. Select a track", choices = NULL),    
      checkboxGroupInput("selectTracks", label = "Select tracks", choices = NULL),
      actionButton("addTracks", label = "Add tracks"),
      # tableOutput("yourTracks"),
      # textOutput("count"),
      # textOutput("class"),
      # textOutput("length"),
      # textOutput("dim"),
      actionButton("clearTracks", label = "Clear tracks")
      
      ## ELEMENTS RELATED TO ARTIST SEARCH
      # textInput("artist", "1. Name an artist:"),
      # htmlOutput("artistImage"),
      # selectInput("selectArtist", label = "2. Choose an artist", choices = NULL),
      
    ),
    
    mainPanel(
      # tableOutput("artistTable"),
      # tableOutput("trackTable"),
      # tableOutput("savedTable")li
      # tableOutput("tempTable"),
      tableOutput("masterDF")
    )
  )
))

server <- shinyServer(function(input, output, session) {
  
  # Get Spotify access token 
  Sys.setenv(SPOTIFY_CLIENT_ID = 'a98864ad510b4af6851331638eec170f')
  Sys.setenv(SPOTIFY_CLIENT_SECRET = '6445326414dd4bf381afbc779b182223')
  access_token <- get_spotify_access_token()
  
  ### SEARCH BY TRACK/ARTIST ### 
  # Pulling list of tracks from Spotify
  tracks <- reactive({
    req(input$track)
    # if(!is.null(input$artist)) {
    #     get_tracks_artists(track_artist_name = input$track, artist_name = input$artist, access_token = access_token)
    # }            
    get_tracks_artists(track_artist_name = input$track, access_token = access_token)
  })
  
  # features <- reactive({
  #     req(input$track)
  #     get_track_audio_features(tracks(), access_token = access_token)
  # })
  # 
  # joined <- reactive({
  #     req(input$track)
  #     left_join(x = tracks(), y = features(), by = "track_uri")
  # })
  
  # # Showing the list of track matches
  # output$trackTable <- renderTable({
  #     tracks() %>% select(track_artist)
  # })
  
  # Displaying album image of first match
  output$albumImage <- renderUI({
    if(length(tracks()$album_img[1]) != 0) {
      image_url <- tracks()$album_img[1]
      tags$img(src = image_url, height = 200, width = 200)
    }
  })
  
  # Updating the checkboxes that lets the user choose tracks 
  observeEvent(input$track, {
    choices <- paste(tracks()$track_artist_name, tracks()$artist_name, sep = " - ")
    updateCheckboxGroupInput(
      session = session, inputId = "selectTracks", 
      choices = choices[1:5])
  })
  
  # selected <- data_frame()
  
  # Saving the selected tracks to a dataframe 
  # temp <- c()
  # temp_df <- c()
  
  # Creating a master dataframe that whill hold all information about all tracks added by the user
  master_df <- data_frame()
  
  observeEvent(input$addTracks, {
    # selected_tracks <- c()
    
    # for(i in 1:length(input$selectTracks)) {
    #     selected_tracks <- rbind(temp, input$selectTracks[i])
    # }
    # 
    # output$tempTable <- renderTable({
    #     selected_tracks
    # })
    
    filtered_tracks <- tracks() %>% filter(track_artist %in% input$selectTracks)
    filtered_tracks_unique <- subset(filtered_tracks, !duplicated(filtered_tracks[,1]))
    track_features <- get_track_audio_features(tracks(), access_token = access_token)
    tracks_joined <- left_join(x = filtered_tracks_unique, y = track_features, by = "track_uri")
    master_df <<- bind_rows(master_df, tracks_joined)
    
    # features <- reactive({
    #     req(input$track)
    #     get_track_audio_features(tracks(), access_token = access_token)
    # })
    # 
    # joined <- reactive({
    #     req(input$track)
    #     left_join(x = tracks(), y = features(), by = "track_uri")
    # })
    # 
    # vec <- as.vector(input$selectTracks)
    # temp_df <- data_frame()
    # tt <- tracks() %>% filter(track_artist==selectedT[1])
    # 
    # tt <- joined() %>% filter(track_artist %in% input$selectTracks) 
    # tt <- subset(tt, !duplicated(tt[,1]))
    
    
    # for(i in 1:length(input$selectTracks)) {
    #     tt <- tracks() %>% filter(track_artist %in% input$selectTracks)
    #     # temp_df <<- rbind(temp_df, tt)
    # }
    
    output$masterDF <- renderTable({
      master_df
    })
  })
  
  # Clearing the dataframe with saved tracks
  observeEvent(input$clearTracks, {
    master_df <<- tibble()
    output$masterDF <- renderTable({
      master_df
    })
  })
  
  # Output used for debugging and testing
  # observeEvent(input$selectTracks, {
  #   selected <<- input$selectTracks
  #   
  #   output$count <- renderText({
  #     selected[1]
  #   })
  #   
  #   output$class <- renderText({
  #     selected %>% class()
  #   })
  #   
  #   output$length <- renderText({
  #     length(input$selectTracks)
  #   })
  #   
  #   output$dim <- renderText({
  #     dim(selected)
  #   })
  # })
  
  # Updating dropdown manu with potential matches on Track
  # observeEvent(input$track, {
  #   choices <- tracks()$track_artist_name
  #   updateSelectInput(session, "selectTrack", choices = choices)
  # })
  
  ### OPTION: SEARCH BY ARTIST ###
  # Pulling list of artists from Spotify 
  # artists <- reactive({
  #     req(input$artist)
  #     get_artists(artist_name = input$artist, access_token = access_token) 
  # })
  
  # # Showing the list of potential artist matches 
  # output$artistTable <- renderTable({
  #     artists()$artist_name
  #     
  # },
  # colnames = FALSE)
  
  # Showing image of the first artist match
  # output$artistImage <- renderUI({
  #   image_url <- artists()$artist_img[1]
  #   tags$img(src = image_url, height = 200, width = 200)
  # })
  
  # Updating dropdown menu with artist matches
  # observeEvent(input$artist, {
  #   choices <- artists()$artist_name
  #   updateSelectInput(session, "selectArtist", choices = choices)
  # })
  
})

# Run the application 
shinyApp(ui = ui, server = server)

