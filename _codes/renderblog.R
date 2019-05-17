# Setup----
library(pacman)

p_load(ezknitr)
p_load(styler)

diegpost <- function(file) {
  getwd()
  ezknit(
    paste("../_codes/",file,".Rmd",sep = ""),
    wd="./figs",
    out_dir = "../_posts",
    fig_dir = "../figs",
    keep_html = FALSE
  )
}
#Render 2019-04-27-Using-CountryCodes ----

#diegpost("2019-04-27-Using-CountryCodes")
diegpost("2019-05-05-Cast to subsegments")

#diegpost("2019-05-13-Where-in-the-world")

