### Project Wiki----
rm(list = ls())

library(rvest)
library(sf)
library(cartography)
library(RColorBrewer)
library(dplyr)

### Maps----
# Map import from Eurostat
WorldMap <-
  st_read(
    "https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/countries/geojson/CNTR_RG_10M_2016_3857.geojson",
    stringsAsFactors = FALSE
  ) %>%
  select(ISO_3166_3 = ISO3_CODE)

# CountryCode import
df <- read.csv(
  "https://raw.githubusercontent.com/dieghernan/Country-Codes-and-International-Organizations/master/outputs/Countrycodes.csv",
  na.strings = "",
  stringsAsFactors = FALSE,
  fileEncoding = "utf8"
)

WorldMap <- left_join(WorldMap, df)

rm(df)

# Create bbox of the world
bbox <- st_linestring(rbind(
  c(-180, 90),
  c(180, 90),
  c(180, -90),
  c(-180, -90),
  c(-180, 90)
)) %>%
  st_segmentize(5) %>%
  st_cast("POLYGON") %>%
  st_sfc(crs = 4326) 

# Meat consumption (https://en.wikipedia.org/wiki/List_of_countries_by_meat_consumption)----
Meat <- read.csv("./myprojects/wikimaps/meatconsump.csv", sep=";", stringsAsFactors = F)
MeatMap <- left_join(WorldMap,Meat) %>% st_transform("+proj=robin")

br=seq(from=0, to=160, by=20)


svg("./myprojects/wikimaps/Meat consumption rate (kg) per capita by country gradient map (2009).svg",pointsize = 90, width =  1600/90, height = 800/90)
par(mar=c(0.5,0,0,0))
choroLayer(MeatMap  ,
           var="KG_PERSON_2009",
           breaks = br,
           col=brewer.pal(length(br)-1,"YlOrRd"),
           border = "#646464",
           lwd = 0.1,
           colNA = "#E0E0E0",
           legend.pos = "left",
           legend.title.txt = "",
           legend.values.cex = 0.25
)
plot(bbox %>% st_transform("+proj=robin"),
     add = T,
     border = "#646464",
     lwd = 0.2)
dev.off()

svg("./myprojects/wikimaps/Meat consumption rate (kg) per capita by country gradient map (2002).svg",pointsize = 90, width =  1600/90, height = 800/90)
par(mar=c(0.5,0,0,0))
choroLayer(MeatMap  ,
           var="KG_PERSON_2002",
           breaks = br,
           col=brewer.pal(length(br)-1,"YlOrRd"),
           border = "#646464",
           lwd = 0.1,
           colNA = "#E0E0E0",
           legend.pos = "left",
           legend.title.txt = "",
           legend.values.cex = 0.25
)
plot(bbox %>% st_transform("+proj=robin"),
     add = T,
     border = "#646464",
     lwd = 0.2)
dev.off()
