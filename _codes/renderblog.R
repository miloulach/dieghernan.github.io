library(pacman)

p_load(ezknitr)

#Render 2019-04-27-Using-CountryCodes ----
ezknit("../2019-04-27-Using-CountryCodes.Rmd",
       "_codes/wd",
       out_dir="../../_posts",
       fig_dir="../figs/2019-04-27-Using-CountryCodes",
       keep_html=FALSE
)
