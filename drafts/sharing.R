rm(list = ls())
library(sf)
library(jsonlite)
library(dplyr)

#Coup----
 download.file("https://storage.googleapis.com/providers/a/coup-madrid.json",
              destfile = "_data/shp/sharing/coup_madrid.json")

coup=fromJSON("_data/shp/sharing/coup_madrid.json")
geom=st_polygon(coup[["areas"]][["coordinates"]]) %>% st_cast("MULTIPOLYGON") %>% st_sfc()
coup=st_sf(prov="Muving",city="Madrid",geom)
rm(geom)

#Muving----
download.file("https://storage.googleapis.com/providers/a/muving-madrid.json",
            destfile = "_data/shp/sharing/muving_madrid.json")

muving=fromJSON("_data/shp/sharing/borra.json")
geom=lapply(1:length(muving[["areas"]][["coordinates"]]), function(x){
  st_linestring(muving[["areas"]][["coordinates"]][[x]]) %>% st_cast("POLYGON")
}
  ) %>% st_sfc()
geom=st_combine(geom)
muving=st_sf(prov="Muving",city="Madrid",geom)
rm(geom)

#ecooltra----
 download.file("https://storage.googleapis.com/providers/a/cooltra-madrid.json",
              destfile = "_data/shp/sharing/ecooltra_madrid.json")
ecooltra=fromJSON("_data/shp/sharing/ecooltra_madrid.json")
geom=lapply(1:length(ecooltra[["areas"]][["coordinates"]]), function(x){
  st_linestring(ecooltra[["areas"]][["coordinates"]][[x]][,1:2]) %>% st_cast("POLYGON")
}
) %>% st_sfc()

df=st_sf(area=st_area(geom)/1000,geom)
df=df %>% arrange(desc(area))
for (i in 1:nrow(df)){
  if (i==1){
    keep=df[i,]
  } else {
    if (st_contains(keep,df[i,],sparse = FALSE)){
      keep=st_difference(keep,df[i,])
    } else {
      geom=st_combine(rbind(keep,df[i,]))
      keep=st_sf(st_drop_geometry(keep),geom)
      rm(geom)
    }
  }
}
ecooltra=st_sf(prov="eCooltra",city="Madrid",geom=st_geometry(keep))
rm(i,df,keep)

#Movo----
download.file("https://storage.googleapis.com/providers/a/movo-madrid.json",
              destfile = "_data/shp/sharing/movo_madrid.json")
movo=fromJSON("_data/shp/sharing/movo_madrid.json")

geom=lapply(1:length(movo[["areas"]][["coordinates"]]), function(x){
  st_linestring(movo[["areas"]][["coordinates"]][[x]][,1:2]) %>% st_cast("POLYGON")
}
) %>% st_sfc()

df=st_sf(area=st_area(geom)/1000,geom)
df=df %>% arrange(desc(area))
for (i in 1:nrow(df)){
  if (i==1){
    keep=df[i,]
  } else {
    if (st_contains(keep,df[i,],sparse = FALSE)){
      keep=st_difference(keep,df[i,])
    } else {
      geom=st_combine(rbind(keep,df[i,]))
      keep=st_sf(st_drop_geometry(keep),geom)
      rm(geom)
    }
  }
}
movo=st_sf(prov="Movo",city="Madrid",geom=st_geometry(keep))
rm(i,df,keep)


#Acciona----
download.file("https://storage.googleapis.com/providers/a/acciona-madrid.json",
              destfile = "_data/shp/sharing/acciona_madrid.json")
acciona=fromJSON("_data/shp/sharing/acciona_madrid.json")

geom=lapply(1:length(acciona[["areas"]][["coordinates"]]), function(x){
  st_linestring(acciona[["areas"]][["coordinates"]][[x]][,1:2]) %>% st_cast("POLYGON")
}
) %>% st_sfc()
plot(geom)
df=st_sf(area=st_area(geom)/1000,geom)
df=df %>% arrange(desc(area))
df$a=1
df=df[,3]
for (i in 1:nrow(df)){
  if (i==1){
    keep=df[i,]
  } else {
    if (st_contains(keep,df[i,],sparse = FALSE)){
      keep=st_difference(keep,df[i,])
      keep=keep[,1]
    } else {
      geom=st_combine(rbind(keep,df[i,])) 
      keep=st_sf(st_drop_geometry(keep),geom)
      keep=st_buffer(keep,0)
      rm(geom)
    }
  }
}

acciona=st_sf(prov="Acciona",city="Madrid",geom=st_geometry(keep))
rm(i,df,keep)


#ioscoot----
download.file("https://storage.googleapis.com/providers/a/ioscoot-madrid.json",
              destfile = "_data/shp/sharing/ioscoot_madrid.json")
ioscoot=fromJSON("_data/shp/sharing/ioscoot_madrid.json")

geom=lapply(1:length(ioscoot[["areas"]][["coordinates"]]), function(x){
  st_linestring(ioscoot[["areas"]][["coordinates"]][[x]][,1:2]) %>% st_cast("POLYGON")
}
) %>% st_sfc()
ioscoot=st_sf(prov="ioscoot",city="Madrid",geom=st_geometry(geom))
rm(geom)

#All----
motosharing_madrid=do.call("rbind",list(acciona,coup,movo,ecooltra,ioscoot))
motosharing_madrid=st_cast(motosharing_madrid,"MULTIPOLYGON")
rm(acciona,coup,movo,ecooltra,ioscoot)

