---
title: Statistical Inference
author: JW
date: "2019-03-10"
slug: statistical-inference
tags:
  - R
  - statistics
  - inference
---



Hello again! In this post we're going to explore a very important statistical topic: Inference. 

When we have a problem or question we're trying to answer, it is often impractical or even impossible to gather data on the entire population (political polling data, marketing products, water quality sampling, etc...). **Statistical Inference is a process in which we make conclusions about a population based on a sample from the data.** It draws upon hypothesis testing to make these claims.

The idea behind statistical inference is to understand samples from a hypothetical population in which the Null hypothesis (H~o~), the claim that is not interesting, is true. Most of the time, the goal is to *disprove the null hypothesis* in favor of the Alternative hypothesis (H~a~), the claim corresonding to the question or problem in research.

Let's use a more concrete example. Using the `cancer.in.dogs` datset from the `openintro` package, we want to know whether exposure to the herbicide 2,4-dichlorophenoxyacetic acid (2,4-D) increased the risk of cancer in dogs.

The H~o~ is: There is no relationship between cancer in dogs and exposure to the herbicide.  
The H~a~ is: Dogs exposed to 2,4-D are more likely to have cancer than dogs not exposed to the herbicide.



```r
#load libraries
library(tidyverse)
library(openintro)

#examine the data
table(cancer.in.dogs)
```

```
##           response
## order      cancer no cancer
##   2,4-D       191       304
##   no 2,4-D    300       641
```

This is quite a simple dataset. In the next steps, we will use the `infer` package to model the Null hypothesis and randomize the data to calculate permuted statistics. Permuting the data in this fashion will ensure there is no relationship between the two variables.

## Permuting the Null Distribution


```r
#load infer package
library(infer)

#specify the model
cid_perm <- cancer.in.dogs %>%
  specify(response ~ order, success = "cancer") %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "diff in props", order = c("2,4-D", "no 2,4-D"))

#visualize the results
ggplot(cid_perm, aes(x = stat)) +
  geom_dotplot(binwidth = .001)
```

![plot of chunk unnamed-chunk-2](/figure/source/2019-03-10-statistical-inference/unnamed-chunk-2-1.png)

To summarize, we have *specified* our model terms (response ~ order), declared the *hypothesis* that null is true where response and order are not related, *permuted* the data 1000 times, and calculated the differenice in proportions for each of these permuation sets. This leaves us with the dotplot of showing the distribution of differences in proportions for each of the 1000 permutations.

Now let's calculate the difference in proportions for the actual dataset.

*Important to note, it is also possible to use other statistics, such as the ratio of the proportions, to investigate the relationship between the Null and observed statistics.*


```r
actual <- cancer.in.dogs %>%   
  # Group by 
  group_by(order) %>%
  # Summarize proportion of dogs that have cancer
  summarise(prop_cancer = mean(response == "cancer")) %>%
  #arrange the order*
  arrange(desc(order)) %>%
  # Summarize difference in proportion of dogs with cancer that were exposed vs. not exposed
  summarise(obs_diff_prop = diff(prop_cancer)) %>% # "2,4-D" - no "2,4-D"
  pull()
# See the result
actual
```

```
## [1] 0.06704881
```

**Pro Tip**
In the code above, I arranged the data so that when we took the difference in proportions, we subtract the "no 2,4-D" from "2,4-D" so that the sign is positive. Order matters! Always be sure to check. 

Finally we'll combine the permuted data with the observed data.

```r
cid_perm <- cid_perm %>%
  mutate(actual_diff = actual)

# Plot permuted differences
ggplot(cid_perm, aes(x = stat)) + 
  geom_dotplot(binwidth = .001) +
  geom_vline(aes(xintercept = actual_diff), color = "red")
```

![plot of chunk unnamed-chunk-4](/figure/source/2019-03-10-statistical-inference/unnamed-chunk-4-1.png)

```r
# Compare permuted differences to observed difference
cid_perm %>%
  summarize(sum(actual_diff <= stat))
```

```
## # A tibble: 1 x 1
##   `sum(actual_diff <= stat)`
##                        <int>
## 1                          6
```

Out of the 1000 permutations, only 6 were more extreme than our actual observation. This seems like a small really small number. If our hypothesis were really true, wouldn't we expect to see more permuted differences at or greater than our actual statistic? The data seems to be in disagreement.

## Critical Region

The *extreme* permuted differences, that is, the permuted differences which lie on the tails of the distribution under which the Null hypothesis is true, are also known as the **critical region**. We can compute these using the quantile function.


```r
#find the .9, .95, and .99 quantiles
quants <- cid_perm %>% 
  summarize(q.9 = quantile(stat, p = .9),
            q.95 = quantile(stat, p = .95),
            q.99 = quantile(stat, p = .99))

#examine the results
quants
```

```
## # A tibble: 1 x 3
##      q.9   q.95   q.99
##    <dbl>  <dbl>  <dbl>
## 1 0.0362 0.0424 0.0609
```

```r
cid_perm %>%
  summarise(count = sum(stat >= quants$q.95))
```

```
## # A tibble: 1 x 1
##   count
##   <int>
## 1    64
```

What these values tell us is how much of the Null distribution of permuted differences lies above or below the value. In other words, 95% of the Null distribution falls below the q.95 of 0.0423856 and 5% is above it.

Hypothesis testing can be one sided, or two sided. In a one-sided test, we only care about the relationship of the critical region of permuted observations and the actual observation on one of the tails. In a two-sided test, we want to capture the critical region on both tails.

So why is **.05** such a common cutoff for hypothesis testing? Well, it's actually quite arbitrary. The level of significance is a highly subjective matter which is dependent upon the researcher and the research. Whatever you choose as a signficance, the results should always lead to further investigation.

## Sample Size

The sample size has an important effect on the critical region as we will explore here. We'll create two new datasets stemming from the `cancer.in.dogs` dataset we're already familiar with. One will be a subset of the original data to show the effect small sample sizes have, and the other will be larger.


```r
# set seed for reproducibility
set.seed(455)

#create small dataset - 30% of original data
cid_small <- sample_frac(cancer.in.dogs, size = .3, replace = T)

#create large dataset - 10x larger than original data
cid_large <- sample_frac(cancer.in.dogs, size = 10, replace = T)

#examine contingency tables for each dataset
map(list(cancer.in.dogs, cid_small, cid_large), table)
```

```
## [[1]]
##           response
## order      cancer no cancer
##   2,4-D       191       304
##   no 2,4-D    300       641
## 
## [[2]]
##           response
## order      cancer no cancer
##   2,4-D        48        86
##   no 2,4-D     97       200
## 
## [[3]]
##           response
## order      cancer no cancer
##   2,4-D      1881      3045
##   no 2,4-D   2965      6469
```

As before, let's caclulate the difference in proportions for each.


```r
diff_prop_function <- function(x){
  x %>%
    group_by(order) %>%
    summarise(prop_cancer = mean(response == "cancer")) %>%
    arrange(desc(order)) %>%
    summarise(obs_diff_prop = diff(prop_cancer)) %>%
    pull()
}

#diff in proportions for small dataset
actual_small <- diff_prop_function(cid_small)

#difference in proportions for large dataset
actual_large <- diff_prop_function(cid_large)
```

Now we need to create the permuted difference in proportions for each of the datasets.


```r
permuted_diff_function <- function(x){
  x %>%
    specify(response ~ order, success = "cancer") %>%
    hypothesize(null = "independence") %>%
    generate(reps = 1000, type = "permute") %>%
   calculate(stat = "diff in props", order = c("2,4-D", "no 2,4-D"))
}

#calculate permuted difference in props for small dataset
cid_perm_small <- permuted_diff_function(cid_small)

#calculate permuted difference in props for small dataset
cid_perm_large <- permuted_diff_function(cid_large)
```

Alright! Now it's time to visualize the effect sample size has on the distribution and the critical region.


```r
x <- list(small =cid_perm_small, original = cid_perm, large = cid_perm_large)
y <- list(actual_small, actual, actual_large)

#iterate over the datasets
plots <- pmap(.l = list(x = x,y = y, z = names(x)),
     .f = function(x, y, z) ggplot(x, aes(x = stat)) +
       geom_dotplot(binwidth = 0.001) +
       geom_vline(aes(xintercept = y), color = "red") +
       labs(title = z))

#print output
walk(plots, print)
```

![plot of chunk unnamed-chunk-9](/figure/source/2019-03-10-statistical-inference/unnamed-chunk-9-1.png)![plot of chunk unnamed-chunk-9](/figure/source/2019-03-10-statistical-inference/unnamed-chunk-9-2.png)![plot of chunk unnamed-chunk-9](/figure/source/2019-03-10-statistical-inference/unnamed-chunk-9-3.png)

**As the dataset becomes larger, the likelihood of seeing the observed difference due to chance becomes smaller.**

Now let's examine the critical regions by calculating the upper quantiles for each dataset. 

```r
#quantiles function
calc_upper_quantiles <- function(dataset) {
  dataset %>% 
    summarize(
      q.9 = quantile(stat, p = 0.9),
      q.95 = quantile(stat, p = 0.95),
      q.99 = quantile(stat, p = 0.99)
    )
}

#iterate over datasets
map(x, calc_upper_quantiles)
```

```
## $small
## # A tibble: 1 x 3
##      q.9   q.95  q.99
##    <dbl>  <dbl> <dbl>
## 1 0.0641 0.0858 0.118
## 
## $original
## # A tibble: 1 x 3
##      q.9   q.95   q.99
##    <dbl>  <dbl>  <dbl>
## 1 0.0362 0.0424 0.0609
## 
## $large
## # A tibble: 1 x 3
##      q.9   q.95   q.99
##    <dbl>  <dbl>  <dbl>
## 1 0.0110 0.0138 0.0203
```

Similarly from what we saw above, the quantiles indicate that the difference in proportions must be larger to be significant if the sample size is small. As the sample size increases, the difference in proportions can be smaller to be significant. 

## p-value

Here's a brief summary of what we've learned. We have an understanding of what the distribution should look like when the Null hypothesis is True. The critical regions give us an idea of the extreme ends of the distribution and can be thought of as levels of signficance for the observed data. When our observed statistic is within the critical region it disagrees with the Null hypothesis. 

The **p-value** measures the probability of observing data as or more extreme than the actual value given the Null hypothesis were true. If the p-value is less than critical value (.05 or whatever arbitrary level you set), we must reject the Null hypothesis.

Here, it is simply the number permuted differences greater than or equal to the actuall difference, divided by the total number ob observations. 

```r
#calculate p-value
(p_value <- cid_perm %>%
  summarize(p_value = sum(actual_diff <= stat)))
```

```
## # A tibble: 1 x 1
##   p_value
##     <int>
## 1       6
```
We can visualize this:

```r
ggplot(cid_perm, aes(x=stat)) +
  geom_rect(aes(xmin = quants$q.95, xmax = Inf, ymin =0, ymax = Inf, fill = "critical region"), alpha = 0.5) +
  geom_dotplot(binwidth = 0.001) +
  geom_vline(aes(xintercept = actual_diff, linetype = "observed statistic")) +
  scale_fill_manual("", values = "salmon") +
  scale_linetype_manual("sig.level = 0.95", values = 2)
```

![plot of chunk unnamed-chunk-12](/figure/source/2019-03-10-statistical-inference/unnamed-chunk-12-1.png)

In the even that the Null hypothesis were true, the probability of seeing a value as or more extreme than the observed statistic is .008 which falls below the critical value of .05. Therefore we must reject the Null hypothesis. 

**There is evidence to suggest that cancer rates in dogs is higher when exposed to 2,4-D compared to dogs not exposed to 2,4-D. We should not rely on the results of this data alone to generalize about the population at large. Further investigation is warranted.**

## Hypothesis Testing: Errors & Consequences

Hypothesis testing is not perfect and our conclusions could in fact be wrong. Let's examine the types of errors as a result of our conclusions and the potential consequences they may have.

Type 1 Error: Rejecting the H~o~ in favor of H~A~ when in fact the H~o~ is **TRUE**  
* This type of error is also known as a **False Positive**

With respect to our dataset, a false positive would be accepting the alternative hypothesis, that cancer rates are higher in dogs exposed to the herbicide, when in fact there is no difference between dogs exposed and dogs not exposed. 

Type 2 Error: Not rejecting the H~o~ when in fact the H~A~ is **TRUE**  
* This is called **FALSE Negative Rate** and is what we typically want to avoid in most cases.

With respect to our dataset, a false negative would be failing to reject the null hypothesis, that there is no difference between dogs exposed and not exposed, when in fact there is a difference. 

Type 1 and Type 2 error are important to think about when it comes to hypothesis testing and can be adjusted based on the confidence level you set. This may or may not be useful depending on the problem you are trying to solve.

That's it for statistical inference for now. Stay tuned for **part 2** where I'll dive into estimation problems and confidence intervals. Thanks for reading!

---
