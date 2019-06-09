# 0. Init----
rm(list = ls())
library(sf)
library(readxl)
library(cartography)
library(rosm)
library(dplyr)


source("pass.R")


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
#BarriosMad = st_transform(BarriosMad, 4326)

#2. Get tiles----
neightile = source_from_url_format(
  paste(
    "https://tile.thunderforest.com/neighbourhood/${z}/${x}/${y}.png?apikey=",
    THUNDERFOREST_API,
    sep = ""
  ),
  attribution = "Maps © Thunderforest, Data © OpenStreetMap contributors",
  extension = "png"
)
register_tile_source(neighbourhood = neightile)
tile = getTiles(
  BarriosMad,
  type = "neighbourhood",
  crop = TRUE,
  verbose = TRUE,
  zoom = 11
)
raster::writeRaster(tile,
                    "myprojects/sharing_madrid/assets/Neighbourhood.tif",
                    overwrite = TRUE)
rm(tile, neightile)
tile_import = raster::brick("myprojects/sharing_madrid/assets/Neighbourhood.tif")

voyurl = source_from_url_format(
  url_format = c("http://a.basemaps.cartocdn.com/rastertiles/voyager/${z}/${x}/${y}.png",
                 "http://b.basemaps.cartocdn.com/rastertiles/voyager/${z}/${x}/${y}.png",
                 "http://c.basemaps.cartocdn.com/rastertiles/voyager/${z}/${x}/${y}.png"),
  attribution = "Map tiles by Carto, under CC BY 3.0. Data by OpenStreetMap, under ODbL.",
  extension = "png")
register_tile_source(cartovoyager = voyurl)

tile = getTiles(
  BarriosMad,
  type = "cartovoyager",
  crop = TRUE,
  verbose = TRUE,
  zoom = 11
)
tilesLayer(tile)
raster::writeRaster(tile,
                    "myprojects/sharing_madrid/assets/CartoVoyager.tif",
                    overwrite = TRUE)
# 3. Area kms2----
BarriosMad$G_area_km2 = as.double(st_area(BarriosMad)) / (1000 ^ 2)

# 4. M30----
BarriosMad$G_M30 = ifelse(
  BarriosMad$CODDIS <= '07' | BarriosMad$CODBAR %in%
    c("084", "085", "092", "093", "094"),
  "IN",
  "OUT"
)

st_write(
  BarriosMad,
  "myprojects/sharing_madrid/assets/Madrid_Barrios.gpkg",
  factorsAsCharacter = FALSE,
  layer_options = "OVERWRITE=YES"
)

# 5. Population 2019/05----
#http://www-2.munimadrid.es/TSE6/control/seleccionDatosBarrio
POPMAD <-
  read_excel("myprojects/sharing_madrid/assets/POPMAD_20190501.xls",
             sheet = "Import")

# 6. Income per capita----
# Urban Audit 2015
# Source: https://www.madrid.es/portales/munimadrid/es/Inicio/El-Ayuntamiento/Estadistica/Areas-de-informacion-estadistica/Economia/Renta/?vgnextfmt=default&vgnextchannel=ef863636b44b4210VgnVCM2000000c205a0aRCRD&vgnextoid=ef863636b44b4210VgnVCM2000000c205a0aRCRD

INCOME <-
  read_excel("myprojects/sharing_madrid/assets/URBAN AUDIT.xls",
             sheet = "Import")
# Adding data--
BarriosMad = left_join(
  BarriosMad,
  POPMAD %>%
    select(
      CODBAR,
      P_TargetPop = POB_20_69,
      P_Overall = POP_TOT,
      P_National = POB_NAC,
      P_Foreign = POB_EXT,
      P_PercForeign = PORC_EXT
    )
)

BarriosMad = left_join(BarriosMad,
                       INCOME %>%
                         select(CODBAR,
                                W_IncomePerCap = INCOME_PER_CAPITA))


BarriosMad$D_Density = BarriosMad$P_Overall / BarriosMad$G_area_km2

# 7. Crime 2018 ----
for (i in 1:12) {
  d = as.Date(paste("2018", i, "1", sep = "-"))
  url = paste(
    "https://datos.madrid.es/egob/catalogo/212616",
    48 + i,
    "policia-estadisticas.xlsx",
    sep = "-"
  )
  
  destfile <- paste(tempdir(), "police.xlsx", sep = "/")
  curl::curl_download(url, destfile)
  est <- read_excel(destfile,
                    skip = 1)
  est$refdate = d
  if (i == 1) {
    police = est
  }
  else {
    police = rbind(police, est)
  }
  rm(d, est)
}
rm(i, destfile, filetemp, url)
names(police)
polmad = police %>%
  group_by(DISTRITOS) %>%
  summarise(
    PERS_CRIME = sum(`RELACIONADAS CON LAS PERSONAS`),
    PROPERTY = sum(`RELACIONADAS CON EL PATRIMONIO`),
    WEAPON = sum(`POR TENENCIA DE ARMAS`)
  )


allcrimes = rowSums(polmad[, 2:ncol(polmad)])
polmad = cbind(polmad, allcrimes)



tojoin = BarriosMad %>% st_drop_geometry() %>%
  select(DISTRITOS = NOMDIS,
         CODDIS, P_Overall) %>%
  group_by(CODDIS, DISTRITOS) %>%
  summarise(DIST_POP = sum(P_Overall))


tojoin$DISTRITOS = toupper(tojoin$DISTRITOS)

polmad = left_join(polmad,
                   tojoin)
polmad$C_CrimesPer1000 = 1000 * polmad$allcrimes / polmad$DIST_POP

BarriosMad = left_join(BarriosMad,
                       polmad %>% select(CODDIS,
                                         C_CrimesPer1000)) %>% arrange(desc(CODBAR))


# Merge and keep---

st_write(
  BarriosMad,
  "myprojects/sharing_madrid/assets/Madrid_Barrios.gpkg",
  factorsAsCharacter = FALSE,
  layer_options = "OVERWRITE=YES"
)

#6. Land use----
# 2017
# https://datos.madrid.es/egob/catalogo/211328-10-valores-catastrales-barrio.xls

url = "https://datos.madrid.es/egob/catalogo/211328-10-valores-catastrales-barrio.xls"
destfile <- paste(tempdir(), "land.xls", sep = "/")
curl::curl_download(url, destfile)
land <- read_excel(destfile)
land$sup_cons_barrio = land$sup_cons_barrio / 1000 ^ 2

valueHouses = land %>%
  subset(uso_cod == "V") %>%
  dplyr::select(CODBAR = barrio_cod,
                H_HouseAveVal = val_cat_medio,
                H_HouseSup = sup_cons_barrio)


BarriosMad = left_join(BarriosMad, valueHouses)

off_building_area = land %>%
  subset(uso_cod == "O") %>%
  dplyr::select(CODBAR = barrio_cod,
                H_OfficeSup = sup_cons_barrio)

BarriosMad = left_join(BarriosMad, off_building_area) %>%
  mutate(H_Office2Sup = H_OfficeSup / G_area_km2,
         H_House2Sup = H_HouseSup / G_area_km2)


# Merge and keep----

st_write(
  BarriosMad,
  "myprojects/sharing_madrid/assets/Madrid_Barrios.gpkg",
  factorsAsCharacter = FALSE,
  layer_options = "OVERWRITE=YES"
)

rm(list = ls())

