Leaflet, R, Markdown, Jekyll and GitHub
================

Recently I have been struggling when trying to embed a [leaflet](https://rstudio.github.io/leaflet) map created with **RStudio** on my blog, hosted in GitHub via [Jekyll](https://jekyllrb.com). In my case, I use the [**Beautiful Jekyll**](https://deanattali.com/beautiful-jekyll/getstarted/) implementation created by [daattali](https://github.com/daattali).

[The GitHub/Jekyll part](#gitjek)

1.  [What to include](#step1)

2.  [Where to include](#step2)

[The RStudio part](#rstudio)

1.  [Creating the leaflet map](#step3)

2.  [Set up the YAML front matter](#step4)

[The Markdown part](#md)

1.  [Modifying the `.md`file](#step5)

### The GitHub/Jekyll part <a name="gitjek"></a>

The first step is to call the requested libraries in your GitHub page. As Jekyll basicaly transforms `markdown` into `html`, this step is a matter of **what to include** and **where** in your own repository.

#### 1. What to include <a name="step1"></a>

This part is not complicated. When having a look to the source code of [Leaflet for R](https://rstudio.github.io/leaflet/) site it can be seen this chunk

``` html
<script src="libs/jquery/jquery.min.js"></script>
<meta name="viewport" content="width=device-width, initial-scale=1" />
<link href="libs/bootstrap/css/flatly.min.css" rel="stylesheet" />
<script src="libs/bootstrap/js/bootstrap.min.js"></script>
<script src="libs/bootstrap/shim/html5shiv.min.js"></script>
<!--more libraries-->
<link href="libs/rstudio_leaflet/rstudio_leaflet.css" rel="stylesheet" />
<script src="libs/leaflet-binding/leaflet.js"></script>
```

So now we have it! The only thing to remember is **to reference that part to the source repository (`https://rstudio.github.io/leaflet`)**, like this:

``` html
<script src="https://rstudio.github.io/leaflet/libs/jquery/jquery.min.js"></script>
<meta name="viewport" content="width=device-width, initial-scale=1" />
<link href="https://rstudio.github.io/leaflet/libs/bootstrap/css/flatly.min.css" rel="stylesheet" />
<!--more libraries-->
<link   href="https://rstudio.github.io/leaflet/libs/rstudio_leaflet/rstudio_leaflet.css" rel="stylesheet" />
<script src= "https://rstudio.github.io/leaflet/libs/leaflet-binding/leaflet.js"></script>
```

You can have a look of my implementation on [`./_includes/leaflet.html`](https://github.com/dieghernan/dieghernan.github.io/blob/master/_includes/leaflet.html).

#### 2.Where to include <a name="step2"></a>

This a little bit more complicated. The code chunk should be included in the `<head>` section of your page, so you would need to find where to put it. In the case of **Beautiful Jekyll** it is on [`./_includes/head.html`](https://github.com/dieghernan/dieghernan.github.io/blob/master/_includes/head.html).

You can just copy/paste the ammended code there.

{: .box-note} \*\*<i class="fa fa-star"></i> Pro <tip:**> For a better performance of the site, include these libraries only when you need it. In my case, I added a custom variable in my YAML front matter for those posts with a leaflet map, `leafletmap: true`. Go to [step 4](#step4) for a working example.

### The RStudio part <a name="rstudio"></a>

#### 3. Creating the leaflet map <a name="step3"></a>

Now it's time to create a leaflet map with **RStudio**. I just keep it simple for this post, so I took the first example provided in [Leaflet for R - Introduction](https://rstudio.github.io/leaflet/)

``` r
library(leaflet)

m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")
m  # Print the map
```

<!--html_preserve-->

<script type="application/json" data-for="htmlwidget-f448d774bde4cc9c1b48">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addMarkers","args":[-36.852,174.768,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"The birthplace of R",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]}],"limits":{"lat":[-36.852,-36.852],"lng":[174.768,174.768]}},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->
It is assumed that you are [creating a post with **RStudio**](https://rmarkdown.rstudio.com/authoring_quick_tour.html#rendering_output), so the code presented above should be embedded in an `*Rmd` file. \`

#### 4. Set up the YAML front matter <a name="step4"></a>

Before knitting your `.Rmd`, you have to set up the YAML front matter. Here it is important to set up the option `always_allow_html: yes`, as well as `output: github_document`. As an example, this post was created with the structure:

    ---
    layout: post
    title: Leaflet, R, Markdown, Jekyll and GitHub
    subtitle: Make it work
    tags: [R,leaflet,Jekyll, html, maps]
    leafletmap: true
    linktormd: true
    always_allow_html: yes
    output: github_document
    ---

Now you just have to "Knit" your file and get the corrsponding `.md`file.

### The Markdown part <a name="#md"></a>

#### 5. Modifying the `.md`file <a name="step5"></a>
