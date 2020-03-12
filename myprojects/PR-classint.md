# Head/Tails breaks

As an introductory remark, this method corresponds to "Head/tail breaks 1.0" [Jiang (2019)]. On that paper an 2.0 algorithm with 
more relaxed conditions is presented.

- [Motivation](#motivation)
- [Breaking method](#breaking-method)
- [Step by step example](#step-by-step)
- [Standalone version](#standalone-version)
- [Tests and stress](#tests-and-stress)
- Case study
- [References](#references)

## Motivation
[*Taken from of Jiang (2013)* - brief summary]

*"This paper introduces a new classification scheme – head/tail breaks – in order to find groupings or
hierarchy for data with a heavy-tailed distribution. The heavy-tailed distributions are heavily right
skewed, with a minority of large values in the head and a majority of small values in the tail,
commonly characterized by a power law, a lognormal or an exponential function." (...)*

*"The heavy-tailed distribution is commonly found in many societal and
natural phenomena, including geographical systems. Small events are far more common in geographic
spaces than large events (Jiang 2010), particularly in urban, architectural environments (Salingaros
and West 1999, Jiang 2009). For example, there are far more small cities than large ones (Zipf 1949);
far more short streets than long ones (Jiang 2009); far more small city blocks than large ones, and far
more low-density areas than high-density ones (Jiang and Liu 2011). This is the pattern that underlies
geographic spaces and which should be reflected in the map. "*


## Breaking method

The method itself consists on a four-step process performed recursively until a stopping condition is satisfied:
1. Compute the `mean` of a range of values `values`.
2. Break `values` into the `tail` (as `values <= mean`) and the `head` (as `values > mean`).
3. Assess it the proportion of `head` over `var` is lower or equal than a given thresold (i.e. `length(head)/length(var) <= thresold`)
4. If 3 is `TRUE`, repeat 1 to 3 until the condition is `FALSE` or no more partitions are posible (i.e. `length(head) < 2`). 

It is importat to note that, at the beginning of a new iteration, `values` are replaced by `head`. 
The underlying hypothesis is to create partitions until the `head` and the `tail` are balanced in terms of distribution.
So the stopping criteria is satisfy when the last `head` and the last `tail` are evenly balanced. 

In terms of thresold, Jiang et al. (2013) set 40% as a good approximation, meaning that if the `head` 
contains more than 40% of the overall observatios the distribution is not considered heavy-

The final breaks are the vector of `mean` values.

## Step by step
Pseudo-code as per Jiang (2019):
```
Recursive function Head/tail Breaks:
 Rank the input data from the largest to the smallest
 Break the data into the head and the tail around the mean;
 // the head for those above the mean
 // the tail for those below the mean
 While (head <= 40%):
 Head/tail Breaks (head);
End Function
```

My example in **R** (for illustrative purposes):
```r
#1. Characterization of heavy-tail distributions----
set.seed(1234)
#Pareto distributions a=2 b=6 n=1000
sample_par <- 2 / (1 - runif(1000)) ^ (1 / 6)
```
![Imgur](https://i.imgur.com/LdrU73P.png)

``` r
set.seed(1234)
sample_par <- 2 / (1 - runif(1000)) ^ (1 / 6)
var <- sample_par
ht_thresold <- 0.35 #Cherry-picked value for the example

#Step1
mu0 <- mean(var)
#The breaks are the means of the head
breaks <- c(mu0)
n0 <- length(var)
head0 <- var[var > mu0]
prop0 <- length(head0) / n0

prop0 <= ht_thresold &
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

prop1 <= ht_thresold  & n1 > 1
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
summiter
#>   iter    n nhead       mu  prophead   breaks
#> 1    1 1000   316 2.422568 0.3160000 2.422568
#> 2    2  316   118 2.971249 0.3734177 2.971249
```

<sup>Created on 2020-03-12 by the [reprex package](https://reprex.tidyverse.org) (v0.3.0)</sup>


## Standalone version

This is the function to be implemented. Comments are likely to be removed.

``` r
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
#> [1] "loop end on  2"
#> [1] 2.000114 2.422568 2.971249 6.716770
```

Some inline checks:
- Loop until `i == 100`. As per my tests, no more than 25 iterations has been observed. See also [Tests and stress](#tests-and-stress).
- `thr` is restricted to `[0,.99)`.
- If `head` has only one value the loop stops, given that no more partitions are possible
- Another checks as `NA`, remove `class`, etc. are already implemented on `classIntervals`.


## Tests and stress

Testing has been performed over the next distributions:
- Pareto
- Exponential
- Lognormal
- Weibull
- Normal (non heavy-tailed)
- Truncated Normal (left-tailed)

With sample = 5,000,000 observations. Corner cases of the thresold (i.e. 0,1) has been already tested.

``` r
#Replicate Phyton Results: https://github.com/chad-m/head_tail_breaks_algorithm/blob/master/htb.py
#[0.03883742394002349, 0.177990388624465, 0.481845351678573]
pareto_data <- (1.0 / (1:100)) ^ 1.16
ht_index(pareto_data)
#> [1] "loop end on  3"
#> [1] 0.004786301 0.038496913 0.177990389 0.481845352 1.000000000

benchmarkdist <- function(dist, thr = 0.4, title = "") {
  init <- Sys.time()
  print(ht_index(dist, thr))
  print(Sys.time() - init)
  
  # plot(density(dist),
  #      col = "black",
  #      main = paste0(title, ", thresold =", thr))
  # abline(
  #   v = ht_index(dist, thr),
  #   col = "red",
  #   lwd = 0.1,
  #   lty = 3
  # )
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
#> [1] "loop end on  13"
#>  [1]   6820.000   9093.952  12124.357  16165.270  21571.695  28767.257
#>  [7]  38436.768  51088.167  67879.008  91746.599 125188.317 172521.591
#> [13] 229993.456 316853.432 477990.582
#> Time difference of 0.1835082 secs

#Exponential dist
expdist <- rexp(5000000)
expdist <- c(expdist, rep(max(expdist), 10))

benchmarkdist(expdist, 0.1, title = "Exp. Dist")
#> [1] "loop end on  1"
#> [1] 2.486631e-07 9.995408e-01 1.631739e+01
#> Time difference of 0.1386671 secs

#Lognorm
lognormdist = rlnorm(5000000)
benchmarkdist(lognormdist, 1, title = "LogNorm. Dist")
#> [1] "loop end on  14"
#>  [1] 6.684409e-03 1.647543e+00 3.693586e+00 6.541647e+00 1.037160e+01
#>  [6] 1.538579e+01 2.179592e+01 2.978306e+01 3.980027e+01 5.197645e+01
#> [11] 6.658526e+01 8.343420e+01 1.029956e+02 1.270295e+02 1.422536e+02
#> [16] 1.511637e+02
#> Time difference of 0.169544 secs

#Weibull
weibulldist <- rweibull(5000000, 1, scale = 5)
benchmarkdist(weibulldist, title = "Weibull Dist")
#> [1] "loop end on  14"
#>  [1] 4.773028e-08 4.997080e+00 9.988719e+00 1.497475e+01 1.995891e+01
#>  [6] 2.495467e+01 2.992018e+01 3.487687e+01 3.981749e+01 4.459098e+01
#> [11] 4.939545e+01 5.400467e+01 5.847783e+01 6.302199e+01 6.661435e+01
#> [16] 7.160648e+01
#> Time difference of 0.1406569 secs

#Stress params
stress(pareto_data)
#> [1] "loop end on  1"
#> [1] "loop end on  3"
#> [1] 0.004786301 0.038496913 0.177990389 0.481845352 1.000000000
stress(paretodist)
#> [1] "loop end on  1"
#> [1] "loop end on  13"
#>  [1]   6820.000   9093.952  12124.357  16165.270  21571.695  28767.257
#>  [7]  38436.768  51088.167  67879.008  91746.599 125188.317 172521.591
#> [13] 229993.456 316853.432 477990.582
stress(expdist)
#> [1] "loop end on  1"
#> [1] "loop end on  14"
#>  [1] 2.486631e-07 9.995408e-01 1.999083e+00 2.998493e+00 4.001795e+00
#>  [6] 5.005521e+00 6.017519e+00 7.035013e+00 8.060190e+00 9.119188e+00
#> [11] 1.019895e+01 1.136452e+01 1.277005e+01 1.510582e+01 1.631739e+01
stress(lognormdist)
#> [1] "loop end on  1"
#> [1] "loop end on  14"
#>  [1] 6.684409e-03 1.647543e+00 3.693586e+00 6.541647e+00 1.037160e+01
#>  [6] 1.538579e+01 2.179592e+01 2.978306e+01 3.980027e+01 5.197645e+01
#> [11] 6.658526e+01 8.343420e+01 1.029956e+02 1.270295e+02 1.422536e+02
#> [16] 1.511637e+02
stress(weibulldist)
#> [1] "loop end on  1"
#> [1] "loop end on  16"
#>  [1] 4.773028e-08 4.997080e+00 9.988719e+00 1.497475e+01 1.995891e+01
#>  [6] 2.495467e+01 2.992018e+01 3.487687e+01 3.981749e+01 4.459098e+01
#> [11] 4.939545e+01 5.400467e+01 5.847783e+01 6.302199e+01 6.661435e+01
#> [16] 6.855436e+01 7.081544e+01 7.160648e+01


#Normal dist
normdist = rnorm(5000000)
benchmarkdist(normdist, 0.6, "Normal Dist")
#> [1] "loop end on  17"
#>  [1] -5.0373191567  0.0005166999  0.7983615140  1.3657739096  1.8256670096
#>  [6]  2.2190576389  2.5692628610  2.8878631323  3.1838275736  3.4504796429
#> [11]  3.6949205381  3.9246131539  4.1492496932  4.3632993992  4.5360134288
#> [16]  4.6950124892  4.8831922325  4.9516708017  4.9980740048
#> Time difference of 0.2284279 secs

#Left-tailed distr
leftnorm <- rep(normdist[normdist < mean(normdist)], 2)
benchmarkdist(leftnorm, 0.6, "Trunc. Left,Normal Dist")
#> [1] "loop end on  22"
#>  [1] -5.0373191567 -0.7973900293 -0.3776998664 -0.1863121654 -0.0926179210
#>  [6] -0.0459554421 -0.0227232437 -0.0110984378 -0.0053195395 -0.0024291369
#> [11] -0.0009759062 -0.0002398865  0.0001317035  0.0003275021  0.0004247355
#> [16]  0.0004730943  0.0004936848  0.0005045994  0.0005097279  0.0005129480
#> [21]  0.0005141381  0.0005152212  0.0005153094
#> Time difference of 0.295208 secs

# On non skewed or left tails thresold should be stressed beyond 50%, otherwise just the first iter (i.e. min, mean, max) is returned.
```


## References
- Jiang, B. (2013). "Head/tail breaks: A new classification scheme for data with a heavy-tailed distribution", *The Professional Geographer*, 65 (3), 482 – 494. https://arxiv.org/abs/1209.2801v1
- Jiang, B. Liu, X. and Jia, T. (2013). "Scaling of geographic space as a universal rule for map generalization", *Annals of the Association of American Geographers*, 103(4), 844 – 855. https://arxiv.org/abs/1102.1561v3
- Jiang, B. (2019). "A recursive definition of goodness of space for bridging the concepts of space and place for sustainability". *Sustainability*, 11(15), 4091. https://arxiv.org/abs/1909.01073v1
