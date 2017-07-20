library(shinydashboard)
library(data.table)
library(DT)
library(mongolite)

Number_of_days <- 2
ups_rates <- 21.00
Type_of_Shipping <- "2 Day Air"
Warehouse_zip = 500
Destination_zip = 750

#DATA SET
# MongDB login info
options(
  mongodb = list(
    host = "ds127211-a0.mlab.com:27211",
    username = "grandcanals",
    password = "superman1"
  )
)
databaseName <- "grandcanals"
#########################################################################################################
#----------------------------------------------------
gettransittimes <- function(...) {
    db <- mongo(
      collection = "transittimes",
      url = sprintf(
        "mongodb://%s:%s@%s/%s",
        options()$mongodb$username,
        options()$mongodb$password,
        options()$mongodb$host,
        databaseName
      )
    )

    # Gets transit times based on input in shiny
    mongo_string = sprintf('{"origin" : %s, "destination" : %s}', Warehouse_zip, Destination_zip)
    transit_times <- db$find(query = mongo_string)
    return(transit_times)
    break  
}


########################################################################################3
#LLoad Data based on zip codes
# 
loadData <- function(...) {
      db <- mongo(
      url = sprintf(
        "mongodb://%s:%s@%s/%s",
        options()$mongodb$username,
        options()$mongodb$password,
        options()$mongodb$host,
        databaseName
      )
    )
    mongo_string = sprintf('{"originzip" : %s, "destinationzip" : %s}', Warehouse_zip, Destination_zip)
    collection_data <- db$find(query = mongo_string)
    return(collection_data)
}
# 
# 
# ###########################################################################################
# #CREATE GLOBAL FUNCTIONS TO CALCULATE ZIP TO ZONE FOR SERVER.R USAGE
# ## Find zone
FedExZiptoZone <- loadData(collection = "FedExZiptoZone", Warehouse_zip, Destination_zip)


fedexzone <- function(orginzip, destinationzip){
  FedExNewZone <- (orginzip >= FedExZiptoZone$Zip_Low &
                FedExZiptoZone$Zip_High >= orginzip &
                destinationzip >= FedExZiptoZone$Destination_Zip_Low &
                FedExZiptoZone$Destination_Zip_High >= destinationzip)
  FedExNewZone <- match(TRUE, FedExNewZone)
  FedExNewZone <- FedExZiptoZone[FedExNewZone,"Zone"]
  return(FedExNewZone)
  FedExNewZone

}

fedexzone(orginzip = 500,destinationzip = 750)




UPSZiptoZone <- loadData(collection = "UPSZiptoZone", Warehouse_zip, Destination_zip)


upszone <- function(orginzip, destinationzip){
  UPSNewZone <- (orginzip >= UPSZiptoZone$Zip_Low &
                UPSZiptoZone$Zip_High >= orginzip &
                destinationzip >= UPSZiptoZone$Destination_Zip_Low &
                UPSZiptoZone$Destination_Zip_High >= destinationzip)
  UPSNewZone <- match(TRUE, UPSNewZone)
  UPSNewZone <-UPSZiptoZone[UPSNewZone,"Zone"]
  return(UPSNewZone)
  UPSNewZone
  
}

# ###########################################################################################
# Get UPS and Fedex Rates

getNetRateFedex <- function(...) {
  db <- mongo(
    collection = "NetRatesFedEx",
    url = sprintf(
      "mongodb://%s:%s@%s/%s",
      options()$mongodb$username,
      options()$mongodb$password,
      options()$mongodb$host,
      databaseName
    )
  )
  # Gets FedEx based on input in shiny
  mongo_string = sprintf('{"weight" : %s, "zone" : %s}', Weight, Fedex_Zone)
  fedex_rates <- db$find(query = mongo_string)
  return(fedex_rates)
  break  
}



getNetRateUPS <- function(...) {
  db <- mongo(
    collection = "NetRatesUPS",
    url = sprintf(
      "mongodb://%s:%s@%s/%s",
      options()$mongodb$username,
      options()$mongodb$password,
      options()$mongodb$host,
      databaseName
    )
  )
  mongo_string = sprintf('{"weight" : %s, "zone" : %s}', Weight, UPS_Zone)
  ups_rates <- db$find(query = mongo_string)
  return(ups_rates)
}
