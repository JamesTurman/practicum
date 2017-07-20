shinyServer(function(input, output, session) {

observeEvent(input$button,{
  
    Warehouse_zip <- input$Warehouse_zip
    Destination_zip <- input$Destination_zip
    Weight <- input$Weight
    
    fedexzone(Warehouse_zip, Destination_zip)
    upszone(Warehouse_zip, Destination_zip)
    gettransittimes(Warehouse_zip, Destination_zip)
    getNetRateFedex(Weight, FedExNewZone)
    getNetRateUPS(Weight, UPSNewZone)
    
    if (length(input$Warehouse_zip)){
      data$c1 <- grepl(paste(input$Warehouse_zip, collapse = "|"), data$Warehouse_zip)
    }
    else {
      data$c1 <- TRUE
    }
    
    if (length(input$Destination_zip)){
      data$c2 <- grepl(paste(input$Destination_zip, collapse = "|"), data$Destination_zip)
    }
    else {
      data$c2 <- TRUE
    }
    if (length(input$Weight)){
      data$c3 <- grepl(paste(input$Weight, collapse = "|"), data$Weight)
    }
    else {
      data$c3 <- TRUE
    }
    data[Number_of_days  & ups_rates & Type_of_Shipping ,c("Number_of_days", "Cost", "Type_of_Shipping")]
    })
  
  #output$results <- DT::renderDataTable(
    #DT::datatable(cat(Warehouse_zip, Destination_zip, Weight), rownames = FALSE, options = list(searchable = FALSE)
    #))
  
  # Send a pre-rendered image, and don't delete the image after sending it
  output$Image <- renderImage({
    # When input$n is 3, filename is ./images/image3.jpeg
    filename <- normalizePath(file.path('images/',
                                       paste('image', input$n, '.png', sep='')))
    # Return a list containing the filename and alt text
    list(src = filename,
         alt = paste("Image number", input$n))
    
  }, deleteFile = FALSE)
  
  output$Image2 <- renderImage({
    # When input$n is 3, filename is ./images/image3.jpeg
    filename <- normalizePath(file.path('images/',
                                        paste('image2', input$n, '.png', sep='')))
    # Return a list containing the filename and alt text
    list(src = filename,
         alt = paste("Image number", input$n))
    
  }, deleteFile = FALSE)
  output$days <- renderText({"Transit: 2 Days"})
  output$rate <- renderText({"Cost: 21.00"})
  output$type <- renderText({"Service: 2 Day Morning"})
})
