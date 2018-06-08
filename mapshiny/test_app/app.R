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

# pg = dbDriver("PostgreSQL")
# 
# 
# con = dbConnect(pg, user = 'snosan', password = 'snosan',
#                 host='localhost', port=5433, dbname='snosan')
# 
# query <- dbSendQuery(con, 'select * from operations;')
# operations <- fetch(query, n=-1)
# dbClearResult(query) 
# 
# query <- dbSendQuery(con, 'select * from operations_stats;')
# operations_stat <- fetch(query, n=-1)
# dbClearResult(query)
# 
# dbDisconnect (con)

secmar <- plyr::join(operations, operations_stat, by='operation_id', type="inner")
secmar <- secmar %>% mutate(saison = ifelse(mois>4 & mois<9, 'Haute saison', 'Basse saison')) %>%
                     mutate(sans_flotteur = ifelse(nombre_flotteurs_commerce_impliques > 0 |
                                                          nombre_flotteurs_plaisance_impliques > 0 |
                                                          nombre_flotteurs_loisirs_nautiques_impliques > 0 |
                                                          nombre_flotteurs_peche_impliques > 0 |
                                                          nombre_flotteurs_autre_impliques > 0 |
                                                          nombre_aeronefs_impliques, 0, 1 ))

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

#secmar = secmar %>%
  #mutate(longitude = as.numeric(as.character(str_replace_all(secmar$longitude, ",", ".")))) %>% 
  #mutate(latitude = as.numeric(as.character(str_replace_all(secmar$latitude, ",", ".")))) %>% 
  #mutate(saison = ifelse(date_operation >= "2017-06-01" & date_operation <= "2017-08-31" , "Haute saison", "Basse saison")) %>% 
  #mutate(color = ifelse(nb_decedes_disparus == 0, "green", "red"))


ui <- dashboardPage(
  dashboardHeader(title = "PrediSauvetage Map", 
                  dropdownMenu(type = "tasks", badgeStatus = "success",
                               taskItem(value = 90, color = "green",
                                        "Documentation"
                               ),
                               taskItem(value = 17, color = "aqua",
                                        "Project X"
                               ),
                               taskItem(value = 75, color = "yellow",
                                        "Server deployment"
                               ),
                               taskItem(value = 80, color = "red",
                                        "Overall project"
                               )
                  )),
  
  ## Sidebar content
  dashboardSidebar(
    width = 280,
    switchInput("snosan", value = FALSE, label = "SNOSAN")
   ,
    sidebarMenu(
      
      menuItem("Carte", tabName = "dashboard", icon = icon("map")),
      pickerInput(inputId="cross", label=h4("Quel CROSS a coordoné l'intervention? "), 
                           choices=unique(secmar$cross),
                           options = list(
                             `selected-text-format` = "count > 5",
                             `count-selected-text` = "{0} CROSS sélectionnés",
                             `actions-box` = TRUE,
                             `deselect-all-text` = "Tous désélectionner",
                             `select-all-text` = "Tous sélectionner"
                           ),
                           selected = unique(secmar$cross),
                           multiple = TRUE),
        dateRangeInput('dateRange',
                              label = "Date d'intervention",
                              start = '2017-01-01', end = '2017-12-31',
                              separator = " - ", startview = "year", format = "dd/mm/yyyy"
            ), checkboxGroupButtons("saison", label="Saison",justified = TRUE,
                                       status = "primary",
                                       checkIcon = list(yes = icon("ok", lib = "glyphicon"), no = icon("remove", lib = "glyphicon")),
                                       choices = unique(secmar$saison), selected = unique(secmar$saison)),
      menuItem("Evenement", tabName = "event", icon = icon("anchor"),
               checkboxInput('eve', 'all', value = TRUE),
               selectizeInput(inputId="evenement", label=h4("Quel motif d'intervention? "), 
                           choices=unique(secmar$evenement), 
                           multiple = TRUE)),
      menuItem("Flotteur", tabName = "boat", icon = icon("ship"),
               h4("Quel type de flotteur a été impliqué ?"),
               pickerInput(inputId="flotteur", 
                           choices=flotteur_choices,
                           options = list(
                             `selected-text-format` = "count > 5",
                             `count-selected-text` = "{0} flotteur sélectionnés",
                             `actions-box` = TRUE,
                             `deselect-all-text` = "Tous désélectionner",
                             `select-all-text` = "Tous sélectionner"
                           ),
                           selected = flotteur_choices,
                           multiple = TRUE)
               # checkboxInput('bar', 'all', value = TRUE),
               # checkboxGroupInput('flotteur', label="", 
               #             choices =  flotteur_choices)
               ),
      menuItem("Gravité", tabName = "gravite", icon = icon("heartbeat"),
               "Intervention impliquant au moins", br(), "1 décédé ou disparu",
               switchInput("deces", value = FALSE, size = 'mini'),
               "Intervention impliquant au moins", br(), "1 moyen aérien",
               switchInput("aerien", value = FALSE, size = 'mini')
               ),
      menuItem("Source code", icon = icon("file-code-o"), 
               href = "https://github.com/entrepreneur-interet-general/predisauvetage")
    ),
    sidebarSearchForm(textId = "searchText", buttonId = "searchButton",
                      label = "Search...")
  ),
  ## Body content
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
              fluidPage(
                div(class="outer",
                tags$style(type = "text/css", ".outer {position: fixed; top: 41px; left: 0; right: 0; bottom: 0; overflow: hidden; padding: 0}"),
                leafletOutput("mymap", height = "100%", width = "100%"),
                column(5, verbatimTextOutput("textbounds")),
                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                              draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                              width = 330, height = "auto",
                     br(),
                     h4(textOutput("operation")),
                     br(),   
                     selectizeInput(inputId = "pie", label = "Choisissez votre visualisation",
                                    multiple = FALSE, 
                                    choices = c('Répartition du top 5 événements',
                                                'Répartition du bilan humain', 
                                                'Répartition phase de la journée',
                                                'Répartition des flotteurs',
                                                'Répartition des moyens engagés'),
                                    selected = 'Répartition du bilan humain'),
                     plotlyOutput(outputId= "camembert", height = "250px"),
                     br(),
                     selectizeInput(inputId = "histo", multiple = FALSE, 
                                    label = "Choisissez votre visualisation",
                                    choices = c('Force du vent', 'Force de la mer', 'Direction du vent'),
                                    selected = 'Force du vent'),
                     br(),
                     plotOutput(outputId = "hist", height = "200px")
                )     
            )
         )
      )
    )
  )
)

server <- function(input, output, session) {

  snosanInput <- reactive({
    if (input$snosan == FALSE) {
      secmar
    } else {
      secmar %>% filter(concerne_snosan == TRUE)
    }
    
  })
  
  crossInput <- reactive({
   # if (input$cross == "all") {
    #  snosanInput()
   # } else {
      snosanInput() %>% filter(cross %in% input$cross)
  #  }
    
  })
  
  
  observe({
    updateSelectizeInput(
      session, 'evenement', choices = unique(secmar$evenement),
      selected = if (input$eve) unique(secmar$evenement)
    )
  })
  
  evenementInput <- reactive({
   # if (input$evenement == "all") {
   #   crossInput()
   # } else {
      crossInput() %>% filter(evenement %in% input$evenement)
  #  }
  
  })
  

  
  dateInput <- reactive({
    evenementInput() %>% filter(date_heure_reception_alerte >= input$dateRange[1] & date_heure_reception_alerte <= input$dateRange[2] )
  })
  
  saisonInput <- reactive({
    dateInput() %>% filter(saison %in% input$saison)
  })
  
  
  decesInput <- reactive({
    if (input$deces == FALSE) {
      saisonInput()
    } else {
      saisonInput() %>% filter(nombre_personnes_tous_deces_ou_disparues > 0)
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
  
   #  observe({
   #  updateCheckboxGroupInput(
   #   session, 'flotteur', choices = flotteur_choices,
   #   selected = if (input$bar) flotteur_choices
   # )
   #  })
  
  icons <- awesomeIcons(
    icon = 'ios-close',
    iconColor = 'black',
    library = 'ion',
    markerColor = secmar$color
  )
  
  output$mymap <- renderLeaflet({
   # bounds <- input$mymap_bounds
  #  latRng <- range(bounds$north, bounds$south)
   # lngRng <- range(bounds$east, bounds$west)
    leaflet(secmar_2017) %>% 
      addTiles() %>%  setView(lng = 0.340375, lat = 46.580224, zoom = 6) %>% addMarkers(~longitude, ~latitude, popup=~paste("CROSS : ", cross_sitrep, "</br> Evénement :" , evenement), icon=icons, clusterOptions = markerClusterOptions())
  })
  
  #  %>% fitBounds(bounds$east, bounds$north, bounds$west,  bounds$south ) 

 # observe({
 #  m <- leafletProxy("mymap", data = snosanInput()) %>% clearMarkerClusters()
 #  m %>% addMarkers(~longitude, ~latitude, popup=~paste("CROSS : ", cross_sitrep, "</br> Evénement :" , evenement), icon=icons, clusterOptions = markerClusterOptions())
 # })

  observe({
    m <- leafletProxy("mymap", data = flotteurInput()) %>% clearMarkerClusters()
    m %>% addMarkers(~longitude, ~latitude, popup=~paste("CROSS : ", cross_sitrep, "</br> Evénement :" , evenement), icon=icons, clusterOptions = markerClusterOptions())
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
     ggplot(zipsInBounds(), aes(x=vent_direction))+ 
       geom_histogram(fill="#FF0000") +
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
     plot_ly(sumdata_flotteur, labels=~key, values=~value) %>% add_pie(hole = 0.4)
   } else if (input$pie == "Répartition des moyens engagés") {
     secmar_moyens <- zipsInBounds() %>% select(nombre_moyens_nautiques_engages, nombre_moyens_terrestres_engages, nombre_moyens_aeriens_engages)  %>% replace(is.na(.), 0)
     names(secmar_moyens) <- c('Moyens nautiques', "Moyens terrestres", 'Moyens aériens')
     sumdata_moyens <- data.frame(value=apply(secmar_moyens,2,sum))
     sumdata_moyens$key=rownames(sumdata_moyens)
     plot_ly(sumdata_moyens, labels=~key, values=~value) %>% add_pie(hole = 0.4)
   } else if (input$pie == 'Répartition du top 5 événements'){
     grouped_event <- zipsInBounds() %>% dplyr::group_by(evenement) %>% summarize(count = n()) %>% top_n(5) %>% arrange(desc(count))
     grouped_event$evenement <- factor(grouped_event$evenement, levels = unique(grouped_event$evenement)[order(grouped_event$count, decreasing = TRUE)])
     plot_ly(grouped_event, x= ~evenement, y = ~count, type = 'bar') %>%
       layout(xaxis = list(title = "", tickangle = -25),
              yaxis = list(title = ""),
              font = list(size = 9),
              margin = list(b = 60))
   } else if (input$pie == "Répartition phase de la journée"){
     grouped_phase <- zipsInBounds() %>% dplyr::group_by(phase_journee) %>% summarize(count = n())
     plot_ly(grouped_phase, labels= ~phase_journee, values = ~count) %>% add_pie(hole = 0.4)
   } 
 }) 
  
  output$camembert <- renderPlotly({
    if (nrow(zipsInBounds()) == 0)
      return("a")
    cam()

  })

}

shinyApp(ui, server)

