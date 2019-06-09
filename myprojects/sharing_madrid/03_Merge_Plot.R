# 0. Init----
rm(list = ls())
library(sf)
library(classInt)
library(cartography)
library(dplyr)
library(RColorBrewer)

bc=st_read("M30.kml")
st_geometry_type(bc)
m30=bc[st_geometry_type(bc)=="LINESTRING",] %>% st_cast("LINESTRING")

bc=st_read("M40.kml")
plot(bc)

plot(bc)
plot(bc)
bc=rgdal::readOGR("M30.gpkg")
windowsFonts(
  roboto=windowsFont("Roboto")
)

unique(St$VIA_CLASE)

Barrios = st_read("myprojects/sharing_madrid/assets/Madrid_Barrios.gpkg",
                  stringsAsFactors = FALSE)
Sharing = st_read("myprojects/sharing_madrid/assets/areas_sharing.gpkg",
                  stringsAsFactors = FALSE)



# 1. Download shapefile----
# source:Portal de Datos Abiertos de Madrid https://datos.madrid.es
tempfile(fileext = ".zip")
tempfile(fileext = ".zip")
tempdir()
filetemp = paste(tempdir(), "temp.zip", sep = "/")
tempdir()

download.file(
  "https://datos.madrid.es/egob/catalogo/300138-0-Ejes_viario.zip",
  filetemp
)
unzip(filetemp, exdir = tempdir(), junkpaths = T)
Via = st_read(paste(tempdir(), "EJES_VIA.shp", sep = "/"),
                     stringsAsFactors = FALSE)
#Streets
St=read.csv("https://datos.madrid.es/egob/catalogo/213605-0-callejero-oficial-madrid.csv",
            sep=";")
at= St %>% subset(VIA_CLASE %in% c("AUTOPISTA","AUTOVÍA") | 
                    NOMBRE_TERMINA =="LIMITE TERMINO MUNICIPAL")


Via$COD_VIA=as.double(Via$COD_VIA)
AT=inner_join(Via,at)
plot(st_geometry(AT))
dev.off()
# 1. Get coverage----
for (i in 1:nrow(Sharing)) {
  provmap = Sharing[i,]
  r = st_intersection(provmap, Barrios)
  r$cov = as.double(st_area(r)) / (1000 ^ 2)
  r$percov = round(r$cov / r$G_area_km2, 4)
  Fin = left_join(
    Barrios %>%
      st_drop_geometry() %>%
      select(CODBAR),
    r  %>%
      st_drop_geometry() %>%
      select(CODBAR,
             prov = percov)
  )
  names(Fin) = append("CODBAR", paste("Cov",  unique(r$provider), sep =
                                        "_"))
  Fin[is.na(Fin)] <- 0
  Barrios = left_join(Barrios, Fin)
  rm(Fin, provmap, r)
}
Barrios$Cov_DistServArea = as.integer(st_distance(st_centroid(Barrios), Sharing[1, ])) /
  1000
plot(Barrios[10:33], max.plot = 23)

st_write(
  Barrios,
  "myprojects/sharing_madrid/assets/Madrid_Barrios_End.gpkg",
  factorsAsCharacter = FALSE,
  layer_options = "OVERWRITE=YES"
)




#2. Var cuts ----
getPalette = colorRampPalette(rev(brewer.pal(3, "RdYlBu")))
tile = raster::brick("myprojects/sharing_madrid/assets/CartoVoyager.tif")
#Init----




#a. G_area----
var = Barrios$G_area_km2
classIntervals(var,
               n = 8,
               style = "kmeans")

varbreaks = as.integer(classIntervals(var,
                                      n = 8,
                                      style = "kmeans")$brks)
univar=cbind(Barrios,var)


par(mar = c(1, 1, 1, 1),
        family=windowsFont("roboto"))


choroLayer(
  univar,
  var = "var",
  border = NA,
  breaks = varbreaks,
  col =  paste(getPalette(length(varbreaks)),
                        95, #alpha
                        sep = "",
               ),
  legend.pos = "n"
)

legendChoro(
  pos = "topleft",
  breaks = paste(varbreaks, "km2", sep = " "),
  title.txt = "",
  col = getPalette(length(varbreaks)),
  nodata = FALSE
)
plot(st_geometry(AT),add=T)

layoutLayer(
  title = "Madrid - Ward's area (km2)",
  col="#008080",
  scale=5,
  posscale = "bottomright",
  tabtitle = TRUE,
  north = TRUE,
  sources = "Portal de Datos Abiertos de Madrid",
  author = "dieghernan, 2019"
)

#b. M30----

tilesLayer(tile)
typoLayer(Barrios,
          var="G_M30",
          legend.title.txt = "",
          legend.pos="topleft",
          legend.values.order = c("IN","OUT"),
          border = NA,
          col=paste(getPalette(length(unique(Barrios$G_M30))),
                60, #alpha
                sep = ""),
          add=T
          )
layoutLayer(
  title = "Madrid - Wards and M-30 main road",
  col="#008080",
  horiz = FALSE,
  scale=5,
  posscale = "bottomleft",
  tabtitle = TRUE,
  north = TRUE,
  sources = "Portal de Datos Abiertos de Madrid \n Maps © Thunderforest, Data © OpenStreetMap contributors",
  author = "dieghernan, 2019"
)

shpm30=Barrios %>% subset(G_M30=="IN") %>% st_union() %>% st_cast("LINESTRING")
#----
names(Barrios)
var = Barrios$P_TargetPop
classIntervals(var,
               n = 5,
               style = "pretty")

varbreaks = as.integer(classIntervals(var,
                                      n = 5,
                                      style = "pretty")$brks)
univar=cbind(Barrios,var)


par(mar = c(1, 1, 1, 1),
    family=windowsFont("roboto"))

#tilesLayer(tile)
choroLayer(
  univar,
  var = "var",
  border = NA,
  breaks = varbreaks,
  col =  paste(getPalette(length(varbreaks)),
               95, #alpha
               sep = ""),
  legend.pos = "n"
)
plot(st_geometry(AT),add=T,col="grey50")
legendChoro(
  pos = "topleft",
  breaks = paste(format(varbreaks, nsmall=1, big.mark=","), "pop", sep = " "),
  title.txt = "",
  col = getPalette(length(varbreaks)),
  nodata = FALSE
)

layoutLayer(
  title = "Madrid - Population",
  col="#008080",
  scale=5,
  posscale = "bottomright",
  tabtitle = TRUE,
  north = TRUE,
  sources = "Portal de Datos Abiertos de Madrid",
  author = "dieghernan, 2019"
)


#----
Barrios$Cov_all
plot(st_geometry(Barrios), col = "yellow", border = NA, bg = "lightblue1")
# plot isopleth map
discLayer(Barrios,
          df=st_drop_geometry(Barrios),var = "Cov_all",
          nclass=3)

discLayer(
  x = mtq.contig, 
  df = mtq, 
  var = "MED",
  type = "rel", 
  method = "geom", 
  nclass = 3,
  threshold = 0.4,
  sizemin = 0.7, 
  sizemax = 6, 
  col = "red4",
  legend.values.rnd = 1, 
  legend.title.txt = "Relative\nDiscontinuities", 
  legend.pos = "right",
  add = TRUE
)     
           
95, #alpha
sep = "")

typoLayer(BarriosMad,var="G_M30",
          col=palM30,
          legend.title.txt = "",
          legend.pos="topleft",
          legend.values.order = c("IN","OUT"),
          border = "grey90",
          lwd = 1,
          add=T)

choroLayer(
  univar,
  var = "var",
  border = "grey",
  lwd = 2,
  breaks = varbreaks,
  col =  paste(getPalette(length(varbreaks)),
               95, #alpha
               sep = ""),
  legend.pos = "n"
)

#----




ncol(Barrios)

a=c(0,0.1,0.5,1,2,10)

choroLayer(tt,var="dist",
           breaks = a,
           legend.values.rnd = 2,
           col = rev(brewer.pal(min(9,length(a)),"Spectral" ))
)


plot(st_geometry(Sharing[1,]),add=T,col=NA,border="green",lwd=3)

a
plot(global_service)

prov="movo"
r=st_intersection(Sharing %>% subset(provider==prov),Barrios)
r$cov=as.double(st_area(r)) / (1000 ^ 2)
r$percov=round(r$cov/r$G_area_km2,4)
Fin=left_join(Barrios %>%
                st_drop_geometry() %>% 
                select(CODBAR),
              r %>% 
                st_drop_geometry() %>% 
                select(CODBAR,
                       prov=percov)
              )
Fin[is.na(Fin)]<-0
names(Fin) = append("CODBAR",paste("Cov",prov,sep="_"))
Barrios=left_join(Barrios,Fin)
drop()

roun
plot(r)

#Plot and check
abreaks = as.integer(classInt::classIntervals(BarriosMad$G_area_km2,
                                              n = 8,
                                              style = "kmeans")$brks)

getPalette = colorRampPalette(rev(brewer.pal(3, "RdYlBu")))
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



#Plot----
par(mfrow=c(2,2),mar = c(1, 1, 1, 1))
#dev.off()

b=unlist(
  classIntervals(BarriosMad$P_TargetPop,n=5,style = "pretty")[["brks"]]
)

choroLayer(BarriosMad,var="P_TargetPop",
           breaks=b,
           col=getPalette(length(b)),
           legend.pos = "topleft")

b=unlist(
  classIntervals(BarriosMad$P_PercForeign,n=6,style = "pretty")[["brks"]]
)

choroLayer(BarriosMad,var="P_PercForeign",
           breaks=b,
           col=getPalette(length(b)),
           legend.values.rnd=2,
           legend.pos = "topleft",
)
b=unlist(
  classIntervals(BarriosMad$W_IncomePerCap,n=5,style = "jenks")[["brks"]]
)
end=b[length(b)]+10000
b=as.integer(append(append(0,b[1:length(b)-1]),end)/1000)*1000


choroLayer(BarriosMad,var="W_IncomePerCap",
           breaks=b,
           col=getPalette(length(b)),
           legend.pos = "topleft")

b=unlist(
  classIntervals(BarriosMad$D_Density,n=6,style = "pretty")[["brks"]]
)
b


choroLayer(BarriosMad,var="D_Density",
           breaks=b,
           col=getPalette(length(b)),
           legend.pos = "topleft")
