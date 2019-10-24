setwd("/cloud/project/myprojects/wikimaps")

# Libraries----

rm(list = ls())
library(readxl)
library(sf)
library(dplyr)
library(cartography)
library(scales)

# Import maps----
MUNIC = st_read("../../assets/shp/ESRI/Municipios_IGN.shp",
              stringsAsFactors = FALSE)




CAN = ALL %>% subset(CODNUT2 == "ES70") %>% st_transform(3857)
CANNEW = st_sf(st_drop_geometry(CAN),
               geometry = st_geometry(CAN) + c(550000, 920000))

st_crs(CANNEW) <- 3857

CANNEW = CANNEW %>% st_transform(st_crs(ALL))

ALL = ALL %>% subset(CODNUT2 != "ES70") %>% rbind(CANNEW)


All.df = st_drop_geometry(ALL)

Pad18 = read_xlsx("pobmun18.xlsx")

Pad18$CODIGOINE = substr(paste(Pad18$CPRO, Pad18$CMUN, sep = "") , 1, 5)
fullj = full_join(All.df, Pad18)



Map2 = left_join(ALL,
                 Pad18 %>%
                   select(PROVINCIA,
                          CODIGOINE,
                          NOMBRE,
                          Poblacion = POB18))

Map2$area = as.double(st_area(Map2)) / 1000000
Map2$dens = Map2$Poblacion / Map2$area


# Group CCAA/PROV----

CCAA <- ALL %>% select(CODNUT2) %>% group_by(CODNUT2) %>%
  summarise(a = 1) %>% select(-a)


PROV <-  ALL %>% select(CODNUT3) %>% group_by(CODNUT3) %>%
  summarise(a = 1) %>% select(-a)

download.file(
  "https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/countries/geojson/CNTR_RG_03M_2016_3857.geojson",
  "world.geojson"
)

WORLD = st_read("world.geojson",
                stringsAsFactors = FALSE) %>% 
  st_transform(st_crs(Map2))

# Areas metropolitanas----
download.file(
  "https://es.wikipedia.org/wiki/Anexo:%C3%81reas_metropolitanas_de_Espa%C3%B1a",
  "metro.html"
)

tab = read_html("metro.html") %>%
  html_nodes(xpath = '//*[@id="mw-content-text"]/div/table') %>%
  html_table(fill = T) %>%
  as.data.frame(stringsAsFactors = F,
                fix.empty.names = F)

tab$name = tab$Área.metropolitana
tab$pop = as.numeric(gsub(
  ",",
  ".",
  gsub("\\.", "", tab$Ministerio.de.Fomento..2018..5..U.200B.)
))
tab = tab %>% select(name, pop) %>% filter(pop > 600000)

coords = function(res) {
  download.file(
    paste(
      "http://api.geonames.org/searchJSON?formatted=true&username=dieghernan&style=medium&maxRows=1&q=",
      res,
      sep = ""
    ),
    "t.json"
  )
  geonames = fromJSON("t.json")
  geonames = data.frame(geonames[["geonames"]])
  geonames$dest = res
  geonames = geonames %>% select(tofun = dest,
                                 toponymName,
                                 countryCode,
                                 long = lng,
                                 lat)
  geonames$long = as.numeric(geonames$long)
  geonames$lat = as.numeric(geonames$lat)
  
  return(geonames)
}

datos = tab
tab$name
datos$fixname = c(
  "Madrid",
  "Barcelona",
  "Valencia",
  "Sevilla",
  "Malaga",
  "Bilbao",
  "Asturias",
  "Zaragoza",
  "Alicante",
  "Murcia",
  "Jerez"
)
datos$tofun = paste(datos$fixname, "+ES", sep = "")


for (i in 1:nrow(datos)) {
  cc = coords(as.character(datos[i, "tofun"]))
  if (i == 1) {
    finalcoords = cc
  } else {
    finalcoords = rbind(finalcoords, cc)
  }
  rm(cc)
  # file.remove("t.json",)
}

finpop = left_join(datos, finalcoords)

metro.sf = st_as_sf(finpop, coords = c("long", "lat"),
                    crs = 4326) %>% st_transform(st_crs(WORLD))

metro.sf2 = metro.sf
metro.sf$name = "           "
metro.sffin = rbind(metro.sf, metro.sf2)



# Plot----
svg(
  "testpad.svg",
  pointsize = 30,
  width =  800 / 30,
  height = 440 / 30
)
par(mar = c(0, 0, 0, 0))
plot(st_geometry(Map2),
     col = NA,
     border = NA,
     bg = "#C6ECFF")
plot(st_geometry(WORLD),
     col = "#E0E0E0",
     bg = "#C6ECFF",
     add = T)

br = c(0, 30, 60, 90, 120, 200, 300, 500, 1000, 5000, 10000, 30000)
choroLayer(
  Map2,
  add = T,
  var = "dens",
  border = "#646464",
  breaks = br,
  col = rev(inferno(length(br) - 1, 0.5)),
  lwd = 0.1,
  legend.pos = "n"
  # colNA = "#E0E0E0",
  # legend.pos = "left",
  # legend.title.txt = "",
  # legend.values.cex = 0.25
  
)




legendChoro(
  pos = "left",
  title.txt = " ",
  title.cex = 0.5,
  values.cex = 0.7,
  breaks = format(br, big.mark = ","),
  col = rev(inferno(length(br) - 1, 0.5)),
  nodata = T,
  nodata.txt = "n.d.",
  nodata.col = "#E0E0E0"
)

# plot(
#   st_geometry(PROV),
#   lwd = 0.5,
#   lty = 3,
#   border = "black",
#   add = T
# )
# 
# plot(st_geometry(CCAA),
#      lwd = 0.7,
#      border = "black",
#      add = T)

inferno(length(br) - 1)[1]
propSymbolsLayer(
  metro.sf,
  var = "pop",
  border = (inferno(length(br) - 1))[1],
  col = NA,
  inches = 0.5,
  lwd = 1,
  legend.pos = "n",
  add = T
)
labelLayer(
  metro.sffin,
  txt = "name",
  overlap = F,
  cex = 0.6,
  halo = T
)

dev.off()

