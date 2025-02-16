---
title: Visualizing Data in R with ggplot2 (Part 3)
author: JW
date: '2018-11-29'
slug: visualizind-data-in-r-with-ggplot2-part-3
categories:
  - R Programming
tags:
  - data visualization
  - '2018'
published: true
---


## This is the final part of the series on data visualization using the popular ggplot2 package. 

**For more on data viz, get an introduction to ggplot2 in [part 1](https://jpwalker625.github.io/r/visualization/2018/11/26/visualizing-data-in-r-with-ggplot2-part-1) or expand your knowledge in [part 2!](https://jpwalker625.github.io/r/visualization/2018/11/27/visualizing-data-in-r-with-ggplot2-part-2)**

## Part 3

In **part 1** of this series, we explored the fundamentals of `ggplot2`. We learned about the **grammar of graphics** beginning with **data, aesthetics, and geometries.** 

In **part 2**, we extended our understanding of data visaluzation by learning about additional graphical elements including: **statistics, coordinates, facets, and themes.** We even learned some best practices along the way. 

In this final chapter, we will explore plots intended for a specialty audience. We will also learn about plots for specific data types such as **ternary plots, networks and maps.**

Before we dive in, let's load the required packages.

```r
# load required packages
library(forcats)
library(geomnet)
library(ggfortify)
library(ggplot2movies) #for datasets
library(ggtern)
library(reshape2)
library(stringr)
library(tidyverse)
```

## Statistical Plots for an Academic Audience

There are two common types of plots presented to an academic audience: Box plots and Density plots.

### Box Plots

Box plots were first described by John Tukey in 1977 in his classic text, 'Exploratory Data Analysis'. The Box Plot gives us what Tukey describes as the 5 number summary:

* minimum
* 1st quartile 
* 2nd quartile (the median)
* 3rd quartile
* maximum

This is advantageous over using the mean and standard deviation for data sets that may not be normally distributed and prone to extreme outliers. 

The **inner quartile range** is the difference between the 3rd and 1st quartiles, or what we commonly see as the box in a box plot.

The following examples use the `movies` dataset from the `ggplot2movies` package.


```r
# examine the dataset
str(movies)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	58788 obs. of  24 variables:
##  $ title      : chr  "$" "$1000 a Touchdown" "$21 a Day Once a Month" "$40,000" ...
##  $ year       : int  1971 1939 1941 1996 1975 2000 2002 2002 1987 1917 ...
##  $ length     : int  121 71 7 70 71 91 93 25 97 61 ...
##  $ budget     : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ rating     : num  6.4 6 8.2 8.2 3.4 4.3 5.3 6.7 6.6 6 ...
##  $ votes      : int  348 20 5 6 17 45 200 24 18 51 ...
##  $ r1         : num  4.5 0 0 14.5 24.5 4.5 4.5 4.5 4.5 4.5 ...
##  $ r2         : num  4.5 14.5 0 0 4.5 4.5 0 4.5 4.5 0 ...
##  $ r3         : num  4.5 4.5 0 0 0 4.5 4.5 4.5 4.5 4.5 ...
##  $ r4         : num  4.5 24.5 0 0 14.5 14.5 4.5 4.5 0 4.5 ...
##  $ r5         : num  14.5 14.5 0 0 14.5 14.5 24.5 4.5 0 4.5 ...
##  $ r6         : num  24.5 14.5 24.5 0 4.5 14.5 24.5 14.5 0 44.5 ...
##  $ r7         : num  24.5 14.5 0 0 0 4.5 14.5 14.5 34.5 14.5 ...
##  $ r8         : num  14.5 4.5 44.5 0 0 4.5 4.5 14.5 14.5 4.5 ...
##  $ r9         : num  4.5 4.5 24.5 34.5 0 14.5 4.5 4.5 4.5 4.5 ...
##  $ r10        : num  4.5 14.5 24.5 45.5 24.5 14.5 14.5 14.5 24.5 4.5 ...
##  $ mpaa       : chr  "" "" "" "" ...
##  $ Action     : int  0 0 0 0 0 0 1 0 0 0 ...
##  $ Animation  : int  0 0 1 0 0 0 0 0 0 0 ...
##  $ Comedy     : int  1 1 0 1 0 0 0 0 0 0 ...
##  $ Drama      : int  1 0 0 0 0 1 1 0 1 0 ...
##  $ Documentary: int  0 0 0 0 0 0 0 1 0 0 ...
##  $ Romance    : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ Short      : int  0 0 1 0 0 0 0 1 0 0 ...
```

```r
# gather the movie genre into one column
movies <- movies %>% gather(key = 'genre', value = 'value', -c(1:17))

# convert mpaa to factor
movies$mpaa <- as_factor(movies$mpaa)

# relabel movies not rated with 'N/A'
movies$mpaa <- fct_recode(movies$mpaa, 'N/A' = "")

# set seed for reprducibility
set.seed(123)

# sample the movies dataset
movie_sample <- movies[sample(nrow(movies), 10001), ]

# factor the ratings variable and round to the nearest whole number
movie_sample$rating <- factor(round(movie_sample$rating))

# create a boxplot object
p <- ggplot(movie_sample, aes(x = rating, y = votes, group = rating)) +
  geom_point() +
  geom_boxplot() +
  stat_summary(fun.data = "mean_cl_normal",
               geom = "crossbar",
               width = 0.2,
               col = "red")

# boxplot
p
```

![plot of chunk unnamed-chunk-2](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-2-1.png)

There is a large number of votes for rating. We will need to make some transformations on the data. Be careful as the tranformation will occur differently depending on how you call your stat functions and arguments.


```r
# transformation happens before statistics are calculated
p + scale_y_log10()  
```

![plot of chunk unnamed-chunk-3](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-3-1.png)

```r
# transformation happens after the statistics are calculated
p + coord_trans(y = "log10")
```

![plot of chunk unnamed-chunk-3](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-3-2.png)

It is possible to cut up continuous variables into ordinal variables using the following functions which `cut` the data.
  
`cut_interval(x, n)` makes n groups from vector x with equal range.  
`cut_number(x, n)` makes n groups from vector x with (approximately) equal numbers of observations.  
`cut_width(x, width)` makes groups of width width from vector x.  


```r
# create plot object from movies sample dataset
p <- ggplot(movie_sample, aes(x = year, y = budget)) + scale_y_log10(labels = scales::dollar)

# examine the plot
p + geom_point()
```

![plot of chunk unnamed-chunk-4](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-4-1.png)

```r
# use cut_interval to divide year into  sections with equal range
#every 25 years or so
p + geom_boxplot(aes(group = cut_interval(year, n = 5)))
```

![plot of chunk unnamed-chunk-4](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-4-2.png)

```r
# use cut_number function to divide year into groups with approximately equal number of observations
# reveals that we do not have budget records for the early part of the 20th century
p + geom_boxplot(aes(group = cut_number(year, n = 5)))
```

![plot of chunk unnamed-chunk-4](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-4-3.png)

```r
# use cut_width to make group of specified width
# .e. decades
p + geom_boxplot(aes(group = cut_width(year, width = 10)))
```

![plot of chunk unnamed-chunk-4](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-4-4.png)

One drawback of the box plot visualization is that you don't have any indication of the sample size for each group. One way of showing this variation is to use the `varwidth` argument.


```r
# create plot object using movie_sample dataset
p <- ggplot(movie_sample, aes(x = mpaa, y= budget)) + scale_y_log10(labels = scales::dollar)

# view plot object with boxplot and adjust the widths of the boxes based on the sample size
p + geom_boxplot(varwidth = T)
```

![plot of chunk unnamed-chunk-5](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-5-1.png)

And just so we can confirm this argument is doing what we expect it to, we can check the math manually.

```r
movie_sample %>%
  group_by(mpaa) %>%
  summarize(count = n()) %>%
  knitr::kable(align = 'c')
```



| mpaa  | count |
|:-----:|:-----:|
|  N/A  | 9107  |
|   R   |  594  |
| PG-13 |  194  |
|  PG   |  103  |
| NC-17 |   3   |


### Density Plots

Theoretical density plots use the probability density function (PDF) to plot the distribution of univariate data. You have certainly seen these types of plots before. They include: normal, t, chi-squared, and F distributions. 

Empirical density plots use real data using the Kernal Density Estimate.

The KDE is defined as:

> A sum of 'bumps' placed at the observations. The kernel function determines the shape of the bumps while the window width, h, determines their width. 

The KDE calculates a normal distribution for each value in the data. These are known as the bumps.

To obtain the true density curve, we simply add up all the y-values for each bump along our x-axis.

The following examples use the `quakes` data from the base r datasets packag. We will be examining the distribution of the magnitudes of quakes measured near Fiji since 1964.

```r
# examine the density of the magnitudes
(d <- density(quakes$mag))
```

```
## 
## Call:
## 	density.default(x = quakes$mag)
## 
## Data: quakes$mag (1000 obs.);	Bandwidth 'bw' = 0.09105
## 
##        x               y            
##  Min.   :3.727   Min.   :0.0000497  
##  1st Qu.:4.463   1st Qu.:0.0196331  
##  Median :5.200   Median :0.1868643  
##  Mean   :5.200   Mean   :0.3390539  
##  3rd Qu.:5.937   3rd Qu.:0.6270866  
##  Max.   :6.673   Max.   :1.0294696
```

```r
# calculate the mode of the density distribution of quake magnitudes
(mode <- d$x[which.max(d$y)])
```

```
## [1] 4.510986
```

```r
# visualize the desnity distribution
ggplot(quakes, aes(x = mag)) +
  geom_rug() +
  geom_density() +
  geom_vline(xintercept = mode, col = "red")
```

![plot of chunk unnamed-chunk-7](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-7-1.png)

There are three parameters that you may be tempted to adjust in a density plot:

- bw - the smoothing bandwidth to be used, see ?density for details  
- adjust - adjustment of the bandwidth, see density for details 
- kernel - kernel used for density estimation, defined as: 

* "g" = gaussian 
* "r" = rectangular 
* "t" = triangular 
* "e" = epanechnikov 
* "b" = biweight 
* "c" = cosine 
* "o" = optcosine


```r
# first lets get the bandwidth
(get_bw <- d$bw)
```

```
## [1] 0.0910548
```

```r
# create default plotting object
p <- ggplot(quakes, aes(x = mag)) +
  geom_rug()

# basic density plot
p + geom_density()
```

![plot of chunk unnamed-chunk-8](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-8-1.png)

```r
# adjust the bandwidth 2 different ways
p + geom_density(bw = 0.25 * get_bw, color = 'red')
```

![plot of chunk unnamed-chunk-8](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-8-2.png)

```r
p +  geom_density(adjust = 0.25)
```

![plot of chunk unnamed-chunk-8](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-8-3.png)

```r
# adjust the kernel
p + geom_density(kernel = "r")
```

![plot of chunk unnamed-chunk-8](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-8-4.png)

## Plots for Specific Data Types

### Scatter Plot Matrices

How do you define largenesss of a data set? Many observations? Many variables? A combination of both?

Base R provides a quick and dirty function, `pairs()` that will output a scatterplot matrix, or SPLOM. This function will only work for continuous variables.


```r
pairs(iris[1:4])
```

![plot of chunk unnamed-chunk-9](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-9-1.png)

This can also be done in `ggplot2`


```r
cor_list <- function(x) {
  L <- M <- cor(x)
  
  M[lower.tri(M, diag = TRUE)] <- NA
  M <- melt(M)
  names(M)[3] <- "points"
  
  L[upper.tri(L, diag = TRUE)] <- NA
  L <- melt(L)
  names(L)[3] <- "labels"
  
  merge(M, L)
}

# Calculate xx with cor_list
xx <- iris %>%
  group_by(Species) %>%
  do(cor_list(.[1:4])) 

# Finish the plot
ggplot(xx, aes(x = Var1, y = Var2)) +
  geom_point(aes(col = points, size = abs(points)), shape = 16) +
  geom_text(aes(col = labels,  size = abs(labels), label = round(labels, 2))) +
  scale_size(range = c(0, 6)) +
  scale_color_gradient2("r", limits = c(-1, 1)) +
  scale_y_discrete("", limits = rev(levels(xx$Var1))) +
  scale_x_discrete("") +
  guides(size = FALSE) +
  geom_abline(slope = -1, intercept = nlevels(xx$Var1) + 1) +
  coord_fixed() +
  facet_grid(. ~ Species) +
  theme(axis.text.y = element_text(angle = 45, hjust = 1),
        axis.text.x = element_text(angle = 45, hjust = 1),
        strip.background = element_blank()) 
```

![plot of chunk unnamed-chunk-10](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-10-1.png)

### Ternary Plot

A **Ternary plot**, also known as a triangle plot, can be used for compositional trivariate data. This means that the variables add up to 100%. 

You could visualize this type of data with a stacked bar plot, but the ternary plot is better suited for comparing the different compositions.

The following example uses the `USDA` data set, providing textural classification data of land samples.

```r
# load dataset from the ggtern package
data("USDA")

# examine the USDA data set
str(USDA)
```

```
## 'data.frame':	53 obs. of  4 variables:
##  $ Clay : num  1 0.55 0.4 0.4 0.6 0.55 0.35 0.35 0.35 0.2 ...
##  $ Sand : num  0 0.45 0.45 0.2 0 0.45 0.65 0.45 0.65 0.8 ...
##  $ Silt : num  0 0 0.15 0.4 0.4 0 0 0.2 0 0 ...
##  $ Label: Factor w/ 12 levels "Clay","Sandy Clay",..: 1 1 1 1 1 2 2 2 3 3 ...
```

```r
# create ID column
USDA$ID <- row.names(USDA)

# tidy USDA to long format
USDA_long <- gather(USDA, key, value, -c(Label, ID))

# create stacked bar plot to depict data
ggplot(USDA_long, aes(x = ID, y = value, fill = key))+
  geom_col() +
  coord_flip()
```

![plot of chunk unnamed-chunk-11](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-11-1.png)

This is a an acceptable plot to represent the composition of soil for each sample. But suppose we wanted to use a ternary plot to visaulize this.

The ternary plot works like this:


```r
DATA <- data.frame(x = c(1,0,0),
                   y = c(0,1,0),
                   z = c(0,0,1),
                   xend = c(0,.5,.5),
                   yend = c(.5,0,.5),
                   zend = c(.5,.5,0),
                   Series = c("yz","xz","xy"))
ggtern(data=DATA,aes(x,y,z,xend=xend,yend=yend,zend=zend)) + 
  geom_segment(aes(color=Series),size=1) +
  scale_color_manual(values=c("darkgreen","darkblue","darkred")) +
  theme_bw() + theme_nogrid() + 
  theme(legend.position=c(0,1),legend.justification=c(0,1)) + 
  labs(title = "Sample Midpoint Segments")
```

![plot of chunk unnamed-chunk-12](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-12-1.png)

And with the USDA soil dataset,


```r
# create ternary diagram plot object
p <- ggtern(USDA, aes(x = Sand, y = Silt, z = Clay))

# plot points on ternary plot
p + geom_point() 
```

![plot of chunk unnamed-chunk-13](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-13-1.png)

The `ggtern` package is compatible with `ggplot2` functionality to create ternary plots.

As we saw in previous examples, we can combine 2d density plots and other types of visualizations with the ternary plot.


```r
p +
  stat_density_tern(geom = 'polygon', aes(fill = ..level.., alpha = ..level..))+
  guides(alpha = F)
```

![plot of chunk unnamed-chunk-14](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-14-1.png)

### Network Plot

Visualizing relationships between factors in a variable.

For this, we will need the `geomnet` package. 

The following examples use the `madmen` dataset from the geomnet library.


```r
str(madmen)
```

```
## List of 2
##  $ edges   :'data.frame':	39 obs. of  2 variables:
##   ..$ Name1: Factor w/ 9 levels "Betty Draper",..: 1 1 2 2 2 2 2 2 2 2 ...
##   ..$ Name2: Factor w/ 39 levels "Abe Drexler",..: 15 31 2 4 5 6 8 9 11 21 ...
##  $ vertices:'data.frame':	45 obs. of  2 variables:
##   ..$ label : Factor w/ 45 levels "Abe Drexler",..: 5 9 16 23 26 32 33 38 39 17 ...
##   ..$ Gender: Factor w/ 2 levels "female","male": 1 2 2 1 2 1 2 2 2 2 ...
```

```r
# merge the edges and vertices datasets
mmnet <- full_join(madmen$edges, madmen$vertices, by = c('Name1' = 'label'))


# plot the relationship
ggplot(mmnet, aes(from_id = Name1, to_id = Name2, col = Gender )) +
  geom_net(labelon = T, 
           size = 6, 
           fontsize = 3, 
           labelcolour = 'black', 
           linewidth = 1,
           directed = T) +
  theme_void() +
  xlim(c(-.5, 1.05))
```

![plot of chunk unnamed-chunk-15](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-15-1.png)


### Diagnostic Plots

Can be used to assess how well the fit of a model is. The base R function `plot` will display 4 plots based on the model you use in your call to the function. 

Here's an examples using the `trees` dataset from the `stats` package (default package loaded on startup).


```r
# examine the trees dataset
str(trees)
```

```
## 'data.frame':	31 obs. of  3 variables:
##  $ Girth : num  8.3 8.6 8.8 10.5 10.7 10.8 11 11 11.1 11.2 ...
##  $ Height: num  70 65 63 72 81 83 66 75 80 75 ...
##  $ Volume: num  10.3 10.3 10.2 16.4 18.8 19.7 15.6 18.2 22.6 19.9 ...
```

```r
# create a linear model object
res <- lm(Volume ~ Girth, data = trees)

# display diagnostic plots of the model
plot(res)
```

![plot of chunk unnamed-chunk-16](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-16-1.png)![plot of chunk unnamed-chunk-16](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-16-2.png)![plot of chunk unnamed-chunk-16](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-16-3.png)![plot of chunk unnamed-chunk-16](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-16-4.png)

We can achieve similar results in ggplot2 using the `ggfortify` package. This package converts funcitons between the base R plot `graphics` and `ggplot2` using the `grid` graphics.


```r
autoplot(res, ncol = 2)
```

![plot of chunk unnamed-chunk-17](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-17-1.png)

Autoplot works with time series as well!


```r
# examine the EUStockMarkets timeseires dataset
str(EuStockMarkets)
```

```
##  Time-Series [1:1860, 1:4] from 1991 to 1999: 1629 1614 1607 1621 1618 ...
##  - attr(*, "dimnames")=List of 2
##   ..$ : NULL
##   ..$ : chr [1:4] "DAX" "SMI" "CAC" "FTSE"
```

```r
autoplot(datasets::EuStockMarkets)
```

![plot of chunk unnamed-chunk-18](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-18-1.png)

### Distance Matrices and Multi Dimensional Scaling (MDS)

The cmdscale() function from the stats package performs Classical Multi-Dimensional Scaling and returns point coodinates as a matrix. Although autoplot() will work on this object, it will produce a heatmap, and not a scatter plot. However, if either eig = TRUE, add = TRUE or x.ret = TRUE is specified, cmdscale() will return a list instead of matrix. In these cases, the list method for autoplot() in the ggfortify package can deal with the output.


```r
# examine the eurodist dataset
str(eurodist)
```

```
## Class 'dist'  atomic [1:210] 3313 2963 3175 3339 2762 ...
##   ..- attr(*, "Size")= num 21
##   ..- attr(*, "Labels")= chr [1:21] "Athens" "Barcelona" "Brussels" "Calais" ...
```

```r
# Autoplot + ggplot2 tweaking
autoplot(eurodist) + 
  coord_fixed()
```

![plot of chunk unnamed-chunk-19](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-19-1.png)

```r
# Autoplot of MDS
autoplot(cmdscale(eurodist, eig = TRUE), 
         label = TRUE, 
         label.size = 3, 
         size = 0)
```

![plot of chunk unnamed-chunk-19](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-19-2.png)

### K-Means Clustering
ggfortify also supports stats::kmeans class objects. You must explicitly pass the original data to the autoplot function via the data argument, since kmeans objects don't contain the original data. The result will be automatically colored according to cluster.


```r
# Perform clustering
iris_k <- kmeans(iris[-5], 3)

# Autoplot: color according to cluster
autoplot(iris_k, data = iris, frame = TRUE)
```

![plot of chunk unnamed-chunk-20](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-20-1.png)

```r
# Autoplot: above, plus shape according to species
autoplot(iris_k, data = iris, frame = TRUE, shape = 'Species')
```

![plot of chunk unnamed-chunk-20](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-20-2.png)

## Maps

Many people are turning to R as a mapping tools for Geogrpahic Information Systems (GIS). There are different types of maps, including:

* Choropleths - drawing a bunch of polygons 
* Cartographic Maps


### Choropleths

The `maps` package is the easiest way to obtain map polygons, although, there are only a few locations available. 

The available maps of political boundaries are:

* Global: world, world2  
* Country: france, italy, nz, usa  
* USA: county, state  

The maps can be accessed via `map_data()` from the  `ggplot2` package, which converts the map into a data frame containing the variables long and lat. To draw the map, you need to use `geom_polygon()` which will connect the points of latitude and longitude for you.


```r
# create map object using the map_data function
state <- map_data(map = "state")

# examine usa data
str(state)
```

```
## 'data.frame':	15537 obs. of  6 variables:
##  $ long     : num  -87.5 -87.5 -87.5 -87.5 -87.6 ...
##  $ lat      : num  30.4 30.4 30.4 30.3 30.3 ...
##  $ group    : num  1 1 1 1 1 1 1 1 1 1 ...
##  $ order    : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ region   : chr  "alabama" "alabama" "alabama" "alabama" ...
##  $ subregion: chr  NA NA NA NA ...
```

```r
# build the map
ggplot(state, aes(x = long, y = lat, group = group)) +
  geom_polygon(color = "white") +
  coord_map() +
  theme_void()
```

![plot of chunk unnamed-chunk-21](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-21-1.png)

Let's add some information to our map. We will use the `us.cities` dataset from the `maps` package


```r
# load require package
library(maps)

# exmaine the dataset
str(us.cities)
```

```
## 'data.frame':	1005 obs. of  6 variables:
##  $ name       : chr  "Abilene TX" "Akron OH" "Alameda CA" "Albany GA" ...
##  $ country.etc: chr  "TX" "OH" "CA" "GA" ...
##  $ pop        : int  113888 206634 70069 75510 93576 45535 494962 44933 127159 88857 ...
##  $ lat        : num  32.5 41.1 37.8 31.6 42.7 ...
##  $ long       : num  -99.7 -81.5 -122.3 -84.2 -73.8 ...
##  $ capital    : int  0 0 0 0 2 0 0 0 0 0 ...
```

```r
# filter out Alaska and Hawaii
us.cities <- us.cities %>% filter(!country.etc %in% c('HI', 'AK'))

# build the map with data from the us.cities dataframe
p <- ggplot(state, aes(x = long, y = lat, group = group)) +
  geom_polygon(color = 'black', fill = 'grey90') +
  coord_map() +
  theme_void()

# display map with city pop info as points  
p + geom_point(data = us.cities, 
             aes(group = country.etc, col = pop),
             size = 1.2, alpha = 0.5) +
  scale_color_distiller(palette = 'Spectral')
```

![plot of chunk unnamed-chunk-22](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-22-1.png)

### Cartographic Maps

Topographical and/or Photographic Maps

Using the `ggmap`[^1] package, we can use the `get_map()` function to access various maps, such as those offered by google. The only essential argument is `location`, however, there are many other options which you can specify.


```r
# load required package
library(ggmap)

houston <- get_map(location = "Houston, Texas", source = "stamen", maptype = "toner")
```

```
## Error in download.file(url, destfile = tmp, quiet = !messaging, mode = "wb"): cannot open URL 'http://maps.googleapis.com/maps/api/staticmap?center=Houston,+Texas&zoom=10&size=640x640&scale=2&maptype=terrain&sensor=false'
```

```r
# plot location using ggmap
ggmap(houston)
```

```
## Error in ggmap(houston): object 'houston' not found
```

Similar to choropleths, we can map points onto a cartographic map. Using the houston map from above, we can map the `crime` dataset from the `ggmap` package which include Houston related crimes between Jan 2010 to August 2010.


```r
# load required package
library(ggthemes) #for map theme

# examine the crime dataset
str(crime)
```

```
## 'data.frame':	86314 obs. of  17 variables:
##  $ time    : POSIXt, format: "2010-01-01 06:00:00" "2010-01-01 06:00:00" ...
##  $ date    : chr  "1/1/2010" "1/1/2010" "1/1/2010" "1/1/2010" ...
##  $ hour    : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ premise : chr  "18A" "13R" "20R" "20R" ...
##  $ offense : Factor w/ 7 levels "aggravated assault",..: 4 6 1 1 1 3 3 3 3 3 ...
##  $ beat    : chr  "15E30" "13D10" "16E20" "2A30" ...
##  $ block   : chr  "9600-9699" "4700-4799" "5000-5099" "1000-1099" ...
##  $ street  : chr  "marlive" "telephone" "wickview" "ashland" ...
##  $ type    : chr  "ln" "rd" "ln" "st" ...
##  $ suffix  : chr  "-" "-" "-" "-" ...
##  $ number  : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ month   : Ord.factor w/ 8 levels "january"<"february"<..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ day     : Ord.factor w/ 7 levels "monday"<"tuesday"<..: 5 5 5 5 5 5 5 5 5 5 ...
##  $ location: chr  "apartment parking lot" "road / street / sidewalk" "residence / house" "residence / house" ...
##  $ address : chr  "9650 marlive ln" "4750 telephone rd" "5050 wickview ln" "1050 ashland st" ...
##  $ lon     : num  -95.4 -95.3 -95.5 -95.4 -95.4 ...
##  $ lat     : num  29.7 29.7 29.6 29.8 29.7 ...
```

```r
# map the crime statistics colored by offense
ggmap(houston) +
  geom_point(data = crime, aes(col = offense), size = 1, alpha = 0.4)+
  theme_void()
```

```
## Error in ggmap(houston): object 'houston' not found
```

Not bad! `ggmap` even has functions which allow you to *geocode* locations by pulling the information from the internet (google).


```r
# examine the sites around houston we are interested in
houston_sites <- c("Houston Zoo, Houston", "Space Center, Houston", "Minute Maid Park, Houston", "George Bush Intercontinental Airport, Houston")

# geocode houston_sites
codes <- geocode(houston_sites)

codes$location <- str_replace(string = houston_sites, pattern = ", Houston", replace = "")

# examine codes
codes
```

```
##   lon lat                             location
## 1  NA  NA                          Houston Zoo
## 2  NA  NA                         Space Center
## 3  NA  NA                     Minute Maid Park
## 4  NA  NA George Bush Intercontinental Airport
```

```r
# create map object
houston <- get_map(location = "Houston, Texas", source = "google", maptype = 'terrain')
```

```
## Error in download.file(url, destfile = tmp, quiet = !messaging, mode = "wb"): cannot open URL 'http://maps.googleapis.com/maps/api/staticmap?center=Houston,+Texas&zoom=10&size=640x640&scale=2&maptype=terrain&language=en-EN&sensor=false'
```

```r
# map our newly coded locations
ggmap(houston) + 
  geom_point(data = codes, aes(color = location), size = 5) +
  theme_map()
```

```
## Error in ggmap(houston): object 'houston' not found
```

There's one more way we can define the coordinates of our map. Instead of using a particular location, The `bbox` function allows you to define the boundary box around your coordinates. We'll use the `wind` dataset which has wind data from Hurricane Ike. 


```r
# filter crime to include only points in Houston area
crime_sub <- crime %>% filter(lon <= -94.5 & lon > -97 & lat > 26 & lat < 30)

# create a bbox using the coordinates of the long and lat of the codes dataframe.
#f is the fraction to which the boundaries are to be extended.
bbox <- make_bbox(data = crime_sub, lon = lon, lat = lat, f = 1)

# create map object using bbox coordinates
houston <- get_map(location = bbox, zoom = 11,  maptype = 'terrain')
```

```
## Error in download.file(url, destfile = tmp, quiet = !messaging, mode = "wb"): cannot open URL 'http://maps.googleapis.com/maps/api/staticmap?center=29.741517,-95.405337&zoom=11&size=640x640&scale=2&maptype=terrain&language=en-EN&sensor=false'
```

```r
ggmap(houston) +
  stat_density2d(data = crime_sub,
                 aes(x = lon, y = lat, fill = ..level.., alpha = ..level..),
                 geom = 'polygon', bins = 15, show.legend = F) +
  scale_fill_gradient(low = "forestgreen", high = "red") +
  theme_map()
```

```
## Error in ggmap(houston): object 'houston' not found
```

## Animations

Animations are useful for dense temporal data, or geospatial data. They can be used as a great exploratory tool as well. 

The `animation` and `gganimate` packages are useful for creating plots with motion. 

You will need a graphic device converter such as [ImageMagick](https://imagemagick.org/) or [GraphicsMagick](http://www.graphicsmagick.org/) to get your animated plots to work. 

For MAC users, you may also need to install [FFMPEG](https://www.ffmpeg.org/). 


Let's make a simple animation using the `animation` package. The `saveGIF` function takes on the following arguments: 

- *expression* - the plot you want to animate (generally some sort of loop to create multiple plots which will be combined to create our gif)  
- *movie.name* - the name of the animation (with the extension i.e. '.gif')
- *img.name* - the filename of the sequence of images. **I find this is necessary to include to get the animation to run without any errors**
- *interval* - the speed at which you want your animation to run at. The higher the value, the slower the animation.  
- *convert* - the call to the converter (either imagemagick or graphicsmagick)


```r
library(animation)

# Use saveGIF function with for loop to create animated plot object
saveGIF(expr = {
  
  # sets environment options to use the graphics magick convert option
  ani.options(convert = "gm convert")
  
  # use for loop to create a series of plots which will be pasted together
  for (i in 1:10) plot(runif(25), ylim = 0:1)
  
  },movie.name = "runif.gif", img.name = 'runif', interval = 0.2, convert = 'gm convert')
```

```
## [1] FALSE
```
If everything is installed properly, the code above should generate a plot in the R console, and save the animation to the working directory. To get the animation to run in a document such as this, you will need to create a link to the saved animation like this:  

`![insert_caption_here](path_to_file/filename.gif)`

Your animation should appear with the caption below it.

![histogram](C:/workspace/jpwalker625.github.io/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/runif.gif)

The `gganimate` package is a wrapper around the `animation` package which makes it easier to use than its predecessor, in my opinion. It takes advantage of the `frame` aesthetic, which acts like the for loop on the variable you want to animate. Let's take a look at some historical storm data using the `storms` dataset.


```r
# load package
library(gganimate)
library(lubridate)

# examine the storms dataset
str(storms)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	10010 obs. of  13 variables:
##  $ name       : chr  "Amy" "Amy" "Amy" "Amy" ...
##  $ year       : num  1975 1975 1975 1975 1975 ...
##  $ month      : num  6 6 6 6 6 6 6 6 6 6 ...
##  $ day        : int  27 27 27 27 28 28 28 28 29 29 ...
##  $ hour       : num  0 6 12 18 0 6 12 18 0 6 ...
##  $ lat        : num  27.5 28.5 29.5 30.5 31.5 32.4 33.3 34 34.4 34 ...
##  $ long       : num  -79 -79 -79 -79 -78.8 -78.7 -78 -77 -75.8 -74.8 ...
##  $ status     : chr  "tropical depression" "tropical depression" "tropical depression" "tropical depression" ...
##  $ category   : Ord.factor w/ 7 levels "-1"<"0"<"1"<"2"<..: 1 1 1 1 1 1 1 1 2 2 ...
##  $ wind       : int  25 25 25 25 25 25 25 30 35 40 ...
##  $ pressure   : int  1013 1013 1013 1013 1012 1012 1011 1006 1004 1002 ...
##  $ ts_diameter: num  NA NA NA NA NA NA NA NA NA NA ...
##  $ hu_diameter: num  NA NA NA NA NA NA NA NA NA NA ...
```

```r
# extract names of  storms from 2005 that reached ctaegory 5
names <- storms %>% 
  filter(year == 2005 & category ==5) %>% 
  dplyr::select(name) %>% 
  distinct %>% 
  pull # converts data frame to vector


# filter storms dataset to include all data from storms that reached category 5 in 2005
storms <- storms %>% filter(name %in% names & year == 2005)

# create date variable using existing date related variables
storms <- storms %>% mutate(date = str_c(storms$year, storms$month, storms$day, sep = "-"))

# add hour
storms <- storms %>% mutate(date = str_c(storms$date, storms$hour, sep = " "))

# make date time
# truncated = allows the time to be converted to date_time without having the minutes or seconds
storms$date <- ymd_h(storms$date, truncated = 3)

# create bbox using long & lat of storms dataset
storms_bbox <- make_bbox(data = storms, lon = long, lat = lat)

# get map of the storm coordinates made from bbox
storms_map <- get_map(storms_bbox,maptype = 'watercolor', source = "google")

# create map object and plot data to map
p <- ggmap(storms_map) +
  geom_label(data = storms, 
             
            aes(x = long,
                y = lat,
                color = factor(name),
                label = category,
                size = category,
                group = factor(name),
                frame = date,
                cumulative = T))+
  # guides(size = "none")+
  scale_color_discrete("Hurricane") +
  theme_void() +
  coord_map()
p
```

![plot of chunk unnamed-chunk-28](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-28-1.png)

```r
# Make animated plot, save to file in working directory
gganimate(p, interval = 0.2, filename = 'storms.gif', convert = "gm convert")
```

How do the wind speeds compare at each category level for the different Hurricanes?


```r
p <- ggplot(storms, aes(x = date, y = wind, color = name, frame = date, group = name, cumulative = T)) +
  geom_line() +
  facet_wrap(~name, scales = "free")
p
```

![plot of chunk unnamed-chunk-29](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-29-1.png)

```r
gganimate(p, interval = 0.2, filename = "storm-winds.gif", convert = "gm convert")
```

And finally, for those that are extremely obsessive when it comes to their visualizations, we can use the `tweenr` package to create beautiful smooth plots.

You can install it from cran or you can install the development version using: `devtools::install_github("thomasp85/tweenr")`


```r
library(tweenr)
```

```
## Error in library(tweenr): there is no package called 'tweenr'
```

```r
# Create variables needed for tween_elements
storms <- storms %>% 
  mutate(date = as.numeric(date - min(date)+1),
         ease = "linear",
         status = as.factor(status))


# create a tween_elements object from our storms dataset
storms_tween <- tweenr::tween_elements(data = storms, time = "date", group = "name", ease = 'ease', nframes = 1000)
```

```
## Error in loadNamespace(name): there is no package called 'tweenr'
```

```r
p <- ggplot(storms_tween, aes(x = wind, y = pressure, color = .group, size = category, frame = .frame, group = .group), cumulative = T) +
  geom_point()
```

```
## Error in ggplot(storms_tween, aes(x = wind, y = pressure, color = .group, : object 'storms_tween' not found
```

```r
gganimate(p, interval = 0.2, filename = 'storms.gif', convert = "gm convert")
```

## Internals

Grid graphics are the foundation on which `ggplot2` is built. In the examples below, we will explore some of the features of the `grid` package.

The package was developed by Paul Murell to overcome some of the deficiencies base R plotting functions. There are two components to grid graphics: graphic output, and viewports.


**Graphical oututs are controlled with the `grid.___()` functions.**


```r
# load grid package
library(grid)

# Draw rectangle in null viewport
grid.rect(gp = gpar(fill = "grey90"))

# Write text in null viewport
grid.text("null viewport")

# Draw a line
grid.lines(x = c(0, 0.75), y = c(0.25, 1),
          gp = gpar(lty = 2, col = "red"))
```

![plot of chunk unnamed-chunk-31](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-31-1.png)

**Viewports control how graphical outputs are arranged/plotted.**


```r
# Create new viewport: vp
vp <- viewport(x = 0.5, y = 0.5, width = 0.5, height = 0.5, just = "center")

# Push vp
pushViewport(vp)

# Populate new viewport with rectangle
grid.circle(gp = gpar(fill = "blue"))
```

![plot of chunk unnamed-chunk-32](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-32-1.png)

*Grobs*, or Graphical Objects, are the object forms of the graphical outputs found in plots.


```r
# A simple plot p
p <- ggplot(mtcars, aes(x = wt, y = mpg, col = factor(cyl))) + geom_point()

# Create gtab with ggplotGrob()
gtab <- ggplotGrob(p)

# Print out gtab
gtab
```

```
## TableGrob (10 x 9) "layout": 18 grobs
##     z         cells       name                                      grob
## 1   0 ( 1-10, 1- 9) background        rect[plot.background..rect.102974]
## 2   5 ( 5- 5, 3- 3)     spacer                            zeroGrob[NULL]
## 3   7 ( 6- 6, 3- 3)     axis-l    absoluteGrob[GRID.absoluteGrob.102950]
## 4   3 ( 7- 7, 3- 3)     spacer                            zeroGrob[NULL]
## 5   6 ( 5- 5, 4- 4)     axis-t                            zeroGrob[NULL]
## 6   1 ( 6- 6, 4- 4)      panel               gTree[panel-1.gTree.102930]
## 7   9 ( 7- 7, 4- 4)     axis-b    absoluteGrob[GRID.absoluteGrob.102943]
## 8   4 ( 5- 5, 5- 5)     spacer                            zeroGrob[NULL]
## 9   8 ( 6- 6, 5- 5)     axis-r                            zeroGrob[NULL]
## 10  2 ( 7- 7, 5- 5)     spacer                            zeroGrob[NULL]
## 11 10 ( 4- 4, 4- 4)     xlab-t                            zeroGrob[NULL]
## 12 11 ( 8- 8, 4- 4)     xlab-b titleGrob[axis.title.x..titleGrob.102933]
## 13 12 ( 6- 6, 2- 2)     ylab-l titleGrob[axis.title.y..titleGrob.102936]
## 14 13 ( 6- 6, 6- 6)     ylab-r                            zeroGrob[NULL]
## 15 14 ( 6- 6, 8- 8)  guide-box                         gtable[guide-box]
## 16 15 ( 3- 3, 4- 4)   subtitle  zeroGrob[plot.subtitle..zeroGrob.102971]
## 17 16 ( 2- 2, 4- 4)      title     zeroGrob[plot.title..zeroGrob.102970]
## 18 17 ( 9- 9, 4- 4)    caption   zeroGrob[plot.caption..zeroGrob.102972]
```

```r
# Extract the grobs from gtab: gtab
g <- gtab$grobs

# draw only the legend
legend_index <- which(vapply(g, inherits, what = "gtable", logical(1)))

grid.draw(g[[legend_index]])

grid.draw(g[[15]])
```

![plot of chunk unnamed-chunk-33](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-33-1.png)

It is possible to modify the gtable to add new graphical objects as in this example:


```r
# show layout of the legend grob
gtable::gtable_show_layout(g[[legend_index]])

# Create text grob
my_text <- textGrob(label = "Motor Trend, 1974", gp = gpar(fontsize = 7, col = "gray25"))

# 2 - Use gtable_add_grob to modify original gtab
new_legend <- gtable::gtable_add_grob(x = gtab$grobs[[legend_index]], grobs = my_text, t = 2, l = 3, b = 5, r = 2)
  
# 3 - Update in gtab
gtab$grobs[[legend_index]] <- new_legend

# 4 - Draw gtab
grid.draw(gtab)
```

![plot of chunk unnamed-chunk-34](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-34-1.png)

## BagPlots

A useful but not very popular plot that can take the place of a boxplot. It has three essential parts:  
  
* The hull: the inner ring which outlines the center region (not that informative)
* The Bag: Contains 50% of the datapoints, similar to the IQR
* The Loop: Contains all points within the fence which is calculated as some factor enlargement of the bag (default 3)

Points outside the loops are drawn as individual dots.

We can compute the data for a bagplot and plot one using the `aplpack` package.


```r
# load required package
library(aplpack)
```

```
## Error in library(aplpack): there is no package called 'aplpack'
```

```r
# sample the diamonds dataset
diamonds_subset <- sample_n(tbl = diamonds, size = 500)

# Create bagplot of diamonds dataset: diamonds$carat vs. diamonds$price
bagplot(x = diamonds_subset$carat, y = diamonds_subset$price)
```

```
## Error in eval(expr, envir, enclos): could not find function "bagplot"
```

```r
# Get bagplot stats
bag <- compute.bagplot(x = diamonds_subset$carat, y = diamonds_subset$price)
```

```
## Error in eval(expr, envir, enclos): could not find function "compute.bagplot"
```

```r
# Examine the variables computed in the bag object.
names(bag)
```

```
## Error in eval(expr, envir, enclos): object 'bag' not found
```

```r
# Highlight components
points(bag$hull.loop, col = "green", pch = 16)
```

```
## Error in points(bag$hull.loop, col = "green", pch = 16): object 'bag' not found
```

```r
points(bag$hull.bag, col = "orange", pch = 16)
```

```
## Error in points(bag$hull.bag, col = "orange", pch = 16): object 'bag' not found
```

```r
points(bag$pxy.outlier, col = "purple", pch = 16)
```

```
## Error in points(bag$pxy.outlier, col = "purple", pch = 16): object 'bag' not found
```

The `alpack` package makes it easy to create this bagplot with the built-in function. If were to make this plot using ggplot2, we could make three separate geom layers as in this example:


```r
# Create data frames from the bag matrices
hull.loop <- data.frame(x = bag$hull.loop[,1], y = bag$hull.loop[,2])
```

```
## Error in data.frame(x = bag$hull.loop[, 1], y = bag$hull.loop[, 2]): object 'bag' not found
```

```r
hull.bag <- data.frame(x = bag$hull.bag[,1], y = bag$hull.bag[,2])
```

```
## Error in data.frame(x = bag$hull.bag[, 1], y = bag$hull.bag[, 2]): object 'bag' not found
```

```r
pxy.outlier <- data.frame(x = bag$pxy.outlier[,1], y = bag$pxy.outlier[,2])
```

```
## Error in data.frame(x = bag$pxy.outlier[, 1], y = bag$pxy.outlier[, 2]): object 'bag' not found
```

```r
# Finish the ggplot command
ggplot(diamonds_subset, aes(x = carat,  y = price)) +
  geom_polygon(data = hull.loop, aes(x = x, y = y), fill = "green") +
  geom_polygon(data = hull.bag, aes(x = x, y = y), fill = "orange") +
  geom_point(data = pxy.outlier, aes(x = x, y = y), col = "purple", pch = 16, cex = 1.5)
```

```
## Error in fortify(data): object 'hull.loop' not found
```

The plot above is a good starting point, but we can do better. In the process, we will learn how to use the `ggproto` function which can be used to make any new layer you can think of and ultimately build your own plots. `ggproto` takes 4 arguments:

* name of the object (in quotations)
* what it inherits from (usually Stat)
* required aesthetics
* what the stat should do


```r
# ggproto for StatLoop (hull.loop)
StatLoop <- ggproto("StatLoop", Stat,
                    required_aes = c("x", "y"),
                    compute_group = function(data, scales) {
                      bag <- compute.bagplot(x = data$x, y = data$y)
                      data.frame(x = bag$hull.loop[,1], y = bag$hull.loop[,2])
                    })

# ggproto for StatBag (hull.bag)
StatBag <- ggproto("StatBag", Stat,
                   required_aes = c("x", "y"),
                   compute_group = function(data, scales) {
                     bag <- compute.bagplot(x = data$x, y = data$y)
                     data.frame(x = bag$hull.bag[,1], y = bag$hull.bag[,2])
                   })

# ggproto for StatOut (pxy.outlier)
StatOut <- ggproto("StatOut", Stat,
                   required_aes = c("x", "y"),
                   compute_group = function(data, scales) {
                     bag <- compute.bagplot(x = data$x, y = data$y)
                     data.frame(x = bag$pxy.outlier[,1], y = bag$pxy.outlier[,2])
                   })
```

Next we need to plug our ggproto objects into a ggplot function with a custom layer that will plot the bagplot.


```r
# Combine ggproto objects in layers to build stat_bag()
stat_bag <- function(mapping = NULL, data = NULL, geom = "polygon",
                     position = "identity", na.rm = FALSE, show.legend = NA,
                     inherit.aes = TRUE, loop = FALSE, ...) {
  list(
    # StatLoop layer
    layer(
      stat = StatLoop, data = data, mapping = mapping, geom = geom, 
      position = position, show.legend = show.legend, inherit.aes = inherit.aes,
      params = list(na.rm = na.rm, alpha = 0.35,  col = NA, ...)
    ),
    # StatBag layer
    layer(
      stat = StatBag, data = data, mapping = mapping, geom = geom, 
      position = position, show.legend = show.legend, inherit.aes = inherit.aes,
      params = list(na.rm = na.rm, alpha = 0.35, col = NA, ...)
    ),
    # StatOut layer
    layer(
      stat = StatOut, data = data, mapping = mapping, geom = "point", 
      position = position, show.legend = show.legend, inherit.aes = inherit.aes,
      params = list(na.rm = na.rm, alpha = 0.7, col = NA, shape = 21, ...)
    )
  )
}
```

And finally, we can apply the data to our new function to make the plot


```r
ggplot(diamonds_subset, aes(x = carat,  y = price))+
  stat_bag(fill = "black")
```

![plot of chunk unnamed-chunk-39](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-39-1.png)

This custom function is flexible as well. Instead of calling the fill in the stat_bag layer, we can group the dataset and apply the stat_bag function to each group.


```r
ggplot(diamonds_subset, aes(x = carat,  y = price, fill = clarity ))+
  stat_bag()
```

![plot of chunk unnamed-chunk-40](/figure/source/2018-11-29-visualizind-data-in-r-with-ggplot2-part-3/unnamed-chunk-40-1.png)


[^1]: D. Kahle and H. Wickham. ggmap: Spatial Visualization with ggplot2. The R Journal, 5(1), 144-161. URL
  http://journal.r-project.org/archive/2013-1/kahle-wickham.pdf
