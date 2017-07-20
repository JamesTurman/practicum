# ui.R
dashboardPage(skin = "green",
              dashboardHeader(title = 'Shipping Optimizer'),
              dashboardSidebar(
                sidebarMenu(
                  #User inputs package info, ouput is prices
                  menuItem("Package Pricings", tabName = "package", icon=icon("user")),
                  #Shows a map of the clustering, where ideal warehouse are located
                  menuItem("Warehouses", tabName = "warehouses", icon=icon("search")),
                  menuItem("About App", tabName="about", icon = icon("info"))
                )
              ),
              dashboardBody(
                tabItems(
                  tabItem(tabName ="package",
                          tabBox( title = "", 
                                  width = 12, id = "tabset1", height = "850px",
                                  tabPanel("Shipping Prices", imageOutput("Image2",height = 80, width = 80),
                                           fluidRow(
                                             box(title = "", solidHeader = TRUE,
                                                 background = "green" , collapsible = TRUE, width = 12,
                                                 fluidRow(
                                                   column(4,textInput("Warehouse_zip",label="Warehouse Zip Code")),
                                                   column(4,textInput("Destination_zip",label="Destination Zipcode")),
                                                   column(4,textInput("Weight",label="Weight")),
                                                   column(4,actionButton("button", "Search")) 
                                                 )
                                             )
                                           ),
                                           fluidRow(
                                             box(title = "Search Results", solidHeader = TRUE,
                                                 background = "blue" , collapsible = TRUE, width = 12,
                                                 fluidRow(
                                                   column(4,textOutput({"days"})),
                                                   column(4,textOutput({"rate"})),
                                                   column(4,textOutput({"type"}))
                                                                                              
                                             )
                                           )
                                  )
                          )
                  ),
                  tabItem(tabName="warehouses",
                          titlePanel("Warehouse Locations"),
                          HTML("Show clustering map of where the clusters are and warehouse locations"),
                          imageOutput("Image")
                  ),
                  tabItem(tabName="about",
                          titlePanel("About APP"),
                          HTML("This is an app.")
                  )
                )
              )
))
