rm(list = ls())
library(sf)
library(rnaturalearth)
library(dplyr)

test = ne_countries(50, country = "spain", returnclass = "sf") %>%
  st_cast("POLYGON")
test$area = as.integer(st_area(test)) / 1000
test = test %>% arrange((area)) %>% top_n(1)
plot(st_geometry(test), col = c("red", "yellow", "blue"))
test_lines = test %>% st_cast("LINESTRING")
plot(st_geometry(test_lines), col = c("red", "yellow", "blue"))

breaklin = st_multilinestring(lapply(1:(length(
  st_coordinates(test_lines)[, 1]
) - 1),
function(x)
  rbind(
    as.numeric(st_coordinates(test_lines)[x, 1:2]),
    as.numeric(st_coordinates(test_lines)[x + 1, 1:2])
  ))) %>%
  st_sfc(crs = st_crs(test_lines)) %>%
  st_cast("LINESTRING")

f2 = function(input) {
  a =
    lapply(1:(length(st_coordinates(input)[, 1]) - 1),
           function(x)
             rbind(
               as.numeric(st_coordinates(input)[x, 1:2]),
               as.numeric(st_coordinates(input)[x + 1, 1:2])
             )) %>%
    st_multilinestring() %>%
    st_sfc(crs = st_crs(input))
  
  return(a)
}
sl = f2(test_lines)
sl2 = f2(test_lines)
st_geometry(test)
p = st_linestring(list(list(sl),
                       list(sl2)))


plot(p)
p2 = st_sf(a1 = 1, p)

cc = sl %>% st_cast("LINESTRING")
plot(sl, col = c("red", "yellow", "blue"))
plot(cc, col = c("red", "yellow", "blue"))

# aa

rm(list = ls())
x = testsh
stdh_cast_subtring = function(x, to = "MULTILINESTRING") {
  ggg = st_geometry(x)
  
  if (!unique(st_geometry_type(ggg)) %in% c("POLYGON", "LINESTRING")) {
    stop("Input should be  LINESTRING or POLYGON")
  }
  for (k in 1:length(st_geometry(ggg))) {
    sub = ggg[k]
    geom = lapply(1:(length(st_coordinates(sub)[, 1]) - 1),
                  function(i)
                    rbind(
                      as.numeric(st_coordinates(sub)[i, 1:2]),
                      as.numeric(st_coordinates(sub)[i + 1, 1:2])
                    )) %>%
      st_multilinestring() %>%
      st_sfc()
    
    if (k == 1) {
      endgeom = geom
    }
    else {
      endgeom = rbind(endgeom, geom)
    }
  }
  endgeom = endgeom %>% st_sfc(crs = st_crs(x))
  if (class(x)[1] == "sf") {
    endgeom = st_set_geometry(x, endgeom)
  }
  
  if (to == "LINESTRING") {
    endgeom = endgeom %>% st_cast("LINESTRING")
  }
  return(endgeom)
}
test = ne_countries(50, returnclass = "sf") %>%
  st_cast("POLYGON")
init = Sys.time()
r3 = stdh_cast_subtring(test, "LINESTRING")
end = Sys.time()
end - init
par(mar=c(0,0,0,0))
plot(st_geometry(r3), col = c("red", "yellow", "blue"))
