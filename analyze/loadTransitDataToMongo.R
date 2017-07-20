library(mongolite)

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
####  Merge UPS & Ground Data  ###

ups <- read.csv(file = "Downloads/UPS.csv")
ups$X <- "UPS"
names(ups)[1] <- "Carrier"

fedex <- read.csv(file = "Downloads/cleanFedEx.csv")
fedex$X <- "FedEx"
fedex$Unnamed..0 <- NULL
fedex$ship_info <- NULL
names(fedex)[1] <- "Carrier"


#########################################################################################################
####  Save data to Mongo  ###

saveData <- function(data, collectionName) {
  # Connect to the database
  
  db <-
    mongo(
      collection = collectionName,
      url = sprintf(
        "mongodb://%s:%s@%s/%s",
        options()$mongodb$username,
        options()$mongodb$password,
        options()$mongodb$host,
        databaseName
      )
    )
  data <- as.data.frame(data)
  db$insert(data)
  rm(db)
}

# First assign .csv to "data" and then change the collectionName below
saveData(data = fedex,collectionName = "transittimes")
saveData(data = ups,collectionName = "transittimes")
