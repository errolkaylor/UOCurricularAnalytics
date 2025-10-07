library(tidyverse)
library(stringr)
library(shiny)
library(visNetwork)
library(kableExtra)
library(CurricularAnalytics)
library(bslib)

generate_coords <- function(curriculum_graph) {
  coords <- matrix(ncol = 2)


  num_in_section <- array(0,dim = c(5,10))
  y_coord <- 0
  old_dept <- "not!"
  old_term <- 0
  for (i in curriculum_graph$node_list$id) {
    term <- as.numeric(curriculum_graph$node_list$term[i])
    label <- curriculum_graph$node_list$label[i]
    nums <- as.numeric(str_extract(label,pattern = "\\d\\d\\d"))
    dept <- str_extract(label,pattern ="[A-Z]+")
    y_starter <- case_when(
      dept == "CS" ~ 1,
      dept == "MATH" ~ 2,
      dept == "PHYS" ~ 3,
      dept == "PEO" ~ 4
    )

    section_depth <- num_in_section[y_starter,term]

    num_in_section[y_starter,term]<-section_depth+2

    ycoord <- (y_starter * 20) + section_depth


    coords <- rbind(coords, c(term,((y_starter * 25) + section_depth)))

  }

  coords <- stats::na.omit(coords)
  return(coords)
}


# Define server logic required to draw a histogram
server <- function(input, output) {
  all_paths<- readRDS("data/full_paths.rds")

  full_curriculum <- readRDS("data/all_courses_network.rds")
  full_coords<- generate_coords(full_curriculum)

  C_min<- readRDS("data/min_path.rds")
  min_coords<- generate_coords(C_min)

  C_max<- readRDS("data/save_rep_C_max.rds")
  max_coords <- generate_coords(C_max)




  output$max_path <- renderVisNetwork({

    visNetwork(C_max$node_list,C_max$edge_list) %>%
      visNodes(shape = "circle",
               color = list(background = "lightgreen",
                            border = "darkgreen",
                            highlight = "yellow")) %>%
      visEdges(arrows = "to",color = "green") %>%
      visIgraphLayout(layout = "layout.norm",layoutMatrix = max_coords) %>%
      visEvents(
        selectNode = "function(properties) {
      alert('Course Code: ' + this.body.data.nodes.get(properties.nodes[0]).label + '; Structural Complexity: ' + this.body.data.nodes.get(properties.nodes[0]).sc + '; Centrality Factor: ' + this.body.data.nodes.get(properties.nodes[0]).cf + '; Blocking Factor: ' + this.body.data.nodes.get(properties.nodes[0]).bf + '; Delay Factor: ' + this.body.data.nodes.get(properties.nodes[0]).df);}"
      )
  })

  output$min_path <- renderVisNetwork({

    visNetwork(C_min$node_list,C_min$edge_list) %>%
      visNodes(shape = "circle",
               color = list(background = "lightgreen",
                            border = "darkgreen",
                            highlight = "yellow")) %>%
      visEdges(arrows = "to",color = "green") %>%
      visIgraphLayout(layout = "layout.norm",layoutMatrix = min_coords) %>%
      visEvents(
        selectNode = "function(properties) {
      alert('Course Code: ' + this.body.data.nodes.get(properties.nodes[0]).label + '; Structural Complexity: ' + this.body.data.nodes.get(properties.nodes[0]).sc + '; Centrality Factor: ' + this.body.data.nodes.get(properties.nodes[0]).cf + '; Blocking Factor: ' + this.body.data.nodes.get(properties.nodes[0]).bf + '; Delay Factor: ' + this.body.data.nodes.get(properties.nodes[0]).df);}"
      )
  })



  idx <- !(C_max$node_list$label %in% C_min$node_list$label)
  max_tab <- data.frame(Max_Only_Courses=C_max$node_list$label[idx],
                        BLocking_Factor = C_max$node_list$bf[idx],
                        Delay_Factor = C_max$node_list$df[idx],
                        Centrality = C_max$node_list$cf[idx],
                        Structural_Complexity = C_max$node_list$sc[idx])



  idx <- !(C_min$node_list$label %in% C_max$node_list$label)
  min_tab<- data.frame(Min_Only_Courses=C_min$node_list$label[idx],
                       BLocking_Factor = C_min$node_list$bf[idx],
                       Delay_Factor = C_min$node_list$df[idx],
                       Centrality = C_min$node_list$cf[idx],
                       Structural_Complexity = C_min$node_list$sc[idx])

  output$max_only_courses <- renderTable(max_tab,
                                         striped = TRUE,
                                         align = "c")
  output$min_only_courses <- renderTable(min_tab,
                                         striped = TRUE,
                                         align = "c")

  output$full_course_vis <- renderVisNetwork({

    visNetwork(full_curriculum$node_list,full_curriculum$edge_list) %>%
      visNodes(shape = "circle",
               color = list(background = "lightgreen",
                            border = "darkgreen",
                            highlight = "yellow")) %>%
      visEdges(arrows = "to",color = "green") %>%
      visIgraphLayout(layout = "layout.norm",layoutMatrix =full_coords)
  })
}

ui <- page_navbar(
  title = "University of Oregon Curricular Analytics and Degree Path Visualizations",

  nav_panel(title = "Overall Course Network",
            card(visNetworkOutput("full_course_vis"))),

  nav_panel(title = "Max vs. Minimal Degree Paths in Computer Science",
            layout_column_wrap(
              width= 1/2,
              heights_equal="row",
              card(visNetworkOutput("max_path")),
              card(visNetworkOutput("min_path")),
              card(tableOutput("max_only_courses")),
              card(tableOutput("min_only_courses"))
            )
            ),

  nav_spacer(),

  nav_menu(
    title = "Links",
    align = "right",
    nav_item(tags$a("UO Quantitative Methods", href="https://education.uoregon.edu/qrme")),
    nav_item(tags$a("Computer Science Degree Guide",href="https://catalog.uoregon.edu/arts-sciences/school-computer-data-sciences/computer-science/ug-computer-science/#requirementstext")),
    nav_item(tags$a("README",href="https://github.com/errolkaylor/UOCurricularAnalytics/blob/master/README.md"))

  )


)

# Run the application
shinyApp(ui = ui, server = server)
