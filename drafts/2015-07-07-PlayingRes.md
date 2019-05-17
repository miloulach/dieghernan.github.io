Exploring resolutions with leaflet
================

Reading the data
----------------

The first step consists on reading the database provided (in this example the `json` file) and extracting one international organization. In this example we will plot the [Commonwealth of Nations](https://en.wikipedia.org/wiki/Commonwealth_of_Nations).

``` r
library(leaflet)

map <- leaflet(options = leafletOptions(minZoom = 1.5)) %>%
  addTiles(options = list(
    detectRetina = TRUE,
    noWrap = TRUE
  )) %>%
  setView(-3.56948, 40.49181, zoom = 3) %>%
  setMaxBounds(-180, -90, 180, 90)

map # Print the map
```

<!--html_preserve-->

<script type="application/json" data-for="htmlwidget-4749cc10c52986c7431c">{"x":{"options":{"minZoom":1.5,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"detectRetina":true,"noWrap":true,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-180,90,180]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->
\# new one

``` r
library(leaflet)

map2 <- leaflet(options = leafletOptions(minZoom = 1.5)) %>%
  addTiles(options = list(
    detectRetina = TRUE,
    noWrap = TRUE
  )) %>%
  setView(-3.56948, 40.49181, zoom = 3) %>%
  setMaxBounds(-180, -90, 180, 90)

map2 # Print the map
```

<!--html_preserve-->

<script type="application/json" data-for="htmlwidget-e686bb38a896274a4abd">{"x":{"options":{"minZoom":1.5,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"detectRetina":true,"noWrap":true,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-180,90,180]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->
And last

``` r
map3 <- leaflet(options = leafletOptions(minZoom = 1.5)) %>%
  addTiles(options = list(
    detectRetina = TRUE,
    noWrap = TRUE
  )) %>%
  setView(-3.56948, 40.49181, zoom = 3) %>%
  setMaxBounds(-180, -90, 180, 90)

map3 # Print the map
```

<!--html_preserve-->

<script type="application/json" data-for="htmlwidget-10ac6a0ca7fd861d823d">{"x":{"options":{"minZoom":1.5,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"detectRetina":true,"noWrap":true,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-180,90,180]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->
