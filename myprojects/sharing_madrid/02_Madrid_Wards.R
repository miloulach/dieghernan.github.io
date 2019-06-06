# 0. Init----
rm(list = ls())
library(sf)
library(jsonlite)
library(dplyr)
library(readxl)

# 1. Download shapefile----

# source:Portal de Datos Abiertos de Madrid https://datos.madrid.es
tempfile(fileext = ".zip")
tempfile(fileext = ".zip")
tempdir()
filetemp = paste(tempdir(), "temp.zip", sep = "/")
tempdir()

download.file(
  "https://datos.madrid.es/egob/catalogo/200078-10-distritos-barrios.zip",
  filetemp
)
unzip(filetemp, exdir = tempdir(), junkpaths = T)
BarriosMad = st_read(paste(tempdir(), "BARRIOS.shp", sep = "/"),
                     stringsAsFactors = FALSE)
BarriosMad = st_transform(BarriosMad, 4326)
BarriosMad$area_km2 = as.double(st_area(BarriosMad)) / (1000 ^ 2)

st_write(
  BarriosMad,
  "myprojects/sharing_madrid/assets/Madrid_Barrios.gpkg",
  factorsAsCharacter = FALSE,
  layer_options = "OVERWRITE=YES"
)

