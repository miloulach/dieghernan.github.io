``` r
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
```

![](https://i.imgur.com/QQyP4qx.png)

``` r

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
```

![](https://i.imgur.com/8JDdEV2.png)

``` r



prop0 <= thr &
  n0 > 1 #Additional control to stop if no more breaks are possible
#> [1] TRUE


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
```

![](https://i.imgur.com/FHhFkIh.png)

``` r

prop1 <= thr  & n1 > 1
#> [1] FALSE

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
```

<table>
<thead>
<tr class="header">
<th style="text-align: right;">iter</th>
<th style="text-align: right;">n</th>
<th style="text-align: right;">nhead</th>
<th style="text-align: right;">mu</th>
<th style="text-align: right;">prophead</th>
<th style="text-align: right;">breaks</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: right;">1</td>
<td style="text-align: right;">1000</td>
<td style="text-align: right;">316</td>
<td style="text-align: right;">2.422568</td>
<td style="text-align: right;">0.3160000</td>
<td style="text-align: right;">2.422568</td>
</tr>
<tr class="even">
<td style="text-align: right;">2</td>
<td style="text-align: right;">316</td>
<td style="text-align: right;">118</td>
<td style="text-align: right;">2.971249</td>
<td style="text-align: right;">0.3734177</td>
<td style="text-align: right;">2.971249</td>
</tr>
</tbody>
</table>

``` r



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
#> [1] "prop:0.316 nhead:316"
#> [1] "prop:0.373417721518987 nhead:118"
#> [1] "Breaks found:  2 , Intervals:"
#> [1] 2.000114 2.422568 2.971249 6.716770

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
```

![](https://i.imgur.com/FOwpT6M.png)

``` r

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
#> [1] "prop:0.3543272 nhead:1771636"
#> [1] "prop:0.354200862931212 nhead:627515"
#> [1] "prop:0.354158864728333 nhead:222240"
#> [1] "prop:0.354063174946004 nhead:78687"
#> [1] "prop:0.35352726625745 nhead:27818"
#> [1] "prop:0.355345459774247 nhead:9885"
#> [1] "prop:0.355791603439555 nhead:3517"
#> [1] "prop:0.35371054876315 nhead:1244"
#> [1] "prop:0.343247588424437 nhead:427"
#> [1] "prop:0.346604215456674 nhead:148"
#> [1] "prop:0.371621621621622 nhead:55"
#> [1] "prop:0.327272727272727 nhead:18"
#> [1] "prop:0.388888888888889 nhead:7"
#> [1] "prop:0.142857142857143 nhead:1"
#> [1] "Breaks found:  14 , Intervals:"
#> Time difference of 0.278265 secs
```

![](https://i.imgur.com/twt5fS6.png)

``` r
testresults <-
  benchmarkdist(paretodist, 0, title = "Pareto Dist", plot = FALSE)
#> [1] "prop:0.3543272 nhead:1771636"
#> [1] "Breaks found:  1 , Intervals:"
#> Time difference of 0.1866319 secs
testresults <-
  benchmarkdist(paretodist, 1, title = "Pareto Dist", plot = FALSE)
#> [1] "prop:0.3543272 nhead:1771636"
#> [1] "prop:0.354200862931212 nhead:627515"
#> [1] "prop:0.354158864728333 nhead:222240"
#> [1] "prop:0.354063174946004 nhead:78687"
#> [1] "prop:0.35352726625745 nhead:27818"
#> [1] "prop:0.355345459774247 nhead:9885"
#> [1] "prop:0.355791603439555 nhead:3517"
#> [1] "prop:0.35371054876315 nhead:1244"
#> [1] "prop:0.343247588424437 nhead:427"
#> [1] "prop:0.346604215456674 nhead:148"
#> [1] "prop:0.371621621621622 nhead:55"
#> [1] "prop:0.327272727272727 nhead:18"
#> [1] "prop:0.388888888888889 nhead:7"
#> [1] "prop:0.142857142857143 nhead:1"
#> [1] "Breaks found:  14 , Intervals:"
#> Time difference of 0.214011 secs

testresults <- benchmarkdist(expdist, title = "ExpDist")
#> [1] "prop:0.3677448 nhead:1838724"
#> [1] "prop:0.367977466982538 nhead:676609"
#> [1] "prop:0.368261433117207 nhead:249169"
#> [1] "prop:0.367794549081146 nhead:91643"
#> [1] "prop:0.367807688530493 nhead:33707"
#> [1] "prop:0.368706796807785 nhead:12428"
#> [1] "prop:0.36562600579337 nhead:4544"
#> [1] "prop:0.36949823943662 nhead:1679"
#> [1] "prop:0.363311494937463 nhead:610"
#> [1] "prop:0.360655737704918 nhead:220"
#> [1] "prop:0.354545454545455 nhead:78"
#> [1] "prop:0.397435897435897 nhead:31"
#> [1] "prop:0.387096774193548 nhead:12"
#> [1] "prop:0.333333333333333 nhead:4"
#> [1] "prop:0.5 nhead:2"
#> [1] "Breaks found:  15 , Intervals:"
#> Time difference of 0.2255881 secs
```

![](https://i.imgur.com/JW8tNqA.png)

``` r
testresults <-
  benchmarkdist(expdist, 0, title = "ExpDist", plot = FALSE)
#> [1] "prop:0.3677448 nhead:1838724"
#> [1] "Breaks found:  1 , Intervals:"
#> Time difference of 0.120697 secs
testresults <-
  benchmarkdist(expdist, 1, title = "ExpDist", plot = FALSE)
#> [1] "prop:0.3677448 nhead:1838724"
#> [1] "prop:0.367977466982538 nhead:676609"
#> [1] "prop:0.368261433117207 nhead:249169"
#> [1] "prop:0.367794549081146 nhead:91643"
#> [1] "prop:0.367807688530493 nhead:33707"
#> [1] "prop:0.368706796807785 nhead:12428"
#> [1] "prop:0.36562600579337 nhead:4544"
#> [1] "prop:0.36949823943662 nhead:1679"
#> [1] "prop:0.363311494937463 nhead:610"
#> [1] "prop:0.360655737704918 nhead:220"
#> [1] "prop:0.354545454545455 nhead:78"
#> [1] "prop:0.397435897435897 nhead:31"
#> [1] "prop:0.387096774193548 nhead:12"
#> [1] "prop:0.333333333333333 nhead:4"
#> [1] "prop:0.5 nhead:2"
#> [1] "prop:0.5 nhead:1"
#> [1] "Breaks found:  16 , Intervals:"
#> Time difference of 0.2559481 secs

testresults <- benchmarkdist(lognormdist, 0.75, title = "LogNorm")
#> [1] "prop:0.3087264 nhead:1543632"
#> [1] "prop:0.309735740124589 nhead:478118"
#> [1] "prop:0.315926193952121 nhead:151050"
#> [1] "prop:0.319311486262827 nhead:48232"
#> [1] "prop:0.323270857521977 nhead:15592"
#> [1] "prop:0.333760903027193 nhead:5204"
#> [1] "prop:0.329554189085319 nhead:1715"
#> [1] "prop:0.332361516034985 nhead:570"
#> [1] "prop:0.335087719298246 nhead:191"
#> [1] "prop:0.350785340314136 nhead:67"
#> [1] "prop:0.26865671641791 nhead:18"
#> [1] "prop:0.277777777777778 nhead:5"
#> [1] "prop:0.4 nhead:2"
#> [1] "prop:0.5 nhead:1"
#> [1] "Breaks found:  14 , Intervals:"
#> Time difference of 0.2131069 secs
```

![](https://i.imgur.com/QVzM26X.png)

``` r
testresults <-
  benchmarkdist(lognormdist, 0, title = "LogNorm", plot = FALSE)
#> [1] "prop:0.3087264 nhead:1543632"
#> [1] "Breaks found:  1 , Intervals:"
#> Time difference of 0.1389289 secs
testresults <-
  benchmarkdist(lognormdist, 1, title = "LogNorm", plot = FALSE)
#> [1] "prop:0.3087264 nhead:1543632"
#> [1] "prop:0.309735740124589 nhead:478118"
#> [1] "prop:0.315926193952121 nhead:151050"
#> [1] "prop:0.319311486262827 nhead:48232"
#> [1] "prop:0.323270857521977 nhead:15592"
#> [1] "prop:0.333760903027193 nhead:5204"
#> [1] "prop:0.329554189085319 nhead:1715"
#> [1] "prop:0.332361516034985 nhead:570"
#> [1] "prop:0.335087719298246 nhead:191"
#> [1] "prop:0.350785340314136 nhead:67"
#> [1] "prop:0.26865671641791 nhead:18"
#> [1] "prop:0.277777777777778 nhead:5"
#> [1] "prop:0.4 nhead:2"
#> [1] "prop:0.5 nhead:1"
#> [1] "Breaks found:  14 , Intervals:"
#> Time difference of 0.2225449 secs

testresults <- benchmarkdist(weibulldist, 0.25, title = "Weibull")
#> [1] "prop:0.3679468 nhead:1839734"
#> [1] "Breaks found:  1 , Intervals:"
#> Time difference of 0.200336 secs
```

![](https://i.imgur.com/4bomzpC.png)

``` r
testresults <-
  benchmarkdist(weibulldist, 0, title = "Weibull", plot = FALSE)
#> [1] "prop:0.3679468 nhead:1839734"
#> [1] "Breaks found:  1 , Intervals:"
#> Time difference of 0.1328502 secs
testresults <-
  benchmarkdist(weibulldist, 1, title = "Weibull", plot = FALSE)
#> [1] "prop:0.3679468 nhead:1839734"
#> [1] "prop:0.367591727934582 nhead:676271"
#> [1] "prop:0.367926467348149 nhead:248818"
#> [1] "prop:0.367995884542115 nhead:91564"
#> [1] "prop:0.367447905290289 nhead:33645"
#> [1] "prop:0.368108188438104 nhead:12385"
#> [1] "prop:0.373112636253533 nhead:4621"
#> [1] "prop:0.357714780350573 nhead:1653"
#> [1] "prop:0.372655777374471 nhead:616"
#> [1] "prop:0.375 nhead:231"
#> [1] "prop:0.350649350649351 nhead:81"
#> [1] "prop:0.37037037037037 nhead:30"
#> [1] "prop:0.366666666666667 nhead:11"
#> [1] "prop:0.363636363636364 nhead:4"
#> [1] "prop:0.5 nhead:2"
#> [1] "prop:0.5 nhead:1"
#> [1] "Breaks found:  16 , Intervals:"
#> Time difference of 0.2835648 secs

testresults <- benchmarkdist(normdist, 0.8, title = "Normal")
#> [1] "prop:0.5001914 nhead:2500957"
#> [1] "prop:0.425015304141575 nhead:1062945"
#> [1] "prop:0.404747188236456 nhead:430224"
#> [1] "prop:0.39417373275317 nhead:169583"
#> [1] "prop:0.390198309972108 nhead:66171"
#> [1] "prop:0.386498617219023 nhead:25575"
#> [1] "prop:0.380879765395894 nhead:9741"
#> [1] "prop:0.380043116723129 nhead:3702"
#> [1] "prop:0.388438681793625 nhead:1438"
#> [1] "prop:0.376216968011127 nhead:541"
#> [1] "prop:0.384473197781885 nhead:208"
#> [1] "prop:0.375 nhead:78"
#> [1] "prop:0.397435897435897 nhead:31"
#> [1] "prop:0.354838709677419 nhead:11"
#> [1] "prop:0.272727272727273 nhead:3"
#> [1] "prop:0.333333333333333 nhead:1"
#> [1] "Breaks found:  16 , Intervals:"
#> Time difference of 0.2873449 secs
```

![](https://i.imgur.com/ppPblbu.png)

``` r
testresults <-
  benchmarkdist(normdist, 0, title = "Normal", plot = FALSE)
#> [1] "prop:0.5001914 nhead:2500957"
#> [1] "Breaks found:  1 , Intervals:"
#> Time difference of 0.163904 secs
testresults <-
  benchmarkdist(normdist, 1, title = "Normal", plot = FALSE)
#> [1] "prop:0.5001914 nhead:2500957"
#> [1] "prop:0.425015304141575 nhead:1062945"
#> [1] "prop:0.404747188236456 nhead:430224"
#> [1] "prop:0.39417373275317 nhead:169583"
#> [1] "prop:0.390198309972108 nhead:66171"
#> [1] "prop:0.386498617219023 nhead:25575"
#> [1] "prop:0.380879765395894 nhead:9741"
#> [1] "prop:0.380043116723129 nhead:3702"
#> [1] "prop:0.388438681793625 nhead:1438"
#> [1] "prop:0.376216968011127 nhead:541"
#> [1] "prop:0.384473197781885 nhead:208"
#> [1] "prop:0.375 nhead:78"
#> [1] "prop:0.397435897435897 nhead:31"
#> [1] "prop:0.354838709677419 nhead:11"
#> [1] "prop:0.272727272727273 nhead:3"
#> [1] "prop:0.333333333333333 nhead:1"
#> [1] "Breaks found:  16 , Intervals:"
#> Time difference of 0.281585 secs


testresults <-
  benchmarkdist(leftnorm, 0.6, title = "Left. Trunc. Normal")
#> [1] "prop:0.574960895030618 nhead:2873704"
#> [1] "prop:0.51244526228171 nhead:1472616"
#> [1] "prop:0.503100604638276 nhead:740874"
#> [1] "prop:0.501235027818495 nhead:371352"
#> [1] "prop:0.499935371291928 nhead:185652"
#> [1] "prop:0.499935362937108 nhead:92814"
#> [1] "prop:0.499730644083867 nhead:46382"
#> [1] "prop:0.500452761847268 nhead:23212"
#> [1] "prop:0.502240220575564 nhead:11658"
#> [1] "prop:0.490478641276377 nhead:5718"
#> [1] "prop:0.508219657222805 nhead:2906"
#> [1] "prop:0.487267721954577 nhead:1416"
#> [1] "prop:0.505649717514124 nhead:716"
#> [1] "prop:0.494413407821229 nhead:354"
#> [1] "prop:0.497175141242938 nhead:176"
#> [1] "prop:0.488636363636364 nhead:86"
#> [1] "prop:0.511627906976744 nhead:44"
#> [1] "prop:0.454545454545455 nhead:20"
#> [1] "prop:0.5 nhead:10"
#> [1] "prop:0.4 nhead:4"
#> [1] "prop:0.5 nhead:2"
#> [1] "prop:0 nhead:0"
#> [1] "Breaks found:  22 , Intervals:"
#> Time difference of 0.311451 secs
```

![](https://i.imgur.com/kHf8VXZ.png)

``` r
testresults <-
  benchmarkdist(leftnorm, 0, title = "Left. Trunc. Normal", plot = FALSE)
#> [1] "prop:0.574960895030618 nhead:2873704"
#> [1] "Breaks found:  1 , Intervals:"
#> Time difference of 0.1655509 secs
testresults <-
  benchmarkdist(leftnorm, 1, title = "Left. Trunc. Normal", plot = FALSE)
#> [1] "prop:0.574960895030618 nhead:2873704"
#> [1] "prop:0.51244526228171 nhead:1472616"
#> [1] "prop:0.503100604638276 nhead:740874"
#> [1] "prop:0.501235027818495 nhead:371352"
#> [1] "prop:0.499935371291928 nhead:185652"
#> [1] "prop:0.499935362937108 nhead:92814"
#> [1] "prop:0.499730644083867 nhead:46382"
#> [1] "prop:0.500452761847268 nhead:23212"
#> [1] "prop:0.502240220575564 nhead:11658"
#> [1] "prop:0.490478641276377 nhead:5718"
#> [1] "prop:0.508219657222805 nhead:2906"
#> [1] "prop:0.487267721954577 nhead:1416"
#> [1] "prop:0.505649717514124 nhead:716"
#> [1] "prop:0.494413407821229 nhead:354"
#> [1] "prop:0.497175141242938 nhead:176"
#> [1] "prop:0.488636363636364 nhead:86"
#> [1] "prop:0.511627906976744 nhead:44"
#> [1] "prop:0.454545454545455 nhead:20"
#> [1] "prop:0.5 nhead:10"
#> [1] "prop:0.4 nhead:4"
#> [1] "prop:0.5 nhead:2"
#> [1] "prop:0 nhead:0"
#> [1] "Breaks found:  22 , Intervals:"
#> Time difference of 0.404407 secs


testresults <-
  benchmarkdist(logcauchdist, 0.7896, title = "LogCauchy", plot = FALSE)
#> [1] "prop:3.16580735701571e-05 nhead:158"
#> [1] "prop:0.20253164556962 nhead:32"
#> [1] "prop:0.34375 nhead:11"
#> [1] "prop:0.363636363636364 nhead:4"
#> [1] "prop:0.5 nhead:2"
#> [1] "prop:0.5 nhead:1"
#> [1] "Breaks found:  6 , Intervals:"
#> Time difference of 0.1351271 secs
testresults <-
  benchmarkdist(logcauchdist, 0, title = "LogCauchy", plot = FALSE)
#> [1] "prop:3.16580735701571e-05 nhead:158"
#> [1] "Breaks found:  1 , Intervals:"
#> Time difference of 0.09632516 secs
testresults <-
  benchmarkdist(logcauchdist, 1, title = "LogCauchy", plot = FALSE)
#> [1] "prop:3.16580735701571e-05 nhead:158"
#> [1] "prop:0.20253164556962 nhead:32"
#> [1] "prop:0.34375 nhead:11"
#> [1] "prop:0.363636363636364 nhead:4"
#> [1] "prop:0.5 nhead:2"
#> [1] "prop:0.5 nhead:1"
#> [1] "Breaks found:  6 , Intervals:"
#> Time difference of 0.1050811 secs

# On non skewed or left tails thresold should be stressed beyond 50%,
# otherwise just the first iter (i.e. min, mean, max) is returned.
par(opar)

ht_index(logcauchdist, thr = .7896)
#> [1] "prop:3.16580735701571e-05 nhead:158"
#> [1] "prop:0.20253164556962 nhead:32"
#> [1] "prop:0.34375 nhead:11"
#> [1] "prop:0.363636363636364 nhead:4"
#> [1] "prop:0.5 nhead:2"
#> [1] "prop:0.5 nhead:1"
#> [1] "Breaks found:  6 , Intervals:"
#> [1]  0.000000e+00 3.600688e+302 1.137365e+307 5.236743e+307 9.915649e+307
#> [6] 1.411160e+308 1.637900e+308 1.725945e+308

knitr::kable(testresults[-1, ], format = "markdown", row.names = FALSE)
```

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Title</th>
<th style="text-align: left;">nsample</th>
<th style="text-align: right;">thresold</th>
<th style="text-align: right;">nbreaks</th>
<th style="text-align: left;">time_secs</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">Pareto Dist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.4000</td>
<td style="text-align: right;">15</td>
<td style="text-align: left;">0.278264999389648</td>
</tr>
<tr class="even">
<td style="text-align: left;">Pareto Dist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.186631917953491</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Pareto Dist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">15</td>
<td style="text-align: left;">0.214010953903198</td>
</tr>
<tr class="even">
<td style="text-align: left;">ExpDist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.4000</td>
<td style="text-align: right;">16</td>
<td style="text-align: left;">0.225588083267212</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ExpDist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.120697021484375</td>
</tr>
<tr class="even">
<td style="text-align: left;">ExpDist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">17</td>
<td style="text-align: left;">0.255948066711426</td>
</tr>
<tr class="odd">
<td style="text-align: left;">LogNorm</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.7500</td>
<td style="text-align: right;">15</td>
<td style="text-align: left;">0.213106870651245</td>
</tr>
<tr class="even">
<td style="text-align: left;">LogNorm</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.138928890228271</td>
</tr>
<tr class="odd">
<td style="text-align: left;">LogNorm</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">15</td>
<td style="text-align: left;">0.22254490852356</td>
</tr>
<tr class="even">
<td style="text-align: left;">Weibull</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.2500</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.20033597946167</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Weibull</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.132850170135498</td>
</tr>
<tr class="even">
<td style="text-align: left;">Weibull</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">17</td>
<td style="text-align: left;">0.283564805984497</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Normal</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.8000</td>
<td style="text-align: right;">17</td>
<td style="text-align: left;">0.287344932556152</td>
</tr>
<tr class="even">
<td style="text-align: left;">Normal</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.163903951644897</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Normal</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">17</td>
<td style="text-align: left;">0.281584978103638</td>
</tr>
<tr class="even">
<td style="text-align: left;">Left. Trunc. Normal</td>
<td style="text-align: left;">4,998,086</td>
<td style="text-align: right;">0.6000</td>
<td style="text-align: right;">22</td>
<td style="text-align: left;">0.311450958251953</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Left. Trunc. Normal</td>
<td style="text-align: left;">4,998,086</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.165550947189331</td>
</tr>
<tr class="even">
<td style="text-align: left;">Left. Trunc. Normal</td>
<td style="text-align: left;">4,998,086</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">22</td>
<td style="text-align: left;">0.404407024383545</td>
</tr>
<tr class="odd">
<td style="text-align: left;">LogCauchy</td>
<td style="text-align: left;">4,990,828</td>
<td style="text-align: right;">0.7896</td>
<td style="text-align: right;">7</td>
<td style="text-align: left;">0.135127067565918</td>
</tr>
<tr class="even">
<td style="text-align: left;">LogCauchy</td>
<td style="text-align: left;">4,990,828</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.096325159072876</td>
</tr>
<tr class="odd">
<td style="text-align: left;">LogCauchy</td>
<td style="text-align: left;">4,990,828</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">7</td>
<td style="text-align: left;">0.105081081390381</td>
</tr>
</tbody>
</table>

``` r

# 5. Case study: Population----
library(cartography)
library(sf)
#> Warning: package 'sf' was built under R version 3.5.3
#> Linking to GEOS 3.6.1, GDAL 2.2.3, PROJ 4.9.3
library(classInt)
#> Warning: package 'classInt' was built under R version 3.5.3

nuts3 <- st_as_sf(nuts3.spdf)
nuts3 <- merge(nuts3, nuts3.df)

nrow(nuts3)
#> [1] 1448

nuts3$var <- nuts3$pop2008 / 1000 #Thousands

opar <- par(no.readonly = TRUE)
par(mar = c(3, 2.5, 2, 1))
plot(density(nuts3$var),
     main = "NUTS3 Pop2008 (thousands)",
     ylab = "",
     xlab = "")
```

![](https://i.imgur.com/F2LRsNV.png)

``` r


#benchmark
init <- Sys.time()
brks_ht <- ht_index(nuts3$var)
#> [1] "prop:0.31767955801105 nhead:460"
#> [1] "prop:0.267391304347826 nhead:123"
#> [1] "prop:0.252032520325203 nhead:31"
#> [1] "prop:0.32258064516129 nhead:10"
#> [1] "prop:0.3 nhead:3"
#> [1] "prop:0.333333333333333 nhead:1"
#> [1] "Breaks found:  6 , Intervals:"
Sys.time() - init
#> Time difference of 0.003319025 secs

init <- Sys.time()
brks_fisher <-
  classIntervals(nuts3$var, style = "fisher", n = 7)$brks
Sys.time() - init
#> Time difference of 0.05268717 secs

init <- Sys.time()
brks_kmeans <-
  classIntervals(nuts3$var, style = "kmeans", n = 7)$brks
Sys.time() - init
#> Time difference of 0.01565886 secs


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
```

![](https://i.imgur.com/nL0PS9c.png)

``` r

choroLayer(
  nuts3,
  var = "var",
  breaks = brks_fisher,
  legend.title.txt = "Fisher",
  col = cols,
  border = NA,
  legend.pos = "right"
)
```

![](https://i.imgur.com/wOYVNqG.png)

``` r

choroLayer(
  nuts3,
  var = "var",
  breaks = brks_kmeans,
  legend.title.txt = "Kmeans",
  col = cols,
  border = NA,
  legend.pos = "right"
)
```

![](https://i.imgur.com/bI7Iuxw.png)

``` r
par(opar)

print(paste0("Full running time:", Sys.time() - initrun))
#> [1] "Full running time:17.9884831905365"
```

<sup>Created on 2020-03-15 by the [reprex package](https://reprex.tidyverse.org) (v0.3.0)</sup>
