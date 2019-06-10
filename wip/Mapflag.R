# 0. Init----
rm(list = ls())
library(png)
library(raster)
library(sf)
library(dplyr)

# 1. Get Map----
SPAIN = getData(
  "GADM",
  download = TRUE,
  country = "Spain",
  level = 1,
  path = tempdir()
) %>%
  st_as_sf()

# Move Canary Islands
CAN = SPAIN %>% subset(GID_1 == "ESP.14_1")
CANNEW = st_sf(st_drop_geometry(CAN),
               geometry = st_geometry(CAN) + c(20, 7))
st_crs(CANNEW) <- st_crs(SPAIN)
SPAINV2 = rbind(SPAIN %>% subset(GID_1 != "ESP.14_1"),
                CANNEW) %>% st_transform(4258) # ETRS89 - Spanish Official
rm(CAN, CANNEW, SPAIN)




#Just for completing the map
POR = getData(
  "GADM",
  download = TRUE,
  country = "Portugal",
  level = 0,
  path = tempdir()
) %>% st_as_sf()
FRA = getData(
  "GADM",
  download = TRUE,
  country = "France",
  level = 0,
  path = tempdir()
) %>% st_as_sf()
ITA = getData(
  "GADM",
  download = TRUE,
  country = "Italy",
  level = 0,
  path = tempdir()
) %>% st_as_sf()

NEIGH = rbind(ITA,rbind(POR, FRA)) %>% st_transform(st_crs(SPAINV2))
rm(POR, FRA,ITA)
# Plot

plot(
  st_geometry(SPAINV2),
  axes = T,
  col = NA,
  border = NA,
  bg = "#C6ECFF"
)
plot(st_geometry(NEIGH), col = "#E0E0E0", add = T)
plot(st_geometry(SPAINV2), col = "#FEFEE9", add = T,axes=T)


# 2. Flags----
flags_wiki <- function(url, name) {
  require(curl)
  require(png)
  dest = paste("assets/flags/Flag_", name, ".svg.png", sep = "")
  curl_download(url, dest)
  #Adjust channels and extent for files with less tahn 3 RGB channels
  test = brick(readPNG(dest) * 255)
  extent(test) = extent(brick(dest))
  plotRGB(test)
}
dev.off()
par(mfrow = c(3, 6), mar = c(1, 1, 1, 1))
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Flag_of_Andaluc%C3%ADa.svg/800px-Flag_of_Andaluc%C3%ADa.svg.png",
  "ES.AN"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/Flag_of_Aragon.svg/800px-Flag_of_Aragon.svg.png",
  "ES.AR"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Flag_of_Cantabria.svg/800px-Flag_of_Cantabria.svg.png",
  "ES.CB"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Flag_of_Castile-La_Mancha.svg/800px-Flag_of_Castile-La_Mancha.svg.png",
  "ES.CM"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/Flag_of_Castile_and_Le%C3%B3n.svg/800px-Flag_of_Castile_and_Le%C3%B3n.svg.png",
  "ES.CL"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Flag_of_Catalonia.svg/800px-Flag_of_Catalonia.svg.png",
  "ES.CT"
)
# Select only Ceuta since the shape is combined. Could be splitted but I just did this for clarity
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Flag_Ceuta.svg/800px-Flag_Ceuta.svg.png",
  "ES.ML"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Flag_of_the_Community_of_Madrid.svg/800px-Flag_of_the_Community_of_Madrid.svg.png",
  "ES.MD"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Bandera_de_Navarra.svg/800px-Bandera_de_Navarra.svg.png",
  "ES.NA"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Flag_of_the_Land_of_Valencia_%28official%29.svg/800px-Flag_of_the_Land_of_Valencia_%28official%29.svg.png",
  "ES.VC"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Flag_of_Extremadura_%28with_coat_of_arms%29.svg/800px-Flag_of_Extremadura_%28with_coat_of_arms%29.svg.png",
  "ES.EX"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Flag_of_Galicia.svg/800px-Flag_of_Galicia.svg.png",
  "ES.GA"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Flag_of_the_Balearic_Islands.svg/800px-Flag_of_the_Balearic_Islands.svg.png",
  "ES.PM"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/Flag_of_La_Rioja_%28with_coat_of_arms%29.svg/800px-Flag_of_La_Rioja_%28with_coat_of_arms%29.svg.png",
  "ES.LO"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Flag_of_the_Basque_Country.svg/800px-Flag_of_the_Basque_Country.svg.png",
  "ES.PV"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Flag_of_Asturias.svg/800px-Flag_of_Asturias.svg.png",
  "ES.AS"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Flag_of_the_Region_of_Murcia.svg/800px-Flag_of_the_Region_of_Murcia.svg.png",
  "ES.MU"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Flag_of_the_Canary_Islands.svg/800px-Flag_of_the_Canary_Islands.svg.png",
  "ES.CN"
)



#3. raster and plot----

par(mar = c(2, 2, 2, 2))
# Fix plot
plot(
  st_geometry(SPAINV2),
  axes = T,
  col = NA,
  border = "black",
  bg = "#C6ECFF"
)
plot(st_geometry(NEIGH), col = "#E0E0E0", add = T)
plot(st_geometry(SPAINV2), col = "green", add = T,axes=T)


# iter---
for (i in 1:nrow(SPAINV2)) {
  shp = SPAINV2[i, ]
  CCAA = shp$HASC_1
  flagpath = paste("assets/flags/Flag_", CCAA, ".svg.png", sep = "")
  
  #Load as raster
  flag = brick(readPNG(flagpath) * 255)
  extent(flag) = extent(brick(flagpath))
  
  # Prepare for masking
  projection(flag) <- CRS(st_crs(shp)[["proj4string"]])
  # Adjust the new extent to cover completely the shape and keeping the ratio of the flag
  ratioflag = extent(flag)@xmax / extent(flag)@ymax
  extshp=extent(shp)
  extshp
  new_h=extshp@ymin+(extshp@xmax-extshp@xmin)/ratioflag
  new_w=extshp@xmin+(extshp@ymax-extshp@ymin)*ratioflag
  if (new_w<extshp@xmax){
    new_ext=c(extshp@xmin,extshp@xmax,extshp@ymin,new_h)
  } else {
    new_ext=c(extshp@xmin,new_w,extshp@ymin,extshp@ymax)
  }
  extent(flag) <- new_ext
  fig = mask(flag, shp)
  
  
  plotRGB(fig, bgalpha = 0, add = T)
}

plot(st_geometry(SPAINV2),border="black",lwd=2,axes=T,add=T)

# Test----


shp = SPAINV2 %>% subset(HASC_1=="ES.AN")
CCAA = shp$HASC_1
flagpath = paste("assets/flags/Flag_", CCAA, ".svg.png", sep = "")

#Load as raster
flag = brick(readPNG(flagpath) * 255)
extent(flag) = extent(brick(flagpath))

# Prepare for masking
projection(flag) <- CRS(st_crs(shp)[["proj4string"]])
# Adjust the new extent to cover completely the shape and keeping the ratio of the flag
ratioflag = extent(flag)@xmax / extent(flag)@ymax
extshp=extent(shp)
extshp
new_h=extshp@ymax-(extshp@xmax-extshp@xmin)/ratioflag
new_w=extshp@xmin+(extshp@ymax-extshp@ymin)*ratioflag
if (new_w<extshp@xmax){
  new_ext=c(extshp@xmin,extshp@xmax,new_h,extshp@ymax)
} else {
  new_ext=c(extshp@xmin,new_w,extshp@ymin,extshp@ymax)
}
extent(flag) <- new_ext
plotRGB(flag)
plot(st_geometry(shp),add=T)
fig = mask(flag, shp)


