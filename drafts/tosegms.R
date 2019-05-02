rm(list = ls())
library(sf)
library(rnaturalearth)
library(dplyr)

test=ne_countries(50,country="spain",returnclass = "sf") %>% 
  st_cast("POLYGON")
test$area=as.integer(st_area(test))/1000
test= test %>% arrange((area)) %>% top_n(1)
plot(st_geometry(test),col=c("red","yellow","blue"))
test_lines=test %>% st_cast("LINESTRING")
plot(st_geometry(test_lines),col=c("red","yellow","blue"))

breaklin=st_multilinestring(
  lapply(1:(length(st_coordinates(test_lines)[,1])-1), 
         function(x)
           rbind(as.numeric(st_coordinates(test_lines)[x,1:2]),
                 as.numeric(st_coordinates(test_lines)[x+1,1:2])
                 )
         )
  ) %>%
  st_sfc(crs=st_crs(test_lines)) %>% 
  st_cast("LINESTRING")

f2= function(input){
  a= 
    lapply(1:(length(st_coordinates(input)[,1])-1), 
           function(x)
             rbind(as.numeric(st_coordinates(input)[x,1:2]),
                   as.numeric(st_coordinates(input)[x+1,1:2])
                   )
           ) %>% 
    st_multilinestring() %>% 
    st_sfc(crs=st_crs(input))
   
  return(a)
}
sl=f2(test_lines)
sl2=f2(test_lines)
st_geometry(test)
p=st_linestring(
  list(
    list(sl),
    list(sl2)
    )
   )


plot(p)
p2=st_sf(a1=1,p)

cc=sl %>% st_cast("LINESTRING")
plot(sl,col=c("red","yellow","blue"))
plot(cc,col=c("red","yellow","blue"))

# aa

rm(list = ls())
test=ne_countries(50,continent="europe",returnclass = "sf") %>% 
  st_cast("POLYGON")
stdh_cast_subtring = function(x,to="MULTILINESTRING") {
  if (!unique(st_geometry_type(x)) %in% c("POLYGON","LINESTRING")){
      stop("Input should be  LINESTRING or POLYGON")
    }
  for (k in 1:length(st_geometry(x))) {
    sub = x[k,]
    geom = lapply(1:(length(st_coordinates(sub)[, 1]) - 1),
                  function(i)
                    rbind(
                      as.numeric(st_coordinates(sub)[i, 1:2]),
                      as.numeric(st_coordinates(sub)[i + 1, 1:2])
                    )) %>%
      st_multilinestring() %>%
      st_sfc(crs = st_crs(x))
    sub = st_sf(n = k, geom)
    if (k == 1) {
      endgeom = sub
    }
    else {
      endgeom = rbind(endgeom, sub)
    }
  }
  if (to == "LINESTRING"){
    endgeom=endgeom %>% st_cast("LINESTRING")
  }
  return(endgeom)
}
testmpol=ne_countries(50,returnclass = "sf") %>% st_cast("POLYGON")
sp=stdh_cast_subtring(testmpol)
plot(st_geometry(sp),col=c("red","yellow","blue"))
sp2=stdh_cast_subtring(testmpol,"LINESTRING")
plot(st_geometry(sp2),col=c("red","yellow","blue"))
