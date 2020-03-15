reprex::reprex()


rm(list = ls())


initrun <- Sys.time()
#Implementation of head/tails 1.0


#1. Characterization of heavy-tail distributions----
set.seed(1234)
#Pareto distribution a=2 b=6 n=1000
sample_par <- 2 / (1 - runif(1000)) ^ (1 / 6)

cols <- adjustcolor("grey80", alpha.f = 0.8)
opar <- par(no.readonly = TRUE)
par(mar = c(2, 2, 3, 1))
#Figures
plot(
  density(sample_par),
  lty = 3,
  axes = FALSE,
  ylab = "",
  xlab = "",
  main = "sample_par"
)
axis(2)
hist(
  sample_par,
  col = cols,
  border = NA,
  main = "Pareto",
  freq = FALSE,
  axes = FALSE,
  add = TRUE
)

#2. Step by step example----
set.seed(1234)
sample_par <- 2 / (1 - runif(1000)) ^ (1 / 6)
var <- sample_par
thr <- 0.35 #Cherry-picked thresold  for the example

#Step1
mu0 <- mean(var)
#The breaks are the means of the head
breaks <- c(mu0)
n0 <- length(var)
head0 <- var[var > mu0]
prop0 <- length(head0) / n0

plot(
  density(var),
  lty = 3,
  ylab = "",
  xlab = "",
  main = "Iter2"
)
abline(v = mu0, col = "red")
text(x = 6,
     y = 1,
     labels = paste0("PropHead: ", round(prop0, 4)))



prop0 <= thr &
  n0 > 1 #Additional control to stop if no more breaks are possible


#The process is iterative through the head, i.e, now var <- head0
var <- head0

#Iter2
mu1 <- mean(var)
#Add the break
breaks <- c(breaks, mu1)
n1 <- length(var)
head1 <- var[var > mu1]
prop1 <- length(head1) / n1

plot(
  density(var),
  lty = 3,
  ylab = "",
  xlab = "",
  main = "Iter2"
)
abline(v = mu1, col = "red")
text(x = 6,
     y = 1,
     labels = paste0("PropHead: ", round(prop1, 4)))

prop1 <= thr  & n1 > 1

# End given that condition is FALSE

#Summary
summiter <- data.frame(
  iter = c(1, 2),
  n = c(n0, n1),
  nhead = c(length(head0), length(head1)),
  mu = c(mu0, mu1),
  prophead = c(prop0, prop1)
)
summiter$breaks <- breaks
knitr::kable(summiter, format = "markdown")



#3. Standalone function----
# Default thresold = 0.4 as per Jiang et al. (2013)


ht_index <- function(var, style = "headtails", ...) {
  if (style == "headtails") {
    # Contributed Diego Hernangomez
    dots <- list(...)
    thr = ifelse(is.null(dots$thr),
                 .4,
                 dots$thr)
    
    thr <-  min(0.999,
                max(0, thr)) #prop on head could never be > 1
    head <- var
    breaks <- NULL #Init on null
    #Safe-check loop to set a maximum of iterations
    #Option to set a WHILE loop and set an additional par to stop the loop
    for (i in 1:100) {
      mu <- mean(head, na.rm = TRUE)
      breaks <- c(breaks, mu)
      ntot <- length(head)
      #Switch head
      head <- head[head > mu]
      prop <- length(head) / ntot
      keepiter <- prop <= thr & length(head) > 1
      print(paste0("prop:", prop, " nhead:", length(head)))
      if (isFALSE(keepiter)) {
        #Just for checking the execution
        # to remove on implementation
        print(paste("Breaks found: ", i, ", Intervals:"))
        break
      }
    }
    #Add min and max to complete intervals
    breaks <- sort(unique(c(
      min(var, na.rm = TRUE),
      breaks,
      max(var, na.rm = TRUE)
    )))
    return(breaks)
  }
}
ht_index(sample_par, thr = 0.35)

plot(
  density(sample_par),
  lty = 3,
  axes = FALSE,
  ylab = "",
  xlab = "",
  main = "sample_par: breaks"
)
axis(2)
abline(v = ht_index(sample_par, 0.35), col = "green")
abline(
  v = ht_index(sample_par, 0.4),
  col = "orange",
  lty = 3,
  lwd = 0.5
)
legend(
  "right",
  legend = c("thresold .35", "thresold .4"),
  col = c("green", "orange"),
  lty = c(1, 3),
  cex = 0.8
)

#4. Test and stress----
#Init table on default
testresults <- data.frame(
  Title = NA,
  nsample  = NA,
  thresold = NA,
  nbreaks = NA,
  time_secs = NA
)

benchmarkdist <-
  function(dist,
           thr = 0.4,
           title = "",
           plot = TRUE) {
    dist = c(na.omit(dist))
    init <- Sys.time()
    br <- ht_index(dist, thr = thr)
    a <- Sys.time() - init
    print(a)
    test <- data.frame(
      Title = title,
      nsample  = format(length(dist), scientific = FALSE, big.mark = ","),
      thresold = thr,
      nbreaks = length(br) - 1,
      time_secs = as.character(a)
    )
    testresults <- unique(rbind(testresults, test))
    
    if (plot) {
      plot(density(dist),
           col = "black",
           main = paste0(title, ", thr =", thr, ", nbreaks = ", length(br)-1))
      abline(v = br,
             col = "green",
             lty = 3)
    }
    return(testresults)
  }



#Scalability: 5 millions
set.seed(2389)

#Pareto distributions a=7 b=14
paretodist <- 7 / (1 - runif(5000000)) ^ (1 / 14)
#Exponential dist
expdist <- rexp(5000000)
#Lognorm
lognormdist <- rlnorm(5000000)
#Weibull
weibulldist <- rweibull(5000000, 1, scale = 5)
#Normal dist
normdist <- rnorm(5000000)
#Left-tailed distr
leftnorm <- rep(normdist[normdist < mean(normdist)], 2)
#LogCauchy "super-heavy tail"
logcauchdist <- exp(rcauchy(5000000, 2, 4))
#Remove Inf - this check is already implemented on classIntervals
logcauchdist <- logcauchdist[logcauchdist < Inf]

#Tests
testresults <- benchmarkdist(paretodist, title = "Pareto Dist")
testresults <-
  benchmarkdist(paretodist, 0, title = "Pareto Dist", plot = FALSE)
testresults <-
  benchmarkdist(paretodist, 1, title = "Pareto Dist", plot = FALSE)

testresults <- benchmarkdist(expdist, title = "ExpDist")
testresults <-
  benchmarkdist(expdist, 0, title = "ExpDist", plot = FALSE)
testresults <-
  benchmarkdist(expdist, 1, title = "ExpDist", plot = FALSE)

testresults <- benchmarkdist(lognormdist, 0.75, title = "LogNorm")
testresults <-
  benchmarkdist(lognormdist, 0, title = "LogNorm", plot = FALSE)
testresults <-
  benchmarkdist(lognormdist, 1, title = "LogNorm", plot = FALSE)

testresults <- benchmarkdist(weibulldist, 0.25, title = "Weibull")
testresults <-
  benchmarkdist(weibulldist, 0, title = "Weibull", plot = FALSE)
testresults <-
  benchmarkdist(weibulldist, 1, title = "Weibull", plot = FALSE)

testresults <- benchmarkdist(normdist, 0.8, title = "Normal")
testresults <-
  benchmarkdist(normdist, 0, title = "Normal", plot = FALSE)
testresults <-
  benchmarkdist(normdist, 1, title = "Normal", plot = FALSE)


testresults <-
  benchmarkdist(leftnorm, 0.6, title = "Left. Trunc. Normal")
testresults <-
  benchmarkdist(leftnorm, 0, title = "Left. Trunc. Normal", plot = FALSE)
testresults <-
  benchmarkdist(leftnorm, 1, title = "Left. Trunc. Normal", plot = FALSE)


testresults <-
  benchmarkdist(logcauchdist, 0.7896, title = "LogCauchy", plot = FALSE)
testresults <-
  benchmarkdist(logcauchdist, 0, title = "LogCauchy", plot = FALSE)
testresults <-
  benchmarkdist(logcauchdist, 1, title = "LogCauchy", plot = FALSE)

# On non skewed or left tails thresold should be stressed beyond 50%,
# otherwise just the first iter (i.e. min, mean, max) is returned.
par(opar)

ht_index(logcauchdist, thr = .7896)

knitr::kable(testresults[-1, ], format = "markdown", row.names = FALSE)

# 5. Case study: Population----
library(cartography)
library(sf)
library(classInt)

nuts3 <- st_as_sf(nuts3.spdf)
nuts3 <- merge(nuts3, nuts3.df)

nrow(nuts3)

nuts3$var <- nuts3$pop2008 / 1000 #Thousands

opar <- par(no.readonly = TRUE)
par(mar = c(3, 2.5, 2, 1))
plot(density(nuts3$var),
     main = "NUTS3 Pop2008 (thousands)",
     ylab = "",
     xlab = "")


#benchmark
init <- Sys.time()
brks_ht <- ht_index(nuts3$var)
Sys.time() - init

init <- Sys.time()
brks_fisher <-
  classIntervals(nuts3$var, style = "fisher", n = 7)$brks
Sys.time() - init

init <- Sys.time()
brks_kmeans <-
  classIntervals(nuts3$var, style = "kmeans", n = 7)$brks
Sys.time() - init


cols = c(carto.pal("harmo.pal", 7))



par(mar = c(0, 0, 0, 0))
choroLayer(
  nuts3,
  var = "var",
  breaks = brks_ht,
  legend.title.txt = "HT-index",
  col = cols,
  border = NA,
  legend.pos = "right"
)

choroLayer(
  nuts3,
  var = "var",
  breaks = brks_fisher,
  legend.title.txt = "Fisher",
  col = cols,
  border = NA,
  legend.pos = "right"
)

choroLayer(
  nuts3,
  var = "var",
  breaks = brks_kmeans,
  legend.title.txt = "Kmeans",
  col = cols,
  border = NA,
  legend.pos = "right"
)
par(opar)

print(paste0("Full running time:", Sys.time() - initrun))


#6. References----
# Jiang, Bin (2013). "Head/tail breaks:
# A new classification scheme for data with a heavy-tailed distribution",
# The Professional Geographer, 65 (3), 482 – 494.

# Jiang, Bin, Liu, Xintao and Jia, Tao (2013).
# "Scaling of geographic space as a universal rule for map generalization",
# Annals of the Association of American Geographers, 103(4), 844 – 855.

#Jiang, B. (2019).
# "A recursive definition of goodness of space for bridging the
# concepts of space and place for sustainability".
# Sustainability, 11(15), 4091. 