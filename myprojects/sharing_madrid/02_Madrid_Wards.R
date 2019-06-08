# 0. Init----
rm(list = ls())
library(sf)
library(jsonlite)
library(readxl)
library(cartography)
library(RColorBrewer)
library(dplyr)
library(rosm)
library(classInt)
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

# Check area
BarriosMad$G_area_km2 = as.double(st_area(BarriosMad)) / (1000 ^ 2)
#Plot and check
abreaks = as.integer(classInt::classIntervals(BarriosMad$G_area_km2,
                                              n = 8,
                                              style = "kmeans")$brks)

getPalette = colorRampPalette(rev(brewer.pal(9, "RdYlBu")))
palarea = paste(getPalette(length(abreaks)),
                60, #alpha
                sep = "")

par(mfrow=c(1,2),mar = c(1, 1, 1, 1))

tilesLayer(tile_import)
choroLayer(
  BarriosMad,
  var = "G_area_km2",
  border = "grey90",
  lwd = 1,
  breaks = abreaks,
  col = palarea,
  legend.pos = "n",
  add = T
)

legendChoro(
  pos = "topleft",
  breaks = paste(abreaks, "km2", sep = " "),
  title.txt = "",
  col = getPalette(length(abreaks)),
  nodata = FALSE
)
lege
layoutLayer(
  title = "Area KM2",
  postitle = "center",
  horiz = FALSE,
  coltitle = "#008080",
  col=NA,
  scale=5,
  posscale = "bottomleft",
  tabtitle = TRUE,
  sources = "Portal de Datos Abiertos de Madrid \n Maps © Thunderforest, Data © OpenStreetMap contributors"
)

# Flag M-30

BarriosMad$G_M30=ifelse(BarriosMad$CODDIS <= '07' | BarriosMad$CODBAR %in% 
                          c("084","085","092","093","094"),
                         "IN","OUT")

palM30=paste(getPalette(2),
              60, #alpha
              sep="")

tilesLayer(tile_import)
typoLayer(BarriosMad,var="G_M30",
           col=palM30,
          legend.title.txt = "",
          legend.pos="topleft",
          legend.values.order = c("IN","OUT"),
          border = "grey90",
          lwd = 1,
          add=T)
layoutLayer(
  title = "Area inside M-30 road",
  postitle = "center",
  horiz = FALSE,
  coltitle = "#008080",
  col=NA,
  scale=5,
  posscale = "bottomleft",
  tabtitle = TRUE,
  sources = "Portal de Datos Abiertos de Madrid \n Maps © Thunderforest, Data © OpenStreetMap contributors"
)

st_write(
  BarriosMad,
  "myprojects/sharing_madrid/assets/Madrid_Barrios.gpkg",
  factorsAsCharacter = FALSE,
  layer_options = "OVERWRITE=YES"
)
dev.off()

# 2. Population 2019/05----
#http://www-2.munimadrid.es/TSE6/control/seleccionDatosBarrio
POPMAD <-
  read_excel("myprojects/sharing_madrid/assets/POPMAD_20190501.xls",
             sheet = "Import")

# 3. Income per capita----
# Urban Audit 2015
# Source: https://www.madrid.es/portales/munimadrid/es/Inicio/El-Ayuntamiento/Estadistica/Areas-de-informacion-estadistica/Economia/Renta/?vgnextfmt=default&vgnextchannel=ef863636b44b4210VgnVCM2000000c205a0aRCRD&vgnextoid=ef863636b44b4210VgnVCM2000000c205a0aRCRD

INCOME <-
  read_excel("myprojects/sharing_madrid/assets/URBAN AUDIT.xls",
             sheet = "Import")
# Adding data----
BarriosMad = left_join(BarriosMad,
                       POPMAD %>%
                         select(CODBAR,
                                P_TargetPop=POB_20_69,
                                P_Overall=POP_TOT,
                                P_National=POB_NAC,
                                P_Foreign=POB_EXT,
                                P_PercForeign=PORC_EXT))

BarriosMad = left_join(BarriosMad,
                       INCOME %>%
                         select(CODBAR,
                                W_IncomePerCap=INCOME_PER_CAPITA))


BarriosMad$D_Density=BarriosMad$P_Overall/BarriosMad$G_area_km2
#par(mfrow=c(2,2),mar = c(1, 1, 1, 1))
pal=paste(getPalette(6),
             60, #alpha
             sep="")

b=unlist(
  classIntervals(BarriosMad$P_TargetPop,n=5,style = "pretty")[["brks"]]
  )
tilesLayer(tile_import)
choroLayer(BarriosMad,var="P_TargetPop",
           breaks=b,
           col=paste(getPalette(length(b)),
                     80, #alpha
                     sep=""),
           legend.pos = "topleft",
           add=T)

b=unlist(
  classIntervals(BarriosMad$P_PercForeign,n=6,style = "pretty")[["brks"]]
)

tilesLayer(tile_import)
choroLayer(BarriosMad,var="P_PercForeign",
           breaks=b,
           col=paste(getPalette(length(b)),
                     80, #alpha
                     sep=""),
           legend.values.rnd=2,
           legend.pos = "topleft",
           add=T)
b=unlist(
  classIntervals(BarriosMad$W_IncomePerCap,n=5,style = "quantile")[["brks"]]
)
b=as.integer(b/1000)*1000

tilesLayer(tile_import)
choroLayer(BarriosMad,var="W_IncomePerCap",
           breaks=b,
           col=paste(getPalette(length(b)),
                     80, #alpha
                     sep=""),
           legend.pos = "topleft",
           add=T)
tilesLayer(tile_import)
choroLayer(BarriosMad,var="D_Density",
           nclass=6,col=pal,
           legend.pos = "topleft",
           add=T)

# 4. Crime 2018 ----



for (i in 1:12) {
  d = as.Date(paste("2018", i, "1", sep = "-"))
  url = paste(
    "https://datos.madrid.es/egob/catalogo/212616",
    48 + i,
    "policia-estadisticas.xlsx",
    sep = "-"
  )
  destfile <- paste(tempdir(), "police.xlsx", sep = "/")
  download.file(url,
                destfile)
  est <- read_excel(destfile,
                    skip = 1)
  est$refdate=d
  if (i==1){
    police=est
  } 
  else {
    police=rbind(police,est)
  }
  rm(d,est)
}
rm(i,destfile,filetemp,url)
names(police)
polmad= police %>% 
  group_by(DISTRITOS) %>%
  summarise(PERS_CRIME=sum(`RELACIONADAS CON LAS PERSONAS`),
            PROPERTY=sum(`RELACIONADAS CON EL PATRIMONIO`),
            WEAPON=sum(`POR TENENCIA DE ARMAS`)
            )


allcrimes=rowSums(polmad[,2:ncol(polmad)])
polmad=cbind(polmad,allcrimes)



tojoin= BarriosMad %>% st_drop_geometry() %>% 
  dplyr::select(DISTRITOS=NOMDIS,
         CODDIS,POP_TOT) %>% 
  group_by(CODDIS,DISTRITOS) %>%
  summarise(DIST_POP=sum(POP_TOT)) 


tojoin$DISTRITOS=toupper(tojoin$DISTRITOS)

polmad=left_join(polmad,
                    tojoin)
polmad$DIST_CRIMES_PER_1000=1000*polmad$allcrimes/polmad$DIST_POP

BarriosMad = left_join(BarriosMad,
                       polmad %>% select(
                         CODDIS,
                         DIST_CRIMES_PER_1000
                         )
                       ) %>% arrange(desc(CODBAR))


# Merge and keep----

st_write(
  BarriosMad,
  "myprojects/sharing_madrid/assets/Madrid_Barrios.gpkg",
  factorsAsCharacter = FALSE,
  layer_options = "OVERWRITE=YES"
)

#5. Land use----
# 2017
# https://datos.madrid.es/egob/catalogo/211328-10-valores-catastrales-barrio.xls

url="https://datos.madrid.es/egob/catalogo/211328-10-valores-catastrales-barrio.xls"
destfile <- paste(tempdir(), "land.xls", sep = "/")
download.file(url,
              destfile)
land <- read_excel(destfile)

valueHouses= land %>% 
  subset(uso_cod=="V") %>%
  dplyr::select(
    CODBAR=barrio_cod,
    HOUSE_AVE_VAL=val_cat_medio)

BarriosMad = left_join(BarriosMad,valueHouses)

off_building_area= land %>% 
  subset(uso_cod=="O") %>%
  dplyr::select(
    CODBAR=barrio_cod,
    OFFICES_AREA=sup_cons_barrio)


BarriosMad = left_join(BarriosMad,off_building_area)

# Merge and keep----

st_write(
  BarriosMad,
  "myprojects/sharing_madrid/assets/Madrid_Barrios.gpkg",
  factorsAsCharacter = FALSE,
  layer_options = "OVERWRITE=YES"
)

rm(list = ls())

# Test----

test=st_read("myprojects/sharing_madrid/assets/Madrid_Barrios.gpkg")

names(test)
ncol(test)
plot(test[10:20])


