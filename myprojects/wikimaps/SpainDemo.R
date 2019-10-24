setwd("/cloud/project/myprojects/wikimaps")

# Libraries----

rm(list = ls())
library(readxl)
library(sf)
library(dplyr)
library(cartography)
library(scales)
library(viridis)

# Import maps----
MUNIC = st_read("../../assets/shp/ESRI/Municipios_IGN.shp",
                stringsAsFactors = FALSE)

WORLD = st_read(
  "https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/countries/geojson/CNTR_RG_10M_2016_3857.geojson",
  stringsAsFactors = FALSE
)

ESP <-  st_read(
  "https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/nuts/geojson/NUTS_RG_01M_2016_3857_LEVL_3.geojson",
  stringsAsFactors = FALSE
) %>% subset(CNTR_CODE == "ES")

# Move CAN

CANPROV =   ESP[grep("ES7", ESP$NUTS_ID),]
CANNEW = st_sf(
  st_drop_geometry(CANPROV),
  geometry = st_geometry(CANPROV) + c(550000, 920000),
  crs = st_crs(ESP)
)

ESPPROV = rbind(ESP[-grep("ES7", ESP$NUTS_ID),],
                CANNEW)

# Import ESP Codes----
Cods_ISO_ESP <- read_excel("../../assets/custom/Cods_ISO_ESP.xlsx")


ESPCCAA = left_join(ESPPROV, Cods_ISO_ESP,
                    by = c("NUTS_ID" = "NUTS3")) %>%
  group_by(ISO2, ISO2_CCAA) %>% summarise(a = 1) %>%
  select(-a)


# Move munic CAN

CANMUN = MUNIC %>% subset(CODNUT2 == "ES70") %>% st_transform(st_crs(ESPPROV))

CANMUNNEW = st_sf(
  st_drop_geometry(CANMUN),
  geometry = st_geometry(CANMUN) + c(550000, 920000),
  crs = st_crs(CANMUN)
)

MUNICNEW = rbind(MUNIC %>% subset(CODNUT2 != "ES70") %>% st_transform(st_crs(ESPPROV)),
                 CANMUNNEW)
MUNICNEW = left_join(MUNICNEW,
                     Cods_ISO_ESP %>%
                       select(
                         CODNUT3 = NUTS3,
                         CCAA = ISO2_CCAA,
                         PROV = ISO3_PROV
                       ))

# Clean
rm(CANMUN, CANMUNNEW, CANNEW, CANPROV, ESP, MUNIC)

# Population data----
Pad18 = read_xlsx("pobmun18.xlsx")
Pad18$CODIGOINE = substr(paste(Pad18$CPRO, Pad18$CMUN, sep = "") , 1, 5)


MapPad18 = left_join(
  MUNICNEW,
  Pad18 %>%
    select(PROVINCIA,
           CPRO, CMUN,
           CODIGOINE,
           NOMBRE,
           Poblacion18 = POB18)
) %>% arrange(CODIGOINE)

MapPad18$AreaKM2 = as.double(st_area(MapPad18 %>% st_transform(4326))) / 1000000
MapPad18$DensKM2 = MapPad18$Poblacion18 / MapPad18$AreaKM2


# AU Ministerio Fomento----
AU_MFom <- read_xlsx("../../assets/custom/AU_MFom18.xlsx")
AU_MFom$CODIGOINE = AU_MFom$CODE

AU = inner_join(MUNICNEW, AU_MFom %>%
                  filter(!is.na(AREA_URBANA))) %>%
  group_by(AREA_URBANA) %>%
  summarise(Pop = sum(POB18)) %>%
  arrange(desc(Pop))



# Plot----
br = c(0, 10, 25, 50, 100, 200, 500, 1000, 5000, 10000, 30000)

#pdi=90
pdi = 300

svg(
  "NewPad.svg",
  pointsize = pdi,
  width =  160 / pdi,
  height = 88 / pdi
)

par(mar = c(0, 0, 0, 0))
plot(st_geometry(ESPPROV),
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
  MapPad18,
  add = T,
  var = "DensKM2",
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
  values.cex = 0.15,
  breaks = format(br, big.mark = ","),
  col = rev(inferno(length(br) - 1, 0.5)),
  nodata = T,
  nodata.txt = "n.d.",
  nodata.col = "#E0E0E0"
)

plot(
  st_geometry(ESPPROV),
  lwd = 0.15,
  lty = 3,
  border = "black",
  add = T
)
plot(st_geometry(ESPCCAA),
     lwd = 0.15,
     border = "black",
     add = T)
dev.off()

#Export----
MUNIC = st_read("../../assets/shp/ESRI/Municipios_IGN.shp",
                stringsAsFactors = FALSE)


df = st_drop_geometry(MapPad18)
df = left_join(df, AU_MFom %>%
                 select(CODIGOINE, AREA_URBANA))

MunExport = left_join(MUNIC,
                      df) %>% select(
                        CODIGOINE,
                        CPRO,
                        CMUN,
                        CCAA,
                        PROVINCIA,
                        NOMBRE,
                        POBLACION18 = Poblacion18,
                        AreaKM2,
                        DensKM2,
                        AREA_URBANA
                      )

exportpad = st_write(
  MunExport,
  "MunExport.gpkg",
  factorsAsCharacter = FALSE,
  layer_options = "OVERWRITE=YES"
)

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
  "Large Urban Areas in Spain (2018).svg",
  pointsize = pdi,
  width =  1600 / pdi,
  height = 880 / pdi
)
par(mar = c(0, 0, 0, 0))
plot(st_geometry(ESPPROV),
     col = NA,
     border = NA,
     bg = "#C6ECFF")
plot(st_geometry(WORLD),
     col = "#E0E0E0",
     bg = "#C6ECFF",
     add = T)
plot(st_geometry(ESPPROV),
     col = "#FEFEE9",
     lty = 3,
     add = T)
plot(st_geometry(ESPCCAA), col = NA,  add = T)

br2 = c(0, 50000, 100000, 600000, 10000000)

AU$categs = cut(AU$Pop, unique(br2))

typoLayer(
  AU,
  var = "categs",
  col =  brewer.pal(4, "PuOr"),
  legend.pos = "n",
  add = T
)

legendTypo(
  pos = "left",
  title.txt = "",
  values.cex = 0.3,
  categ = rev(c(
    "<50.000", "50.000-100.000", "100.000-600.000", ">600.000"
  )),
  nodata = F,
  col =  brewer.pal(4, "PuOr")
)

dev.off()

rsvg::rsvg_png("Large Urban Areas in Spain (2018).svg",
               "Large Urban Areas in Spain (2018).png")