# Setup----
library(pacman)

p_load(ezknitr)


diegpost <- function(dirname) {
  dir.create(paste("_codes/", dirname,sep=""))
  getwd()
  ezknit(
    "../2019-04-27-Using-CountryCodes.Rmd",
    wd=paste("./_codes/", dirname,sep=""),
    out_dir = "../../_posts",
    fig_dir = paste("../_codes/", dirname,sep=""),
    keep_html = FALSE
  )
}
#Render 2019-04-27-Using-CountryCodes ----
diegpost("2019-04-27-Using-CountryCodes")


