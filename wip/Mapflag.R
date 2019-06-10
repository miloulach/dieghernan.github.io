# 0. Init----
rm(list = ls())
library(png)
library(raster)
library(sf)
library(dplyr)

# 1. Get Map----
SPAIN=getData("GADM",
              download = TRUE,
              country="Spain",
              level=1,path=tempdir())%>%
  st_as_sf()


# Move Canary Islands
CAN= SPAIN %>% subset(GID_1=="ESP.14_1")
CANNEW=st_sf(st_drop_geometry(CAN),
             geometry=st_geometry(CAN)+c(20,7)
)

st_crs(CANNEW) <- st_crs(SPAIN)

SPAINV2=rbind(
  SPAIN %>% subset(GID_1!="ESP.14_1"),
  CANNEW
) %>% st_transform(4258) # ETRS89 - Spanish Official
rm(CAN,CANNEW,SPAIN)

#Just for completing the map
POR=getData("GADM",
            download = TRUE,
            country="Portugal",
            level=0,path=tempdir()) %>% st_as_sf()
FRA=getData("GADM",
            download = TRUE,
            country="FRANCE",
            level=0,path=tempdir()) %>% st_as_sf()

NEIGH=rbind(POR,FRA) %>% st_transform(st_crs(SPAINV2)) 
rm(POR,FRA)
# Plot
plot(st_geometry(SPAINV2),axes=T,col=NA,border=NA,bg="#C6ECFF")
plot(st_geometry(NEIGH),col="#E0E0E0",add=T)
plot(st_geometry(SPAINV2),col="#FEFEE9",add=T)


# 2. Flags----
flags_wiki <- function(url, name) {
  require(curl)
  curl_download(url, paste("assets/flags/Flag_", name, ".svg.png", sep = ""))
  c = brick(paste("assets/flags/Flag_", name, ".svg.png", sep = ""))
  plotRGB(c)
}

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
  "https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/Flag_of_Castile_and_Le%C3%B3n.svg/780px-Flag_of_Castile_and_Le%C3%B3n.svg.png",
  "ES.CL"
)
# flags_wiki(
#   "https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Flag_of_Catalonia.svg/640px-Flag_of_Catalonia.svg.png",
#   "ES.CT"
# )
# Select only Ceuta since the shape is combined. Could be splitted but I just did this for clarity
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Flag_Ceuta.svg/800px-Flag_Ceuta.svg.png",
  "ES.ML"
)
# flags_wiki(
#   "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Flag_of_the_Community_of_Madrid.svg/800px-Flag_of_the_Community_of_Madrid.svg.png",
#   "ES.MD"
# )
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Bandera_de_Navarra.svg/750px-Bandera_de_Navarra.svg.png",
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


CCAA="ES.CT"
shp=SPAINV2 %>% subset(HASC_1==CCAA)
flag=brick(paste("assets/flags/Flag_",CCAA,".svg.png",sep = ""))
plotRGB(flag)
ratioflag=extent(flag)@xmax/extent(flag)@ymax
neww=1.3*(extent(shp)@ymax-extent(shp)@ymin)*ratioflag+extent(shp)@xmin
new=c(extent(shp)@xmin,neww,extent(shp)@ymin,extent(shp)@ymax)
extent(flag)<-new
projection(flag)<- CRS(st_crs(shp)[["proj4string"]])
f1=mask(flag,shp)



CCAA="ES.CB"
shp=SPAINV2 %>% subset(HASC_1==CCAA)
flag=brick(paste("assets/flags/Flag_",CCAA,".svg.png",sep = ""))
ratioflag=extent(flag)@xmax/extent(flag)@ymax
neww=1.3*(extent(shp)@ymax-extent(shp)@ymin)*ratioflag+extent(shp)@xmin
new=c(extent(shp)@xmin,neww,extent(shp)@ymin,extent(shp)@ymax)
extent(flag)<-new
projection(flag)<- CRS(st_crs(shp)[["proj4string"]])
f2=mask(flag,shp)

f1
f2_end=mask(f2,SPAINV2)

plot(st_geometry(SPAINV2),border=NA)
plotRGB(f1,add=T)
plotRGB(f2,add=T)
plot(st_geometry(SPAINV2),add=T)
c=crop(f2_end,SPAINV2)

res(f2_c)<-res(f1_c)
origin(f2_c)<-origin(f1_c)

c2=merge(f1_c,f2_c)

c3=merge(f1,f2)

c=raster(f1)
c2=raster(f2)
c3=merge(c,c2)



c2=merge(f1,f2)
c2=stack(f1,f2)
c3=bind(f1,f2)
plotRGB(c2)
origin(f2)<-origin(f1)
origin(f1)
origin(f2)
c3=brick(f1,f2)

c2=brick(extent(SPAINV2))
res(c2) <- res(f1)
origin(c2)<-origin(f1)
c=merge(c2,f1)
res(f2)<-res(c)
origin(f2)<-origin(c)
d=merge(c,f2)
plotRGB(c,axes=T)
SPAINV2

require(curl)
curl_download(url,paste("assets/flags/Flag_",name,".svg.png",sep = ""))
c=brick(paste("assets/flags/Flag_",name,".svg.png",sep = ""))
plotRGB(c)



curl::curl_download("https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Flag_of_Spain.svg/500px-Flag_of_Spain.svg.png",
                    "flag.png"
)
c=brick("flag.png")
plotRGB(c)
