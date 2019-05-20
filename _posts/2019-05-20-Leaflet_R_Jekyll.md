---
layout: post
title: Leaflet, R, Markdown, Jekyll and GitHub
subtitle: Make it work in 6 steps - a short tutorial
tags: [R,leaflet,Jekyll, html, maps]
leafletmap: true
linktormd: true
always_allow_html: yes
output: github_document
---


Recently I have been struggling when trying to embed a [leaflet](https://rstudio.github.io/leaflet) map created with **RStudio** on my blog, hosted in GitHub via [Jekyll](https://jekyllrb.com) (**Spoiler**: [I succeeded](https://dieghernan.github.io/2019-133-Where-in-the-world)). In my case, I use the [**Beautiful Jekyll**](https://deanattali.com/beautiful-jekyll/getstarted/) implementation created by [daattali](https://github.com/daattali).

So here I present a guide on how I got it, hopefully it is easy to follow:



1.  [What to include](#step1)

2.  [Where to include](#step2)

3.  [Creating the leaflet map](#step3)

4.  [Set up the YAML front matter](#step4)

5.  [Modifying the `.md`file](#step5)

6.  [Publish your post](#step6)

[Extra: Resolutions of a leaflet map](#extra)
---------------------------------------------

So let's start!

### The GitHub/Jekyll part <a name="gitjek"></a>

The first step is to call the requested libraries in your GitHub page. As Jekyll basically transforms `markdown` into `html`, this step is a matter of **what to include** and **where** in your own repository.

#### 1. What to include <a name="step1"></a>

This part is not complicated. When having a look to the source code of [Leaflet for R](https://rstudio.github.io/leaflet/) site it can be seen this chunk

``` html
<head>
  <!--code-->
  <script src="libs/jquery/jquery.min.js"></script>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="libs/bootstrap/css/flatly.min.css" rel="stylesheet" />
  <script src="libs/bootstrap/js/bootstrap.min.js"></script>
  <script src="libs/bootstrap/shim/html5shiv.min.js"></script>
  ...
  <!--more libraries-->
  ...
  <link href="libs/rstudio_leaflet/rstudio_leaflet.css" rel="stylesheet" />
  <script src="libs/leaflet-binding/leaflet.js"></script>
  <!--code-->
</head>
```

So now we have it! The only thing to remember is **to reference that part to the source repository (`https://rstudio.github.io/leaflet`)**, like this:

``` html
  <script src="https://rstudio.github.io/leaflet/libs/jquery/jquery.min.js"></script>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="https://rstudio.github.io/leaflet/libs/bootstrap/css/flatly.min.css" rel="stylesheet" />
  ...
  <!--more libraries-->
  ...
  <link     href="https://rstudio.github.io/leaflet/libs/rstudio_leaflet/rstudio_leaflet.css" rel="stylesheet" />
  <script src= "https://rstudio.github.io/leaflet/libs/leaflet-binding/leaflet.js"></script>
```

You can have a look of my implementation on [`./_includes/leaflet.html`](https://github.com/dieghernan/dieghernan.github.io/blob/master/_includes/leaflet.html).

#### 2.Where to include <a name="step2"></a>

This a little bit more complicated. The code chunk should be included in the `<head>` section of your page, so you would need to find where to put it. In the case of **Beautiful Jekyll** it is on [`./_includes/head.html`](https://github.com/dieghernan/dieghernan.github.io/blob/master/_includes/head.html).

You can just copy/paste the amended code there.

{: .box-note}
 **<i class="fa fa-star"></i> Pro tip:** For a better performance of the site, include these libraries only when you need it. In my case, I added a custom variable in my YAML front matter for those posts with a leaflet map, `leafletmap: true`. Go to [step 4](#step4) for a working example.

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

It is assumed that you are [creating a post with **RStudio**](https://rmarkdown.rstudio.com/authoring_quick_tour.html#rendering_output), so the code presented above should be embedded in an `.Rmd` file.

#### 4. Set up the YAML front matter <a name="step4"></a>

Before knitting your `.Rmd`, you have to set up the YAML front matter. Here it is important to set up the option `always_allow_html: yes`, as well as `output: github_document`. As an example, this post was created with the front matter:

      ---
      layout: post
      title: Leaflet, R, Markdown, Jekyll and GitHub
      subtitle: Make it work in 6 steps - a short tutorial
      tags: [R,leaflet,Jekyll, html, maps]
      leafletmap: true
      linktormd: true
      always_allow_html: yes
      output: github_document
      ---

Now you just have to "Knit" your file and get the corresponding `.md`file.

### The Markdown part <a name="#md"></a>

#### 5. Modifying the `.md`file <a name="step5"></a>

Now that you have knitted your code have a look to the `.md` code itself. Although not displayed in the preview, you can see in the file itself a code that looks like this:

``` html
<!--html_preserve-->

  <script type="application/json"data-for="htmlwidget-7ab57412f7b1df4d5773">
    {"x":{"options":
      ...
      "jsHooks":[]}
  </script>
<!--/html_preserve-->
```

Now you just need to paste this piece of code before that chunk:

``` html
<!--html_preserve-->
<div id="htmlwidget-7ab57412f7b1df4d5773" style="width:100%;height:216px;" class="leaflet html-widget">

  <script type="application/json"data-for="htmlwidget-7ab57412f7b1df4d5773">
  ...
<!--/html_preserve-->
```

{: .box-warning} 
**<i class="fa fa-exclamation-triangle"></i> Warning:** Please be sure that the widget id (`7ab57412f7b1df4d5773` in the example) is the same in the `<div>` and in the `<script>` part.

The `style="width:100%;height:216px;`part controls the actual size of the leaflet widget. I put some examples in the end of the post so you can have a look on how to control the size of the widgets.

#### 6. Publish your post <a name="step6"></a>

Now if you preview your `.md` file you are not seeing your map. What you need now is just to post it on GitHub, and when Jekyll builds your post it would include the libraries and make the magic happens, just like this:

<!--html_preserve-->
<div id="htmlwidget-7ab57412f7b1df4d5773" style="width:100%;height:216px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-7ab57412f7b1df4d5773">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addMarkers","args":[-36.852,174.768,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"The birthplace of R",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]}],"limits":{"lat":[-36.852,-36.852],"lng":[174.768,174.768]}},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->
 
 
 
 
Now you just have to publish your post as usual!!

{: .box-warning}
 **<i class="fa fa-exclamation-triangle"> Warning:** Have you checked the YAML front matter of your `.md` file? Have another look, specially if you have followed my [Pro tip](#step2).

### Extra: Resolutions of a leaflet map <a name="#extra"></a>

Soon...
