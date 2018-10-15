#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(leaflet)
library(tidyverse)
library(feather)
library(DT)
library(plotly)
library(RPostgreSQL)
library(shinyWidgets)
library(leaflet.extras)
library(htmlwidgets)
library(shinyjs)
library(shinyBS)
library(writexl)

pg = dbDriver("PostgreSQL")


con = dbConnect(pg, user = Sys.getenv("DATABASE_USERNAME") , password = Sys.getenv("DATABASE_PASSWORD"),
                host=Sys.getenv("DATABASE_HOST"), port=Sys.getenv("DATABASE_PORT"), dbname= Sys.getenv("DATABASE_NAME"))

query <- dbSendQuery(con, 'select * from operations;')
operations <- fetch(query, n=-1)
dbClearResult(query)

query <- dbSendQuery(con, 'select * from operations_stats;')
operations_stat <- fetch(query, n=-1)
dbClearResult(query)

dbDisconnect(con)

srr_etel <- read_file('kml_srr/etel.kml')
departements <- read_file('kml_srr/DEPARTEMENTS.kml')
srr_corsen <- read_file('kml_srr/corsen.kml')
srr_grisnez <- read_file('kml_srr/gris-nez.kml')
srr_antillesguyane <- read_file('kml_srr/antilles-guyane.kml')
srr_lagarde <- read_file('kml_srr/la-garde.kml')
srr_jobourg <- read_file('kml_srr/jobourg.kml')
srr_lareunion <- read_file('kml_srr/la-reunion.kml')
srr_noumea <- read_file('kml_srr/noumea.kml')
srr_tahiti <- read_file('kml_srr/tahiti.kml')

secmar <- plyr::join(operations, operations_stat, by='operation_id', type="inner")
secmar <- secmar %>% mutate(saison = ifelse(mois>4 & mois<10, 'Haute saison', 'Basse saison')) %>%
                     mutate(sans_flotteur = ifelse(nombre_flotteurs_commerce_impliques > 0 |
                                                          nombre_flotteurs_plaisance_impliques > 0 |
                                                          nombre_flotteurs_loisirs_nautiques_impliques > 0 |
                                                          nombre_flotteurs_peche_impliques > 0 |
                                                          nombre_flotteurs_autre_impliques > 0 |
                                                          nombre_aeronefs_impliques, 0, 1 )) %>% 
                     mutate(distance_cote_milles_nautiques = if_else(is.na(distance_cote_milles_nautiques), 0, distance_cote_milles_nautiques)) 

secmar <- secmar %>%
  mutate(distance_cote_milles_nautiques_cat = as.character(cut(distance_cote_milles_nautiques,
                                                               breaks = c(-Inf, 2, 6, 60, Inf),
                                                               labels = c("0-2 milles", "2-6 milles", "6-60 milles", "+60 milles"))))

secmar <- secmar %>% mutate(vent_direction_categorie = factor(vent_direction_categorie, levels = c("nord-ouest", "nord", "nord-est", "est", "sud-est", "sud", "sud-ouest", "ouest"),
                                                                                        labels = c("NO", "N", "NE", "E", "SE", "S", "SO", "O")))

secmar <- secmar %>% mutate(date_heure = as.numeric(format(date_heure_reception_alerte, "%H")) +
                              as.numeric(format(date_heure_reception_alerte, "%M"))/60)
secmar <- secmar %>% mutate(type_operation = replace_na(type_operation, "Non renseigné"))

flotteur_choices <- c('Commerce', 'Plaisance', 'Loisirs nautiques', 'Pêche', 'Autre', 'Aeronéf', 'Sans flotteur')
flotteur_choices_dico <- c('Commerce' = 'nombre_flotteurs_commerce_impliques',
                            'Plaisance' = 'nombre_flotteurs_plaisance_impliques',
                            'Loisirs nautiques' = 'nombre_flotteurs_loisirs_nautiques_impliques',
                            'Pêche' = 'nombre_flotteurs_peche_impliques',
                            'Autre' = 'nombre_flotteurs_autre_impliques',
                            'Aeronéf' = 'nombre_aeronefs_impliques',
                            'Sans flotteur' = 'sans_flotteur')

secmar_2017 <- secmar %>% filter(annee == 2017)

#secmar <- read_feather("../../sauvamer/accident2017.feather")


ui <- dashboardPage(
  dashboardHeader(title = #tags$a(href='https://www.snosan.fr/',
                                 'Carte Secmar'
                                 #)
                  ),

  ## Sidebar content
  dashboardSidebar(
    width = 280,
    sidebarMenu(
      div(
        div(style="width:50%; display:inline-block;",
            switchInput("snosan", value = FALSE, label = "SNOSAN")
            ),
        div(
          style="display:inline-block; ",
          bsButton("q1", label = "", icon = icon("question"),
                   style = "info", size = "extra-small"),
          bsPopover("q1", title ="", content = "Le SNOSAN prend en compte les opérations sur des flotteurs de plaisance, loisirs nautiques et annexes.", 
                    placement = "right",  options = list(container = "body")
                    )
        )
      )
     , 
      switchInput("heatmap", value = FALSE, size = 'mini',
                  onLabel = 'Heatmap', offLabel = 'Cluster', label = 'Changer de visualisation'),
        dateRangeInput('dateRange',
                              label = "Date d'intervention",
                              start = '2017-01-01', end = '2017-12-31',
                              separator = " - ", startview = "year", format = "dd/mm/yyyy"
            ), 
     menuItem("Évenement", tabName = "event", icon = icon("anchor"),
              checkboxInput('eve', 'Tout sélectionner/désélectionner', value = TRUE),
              selectizeInput(inputId="evenement", label=h5("Quel motif d'intervention ?"),
                             choices=unique(secmar$evenement),
                             multiple = TRUE)),
     menuItem("CROSS", tabName = "cross", icon = icon("male"),
              pickerInput(inputId="cross", label=h5("Quel CROSS a coordoné l'intervention ?"),
                          choices=unique(secmar$cross),
                          options = list(
                            `selected-text-format` = "count > 5",
                            `count-selected-text` = "{0} CROSS sélectionnés",
                            `actions-box` = TRUE,
                            `deselect-all-text` = "Tout désélectionner",
                            `select-all-text` = "Tout sélectionner"
                          ),
                          selected = unique(secmar$cross),
                          multiple = TRUE)),
     menuItem("Heure et saison", tabName = "season", icon = icon("hourglass"),
              checkboxGroupButtons("saison", label="Saison",justified = TRUE,
                                   status = "primary",
                                   checkIcon = list(yes = icon("ok", lib = "glyphicon"), no = icon("remove", lib = "glyphicon")),
                                   choices = unique(secmar$saison), selected = unique(secmar$saison)),
              bsPopover("saison", title = "", content = "La haute saison concerne les opérations du 1er mai au 30 septembre.", 
                        placement = "right", options = list(container = "body")),
              sliderInput("heure", label = "Heure de l'alerte (UTC)", min = 0, 
                          max = 24, value = c(0,24))),
      menuItem("Type d'opérations", tabName = "op", icon = icon("ambulance"),
               pickerInput(inputId="operation", label=h5("Quel type d'intervention ?"),
                           choices=unique(secmar$type_operation),
                           options = list(
                             `selected-text-format` = "count > 5",
                             `count-selected-text` = "{0} types sélectionnés",
                             `actions-box` = TRUE,
                             `deselect-all-text` = "Tout désélectionner",
                             `select-all-text` = "Tout sélectionner"
                           ),
                           selected = unique(secmar$type_operation),
                           multiple = TRUE)),
      menuItem("Flotteur", tabName = "boat", icon = icon("ship"),
               h5("Quel type de flotteur a été impliqué ?"),
               pickerInput(inputId="flotteur",
                           choices=flotteur_choices,
                           options = list(
                             `selected-text-format` = "count > 5",
                             `count-selected-text` = "{0} flotteur sélectionnés",
                             `actions-box` = TRUE,
                             `deselect-all-text` = "Tout désélectionner",
                             `select-all-text` = "Tout sélectionner"
                           ),
                           selected = flotteur_choices,
                           multiple = TRUE)
               ),
      menuItem("Gravité", tabName = "gravite", icon = icon("heartbeat"),
               "Intervention impliquant au moins", br(), "1 décédé ou disparu",
               switchInput("deces", value = FALSE, size = 'mini'),
               "Intervention impliquant au moins", br(), "1 moyen aérien",
               switchInput("aerien", value = FALSE, size = 'mini')
               ),
     menuItem("Distance des côtes et responsabilité", tabName = "cote", icon = icon("globe"),
              "",
              pickerInput(inputId="cotes", label=h5("A quelle distance des côtes se déroule les interventions ?"),
                                                choices=unique(secmar$distance_cote_milles_nautiques_cat),
                                                options = list(
                                                  `selected-text-format` = "count > 5",
                                                  `count-selected-text` = "Toutes les distances",
                                                  `actions-box` = TRUE,
                                                  `deselect-all-text` = "Tout désélectionner",
                                                  `select-all-text` = "Tout sélectionner"
                                                ),
                                                selected = unique(secmar$distance_cote_milles_nautiques_cat),
                                                multiple = TRUE),
              pickerInput(inputId="zones", label=h5("Quelle est la zone de responsabilité de l'intervention ?"),
                          choices=unique(secmar$zone_responsabilite),
                          options = list(
                            `selected-text-format` = "count > 5",
                            `count-selected-text` = "Toutes les zones",
                            `actions-box` = TRUE,
                            `deselect-all-text` = "Tout désélectionner",
                            `select-all-text` = "Tout sélectionner"
                          ),
                          selected = unique(secmar$zone_responsabilite),
                          multiple = TRUE)   
     ),
     menuItem("Code source", icon = icon("file-code-o"),
              href = "https://github.com/entrepreneur-interet-general/predisauvetage"),
     menuItem("Documentation", icon = icon("book"),
              href = "https://mtes-mct.github.io/secmar-documentation") ,     
   downloadButton("downloadData", "Télécharger les données dans la zone (Excel)", style='padding:5px; font-size:80%'),
   br(),
   br(),
   downloadButton("downloadDataCSV", "Télécharger les données dans la zone (CSV)", style='padding:5px; font-size:80%')
  )
  ),

  ## Body content
  dashboardBody(
    #tabItems(
     # tabItem(tabName = "dashboard",
              fluidPage(
                div(class="outer",
                tags$style(type = "text/css", ".outer {position: fixed; top: 41px; left: 0; right: 0; bottom: 0; overflow: hidden; padding: 0}"),
                leafletOutput("mymap", height = "100%", width = "100%"),
                column(5, verbatimTextOutput("textbounds")),
                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                              draggable = TRUE, top = 20, left = "auto", right = 20, bottom = "auto",
                              width = 350, height = "auto",
                     div(style="padding: 10px;",          
                     br(),
                     h4(textOutput("operation")),
                     br(),
                     selectizeInput(inputId = "pie", label = "Choisissez votre visualisation",
                                    multiple = FALSE,
                                    choices = c('Répartition du top 5 événements',
                                                'Répartition du bilan humain',
                                                'Répartition phase de la journée',
                                                'Répartition des flotteurs',
                                                'Répartition nombre de moyens engagés',
                                                'Répartition heures de moyens engagés',
                                                'Evolution temporelle'),
                                    selected = 'Répartition du bilan humain'),
                     plotlyOutput(outputId= "camembert", height = "250px"),
                     br(),
                     selectizeInput(inputId = "histo", multiple = FALSE,
                                    label = "Choisissez votre visualisation",
                                    choices = c('Force du vent', 'Force de la mer', 'Direction du vent'),
                                    selected = 'Force du vent'),
                     br(),
                     plotOutput(outputId = "hist", height = "200px"))
               # )
          #  )
         )
      )
    )
  )
)

server <- function(input, output, session) {

  snosanInput <- reactive({
    if (input$snosan == FALSE) {
      secmar %>% drop_na(longitude, latitude)
    } else {
      secmar %>% drop_na(longitude, latitude) %>% filter(concerne_snosan == TRUE)
    }

  })

  crossInput <- reactive({
   # if (input$cross == "all") {
    #  snosanInput()
   # } else {
      snosanInput() %>% filter(cross %in% input$cross)
  #  }

  })
  
  operationInput <- reactive({
    crossInput() %>% filter(type_operation %in% input$operation)
  })


  observe({
    updateSelectizeInput(
      session, 'evenement', choices = unique(secmar$evenement),
      selected = if (input$eve) unique(secmar$evenement)
    )
  })

  evenementInput <- reactive({
      operationInput() %>% filter(evenement %in% input$evenement)

  })
  
  

  
  cotesInput <- reactive({
    evenementInput() %>% filter(distance_cote_milles_nautiques_cat %in% input$cotes)
    
  })
  
  zonesInput <- reactive({
    cotesInput() %>% filter(zone_responsabilite %in% input$zones)
    
  })


  dateInput <- reactive({
    zonesInput() %>% filter(date >= input$dateRange[1] & date <= input$dateRange[2] )
  })

  saisonInput <- reactive({
    dateInput() %>% filter(saison %in% input$saison)
  })
  
  heureInput <- reactive({
    saisonInput() %>% filter(date_heure >= input$heure[1] & date_heure <= input$heure[2])
  })


  decesInput <- reactive({
    if (input$deces == FALSE) {
      heureInput()
    } else {
      heureInput() %>% filter(nombre_personnes_tous_deces_ou_disparues > 0)
    }

  })

  aerienInput <- reactive({
    if (input$aerien == FALSE) {
     decesInput()
    } else {
      decesInput() %>% filter(nombre_moyens_aeriens_engages > 0)
    }

  })


  flotteurInput <- reactive({
   if (length(input$flotteur) == length(flotteur_choices)){
    aerienInput()
   } else if (is.null(input$flotteur)) {
      aerienInput() %>% filter(evenement %in% (""))
  } else {
#Mapper la liste des noms et il faut ajouter une colonne sans navire aussi
     list <- plyr::revalue(input$flotteur, flotteur_choices_dico)
     filter_at(aerienInput(), vars(list), any_vars(. > 0))
  }

  })


  # icons <- awesomeIcons(
  #   icon = 'ios-close',
  #   iconColor = 'black',
  #   library = 'ion',
  #   markerColor = secmar$color
  # )

  output$mymap <- renderLeaflet({

    leaflet(secmar_2017) %>% 
      addTiles() %>%  addProviderTiles(providers$OpenSeaMap, group = "OpenSeaMap") %>%  
      addTiles(urlTemplate = 'https://wxs.ign.fr/an7nvfzojv5wa96dsga5nk8w/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.COASTALMAPS&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fpng&TileMatrix={z}&TileCol={x}&TileRow={y}', attribution = '&copy; https://www.geoportail.gouv.fr', group = "IGN") %>%
      addTiles(urlTemplate = 'https://geoapi.fr/shomgt/tile.php/gtpyr/{z}/{x}/{y}.png',  attribution =  '<a href="http://www.shom.fr/">SHOM</a>', group = "SHOM") %>%
      setView(lng = 0.340375, lat = 46.580224, zoom = 6) %>%
      addMarkers(~longitude, ~latitude,
                 popup=~paste("CROSS : ", cross,
                              "</br> Evénement : " , evenement,
                              "</br> Sitrep : ", cross_sitrep,
                              "</br> Date et heure de l'alerte (UTC) : ", date_heure_reception_alerte,
                              "</br> Nombre de personnes décédées ou disparues : ", nombre_personnes_tous_deces_ou_disparues,
                              "</br> Distance des côtes (milles) : ", distance_cote_milles_nautiques),
                  clusterOptions = markerClusterOptions()) %>%
      addLayersControl(baseGroups = c("OpenSeaMap", "SHOM", "IGN")) #%>% htmlwidgets::onRender("
            # function(el,x) {
            #    var map = this
            #    var markers = L.markerClusterGroup({ maxClusterRadius: function(zoom) {return (zoom > 10) ? 40 : 80}}).addTo(map);
            #  }")
  })

  observe({
   
    if (input$heatmap == FALSE) {
      m <- leafletProxy("mymap", data = flotteurInput()) %>% clearHeatmap() %>% clearMarkerClusters()
    #if (nrow(flotteurInput())>100){
      m %>% addMarkers(~longitude, ~latitude,
                       popup=~paste("CROSS : ", cross,
                                    "</br> Evénement : " , evenement,
                                    "</br> Sitrep : ", cross_sitrep,
                                    "</br> Date et heure de l'alerte (UTC) : ", date_heure_reception_alerte,
                                    "</br> Nombre de personnes décédées ou disparues : ", nombre_personnes_tous_deces_ou_disparues,
                                    "</br> Distance des côtes (milles) : ", distance_cote_milles_nautiques),
                       clusterOptions = markerClusterOptions()) %>% 
        addKML(srr_etel,  color = 'grey',fill=FALSE, weight = 1.5, label = "Etel", labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),textsize = "15px", opacity = 4, color = "black",
          direction = "auto")) %>% 
        addKML(departements,  color = '#00997a', fill=FALSE, weight = 1) %>% 
        addKML(srr_corsen,  color = 'grey',fill=FALSE, weight = 1.5) %>% 
        addKML(srr_grisnez,  color = 'grey',fill=FALSE, weight = 1.5) %>% 
        addKML(srr_antillesguyane,  color = 'grey',fill=FALSE, weight = 1.5) %>% 
        addKML(srr_lagarde,  color = 'grey',fill=FALSE, weight = 1.5) %>% 
        addKML(srr_jobourg,  color = 'grey',fill=FALSE, weight = 1.5) %>% 
        addKML(srr_lareunion,  color = 'grey',fill=FALSE, weight = 1.5) %>% 
        addKML(srr_noumea,  color = 'grey',fill=FALSE, weight = 1.5) %>% 
        addKML(srr_tahiti,  color = 'grey',fill=FALSE, weight = 1.5) 
      
      
    } else if (input$heatmap == TRUE) {
      m <- leafletProxy("mymap", data = flotteurInput()) %>% clearHeatmap() %>% clearMarkerClusters()
      m %>% addHeatmap(group="heat", lng=~longitude, lat=~latitude, blur=20, radius = 11)
    }
   # } else {
    #   m %>% addMarkers(~longitude, ~latitude,
    #                    popup=~paste("CROSS : ", cross,
    #                                 "</br> Evénement : " , evenement,
    #                                 "</br> Sitrep : ", cross_sitrep,
    #                                 "</br> Date et heure de l'alerte (UTC) : ", date_heure_reception_alerte,
    #                                 "</br> Nombre de personnes décédées ou disparues : ", nombre_personnes_tous_deces_ou_disparues,
    #                                 "</br> Distance des côtes (milles) : ", distance_cote_milles_nautiques))
    # }

  })

  zipsInBounds <- reactive({
    req(input$mymap_bounds)
    bounds <- input$mymap_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)

    subset(flotteurInput(),  latitude >= latRng[1] & latitude <= latRng[2] & longitude >= lngRng[1] & longitude <= lngRng[2])
  })

 output$text <- DT::renderDataTable({
   zipsInBounds()
 })


# output$plot <- renderPlotly({
 #  gg <- zipsInBounds() %>% ggplot(aes(x=moyen_alerte)) + geom_bar() + labs(x="Moyen d'alerte", y="Fréquence") + theme_minimal()
   #ggplotly(gg)
  # plot_ly(zipsInBounds(), y = ~moyen_alerte)
 #})

 output$operation <- renderText({
     paste(nrow(zipsInBounds()), " interventions aux CROSS sur la période selectionnée et sur la zone affichée")
 })


 histogram <- reactive({
   if (input$histo == 'Force du vent'){
     ggplot(zipsInBounds(), aes(x=as.factor(vent_force)))+
       geom_bar(fill="lightgrey") +
       labs(x= "Force du vent", y="Fréquence")+
       theme_minimal()
   } else if (input$histo == 'Force de la mer'){
     ggplot(zipsInBounds(), aes(x=as.factor(mer_force)))+
        geom_bar(fill="#56B4E9") +
        labs(x= "Force de la mer", y="Fréquence")+
        theme_minimal()
   } else if (input$histo == 'Direction du vent') {
     ggplot(zipsInBounds(), aes(x=vent_direction_categorie))+
       geom_bar(fill="#FF0000") +
       labs(x= "Direction du vent", y="Fréquence")+
       theme_minimal()
   }
 })

 output$hist <- renderPlot({
   if (nrow(zipsInBounds()) == 0)
     return("a")
   histogram()
  })


 cam <- reactive({
   if (input$pie == 'Répartition du bilan humain'){
     secmar_bilan <- zipsInBounds()  %>% select(nombre_personnes_disparues, nombre_personnes_assistees, nombre_personnes_impliquees_dans_fausse_alerte, nombre_personnes_tirees_daffaire_seule, nombre_personnes_retrouvees, nombre_personnes_secourues, nombre_personnes_tous_deces)  %>% replace(is.na(.), 0)
     names(secmar_bilan) <- c("Diparues", "Assistées", "Impliquées dans fausses alertes", "Tirées d'affaires elles mêmes", "Retrouvées", "Secourues", "Décédées")
     sumdata <- data.frame(value=apply(secmar_bilan,2,sum))
     sumdata$key=rownames(sumdata)
     #bilan <- ggplot(data=sumdata, aes(x="", y=value, fill=key)) +
     # geom_bar(position_fill="stack", stat = "identity") + coord_polar("y", start=0) + theme(legend.position = "none")
     #ggplotly(bilan)
     plot_ly(sumdata, labels=~key, values=~value)%>% add_pie(hole = 0.4) %>% layout(showlegend = TRUE, legend = list(font = list(size=5),
                                                                                                                     orientation = 'v'),
                                                                                    margin = list(b = 0))
   } else if (input$pie == 'Répartition des flotteurs'){
     secmar_flotteur <- zipsInBounds() %>% select(nombre_flotteurs_commerce_impliques, nombre_flotteurs_peche_impliques, nombre_flotteurs_plaisance_impliques, nombre_flotteurs_loisirs_nautiques_impliques, nombre_flotteurs_autre_impliques)  %>% replace(is.na(.), 0)
     names(secmar_flotteur) <- c("Commerce", "Pêche", "Plaisance", "Loisirs nautiques", "Autre")
     sumdata_flotteur <- data.frame(value=apply(secmar_flotteur,2,sum))
     sumdata_flotteur$key=rownames(sumdata_flotteur)
     plot_ly(sumdata_flotteur, labels=~key, values=~value) %>% add_pie(hole = 0.4) %>% layout(showlegend = TRUE, legend = list(font = list(size=5),
                                                                                                                               orientation = 'v'),
                                                                                              margin = list(b = 0))
     
   } else if (input$pie == "Répartition nombre de moyens engagés") {
     secmar_moyens <- zipsInBounds() %>% select(nombre_moyens_nautiques_engages, nombre_moyens_terrestres_engages, nombre_moyens_aeriens_engages)  %>% replace(is.na(.), 0)
     names(secmar_moyens) <- c('Moyens nautiques', "Moyens terrestres", 'Moyens aériens')
     sumdata_moyens <- data.frame(value=apply(secmar_moyens,2,sum))
     sumdata_moyens$key=rownames(sumdata_moyens)
     plot_ly(sumdata_moyens, labels=~key, values=~value) %>% add_pie(hole = 0.4) %>% layout(showlegend = TRUE, legend = list(font = list(size=5),
                                                                                                                             orientation = 'v'),
                                                                                            margin = list(b = 0))
     
     
   } else if (input$pie == "Répartition heures de moyens engagés") {
     secmar_moyens_heures <- zipsInBounds() %>% select(duree_engagement_moyens_nautiques_heures, duree_engagement_moyens_terrestres_heures, duree_engagement_moyens_aeriens_heures)  %>% replace(is.na(.), 0)
     names(secmar_moyens_heures) <- c('Heures moyens nautiques', "Heures moyens terrestres", 'Heures moyens aériens')
     sumdata_moyens <- data.frame(value=apply(secmar_moyens_heures,2,sum))
     sumdata_moyens$key=rownames(sumdata_moyens)
     plot_ly(sumdata_moyens, labels=~key, values=~value) %>% add_pie(hole = 0.4) %>% layout(showlegend = TRUE, legend = list(font = list(size=5),
                                                                                                                             orientation = 'v'),
                                                                                            margin = list(b = 0))
     
     
   } else if (input$pie == 'Répartition du top 5 événements'){
     grouped_event <- zipsInBounds() %>% dplyr::group_by(evenement) %>% summarize(count = n()) %>% top_n(5) %>% arrange(desc(count))
     grouped_event$evenement <- factor(grouped_event$evenement, levels = unique(grouped_event$evenement)[order(grouped_event$count, decreasing = TRUE)])
     plot_ly(grouped_event, x= ~evenement, y = ~count, type = 'bar') %>%
       layout(xaxis = list(title = "", tickangle = -35),
              yaxis = list(title = ""),
              font = list(size = 8),
              margin = list(b = 60))
     
   } else if (input$pie == "Répartition phase de la journée"){
     grouped_phase <- zipsInBounds() %>% dplyr::group_by(phase_journee) %>% summarize(count = n())
     plot_ly(grouped_phase, labels= ~phase_journee, values = ~count) %>% add_pie(hole = 0.4) %>% layout(showlegend = TRUE, legend = list(font = list(size=5),
                                                                                                                                         orientation = 'v'),
                                                                                                        margin = list(b = 0))
     
   } else if (input$pie == 'Evolution temporelle') {
     grouped_date = zipsInBounds() %>% count(date)
     plot_ly(grouped_date, x = ~date, y= ~n, mode='lines') %>% layout(yaxis=list(title="Nombre d'opérations"))
   }
 })

  output$camembert <- renderPlotly({
    validate(
      need(zipsInBounds(), "Sorry, there is no data for you requested combination. 
                      Please change your input selections"
      )
    )
    cam()

  })

  output$downloadData <- downloadHandler(
    filename = "map_data.xlsx",
    content = function(file) {
      write_xlsx(zipsInBounds(), file)
    })
  
  output$downloadDataCSV <- downloadHandler(
    filename = "map_data.csv",
    content = function(file) {
      write.csv(zipsInBounds(), file, row.names = FALSE)
    })

}

shinyApp(ui, server)

