# init----
rm(list = ls())
library(sf)
library(jsonlite)
library(dplyr)

origsharing <- function(data){
  geom = lapply(1:length(data[["areas"]][["coordinates"]]), function(x) {
    st_linestring(data[["areas"]][["coordinates"]][[x]][, 1:2]) %>% st_cast("POLYGON")
  }) %>% st_sfc()
  return(geom)
}

cleansharing <- function(data) {
  geom = lapply(1:length(data[["areas"]][["coordinates"]]), function(x) {
    st_linestring(data[["areas"]][["coordinates"]][[x]][, 1:2]) %>% st_cast("POLYGON")
  }) %>% st_sfc()
  
  df = st_sf(area = st_area(geom) / 1000, geom)
  df = df %>% arrange(desc(area))
  df$a = 1
  df = df[, 3]
  for (i in 1:nrow(df)) {
    if (i == 1) {
      keep = df[i, ]
    } else {
      if (st_contains(keep, df[i, ], sparse = FALSE)) {
        keep = st_difference(keep, df[i, ])
        keep = keep[, 1]
      } else {
        geom = st_combine(rbind(keep, df[i, ]))
        keep = st_sf(st_drop_geometry(keep), geom)
        keep = st_buffer(keep, 0)
        rm(geom)
      }
    }
  }
  return(keep)
}


#Coup----
download.file("https://storage.googleapis.com/providers/a/coup-madrid.json",
              destfile = "assets/shp/sharing/coup_madrid.json")

data=fromJSON("assets/shp/sharing/coup_madrid.json")
init="Coup"
data_init=origsharing(data)
data_clean=cleansharing(data)
par(mfrow=c(1,2),mar=c(1,1,1,1))
plot(data_init,main=paste(init,"-Init"),col="blue")
plot(st_geometry(data_clean),main=paste(init,"-fix"),col="blue")



#Muving----
download.file("https://storage.googleapis.com/providers/a/muving-madrid.json",
              destfile = "assets/shp/sharing/muving_madrid.json")


data=fromJSON("assets/shp/sharing/muving_madrid.json")
init="Muving"
data_init=origsharing(data)
data_clean=cleansharing(data)
par(mfrow=c(1,2),mar=c(1,1,1,1))
plot(data_init,main=paste(init,"-Init"),col="blue")
plot(st_geometry(data_clean),main=paste(init,"-fix"),col="blue")

#ecooltra----
 download.file("https://storage.googleapis.com/providers/a/cooltra-madrid.json",
              destfile = "assets/shp/sharing/ecooltra_madrid.json")


data=fromJSON("assets/shp/sharing/ecooltra_madrid.json")
init="eCooltra"
data_init=origsharing(data)
plot(data_init,col=NA,border="black")
plot(data_init[[1]],add=T,col="green")
plot(data_init[[2]],add=T,col="green")
#plot(data_init[[3]],add=T,col="green")
plot(data_init[[4]],add=T,col="green")
p=st_coordinates(data_init[[4]]) %>% as.data.frame()
p[1:3,]


data_clean=cleansharing(data)
par(mfrow=c(1,2),mar=c(1,1,1,1))
plot(data_init,main=paste(init,"-Init"),col="blue")
plot(st_geometry(data_clean),main=paste(init,"-fix"),col="blue")



#Movo----
download.file("https://storage.googleapis.com/providers/a/movo-madrid.json",
              destfile = "assets/shp/sharing/movo_madrid.json")
data=fromJSON("assets/shp/sharing/movo_madrid.json")
init="Movo"
data_init=origsharing(data)
data_clean=cleansharing(data)
par(mfrow=c(1,2),mar=c(1,1,1,1))
plot(data_init,main=paste(init,"-Init"),col="blue")
plot(st_geometry(data_clean),main=paste(init,"-fix"),col="blue")


#acciona----
download.file("https://storage.googleapis.com/providers/a/acciona-madrid.json",
              destfile = "assets/shp/sharing/acciona_madrid.json")
data=fromJSON("assets/shp/sharing/acciona_madrid.json")
init="Acciona"
data_init=origsharing(data)
data_clean=cleansharing(data)
par(mfrow=c(1,2),mar=c(1,1,1,1))
plot(data_init,main=paste(init,"-Init"),col="blue")
plot(st_geometry(data_clean),main=paste(init,"-fix"),col="blue")


#ioscoot----
download.file("https://storage.googleapis.com/providers/a/ioscoot-madrid.json",
              destfile = "assets/shp/sharing/ioscoot_madrid.json")
data=fromJSON("assets/shp/sharing/ioscoot_madrid.json")
init="ioscoot"
data_init=origsharing(data)
data_clean=cleansharing(data)





par(mfrow=c(1,2),mar=c(1,1,1,1))
plot(data_init,main=paste(init,"-Init"),col="blue")
plot(st_geometry(data_clean),main=paste(init,"-fix"),col="blue")



# End------
data=fromJSON("assets/shp/sharing/ecooltra_madrid.json")
data_geom=cleansharing(data)
data_sf = st_sf(
  cbind(provider = unique(data[["areas"]][["provider"]]),
        city = unique(data[["areas"]][["city"]])),
  coordinates = st_geometry(data_geom)
)
motosharing_madrid=data_sf
#
data=fromJSON("assets/shp/sharing/movo_madrid.json")
data_geom=cleansharing(data)
data_sf = st_sf(
  cbind(provider = unique(data[["areas"]][["provider"]]),
        city = unique(data[["areas"]][["city"]])),
  coordinates = st_geometry(data_geom)
)

motosharing_madrid=rbind(motosharing_madrid,data_sf)
data=fromJSON("assets/shp/sharing/muving_madrid.json")
data_geom=cleansharing(data)
data_sf = st_sf(
  cbind(provider = unique(data[["areas"]][["provider"]]),
        city = unique(data[["areas"]][["city"]])),
  coordinates = st_geometry(data_geom)
)

motosharing_madrid=rbind(motosharing_madrid,data_sf)

data=fromJSON("assets/shp/sharing/coup_madrid.json")
data_geom=cleansharing(data)
data_sf = st_sf(
  cbind(provider = unique(data[["areas"]][["provider"]]),
        city = unique(data[["areas"]][["city"]])),
  coordinates = st_geometry(data_geom)
)

motosharing_madrid=rbind(motosharing_madrid,data_sf)
data=fromJSON("assets/shp/sharing/acciona_madrid.json")
data_geom=cleansharing(data)
data_sf = st_sf(
  cbind(provider = unique(data[["areas"]][["provider"]]),
        city = unique(data[["areas"]][["city"]])),
  coordinates = st_geometry(data_geom)
)

motosharing_madrid=rbind(motosharing_madrid,data_sf)

data=fromJSON("assets/shp/sharing/ioscoot_madrid.json")
data_geom=cleansharing(data)
data_sf = st_sf(
  cbind(provider = unique(data[["areas"]][["provider"]]),
        city = unique(data[["areas"]][["city"]])),
  coordinates = st_geometry(data_geom)
)

motosharing_madrid=rbind(motosharing_madrid,data_sf)
st_crs(motosharing_madrid) <- 4326

motosharing_madrid$area_km2=as.integer(st_area(motosharing_madrid))/1000000

plot(motosharing_madrid[,"provider"],axes=T)
