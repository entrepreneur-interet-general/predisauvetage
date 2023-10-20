#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#Load librairies
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

# Connection to the database
con = dbConnect(pg,
                user = Sys.getenv("DATABASE_USERNAME") ,
                password = Sys.getenv("DATABASE_PASSWORD"),
                host=Sys.getenv("DATABASE_HOST"),
                port=Sys.getenv("DATABASE_PORT"),
                dbname= Sys.getenv("DATABASE_NAME"))

#select all data in the operations table

con = dbConnect(pg, user = Sys.getenv("DATABASE_USERNAME") , password = Sys.getenv("DATABASE_PASSWORD"),
                host=Sys.getenv("DATABASE_HOST"), port=Sys.getenv("DATABASE_PORT"), dbname= Sys.getenv("DATABASE_NAME"))

query <- dbSendQuery(con, 'select * from operations;')
operations <- fetch(query, n=-1)
dbClearResult(query)

#select all data in the operations_stats table
query <- dbSendQuery(con, 'select * from operations_stats;')
operations_stat <- fetch(query, n=-1)
dbClearResult(query)

dbDisconnect(con)


#Read kml files for the SRR
srr_etel <- read_file('kml_srr/SRR_ETEL.kml')
srr_corsen <- read_file('kml_srr/SRR_CORSEN.kml')
srr_grisnez <- read_file('kml_srr/SRR_Gris-Nez.kml')
srr_antillesguyane <- read_file('kml_srr/antilles-guyane.kml')
srr_lagarde <- read_file('kml_srr/SRR_La_Garde.kml')
srr_jobourg <- read_file('kml_srr/SRR_Jobourg.kml')
srr_lareunion <- read_file('kml_srr/la-reunion.kml')
srr_noumea <- read_file('kml_srr/noumea.kml')
srr_tahiti <- read_file('kml_srr/tahiti.kml')
srr_jrcc_tahiti <- read_file('kml_srr/jrcc-tahiti.kml')

#join the two tables
secmar <- plyr::join(operations, operations_stat, by='operation_id', type="inner")

#Create Hause/saison basse saison and create a boolean for operations without flotteur
secmar <- secmar %>%
                 mutate(saison = ifelse(mois>4 & mois<10, 'Haute saison', 'Basse saison')) %>%
                 mutate(sans_flotteur =
                          ifelse(nombre_flotteurs_commerce_impliques > 0 |
                                 nombre_flotteurs_plaisance_impliques > 0 |
                                 nombre_flotteurs_loisirs_nautiques_impliques > 0 |
                                 nombre_flotteurs_peche_impliques > 0 |
                                 nombre_flotteurs_autre_impliques > 0 |
                                 nombre_aeronefs_impliques, 0, 1 )) %>%
                  mutate(flotteurs_plaisance_autre =
                           ifelse(nombre_flotteurs_plaisance_a_moteur_moins_8m_impliques == 0 &
                                    nombre_flotteurs_plaisance_a_moteur_plus_8m_impliques == 0 &
                                    nombre_flotteurs_plaisance_a_voile_impliques == 0
                                    , 1, 0 )) %>%
                  mutate(flotteurs_vehicule_nautique =
                           ifelse(nombre_flotteurs_planche_a_voile_impliques ==0 &
                                  nombre_flotteurs_kitesurf_impliques == 0 &
                                  nombre_flotteurs_plaisance_voile_legere_impliques == 0 &
                                  nombre_flotteurs_ski_nautique_impliques == 0 &
                                  nombre_flotteurs_surf_impliques == 0 &
                                  nombre_flotteurs_autre_loisir_nautique_impliques == 0 &
                                  nombre_flotteurs_engin_de_plage_impliques == 0 &
                                  nombre_flotteurs_canoe_kayak_aviron_impliques == 0,
                                  1, 0)) %>%
                  mutate(distance_cote_milles_nautiques =
                           if_else(is.na(distance_cote_milles_nautiques), 0, distance_cote_milles_nautiques)) #Replace na with 0

#Create categories for distance_cote_milles_nautiques
secmar <- secmar %>%
          mutate(distance_cote_milles_nautiques_cat =
             as.character(
               cut(
                 distance_cote_milles_nautiques,
                 breaks = c(-Inf, 2, 6, 60, Inf),
                 labels = c("0-2 milles",
                            "2-6 milles",
                            "6-60 milles",
                            "+60 milles"))))
# dbDisconnect (con)

#Reorder and rename direction du vent
secmar <- secmar %>%
          mutate(vent_direction_categorie =
                   factor(vent_direction_categorie,
                          levels = c("nord-ouest",
                                     "nord",
                                     "nord-est",
                                     "est",
                                     "sud-est",
                                     "sud",
                                     "sud-ouest",
                                     "ouest"),
                          labels = c("NO", "N", "NE", "E", "SE", "S", "SO", "O")))
#Extract decimal hour
secmar <- secmar %>%
          mutate(date_heure = as.numeric(format(date_heure_reception_alerte, "%H")) +
                              as.numeric(format(date_heure_reception_alerte, "%M"))/60)
#Replace na by Non renseigné for various fields
secmar <- secmar %>%
          mutate(type_operation = replace_na(type_operation, "Non renseigné")) %>%
          mutate(departement = replace_na(departement, "Non renseigné")) %>%
          mutate(evenement = replace_na(evenement, "Non renseigné")) %>%
          mutate(zone_responsabilite = replace_na(zone_responsabilite, "Non renseignée"))

# Create a column with a list of flotteurs involved
secmar <- secmar %>%
  mutate(flotteurs_peche = ifelse(nombre_flotteurs_peche_impliques > 0, 'pêche', ''),
         flotteurs_commerce = ifelse(nombre_flotteurs_commerce_impliques > 0, 'commerce', ''),
         flotteurs_plaisance = ifelse(nombre_flotteurs_plaisance_impliques > 0, 'plaisance', ''),
         flotteurs_loisirs_nautiques = ifelse(nombre_flotteurs_loisirs_nautiques_impliques > 0, 'loisirs nautiques', ''),
         flotteurs_autre = ifelse(nombre_flotteurs_autre_impliques > 0, 'autre', ''),
         flotteurs_aeronef = ifelse(nombre_aeronefs_impliques > 0, 'aeronef', ''),
         flotteurs_sans_flotteur = ifelse(sans_flotteur_implique > 0, 'sans flotteur', '')) %>%
  mutate(liste_flotteurs = paste(flotteurs_peche,
                                 flotteurs_commerce,
                                 flotteurs_plaisance,
                                 flotteurs_loisirs_nautiques,
                                 flotteurs_autre,
                                 flotteurs_aeronef,
                                 flotteurs_sans_flotteur))


#Create dico to map flotteurs values
flotteur_choices <- c('Commerce', 'Plaisance', 'Loisirs nautiques', 'Pêche', 'Autre', 'Aeronéf', 'Sans flotteur')
flotteur_choices_dico <- c('Commerce' = 'nombre_flotteurs_commerce_impliques',
                            'Plaisance' = 'nombre_flotteurs_plaisance_impliques',
                            'Loisirs nautiques' = 'nombre_flotteurs_loisirs_nautiques_impliques',
                            'Pêche' = 'nombre_flotteurs_peche_impliques',
                            'Autre' = 'nombre_flotteurs_autre_impliques',
                            'Aeronéf' = 'nombre_aeronefs_impliques',
                            'Sans flotteur' = 'sans_flotteur')

plaisance_choices <- c('Moteur < 8m', 'Moteur > 8m', 'Voile', 'Autre')
plaisance_choices_dico <- c('Moteur < 8m' = 'nombre_flotteurs_plaisance_a_moteur_moins_8m_impliques',
                           'Moteur > 8m' = 'nombre_flotteurs_plaisance_a_moteur_plus_8m_impliques',
                           'Voile' = 'nombre_flotteurs_plaisance_a_voile_impliques',
                           'Autre' = 'flotteurs_plaisance_autre')


ln_choices <- c('Planche à voile', 'Kitesurf',
                'Plaisance voile légère','Ski nautique',
                'Surf', 'Autre loisir nautique',
                'Engin de plage', 'Canoë / Kayak / Aviron', 'Vehicule nautique à moteur')
ln_choices_dico <- c('Planche à voile' = 'nombre_flotteurs_planche_a_voile_impliques',
                     'Kitesurf' = 'nombre_flotteurs_kitesurf_impliques',
                     'Plaisance voile légère' = 'nombre_flotteurs_plaisance_voile_legere_impliques',
                     'Ski nautique' = 'nombre_flotteurs_ski_nautique_impliques',
                     'Surf' = 'nombre_flotteurs_surf_impliques',
                     'Autre loisir nautique' = 'nombre_flotteurs_autre_loisir_nautique_impliques',
                     'Engin de plage' = 'nombre_flotteurs_engin_de_plage_impliques',
                     'Canoë / Kayak / Aviron' = 'nombre_flotteurs_canoe_kayak_aviron_impliques',
                     'Vehicule nautique à moteur' = 'flotteurs_vehicule_nautique')

#Data set for current year
secmar_year <- secmar %>%
              filter(annee == as.integer(format(Sys.Date(), "%Y")))

#secmar <- read_feather("../../sauvamer/accident2017.feather")


ui <- dashboardPage(
  dashboardHeader(title = #tags$a(href='https://www.snosan.fr/',
                                 'Carte SECMAR'
                                 #)
                  ),

  #Sidebar content
  dashboardSidebar(
    width = 280,
    sidebarMenu(
      div(
        div(style="width:50%; display:inline-block;",
            switchInput("snosan", value = FALSE, label = "SNOSAN")
            ),
  ##add pop up to explain what is SNOSAN
  tags$head(tags$style(HTML('.popover-content{
    font size="4";
  }'))),
         div(
          style="display:inline-block; ",
          bsButton("q1", label = "", icon = icon("question"),
                   style = "info", size = "extra-small"),
          bsPopover("q1", title ="", content = "Le SNOSAN prend en compte les opérations sur des flotteurs de plaisance, loisirs nautiques et annexes ainsi que les opérations sans flotteur liées à des activités de loisirs nautiques (isolement par la marée, baignade, etc…).",
                    placement = "right",  options = list(container = "body")
                    )
        )
      ),
  ##Switch input to change visualization
      switchInput("heatmap", value = FALSE, size = 'mini',
                  onLabel = 'Heatmap', offLabel = 'Cluster', label = 'Changer de visualisation'),
        dateRangeInput('dateRange',
                              label = "Date d'intervention",
                              start = as.Date(paste(c(as.character(Sys.Date(), "%Y"),'01-01'),collapse='-'), format="%Y-%m-%d"),
                              end = Sys.Date(),
                              separator = " - ", startview = "year", format = "dd/mm/yyyy"
            ),
     menuItem("Évenement", tabName = "event", icon = icon("anchor"),
              checkboxInput('eve', 'Tout sélectionner/désélectionner', value = TRUE),
              selectizeInput(inputId="evenement", label=h5("Quel motif d'intervention ?"),
                             choices=sort(unique(secmar$evenement)),
                             multiple = TRUE)),
     menuItem("CROSS et département", tabName = "cross", icon = icon("male"),
              pickerInput(inputId="cross", label=h5("Quel CROSS a coordonné l'intervention ?"),
                          choices=sort(unique(secmar$cross)),
                          options = list(
                            `selected-text-format` = "count > 5",
                            `count-selected-text` = "{0} CROSS sélectionnés",
                            `actions-box` = TRUE,
                            `deselect-all-text` = "Tout désélectionner",
                            `select-all-text` = "Tout sélectionner"
                          ),
                          selected = unique(secmar$cross),
                          multiple = TRUE),
              checkboxInput('dep', 'Tout sélectionner/désélectionner', value = TRUE),
              selectizeInput(inputId="departement", label=h5("Quels sont les départements ?"),
                             choices=sort(unique(secmar$departement)),
                             multiple = TRUE)),
     menuItem("Heure et saison", tabName = "season", icon = icon("hourglass"),
              checkboxGroupButtons("saison", label="Saison",justified = TRUE,
                                   status = "primary",
                                   checkIcon = list(yes = icon("ok", lib = "glyphicon"), no = icon("remove", lib = "glyphicon")),
                                   choices = unique(secmar$saison), selected = unique(secmar$saison)),
              bsPopover("saison", title = "", content = "La haute saison concerne les opérations du 1er mai au 30 septembre.",
                        placement = "right", options = list(container = "body")),
               sliderInput("heure", label = "Heure de l'alerte (UTC)", min = 0,
                           max = 24, value = c(0,24))
              # splitLayout(
              #     selectInput(
              #       "start_heure",
              #       label = h4("De"),
              #       choices = (c(0:24)),
              #       multiple = FALSE,
              #       selected = 22
              #     ),
              #     selectInput(
              #       "end_heure",
              #       label = h4("à"),
              #       choices = (c(0:24)),
              #       multiple = FALSE,
              #       selected = 24
              #     ))
              ),
      menuItem("Type d'opérations", tabName = "op", icon = icon("ambulance"),
               pickerInput(inputId="operation", label=h5("Quel type d'intervention ?"),
                           choices=sort(unique(secmar$type_operation)),
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
                             `count-selected-text` = "{0} flotteurs sélectionnés",
                             `actions-box` = TRUE,
                             `deselect-all-text` = "Tout désélectionner",
                             `select-all-text` = "Tout sélectionner"
                           ),
                           selected = flotteur_choices,
                           multiple = TRUE),
               pickerInput(inputId="plaisance",
                           label = 'Plaisance',
                           choices=plaisance_choices,
                           options = list(
                             `selected-text-format` = "count > 5",
                             `count-selected-text` = "{0} flotteurs de plaisance sélectionnés"
                           ),
                           selected = flotteur_choices,
                           multiple = TRUE),
               pickerInput(inputId="loisirs",
                           label = "Loisirs nautiques",
                           choices=ln_choices,
                           options = list(
                             `selected-text-format` = "count > 5",
                             `count-selected-text` = "{0} flotteurs loisirs nautiques sélectionnés"#,
                             #`none-selected-text` = "Please make a selection!"
                           ),
                           selected = ln_choices,
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
              pickerInput(inputId="cotes", label=h5("À quelle distance des côtes se déroule les interventions ?"),
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
   actionButton("doc", HTML("&nbsp;&nbsp;Documentation"),  icon("book"), style = "margin: 4px 5px 6px 5px; background-color: #222d32;color: #b8c7ce;border-color:#222d32"),
   downloadButton("downloadData", "Télécharger les données dans la zone (Excel)",
                  style='padding:7px; font-size:80%; margin-left:1.5em; margin-top:1em'),
   br(),
   br(),
   downloadButton("downloadDataCSV", "Télécharger les données dans la zone (CSV)",
                  style='padding:7px; font-size:80%; margin-left:1.5em; margin-top: -1em')

   ),
   br(),
   div(style="margin-left:1.5em; color: #b8c7ce; font-size:80%;",
    textOutput("bornes"),
    textOutput("zoom")
   )),

  #Body content
  dashboardBody(
              tags$head(tags$script(src = "https://www.googletagmanager.com/gtag/js?id=UA-133494078-2")),
              tags$head(includeScript("ga.js")),
              fluidPage(
                div(class="outer",
                tags$style(type = "text/css", ".outer {position: fixed; top: 41px; left: 0; right: 0; bottom: 0; overflow: hidden; padding: 0}"),
                leafletOutput("mymap", height = "100%", width = "100%"),
                column(5, verbatimTextOutput("textbounds")),
                ## Define content of absolute panel on the right
                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                              draggable = TRUE, top = 20, left = "auto", right = 20, bottom = "auto",
                              width = 350, height = "auto",
                     div(style="padding: 10px;",
                     br(),
                     ###Return the number of operations in the selected area
                     h4(textOutput("operation")),
                     br(),
                     ###Different charts
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
                     ###Different charts
                     selectizeInput(inputId = "histo", multiple = FALSE,
                                    label = "Choisissez votre visualisation",
                                    choices = c('Force du vent', 'Force de la mer', 'Direction du vent'),
                                    selected = 'Force du vent'),
                     br(),
                     plotOutput(outputId = "hist", height = "200px"))
         )
      )
    )
  )
)

server <- function(input, output, session) {

  observeEvent(input$doc, {
    showModal(modalDialog(
      title =  h1("Documentation"), div(style= "position: relative; top: -110px;left:844px;", actionButton("fermer", label = "", icon = icon("close"),
                                                                                                            style = "background-color: white" )),
      div(style = "font-size: 16px;padding: 15px 30px;line-height: 1.6;", div(h3("Précaution de lecture", style="margin-top: -1.5em;padding: 0.2em 0; border-bottom: 2px solid #E2001D")),
      "Les points sur la cartographie représentent les opérations géolocalisées coordonnées par les CROSS (Centres régionaux opérationnels de surveillance et de sauvetage). Ce jeu de données ne reflète ni l'accidentologie totale survenue au-delà de la bande des 300 mètres ni même l'activité globale des CROSS pour la mission de sauvetage. En effet, apparaissent sur la cartographie seulement les opérations avec des coordonnées géographiques(longitude, latitude)",
      div(h3("Fonctionnalités de la cartographie", style="padding: 0.2em 0; border-bottom: 2px solid #E2001D")),
      div(h4("Panneau de filtre à gauche", style="padding:0.5em;margin-top: 20px;color: #ffffff ;background-color:#0B3F94"), "À gauche de l'écran, vous avez accès à un panneau qui vous permet de filtrer les opérations qui apparaissent sur la cartographie en fonction :",
          tags$ul(
           tags$li("D'une période temporelle"),
           tags$li("Du type d'événements déclenchant l'opération (homme à la mer, abordage, voie d'eau, etc…"),
           tags$li("Du CROSS qui a coordonné l'opération ou du département dans lequel il se déroule"),
           tags$li("D'une plage horaire et de la saison des opérations"),
           tags$li("Du type d'opérations (sauvetage, assistance ou autre"),
           tags$li("Du type de flotteurs impliqués (plaisance, commerce, pêche, etc…)"),
           tags$li("De la gravité d'une opération (si au moins une personne est décédée ou disparue ou qu'au moins un moyen aérien ait été engagé)"),
           tags$li("De la distance des côtes et de la zone de responsabilité de l'opération")
      )),
      div(h4("Fond de carte", style="padding:0.5em;margin-top: 20px;color: #ffffff ;background-color:#0B3F94"), "En cliquant sur l'icône en haut à droite de la cartographie vous pouvez choisir le fond de carte à afficher. Vous avez accès à OpenSeaMap, SHOM, IGN et un fond de carte noir et blanc. "),
      div(h4("Carte de chaleur et cluster", style="padding:0.5em;margin-top: 20px;color: #ffffff ;background-color:#0B3F94"), "Vous pouvez changer la visualisation des points en cliquant sur Changer de visualisation en haut à gauche. Vous avez accès à deux formats :",
          tags$ul(
            tags$li("Cluster : chaque point est modélisé par un marqueur bleu et en cliquant dessus, vous verrez apparaître des détails sur l'opération. Les cercles représentent un regroupement de plusieurs points et le nombre sur le cercle indique le nombre de points. En zoomant sur la carte, vous verrez apparaître de plus en plus de points isolés. "),
            tags$li("Heatmap : La carte de chaleur modélise le nombre d'opération dans une zone avec une échelle de couleur allant du vert au rouge, le rouge représentant les plus grands nombres d'opérations.")
          )),
      div(h4("Panneau de visualisations à droite", style="padding:0.5em;margin-top: 20px;color: #ffffff ;background-color:#0B3F94"),
          "Le panneau de droite s'adapte à la zone que vous avez affichée sur la cartographie et aux filtres que vous avez appliqués. Si vous zoomez ou dézoomez, vous verrez les informations changées. Ce panneau peut être déplacé en cliquant et en le glissant. Tout en haut du panneau, vous avez une information sur le nombre d'opération dans la zone affichée. En dessous, vous avez un premier graphique pour lequel vous pouvez choisir la visualisation à afficher (en passant votre souris sur les graphiques vous aurez plus de détails) :",
          tags$ul(
            tags$li("La répartition du bilan humain affiche sous forme de camembert la proportion de personnes secourues, décédées, etc… dans la zone"),
            tags$li("Le top 5 des événements affiche sous forme d'un histogramme les 5 événements avec le plus d'opérations dans la zone"),
            tags$li("La répartition par phase de la journée affiche sous forme de camembert la proportion d'opérations pour chaque phase de la journée (matinée, déjeuner, après-midi, nuit)"),
            tags$li("La répartition des flotteurs affiche sous forme de camembert la proportion du nombre de chaque type flotteurs (commerce, pêche, etc…) dans la zone"),
            tags$li("La répartition nombre de moyens engagés affiche sous forme de camembert la proportion du nombre de moyens engagés (terrestre, nautique, aérien) dans la zone"),
            tags$li("La répartition heures de moyens engagés affiche sous forme de camembert la proportion des heures de moyens engagés (terrestre, nautique, aérien) dans la zone"),
            tags$li("L'évolution temporelle affiche le nombre d'opérations par jour sur la zone affichée et la période sélectionnée.")
          ),
          "Le graphique en bas vous permet d'avoir d'autres visualisations :"),
      tags$ul(
        tags$li("La force du vent affiche sous forme d'histogramme le nombre d'opérations pour chaque force de vent (de 0 à 12 selon l'échelle de Beaufort) dans la zone"),
        tags$li("La force de la mer affiche sous forme d'histogramme le nombre d'opérations pour chaque force de la mer (de 0 à 9 selon l'échelle de Douglas) dans la zone"),
        tags$li("La direction du vent affiche sous forme d'histogramme le nombre d'opérations pour chaque direction de vent de vent (nord, nord-ouest, nord-est, etc…) dans la zone")
      ),
      div(h4("Export des données", style="padding:0.5em;margin-top: 20px;color: #ffffff ;background-color:#0B3F94"),
          "Vous pouvez télécharger en format CSV ou Excel les opérations affichées dans la zone sur laquelle vous avez zoomé. Il suffit de cliquer en bas à gauche sur télécharger les données dans la zone."),
      div(h3("Pour plus d'informations", style="padding: 0.2em 0; border-bottom: 2px solid #E2001D")),
      a(href="https://www.data.gouv.fr/fr/datasets/operations-coordonnees-par-les-cross/", "Jeu de données des opérations CROSS depuis 1985"),
      br(),
      a(href="https://mtes-mct.github.io/secmar-documentation/", "Documentation sur les tables de données et l'explication de chaque colonne en détail"),
      br(),
      a(href="https://github.com/entrepreneur-interet-general/predisauvetage/blob/master/mapshiny/test_app/app.R", "Code source de l'application"),
      div(
        class = "box-footer",
        style = "color: #ffffff ;background-color:#0B3F94; margin-top: 1.5em",
       "Contact :",
        a("tech@snosan.fr", href = "mailto:tech@snosan.fr"))),
      easyClose = TRUE,
      size = 'l',
      footer = NULL
    ))
  })

  observeEvent(input$fermer,{
    removeModal()
  })

  snosanInput <- reactive({
    if (input$snosan == FALSE) {
      # Need to remove missing values for longitude and latitude
      # because heatmap doesn't handle missing values
      secmar %>% drop_na(longitude, latitude)
    } else {
      secmar %>% drop_na(longitude, latitude) %>% filter(concerne_snosan == TRUE)
    }
  })

  crossInput <- reactive({
      snosanInput() %>% filter(cross %in% input$cross)
  })

  operationInput <- reactive({
    crossInput() %>% filter(type_operation %in% input$operation)
  })

  observe({
    updateSelectizeInput(
      session, 'departement', choices = sort(unique(secmar$departement)),
      selected = if (input$dep) sort(unique(secmar$departement))
    )
  })

  departementInput <- reactive({
    operationInput() %>% filter(departement %in% input$departement)
  })

  observe({
    updateSelectizeInput(
      session, 'evenement', choices=sort(unique(secmar$evenement)),
      selected = if (input$eve) sort(unique(secmar$evenement))
    )
  })

  evenementInput <- reactive({
      departementInput() %>% filter(evenement %in% input$evenement)
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
    # if (input$start_heure >= input$end_heure){
    #   saisonInput() %>% filter(date_heure >= input$start_heure | date_heure <= input$end_heure)
    # } else {
    #   saisonInput() %>% filter((date_heure >= input$start_heure) & (date_heure <= input$end_heure))
    # }
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

  observe({
    updatePickerInput(
      session, 'plaisance', choices = plaisance_choices,
      selected = if ('Plaisance' %in% input$flotteur) plaisance_choices)
  })

  observe({
    updatePickerInput(
      session, 'loisirs', choices = ln_choices,
      selected = if ('Loisirs nautiques' %in% input$flotteur) ln_choices)
  })

  flotteurInput <- reactive({
  #If all values are selected, keep whole dataset
   if (length(input$flotteur) == length(flotteur_choices)){
    aerienInput()
  #If nothing is selected, return empty dataset
   } else if (is.null(input$flotteur)) {
      aerienInput() %>% filter(evenement %in% (""))
  } else {
  #Map flotteurs input choices with dictionnary created before
     list <- plyr::revalue(input$flotteur, flotteur_choices_dico)
     #Check for each row if at least one of input column value is greater than 0
     filter_at(aerienInput(), vars(list), any_vars(. > 0))
  }
  })

  plaisanceInput <- reactive({
    #If all values are selected, keep whole dataset
    if (length(input$plaisance) == length(plaisance_choices)){
      flotteurInput()
      #If nothing is selected, return empty dataset
    } else if (is.null(input$plaisance)) {
      flotteurInput()
    } else {
      #Map flotteurs plaisance input choices with dictionnary created before
      plaisance_not_selected <- plaisance_choices[(!plaisance_choices %in% input$plaisance)]
      list_plaisance <- plyr::revalue(plaisance_not_selected, plaisance_choices_dico)
      #Check for each row if at least one of input column value is  0
      filter_at(flotteurInput(), vars(list_plaisance), all_vars(. == 0))
    }
  })

  loisirsInput <- reactive({
    #If all values are selected, keep whole dataset
    if (length(input$loisirs) == length(ln_choices)){
      plaisanceInput()
      #If nothing is selected, return empty dataset
    } else if (is.null(input$loisirs)) {
      plaisanceInput()
    } else {
      #Map flotteurs loisirs nautiques input choices with dictionnary created before
      ln_not_selected <- ln_choices[(!ln_choices %in% input$loisirs)]
      list_ln <- plyr::revalue(ln_not_selected, ln_choices_dico)
      #Check for each row if at least one of input column value is  0
      filter_at(plaisanceInput(), vars(list_ln), all_vars(. == 0))
    }
  })

  output$mymap <- renderLeaflet({
# Base map
    leaflet(secmar_year) %>%
      addTiles() %>%
      addProviderTiles(providers$OpenSeaMap,
                       group = "OpenSeaMap") %>%
      addProviderTiles(providers$CartoDB.Positron,
                       group = "Noir et blanc") %>%
      addTiles(urlTemplate = 'https://wxs.ign.fr/an7nvfzojv5wa96dsga5nk8w/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.COASTALMAPS&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fpng&TileMatrix={z}&TileCol={x}&TileRow={y}',
               attribution = '&copy; https://www.geoportail.gouv.fr',
               group = "IGN") %>%
      addTiles(urlTemplate = 'https://geoapi.fr/shomgt/tile.php/gtpyr/{z}/{x}/{y}.png',
               attribution =  '<a href="http://www.shom.fr/">SHOM</a>',
               group = "SHOM") %>%
      setView(lng = 0.340375, lat = 46.580224, zoom = 6) %>%
      addMarkers(~longitude, ~latitude,
                 popup=~paste("CROSS : ", cross,
                              "</br> Evénement : " , evenement,
                              "</br> Sitrep : ", cross_sitrep,
                              "</br> Date et heure de l'alerte (UTC) : ", date_heure_reception_alerte,
                              "</br> Type de flotteurs impliqués : ", liste_flotteurs,
                              "</br> Nombre de personnes décédées ou disparues : ", nombre_personnes_tous_deces_ou_disparues,
                              "</br> Distance des côtes (milles) : ", distance_cote_milles_nautiques),
                  clusterOptions = markerClusterOptions()) %>%
      addLayersControl(baseGroups = c("OpenSeaMap", "SHOM", "IGN", "Noir et blanc")) %>%
      #Add kml files for SRR
      addKML(srr_etel,  color = 'red',fill=FALSE, weight = 0.5, label = "Etel", labelOptions = labelOptions(
        style = list("font-weight" = "normal", padding = "3px 8px"),textsize = "15px", opacity = 4, color = "black",
        direction = "auto")) %>%
      addKML(srr_corsen,  color = 'red',fill=FALSE, weight = 0.5) %>%
      addKML(srr_grisnez,  color = 'red',fill=FALSE, weight = 0.5) %>%
      addKML(srr_antillesguyane,  color = 'red',fill=FALSE, weight = 0.5) %>%
      addKML(srr_lagarde,  color = 'red',fill=FALSE, weight = 0.5) %>%
      addKML(srr_jobourg,  color = 'red',fill=FALSE, weight = 0.5) %>%
      addKML(srr_lareunion,  color = 'red',fill=FALSE, weight = 0.5) %>%
      addKML(srr_noumea,  color = 'red',fill=FALSE, weight = 0.5) %>%
      addKML(srr_tahiti,  color = 'red',fill=FALSE, weight = 0.5) %>%
      addKML(srr_jrcc_tahiti,  color = 'orange',fill=FALSE, weight = 0.8)

  })

  #Change map based on filters
    observe({
    if (input$heatmap == FALSE) {
      m <- leafletProxy("mymap", data = loisirsInput()) %>%
        clearHeatmap() %>%
        clearMarkerClusters()
      m %>% addMarkers(~longitude, ~latitude,
                       popup=~paste("CROSS : ", cross,
                                    "</br> Evénement : " , evenement,
                                    "</br> Sitrep : ", cross_sitrep,
                                    "</br> Date et heure de l'alerte (UTC) : ", date_heure_reception_alerte,
                                    "</br> Type de flotteurs impliqués : ", liste_flotteurs,
                                    "</br> Nombre de personnes décédées ou disparues : ", nombre_personnes_tous_deces_ou_disparues,
                                    "</br> Distance des côtes (milles) : ", distance_cote_milles_nautiques),
                       clusterOptions = markerClusterOptions())


    } else if (input$heatmap == TRUE) {
      m <- leafletProxy("mymap", data = loisirsInput()) %>% clearHeatmap() %>% clearMarkerClusters()
      m %>% addHeatmap(group="heat", lng=~longitude, lat=~latitude, blur=20, radius = 11)
    }

  })

  #Find bounds of the map at current screen state
  zipsInBounds <- reactive({
    req(input$mymap_bounds)
    bounds <- input$mymap_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
  #Filter dataset with points that are inside the bounds
    subset(loisirsInput(),  latitude >= latRng[1] & latitude <= latRng[2] & longitude >= lngRng[1] & longitude <= lngRng[2])
  })

 output$text <- DT::renderDataTable({
   zipsInBounds()
 })

 output$operation <- renderText({
     paste(nrow(zipsInBounds()), " interventions géolocalisées au CROSS sur la période selectionnée et sur la zone affichée")
 })

 output$bornes <- renderText({
     paste("Bornes : ", format(input$mymap_bounds$north, digits=6), "N ", format(input$mymap_bounds$east, digits=6), "E ", format(input$mymap_bounds$south, digits=6), "S ",format(input$mymap_bounds$west, digits=6), "O")
 })

 output$zoom <- renderText({
    paste("Zoom : ", input$mymap_zoom)
 })

#Create 3 different barplots with ggplot style
 histogram <- reactive({
   if (input$histo == 'Force du vent'){
     ggplot(zipsInBounds(), aes(x=as.factor(vent_force))) +
       geom_bar(fill="lightgrey") +
       labs(x= "Force du vent", y="Fréquence") +
       theme_minimal()
   } else if (input$histo == 'Force de la mer'){
     ggplot(zipsInBounds(), aes(x=as.factor(mer_force))) +
        geom_bar(fill="#56B4E9") +
        labs(x= "Force de la mer", y="Fréquence") +
        theme_minimal()
   } else if (input$histo == 'Direction du vent') {
     ggplot(zipsInBounds(), aes(x=vent_direction_categorie)) +
       geom_bar(fill="#FF0000") +
       labs(x= "Direction du vent", y="Fréquence") +
       theme_minimal()
   }
 })

 output$hist <- renderPlot({
   if (nrow(zipsInBounds()) == 0)
     return("a")
   histogram()
  })

#Create different plotly graphics for the absolute panels
 cam <- reactive({
   if (input$pie == 'Répartition du bilan humain'){
     secmar_bilan <- zipsInBounds() %>%
                     select(nombre_personnes_disparues,
                            nombre_personnes_assistees,
                            nombre_personnes_impliquees_dans_fausse_alerte,
                            nombre_personnes_tirees_daffaire_seule,
                            nombre_personnes_retrouvees, nombre_personnes_secourues,
                            nombre_personnes_tous_deces) %>%
                     replace(is.na(.), 0)
     names(secmar_bilan) <- c("Diparues",
                              "Assistées",
                              "Impliquées dans fausses alertes",
                              "Tirées d'affaires elles mêmes",
                              "Retrouvées",
                              "Secourues",
                              "Décédées")
     sumdata <- data.frame(value=apply(secmar_bilan,2,sum))
     sumdata$key = rownames(sumdata)
     plot_ly(sumdata, labels=~key, values=~value) %>%
       add_pie(hole = 0.4) %>%
       layout(showlegend = TRUE,
              legend = list(font = list(size=5),
                            orientation = 'v'),
              margin = list(b = 0))

   } else if (input$pie == 'Répartition des flotteurs'){
     secmar_flotteur <- zipsInBounds() %>%
                        select(nombre_flotteurs_commerce_impliques,
                               nombre_flotteurs_peche_impliques,
                               nombre_flotteurs_plaisance_impliques,
                               nombre_flotteurs_loisirs_nautiques_impliques,
                               nombre_flotteurs_autre_impliques)  %>%
                        replace(is.na(.), 0)
     names(secmar_flotteur) <- c("Commerce",
                                 "Pêche",
                                 "Plaisance",
                                 "Loisirs nautiques",
                                 "Autre")
     sumdata_flotteur <- data.frame(value=apply(secmar_flotteur,2,sum))
     sumdata_flotteur$key=rownames(sumdata_flotteur)
     plot_ly(sumdata_flotteur, labels=~key, values=~value) %>%
       add_pie(hole = 0.4) %>%
       layout(showlegend = TRUE,
              legend = list(font = list(size=5), orientation = 'v'),
              margin = list(b = 0))

   } else if (input$pie == "Répartition nombre de moyens engagés") {
     secmar_moyens <- zipsInBounds() %>%
                      select(nombre_moyens_nautiques_engages,
                             nombre_moyens_terrestres_engages,
                             nombre_moyens_aeriens_engages)  %>%
                      replace(is.na(.), 0)
     names(secmar_moyens) <- c('Moyens nautiques', "Moyens terrestres", 'Moyens aériens')
     sumdata_moyens <- data.frame(value=apply(secmar_moyens,2,sum))
     sumdata_moyens$key=rownames(sumdata_moyens)
     plot_ly(sumdata_moyens, labels=~key, values=~value) %>%
       add_pie(hole = 0.4) %>%
       layout(showlegend = TRUE,
              legend = list(font = list(size=5), orientation = 'v'),
              margin = list(b = 0))

   } else if (input$pie == "Répartition heures de moyens engagés") {
     secmar_moyens_heures <- zipsInBounds() %>%
                             select(duree_engagement_moyens_nautiques_heures,
                                    duree_engagement_moyens_terrestres_heures,
                                    duree_engagement_moyens_aeriens_heures)  %>%
                             replace(is.na(.), 0)
     names(secmar_moyens_heures) <- c('Heures moyens nautiques',
                                      "Heures moyens terrestres",
                                      'Heures moyens aériens')
     sumdata_moyens <- data.frame(value=apply(secmar_moyens_heures,2,sum))
     sumdata_moyens$key=rownames(sumdata_moyens)
     plot_ly(sumdata_moyens, labels=~key, values=~value) %>%
       add_pie(hole = 0.4) %>%
       layout(showlegend = TRUE,
              legend = list(font = list(size=5), orientation = 'v'),
              margin = list(b = 0))

   } else if (input$pie == 'Répartition du top 5 événements'){
     grouped_event <- zipsInBounds() %>%
                      dplyr::group_by(evenement) %>%
                      summarize(count = n()) %>%
                      top_n(5) %>%
                      arrange(desc(count))
     grouped_event$evenement <- factor(grouped_event$evenement,
                                       levels = unique(grouped_event$evenement)
                                       [order(grouped_event$count, decreasing = TRUE)])
     plot_ly(grouped_event, x= ~evenement, y = ~count, type = 'bar') %>%
       layout(xaxis = list(title = "", tickangle = -35),
              yaxis = list(title = ""),
              font = list(size = 8),
              margin = list(b = 60))

   } else if (input$pie == "Répartition phase de la journée"){
     grouped_phase <- zipsInBounds() %>%
                      dplyr::group_by(phase_journee) %>%
                      summarize(count = n())
     plot_ly(grouped_phase, labels= ~phase_journee, values = ~count) %>%
      add_pie(hole = 0.4) %>%
      layout(showlegend = TRUE,
             legend = list(font = list(size=5), orientation = 'v'),
             margin = list(b = 0))

   } else if (input$pie == 'Evolution temporelle') {
     grouped_date = zipsInBounds() %>% count(date)
     plot_ly(grouped_date, x = ~date, y= ~n, mode='lines') %>%
       layout(yaxis=list(title="Nombre d'opérations"))
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

