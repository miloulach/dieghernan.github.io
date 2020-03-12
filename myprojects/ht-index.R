rm(list = ls())

initrun <- Sys.time()
#Implementation of head/tails 1.0, another version (2.0 - Jiang (2019)) does exists, but it is not under the scope of this study.


#1. Characterization of heavy-tail distributions----
set.seed(1234)
#Pareto distributions a=2 b=6 n=1000
sample_par <- 2 / (1 - runif(1000)) ^ (1 / 6)

cols = adjustcolor("grey80", alpha.f = 0.8)
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
var <- sample_par
ht_thresold <- 0.35 #Cherry-picked value for the example

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
  main = "Iter1"
)
abline(v = mu0, col = "red")
text(x = 6,
     y = 1,
     labels = paste0("PropHead: ", round(prop0, 4)))
prop0 <= ht_thresold &
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

prop1 <= ht_thresold  & n1 > 1

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
print(summiter)



#3. Standalone function----
# Default thresold = 0.4 as per Jiang et al. (2013)

ht_index <- function(var, ht_thresold = 0.4) {
  thr <-
    min(0.999, max(0, ht_thresold)) #prop on head could never be > 1
  head <- var
  breaks <- NULL #Init on null
  #Safe-check loop to set a maximum of iterations
  #Option to set a WHILE loop and set an additional par to stop the loop
  for (i in 1:100) {
    mu <- mean(head)
    breaks <- c(breaks, mu)
    ntot <- length(head)
    #Switch head
    head <- head[head > mu]
    nhead <- length(head)
    prop <- nhead / ntot
    if (prop <= thr & nhead > 1) {
      next
    } else {
      #Just for checking the execution
      # to remove on implementation
      print(paste("loop end on ", i))
      break
    }
  }
  #Add min and max to complete intervals
  breaks <- unique(c(min(var), breaks, max(var)))
  breaks <- sort(breaks)
  return(breaks)
}
ht_index(sample_par, 0.35)

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

#Replicate Phyton Results: https://github.com/chad-m/head_tail_breaks_algorithm/blob/master/htb.py
#[0.03883742394002349, 0.177990388624465, 0.481845351678573]
pareto_data <- (1.0 / (1:100)) ^ 1.16
ht_index(pareto_data)

benchmarkdist <- function(dist, thr = 0.4, title = "") {
  init <- Sys.time()
  print(ht_index(dist, thr))
  print(Sys.time() - init)
  
  plot(density(dist),
       col = "black",
       main = paste0(title, ", thresold =", thr))
  abline(
    v = ht_index(dist, thr),
    col = "red",
    lwd = 0.1,
    lty = 3
  )
}

stress <- function(dist) {
  ht_index(dist, 0)
  ht_index(dist, 1)
}

#Scalability: 5 millions

# Pareto dist params(6820,4)
#shape <- 4
#scale <- 6820
paretodist <- 6820 / (1 - runif(5000000)) ^ (1 / 4)

benchmarkdist(paretodist, title = "Pareto Dist")

#Exponential dist
expdist <- rexp(5000000)
expdist <- c(expdist, rep(max(expdist), 10))

benchmarkdist(expdist, 0.1, title = "Exp. Dist")

#Lognorm
lognormdist = rlnorm(5000000)
benchmarkdist(lognormdist, 1, title = "LogNorm. Dist")

#Weibull
weibulldist <- rweibull(5000000, 1, scale = 5)
benchmarkdist(weibulldist, title = "Weibull Dist")

#Stress params
stress(pareto_data)
stress(paretodist)
stress(expdist)
stress(lognormdist)
stress(weibulldist)


#Normal dist
normdist = rnorm(5000000)
benchmarkdist(normdist, 0.6, "Normal Dist")

#Left-tailed distr
leftnorm <- rep(normdist[normdist < mean(normdist)], 2)
benchmarkdist(leftnorm, 0.6, "Trunc. Left,Normal Dist")

# On non skewed or left tails thresold should be stressed beyond 50%, otherwise just the first iter (i.e. min, mean, max) is returned.
par(opar)


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
brks_ht <- ht_index(nuts3$var, .5)
Sys.time() - init

init <- Sys.time()
brks_fisher <-
  classIntervals(nuts3$var, style = "fisher", n = 8)$brks
Sys.time() - init

init <- Sys.time()
brks_kmeans <-
  classIntervals(nuts3$var, style = "kmeans", n = 8)$brks
Sys.time() - init


cols = carto.pal("red.pal", 9)


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
# Jiang, Bin (2013). "Head/tail breaks: A new classification scheme for data with a heavy-tailed distribution", The Professional Geographer, 65 (3), 482 – 494.

# Jiang, Bin, Liu, Xintao and Jia, Tao (2013). "Scaling of geographic space as a universal rule for map generalization", Annals of the Association of American Geographers, 103(4), 844 – 855.

#Jiang, B. (2019). "A recursive definition of goodness of space for bridging the concepts of space and place for sustainability". Sustainability, 11(15), 4091. 
