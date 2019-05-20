Leaflet, R, Jekyll and GitHub
================

Recently I have been struggling when trying to embed a
[leaflet](https://rstudio.github.io/leaflet) map created with
**RStudio** on my blog, hosted in GitHub via
[Jekyll](https://jekyllrb.com). In my case, I use the [**Beautiful
Jekyll**](https://deanattali.com/beautiful-jekyll/getstarted/)
implementation created by [daattali](https://github.com/daattali).

1.  [The GitHub/Jekyll part](#gitjek)

2.  TBD

3.  TBD

### 1\. The GitHub/Jekyll part <a name="gitjek"></a>

The first step is to call the requested libraries in your GitHub page.
As Jekyll basicaly transforms `markdown` into `html`, this step is a
matter of **what to include** and **where** in your own repository.

#### What to include

This part is not complicated. When having a look to the source code of
[Leaflet for R](https://rstudio.github.io/leaflet/) site it can be seen
this chunk

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

So now we have it\! The only thing to remember is **to reference that
part to the source repository (`https://rstudio.github.io/leaflet`)**,
like
this:

``` html
<script src="https://rstudio.github.io/leaflet/libs/jquery/jquery.min.js"></script>
<meta name="viewport" content="width=device-width, initial-scale=1" />
<link href="https://rstudio.github.io/leaflet/libs/bootstrap/css/flatly.min.css" rel="stylesheet" />
<!--more libraries-->
<link   href="https://rstudio.github.io/leaflet/libs/rstudio_leaflet/rstudio_leaflet.css" rel="stylesheet" />
<script src= "https://rstudio.github.io/leaflet/libs/leaflet-binding/leaflet.js"></script>
```

You can have a look of my implementation on
[`./_includes/leaflet.html`](https://github.com/dieghernan/dieghernan.github.io/blob/master/_includes/leaflet.html).

#### Where to include

This a little bit more complicated. The code chunk should be included in
the `<head>` section of your page, so you would need to find where to
put it. In the case of **Beautiful Jekyll** it is on
[`./_includes/head.html`](https://github.com/dieghernan/dieghernan.github.io/blob/master/_includes/head.html).

You can just copy/paste the ammended code there.

{: .box-note} **<i class="fa fa-star"></i> Pro tip:** For a better
performance of the site, include these libraries only when you need it.
In my case, I added a custom variable in my YAML front matter for those
posts with a leaflet map, `leafletmap: true`. You can have a look in the
*ADD LINK* source code of this post.

## The Rstudio part

#### Creating the leaflet map

Now it’s time to create a leaflet map with **RStudio**. I just keep it
simple for this post, so I took the first example provided in [Leaflet
for R - Introduction](https://rstudio.github.io/leaflet/)
