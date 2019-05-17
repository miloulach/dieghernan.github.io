---
layout: post
title: Exploring sizes of leaflet maps
subtitle: A test
leafletmap: true
output: github_document
always_allow_html: yes
---


### 100% width 70% height
<div id="htmlwidget-927ec88a166bf954e46a" style="width:100%;height:216px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-927ec88a166bf954e46a">{
  "x": {
    "options": {
      "crs": {
        "crsClass": "L.CRS.EPSG3857",
        "code": null,
        "proj4def": null,
        "projectedBounds": null,
        "options": {}
      }
    },
    "calls": [
      {
        "method": "addTiles",
        "args": [
          "//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          null,
          null,
          {
            "minZoom": 0,
            "maxZoom": 18,
            "tileSize": 256,
            "subdomains": "abc",
            "errorTileUrl": "",
            "tms": false,
            "noWrap": false,
            "zoomOffset": 0,
            "zoomReverse": false,
            "opacity": 1,
            "zIndex": 1,
            "detectRetina": false,
            "attribution": "&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"
          }
        ]
      },
      {
        "method": "addMarkers",
        "args": [
          -36.852,
          174.768,
          null,
          null,
          null,
          {
            "interactive": true,
            "draggable": false,
            "keyboard": true,
            "title": "",
            "alt": "",
            "zIndexOffset": 0,
            "opacity": 1,
            "riseOnHover": false,
            "riseOffset": 250
          },
          "The birthplace of R",
          null,
          null,
          null,
          null,
          {
            "interactive": false,
            "permanent": false,
            "direction": "auto",
            "opacity": 1,
            "offset": [0, 0],
            "textsize": "10px",
            "textOnly": false,
            "className": "",
            "sticky": true
          },
          null
        ]
      }
    ],
    "limits": {
      "lat": [-36.852, -36.852],
      "lng": [174.768, 174.768]
    }
  },
  "evals": [],
  "jsHooks": []
}</script>


Now test another one


```html
<div style="position: relative; width: 100%;padding-top: 70%;" class="leaflet html-widget">
```

<!--html_preserve-->
<div id="htmlwidget-ff516d74fbec24f31bb3" style="position: relative; width: 100%;padding-top: 70%;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-ff516d74fbec24f31bb3">{"x":{"options":{"minZoom":1.5,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"detectRetina":true,"noWrap":true,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a><contributors href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-180,90,180]}],"setView":[[40.49181,-3.56948],2,[]]},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->
  

### 100% width 100% height


```html
<div style="position: relative; width: 100%;padding-top: 100%;" class="leaflet html-widget">
```

<!--html_preserve-->
<div id="htmlwidget-fb5a26410c2ee1130fc3 style="position: relative; width: 100%;padding-top: 100%;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-fb5a26410c2ee1130fc3">{"x":{"options":{"minZoom":1.5,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"detectRetina":true,"noWrap":true,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a><contributors href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-180,90,180]}],"setView":[[40.49181,-3.56948],2,[]]},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->
  
  
  ### 100% width 50% height
```html
<div style="position: relative; width: 100%;padding-top: 50%;" class="leaflet html-widget">
```

<!--html_preserve-->
<div id="htmlwidget-927ec88a166bf954e46a style="position: relative; width: 100%;padding-top: 50%;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-927ec88a166bf954e46a">{"x":{"options":{"minZoom":1.5,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"detectRetina":true,"noWrap":true,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a><contributors href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-180,90,180]}],"setView":[[40.49181,-3.56948],2,[]]},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->
  
