# Setup----
library(pacman)

p_load(ezknitr)


diegpost <- function(dirname) {
  dir.create(paste("_codes/", dirname,sep=""))
  getwd()
  ezknit(
    "../2019-04-27-Using-CountryCodes.Rmd",
    wd="./figs",
    out_dir = "../../_posts",
    fig_dir = "./figs",
    keep_html = FALSE
  )
}
#Render 2019-04-27-Using-CountryCodes ----
diegpost("2019-04-27-Using-CountryCodes")


