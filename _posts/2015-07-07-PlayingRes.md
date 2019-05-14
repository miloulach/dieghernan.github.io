---
layout: post
title: Exploring resolutions with leaflet
subtitle: aaaaa.
tags: [R,sf,maps,vignette]
linktormd: true
leafletmap: true
output: github_document
always_allow_html: yes
---

Exploring resolutions with leaflet
================

Reading the data
----------------

The first step consists on reading the database provided (in this example the `json` file) and extracting one international organization. In this example we will plot the [Commonwealth of Nations](https://en.wikipedia.org/wiki/Commonwealth_of_Nations).



<!--html_preserve-->
<div id="htmlwidget-417a6fcd556a385d93d3" style="position: relative; width: 100%;padding-top: 99%;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-417a6fcd556a385d93d3">{"x":{"options":{"minZoom":1,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"detectRetina":true,"noWrap":true,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-180,90,180]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->

# new one

``` r
library(leaflet)

map2 <- leaflet(options = leafletOptions(minZoom = 1.125)) %>%
  addTiles(options = list(
    detectRetina = TRUE,
    noWrap = TRUE
  )) %>%
  setView(-3.56948, 40.49181, zoom = 3) %>%
  setMaxBounds(-180, -90, 180, 90)

map2 # Print the map
```

<!--html_preserve-->
<div id="htmlwidget-ff516d74fbec24f31bb3" style="position: relative; width: 100%;padding-top: 99%;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-ff516d74fbec24f31bb3">{"x":{"options":{"minZoom":1.125,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"detectRetina":true,"noWrap":true,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-180,90,180]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->
  
  
  
  <!--html_preserve-->
<div id="htmlwidget-ff516d74fbec24f31bb3" style="position: relative; width: 100%;padding-top: 99%;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-ff516d74fbec24f31bb3">{"x":{"options":{"minZoom":2,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"detectRetina":true,"noWrap":true,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-180,90,180]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->
  
    <!--html_preserve-->
<div id="htmlwidget-ff516d74fbec24f31bb3" style="position: relative; width: 100%;padding-top: 90%;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-ff516d74fbec24f31bb3">{"x":{"options":{"minZoom":2,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"detectRetina":true,"noWrap":true,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-180,90,180]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->

