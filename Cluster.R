library(maps)
#### Set Initial Parameters
num_locations = 3
cluster_tolerance = .0001
max_iterations = 25

invoice_data_type = 2 # 1 for FedEx 2 for UPS
######### Load Data ######

# Zip code lat, long
USZipCodes <- read.csv("https://gist.githubusercontent.com/erichurst/7882666/raw/5bdc46db47d9515269ab12ed6fb2850377fd869e/US%2520Zip%2520Codes%2520from%25202013%2520Government%2520Data",
                       header=T, sep=",", stringsAsFactors=FALSE, colClasses=c("ZIP"="character", "LAT"="numeric","LNG"="numeric"))

#Load invoice data
raw.og = read.csv("C:/Users/John Erlandson/Desktop/Grand Canal Solutions/Customer Success Projects/Location Analysis/Grove.csv", header=T,
                  sep="," ,stringsAsFactors = FALSE)

raw.og <- head(x = raw.og,20000) 

if(invoice_data_type == 2){

 ## Rename Columns 
  names(raw.og)[names(raw.og) == 'Receiver.State'] <- "Recipient.State"
  names(raw.og)[names(raw.og) == 'Receiver.Postal'] <- "Recipient.Zip.Code"
  names(raw.og)[names(raw.og) == 'Lead.Shipment.Number'] <- "Express.or.Ground.Tracking.ID"
  
  ### Remove Duplicates
  raw.og <- raw.og[!duplicated(raw.og$Express.or.Ground.Tracking.ID),]
  zipcode <- raw.og$Recipient.Zip.Code
  }

if(invoice_data_type == 1){
zipcode <- if(length(raw.og$Recipient.Zip.Code)>5){
  substr(raw.og$Recipient.Zip.Code, 1, nchar(as.character(raw.og$Recipient.Zip.Code))-6)
    }else{
  raw.og$Recipient.Zip.Code
}
}

zipcode <- sprintf( "%05d", as.numeric(zipcode))

raw.og$Express.or.Ground.Tracking.ID <-  gsub("[^0-9]","",raw.og$Express.or.Ground.Tracking.ID)

# Take out AK and HI
raw.og <- raw.og[ which(raw.og$Recipient.State !='AK' &raw.og$Recipient.State !='HI'), ]

#Load List of potential warehouse locations 
warehouse.locations = read.csv("C:/Users/John Erlandson/Desktop/Grand Canal Solutions/Customer Success Projects/Location Analysis/Warehouse Locations.csv", header=T,
                  sep="," ,stringsAsFactors = FALSE, colClasses=c("Zip"="character"))

warehouse.locations$Zip <- sprintf( "%05s", warehouse.locations$Zip)
warehouse.locations$Longitude <- USZipCodes[match(warehouse.locations$Zip,USZipCodes$ZIP),"LNG"]
warehouse.locations$Latitude <- USZipCodes[match(warehouse.locations$Zip,USZipCodes$ZIP),"LAT"]


Longitude <- USZipCodes[match(zipcode,USZipCodes$ZIP),"LNG"]
Latitude <- USZipCodes[match(zipcode,USZipCodes$ZIP),"LAT"]

TrackingNumber <- raw.og$Express.or.Ground.Tracking.ID
nadata <- complete.cases(Longitude)

orig.data <- as.data.frame(cbind(Longitude,Latitude,nadata,TrackingNumber),stringsAsFactors = FALSE,colClasses=c("Latitude"="numeric", "Longitude"="numeric"))
####################### Changs nadata == 1 if FEDEx
orig.data <- subset(orig.data, nadata==TRUE)
orig.data <- orig.data[, c("Latitude","Longitude")]

orig.data$Longitude <- as.numeric(orig.data$Longitude)
orig.data$Latitude <-  as.numeric(orig.data$Latitude)
orig.data$LocationID <- as.integer(rep(1:length(orig.data$Latitude)))


############################# Clustering Analysis #################################
# Convert to radian
as_radians = function(theta=0){
  return(theta * pi / 180)
}

calc_dist = function(fr, to) {
  lat1 = as_radians(fr$lat)
  lon1 = as_radians(fr$lon)
  lat2 = as_radians(to$lat)
  lon2 = as_radians(to$lon)
  a = 3963.191;
  b = 3949.903;
  numerator = ( a^2 * cos(lat2) )^2 + ( b^2 * sin(lat2) ) ^2
  denominator = ( a * cos(lat2) )^2 + ( b * sin(lat2) )^2
  radiusofearth = sqrt(numerator/denominator) #Accounts for the ellipticity of the earth.
  d = radiusofearth * acos( sin(lat1) * sin(lat2) + cos(lat1)*cos(lat2)*cos(lon2 - lon1) )
  d.return = list(distance_miles=d)
  return(d.return)
}



dirichletClusters_constrained = function(orig.data, k=7921, max.iter = 1000, tolerance = 237630, plot.iter=TRUE) {
  fr = to = NULL
  
  r.k.start = sample(seq(1:k))
  n = nrow( orig.data )
  k.size = ceiling(n/k)
  initial.clusters = rep(r.k.start, k.size)
  
  if(n%%length(initial.clusters)!=0){
    exclude.k = length(initial.clusters) - n%%length(initial.clusters)
  } else {
    exclude.k = 0
  }
  orig.data$cluster = initial.clusters[1:(length(initial.clusters)-exclude.k)]
  orig.data$cluster_original = orig.data$cluster
  
  ## Calc centers and merge
  mu = cbind( by(orig.data$Latitude, orig.data$cluster, mean), by(orig.data$Longitude, orig.data$cluster, mean), seq(1:k) )
  tmp1 = matrix( match(orig.data$cluster, mu[,3]) )
  orig.data.centers = cbind(as.matrix(orig.data), mu[tmp1,])[,c(1:2,4:6)]
  
  ## Calc initial distance from centers
  fr$lat = orig.data.centers[,3]; fr$lon = orig.data.centers[,4]
  to$lat = orig.data.centers[,1]; to$lon = orig.data.centers[,2]
  orig.data$distance.from.center = calc_dist(fr, to)$distance_miles
  orig.data$distance.from.center_original = orig.data$distance.from.center
  
  ## Set some initial configuration values
  is.converged = FALSE
  iteration = 0
  error.old = Inf
  error.curr = Inf
  
  while ( !is.converged && iteration < max.iter ) { # Iterate until threshold or maximum iterations
    
    if(plot.iter==TRUE){
      plot(orig.data$Longitude, orig.data$Latitude, col=orig.data$cluster, pch=16, cex=.6,
           xlab="Longitude",ylab="Latitude")
    }
    iteration = iteration + 1
    start.time = as.numeric(Sys.time())
    cat("Iteration ", iteration,sep="")
    for( i in 1:n ) {
      # Iterate over each observation and measure the distance each observation' from its mean center
      # Produces an exchange. It takes the observation closest to it's mean and in return it gives the observation
      # closest to the giver, k, mean
      fr = to = distances = NULL
      for( j in 1:k ){
        # Determine the distance from each k group
        fr$lat = orig.data$Latitude[i]; fr$lon = orig.data$Longitude[i]
        to$lat = mu[j,1]; to$lon = mu[j,2]
        distances[j] = as.numeric( calc_dist(fr, to) )
      }
      
      # Which k cluster is the observation closest.
      which.min.distance = which(distances==min(distances), arr.ind=TRUE)
      previous.cluster = orig.data$cluster[i]
      orig.data$cluster[i] = which.min.distance # Replace cluster with closest cluster
      
      # Trade an observation that is closest to the giving cluster
      if(previous.cluster != which.min.distance){
        new.cluster.group = orig.data[orig.data$cluster==which.min.distance,]
        
        fr$lat = mu[previous.cluster,1]; fr$lon = mu[previous.cluster,2]
        to$lat = new.cluster.group$Latitude; to$lon = new.cluster.group$Longitude
        new.cluster.group$tmp.dist = calc_dist(fr, to)$distance_miles
        
        take.out.new.cluster.group = which(new.cluster.group$tmp.dist==min(new.cluster.group$tmp.dist), arr.ind=TRUE)
        LocationID = new.cluster.group$LocationID[take.out.new.cluster.group]
        orig.data$cluster[orig.data$LocationID == LocationID] = previous.cluster
      }
      
    }
    
    # Calculate new cluster means
    mu = cbind( by(orig.data$Latitude, orig.data$cluster, mean), by(orig.data$Longitude, orig.data$cluster, mean), seq(1:k) )
    tmp1 = matrix( match(orig.data$cluster, mu[,3]) )
    orig.data.centers = cbind(as.matrix(orig.data), mu[tmp1,])[,c(1:2,4:6)]
    mu = cbind( by(orig.data$Latitude, orig.data$cluster, mean), by(orig.data$Longitude, orig.data$cluster, mean), seq(1:k) )
    
    ## Calc initial distance from centers
    fr$lat = orig.data.centers[,3]; fr$lon = orig.data.centers[,4]
    to$lat = orig.data.centers[,1]; to$lon = orig.data.centers[,2]
    orig.data$distance.from.center = calc_dist(fr, to)$distance_miles
    
    # Test for convergence. Is the previous distance within the threshold of the current total distance from center
    error.curr = sum(orig.data$distance.from.center)
    
    error.diff = abs( error.old - error.curr )
    error.old = error.curr
    if( !is.nan( error.diff ) && error.diff < tolerance ) {
      is.converged = TRUE
    }
    
    # Set a time to see how long the process will take is going through all iterations
    stop.time = as.numeric(Sys.time())
    hour.diff = (((stop.time - start.time) * (max.iter - iteration))/60)/60
    cat("\n Error ",error.diff," Hours remain from iterations ",hour.diff,"\n")
    
    # Write out iterations. Can later be used as a starting point if iterations need to pause
    #write.table(orig.data, paste("C:\\optimize_iteration_",iteration,"_instore_data.csv", sep=""), sep=",", row.names=F)
  }
  
  centers = data.frame(mu)
  ret.val = list("centers" = centers, "cluster" = factor(orig.data$cluster), "LocationID" = orig.data$LocationID,
                 "Latitude" = orig.data$Latitude, "Longitude" = orig.data$Longitude, 
                 "k" = k, "iterations" = iteration, "error.diff" = error.diff)
  
  return(ret.val)
}

# Constrained clustering
cl_constrain = dirichletClusters_constrained(orig.data, k=num_locations, max.iter=max_iterations, tolerance=cluster_tolerance, plot.iter=TRUE)
table( cl_constrain$cluster )
plot(cl_constrain$Longitude, cl_constrain$Latitude, col=cl_constrain$cluster, pch=16, cex=.6,
     xlab="Longitude",ylab="Latitude")


map("state", add=T)
points(cl_constrain$centers[,c(2,1)], pch=4, cex=2, col='orange', lwd=4)

### Find nearest warehouse location from list of possible canidates

num_warehouse <- as.numeric(length(warehouse.locations$City))

result = ""
for(i in 1:num_warehouse){
  lat <- cl_constrain$centers$X1[i]
  lat <-rep(x = lat,num_warehouse)
  lon <- rep(x=cl_constrain$centers$X2[i], num_warehouse)
  fr <- data.frame(lat,lon,stringsAsFactors = FALSE,row.names = NULL)
  lat <- warehouse.locations$Latitude
  lon <- warehouse.locations$Longitude
  to <- data.frame(lat,lon,stringsAsFactors = FALSE)
  result[i] <- calc_dist(fr = fr,to =to)
}


### Adjust Optimum location based on proximity to Rail, Ports & Tax benifits
resultzip <- ""
adjcenterlat <- list(rep(1:num_locations))
adjcenterlon <- list(rep(1:num_locations))
for(i in 1:num_locations){
 city <- warehouse.locations[which.min(as.numeric(unlist(result[i]))),"City"]
 state <- warehouse.locations[which.min(as.numeric(unlist(result[i]))),"State"]
 resultzip[i] <-  warehouse.locations[which.min(as.numeric(unlist(result[i]))),"Zip"]
 adjcenterlat[[i]] <- warehouse.locations[which.min(as.numeric(unlist(result[i]))),"Latitude"]
 adjcenterlon[[i]] <- warehouse.locations[which.min(as.numeric(unlist(result[i]))),"Longitude"]
 print(paste("Optimium location for warehouse ",i," is ", city,", ", state," - Zip Code: ",resultzip[i], sep = ""))
 
}


map("state", add=T)
points(x = adjcenterlon, y = adjcenterlat, pch=4, cex=2, col='purple', lwd=4)



###### Compare with current distribution centers
# 
# 
# CurrentDistributionZip <- unique(raw.og[which(raw.og$Shipper.Country == 'US' & raw.og$Shipper.Zip.Code != ""), ]$Shipper.Zip.Code)
# 
# CurrentDistributionZip <- sprintf( "%05s", CurrentDistributionZip)
# 
# print(length(CurrentDistributionZip))
# 
# print(head(CurrentDistributionZip,10))
# 
# 
# CurrentDistribution$Longitude <- USZipCodes[match(CurrentDistribution$Zip,USZipCodes$ZIP),"LNG"]
# CurrentDistribution$Latitude <- USZipCodes[match(CurrentDistribution$Zip,USZipCodes$ZIP),"LAT"]
# 
# print(unique(CurrentDistribution$Shipper.Zip.Code))


ClusterResult <- cl_constrain$cluster
LocationID <- cl_constrain$LocationID


###### Split up invoice date to prep for rerate
Output <- as.data.frame(cbind(ClusterResult, LocationID))

Output <- merge(orig.data,Output,by=c("LocationID"))

for(i in 1:num_locations){
assign(paste0("orig.data.cluster",i,sep = ""),subset(raw.og, orig.data$TrackingNumber %in% Output$TrackingNumber & Output$ClusterResult == i))
}
