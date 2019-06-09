# 0. Init----
rm(list = ls())
library(sf)
library(classInt)
library(dplyr)
library(RColorBrewer)

Barrios = st_read("myprojects/sharing_madrid/assets/Madrid_Barrios.gpkg")
Sharing = st_read("myprojects/sharing_madrid/assets/areas_sharing.gpkg",
                  stringsAsFactors = FALSE)

# 1. Get coverage----
for (i in 1:nrow(Sharing)) {
  provmap = Sharing[i, ]
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
Barrios$Cov_DistServArea=as.integer(st_distance(st_centroid(Barrios),Sharing[1,]))/1000

plot(Barrios[10:33],max.plot=23)

#2. ModelGlob - Univar




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
