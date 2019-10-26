setwd("~/R/dieghernan.github.io/myprojects/wikimaps")

# Libraries----

rm(list = ls())
library(readxl)
library(sf)
library(dplyr)
library(cartography)
library(scales)
library(viridis)

# Municipios----
PENIN = st_read(
  "~/R/mapslib/CNIG./LineasLimite/recintos_municipales_inspire_peninbal_etrs89.shp",
  stringsAsFactors = F
)
CAN = st_read(
  "~/R/mapslib/CNIG./LineasLimite/recintos_municipales_inspire_canarias_wgs84.shp",
  stringsAsFactors = F
) %>%
  st_transform(3857)

CAN = st_sf(
  st_drop_geometry(CAN),
  geometry = st_geometry(CAN) + c(550000, 920000),
  crs = st_crs(CAN)
)

MUNIC = rbind(st_transform(PENIN, 3857),
              st_transform(CAN, 3857))

MUNIC$CODIGOINE = substr(MUNIC$INSPIREID,
                         nchar(MUNIC$INSPIREID) - 4,
                         nchar(MUNIC$INSPIREID))

MUNIC = MUNIC %>% select(CODNUT1,
                         CODNUT2,
                         CODNUT3,
                         CODIGOINE,
                         MUNICIPIO = NAMEUNIT) %>% arrange(CODIGOINE)


# Import maps----

WORLD = st_read(
  "https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/countries/geojson/CNTR_RG_10M_2016_3857.geojson",
  stringsAsFactors = FALSE
)

# Population data----
Pad18 = read_xlsx("pobmun18.xlsx")
Pad18$CODIGOINE = substr(paste(Pad18$CPRO, Pad18$CMUN, sep = "") , 1, 5)


MapPad18 = left_join(
  MUNIC,
  Pad18 %>%
    select(PROVINCIA,
           CPRO, CMUN,
           CODIGOINE,
           NOMBRE,
           Poblacion18 = POB18)
) %>% arrange(CODIGOINE)

MapPad18$AreaKM2 = as.double(st_area(MapPad18 %>% st_transform(4326))) / 1000000
MapPad18$DensKM2 = MapPad18$Poblacion18 / MapPad18$AreaKM2

# Simplify----

library(rmapshaper)
MunicSimpl=ms_simplify(MapPad18,keep_shapes = T,keep = 0.10)

ProvSimp=MunicSimpl %>% 
  group_by(CODNUT3) %>% 
  summarise(a=1)

CCAASimp=MunicSimpl %>% 
  group_by(CODNUT2) %>% 
  summarise(a=1)


# AU Ministerio Fomento----
AU_MFom <- read_xlsx("../../assets/custom/AU_MFom18.xlsx")
AU_MFom$CODIGOINE = AU_MFom$CODE

AU = inner_join(MunicSimpl, AU_MFom %>%
                  filter(!is.na(AREA_URBANA)),
                by="CODIGOINE") %>%
  group_by(AREA_URBANA) %>%
  summarise(Pop = sum(POB18)) %>%
  arrange(desc(Pop))



# Plot----
br = c(0, 10, 25, 50, 100, 200, 500, 1000, 5000, 10000, 30000)

#pdi=90
pdi = 90

svg(
  "Population per km2 by municipality in Spain (2018).svg",
  pointsize = pdi,
  width =  1600 / pdi,
  height = 880 / pdi,
  bg="#C6ECFF"
)


par(mar = c(0, 0, 0, 0))
plot(st_geometry(ProvSimp),
     col = "#E0E0E0",
     border = NA,
     bg = "#C6ECFF")

plot(
  st_geometry(WORLD),
  col = "#E0E0E0",
  bg = "#C6ECFF",
  add = T,
  lwd = 0.05
)

choroLayer(
  MunicSimpl,
  add = T,
  var = "DensKM2",
  border = "#646464",
  # border=NA,
  breaks = br,
  col = rev(inferno(length(br) - 1, 0.5)),
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)

legendChoro(
  pos = "left",
  title.txt = " ",
  title.cex = 0.5,
  values.cex = 0.25,
  breaks = c(" ", format(br, big.mark = ",")[-c(1,length(br))]," "),
  col = rev(inferno(length(br) - 1, 0.5)),
  nodata = T,
  nodata.txt = "n.d.",
  nodata.col = "#E0E0E0"
)

plot(
  st_geometry(ProvSimp),
  lwd = 0.3,
  lty = 3,
  border = "black",
  add = T
)
plot(st_geometry(CCAASimp),
     lwd = 0.25,
     border = "black",
     add = T)

dev.off()


# Plot pop----

br = c(0,  200, 500,  1000, 
       5000, 10000, 20000, 50000, 
       100000,
       500000,
       1000000,
       5000000) %>% as.integer()

#pdi=90
pdi = 90

svg(
  "Population by municipality in Spain (2018).svg",
  pointsize = pdi,
  width =  1600 / pdi,
  height = 880 / pdi,
  bg="#C6ECFF"
)

par(mar = c(0, 0, 0, 0))
plot(st_geometry(ProvSimp),
     col = "#E0E0E0",
     border = NA,
     bg = "#C6ECFF")

plot(
  st_geometry(WORLD),
  col = "#E0E0E0",
  bg = "#C6ECFF",
  add = T,
  lwd = 0.05
)

choroLayer(
  MunicSimpl,
  add = T,
  var = "Poblacion18",
  border = "#646464",
  breaks = br,
  col = rev(inferno(length(br) - 1, 0.5)),
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)


legendChoro(
  pos = "left",
  title.txt = " ",
  title.cex = 0.5,
  values.cex = 0.25,
  breaks = c(" ", format(br, big.mark = ",")[-c(1,length(br))]," "),
  col = rev(inferno(length(br) - 1, 0.5)),
  nodata = T,
  nodata.txt = "n.d.",
  nodata.col = "#E0E0E0"
)

plot(
  st_geometry(ProvSimp),
  lwd = 0.3,
  lty = 3,
  border = "black",
  add = T
)
plot(st_geometry(CCAASimp),
     lwd = 0.25,
     border = "black",
     add = T)

dev.off()

#Export----
# MUNIC = st_read("../../assets/shp/ESRI/Municipios_IGN.shp",
#                 stringsAsFactors = FALSE)
# 
# 
# df = st_drop_geometry(MapPad18)
# df = left_join(df, AU_MFom %>%
#                  select(CODIGOINE, AREA_URBANA))
# 
# MunExport = left_join(MUNIC,
#                       df) %>% select(
#                         CODIGOINE,
#                         CPRO,
#                         CMUN,
#                         CCAA,
#                         PROVINCIA,
#                         NOMBRE,
#                         POBLACION18 = Poblacion18,
#                         AreaKM2,
#                         DensKM2,
#                         AREA_URBANA
#                       )
# 
# exportpad = st_write(
#   MunExport,
#   "MunExport.gpkg",
#   factorsAsCharacter = FALSE,
#   layer_options = "OVERWRITE=YES"
# )

# Plot AU----

# wikicolors = c("#e41a1c",
#                "#4daf4a",
#                "#984ea3",
#                "#ff7f00",
#                "#377eb8",
#                "#ffff33")


library(RColorBrewer)

pdi = 90

svg(
  "Large Urban Areas in Spain by population (2018).svg",
  pointsize = pdi,
  width =  1600 / pdi,
  height = 880 / pdi,
  bg = "#C6ECFF"
)
par(mar = c(0, 0, 0, 0))
plot(st_geometry(ProvSimp),
     col = NA,
     border = NA,
     bg = "#C6ECFF")
plot(st_geometry(WORLD),
     col = "#E0E0E0",
     bg = "#C6ECFF",
     add = T)
plot(
  st_geometry(ProvSimp),
  col = "#FEFEE9",
  lwd = 0.3,
  lty = 3,
  border = "black",
  add = T
)
plot(st_geometry(CCAASimp),
     lwd = 0.25,
     col = "#FEFEE9",
     border = "black",
     add = T)

br2 = c(0, 50000, 100000, 600000, 10000000)

AU$categs = cut(AU$Pop, unique(br2))
colAU=magma(6)[2:5]

typoLayer(
  AU,
  var = "categs",
  border=NA,
  col =  colAU,
  legend.pos = "n",
  add=T
)

legendTypo(
  pos = "left",
  title.txt = "",
  values.cex = 0.25,
  categ = rev(c(
    "<50.000", "50.000-100.000", "100.000-600.000", ">600.000"
  )),
  nodata = F,
  col =  colAU
)

dev.off()

rsvg::rsvg_png("Large Urban Areas in Spain by population (2018).svg",
               "Large Urban Areas in Spain by population (2018).png")

# Plot muns----
pdi = 90

svg(
  "Muns.svg",
  pointsize = pdi,
  width =  1600 / pdi,
  height = 880 / pdi,
  bg = "#C6ECFF"
)
par(mar = c(0, 0, 0, 0))
plot(st_geometry(ProvSimp),
     col = NA,
     border = NA,
     bg = "#C6ECFF")
plot(st_geometry(WORLD),
     col = "#E0E0E0",
     bg = "#C6ECFF",
     add = T)
plot(st_geometry(MunicSimpl),add = T,
     col = "#FEFEE9",
     border = "grey50",
     lwd=0.3)
plot(
  st_geometry(ProvSimp),
  lwd = 0.4,
  lty = 3,
  border = "grey5",
  add = T
)
plot(st_geometry(CCAASimp),
     lwd = 0.35,
     border = "black",
     add = T)

wikicolors = c("#e41a1c",
               "#4daf4a",
               "#984ea3",
               "#ff7f00"
               )





dev.off()
