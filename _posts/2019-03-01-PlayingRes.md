---
layout: post
title: Exploring sizes of leaflet maps
subtitle: A test
leafletmap: true
output: github_document
always_allow_html: yes
---

## Boxes
You can add notification, warning and error boxes like this:

### Notification

<i class="fa fa-file-powerpoint-o"></i>

{: .box-note}
**Note:** This is a notification box. <i class="fa fa-github"></i>

### Warning

{: .box-warning}
**Warning:** This is a warning box.

### Error

{: .box-error}
**Error:** This is an error box.



### 100% width 70% height

```html
<div style="position: relative; width: 100%;padding-top: 70%;" class="leaflet html-widget">
```
<div id="htmlwidget-6fa038b19035c1fdc62e" style="position: relative; width: 100%;padding-top: 70%;" class="leaflet html-widget"></div><script type="application/json"
data-for="htmlwidget-6fa038b19035c1fdc62e">{"x":{"options":{"minZoom":1.5,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"detectRetina":true,"noWrap":true,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-180,90,180]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->


### 100% width 100% height

```html
<div style="position: relative; width: 100%;padding-top: 100%;" class="leaflet html-widget">
```
<!--html_preserve-->
<div id="htmlwidget-0397b2b18e58d31303dd" style="position: relative; width: 100%;padding-top: 100%;" class="leaflet html-widget"></div><script type="application/json" data-for="htmlwidget-0397b2b18e58d31303dd">{"x":{"options":{"minZoom":1.5,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"detectRetina":true,"noWrap":true,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-180,90,180]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->




  
  
  ### 100% width 50% height
```html
<div style="position: relative; width: 100%;padding-top: 50%;" class="leaflet html-widget">
```

<!--html_preserve-->
<div id="htmlwidget-908d7256a5ca41471041" style="position: relative; width: 100%;padding-top: 50%;" class="leaflet html-widget"></div><script type="application/json" data-for="htmlwidget-908d7256a5ca41471041">{"x":{"options":{"minZoom":1.5,"crs":{"crsClass":"L.CRS.EPSG3857","code": i8null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"detectRetina":true,"noWrap":true,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-180,90,180]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->
