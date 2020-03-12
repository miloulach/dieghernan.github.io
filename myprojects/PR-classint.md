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
contains more than 40% of the overall observatios the distribution is not considered heavy-tailed.

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
- Loop until i = 100. As per my tests, no more than 25 iterations has been observed. See also [Tests and stress](#tests-and-stress).
- `thr` is restricted to `[0,.99)`.
- If `head` has only one value the loop stops, given that no more partitions are possible
- Another checks as `NA`, remove `class`, etc. are already implemented on `classIntervals`.


## Tests and stress


## References
- Jiang, B. (2013). "Head/tail breaks: A new classification scheme for data with a heavy-tailed distribution", *The Professional Geographer*, 65 (3), 482 – 494. https://arxiv.org/abs/1209.2801v1
- Jiang, B. Liu, X. and Jia, T. (2013). "Scaling of geographic space as a universal rule for map generalization", *Annals of the Association of American Geographers*, 103(4), 844 – 855. https://arxiv.org/abs/1102.1561v3
- Jiang, B. (2019). "A recursive definition of goodness of space for bridging the concepts of space and place for sustainability". *Sustainability*, 11(15), 4091. https://arxiv.org/abs/1909.01073v1
