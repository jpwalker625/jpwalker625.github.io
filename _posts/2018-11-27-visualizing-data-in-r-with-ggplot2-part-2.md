---
title: Visualizing Data In R With ggplot2 (Part 2)
author: JW
date: '2018-11-27'
slug: visualizing-data-in-r-with-ggplot2-part-2
categories:
  - R Programming
tags:
  - data visualization
  - '2018'
published: true
---



## This is the second of a three part series on data visualization using the popular ggplot2 package. 

**For more on data viz, get an introduction to ggplot2 in [part 1](https://jpwalker625.github.io/r/visualization/2018/11/26/visualizing-data-in-r-with-ggplot2-part-1) or get into the weeds in [part 3!](https://jpwalker625.github.io/r/visualization/2018/11/29/visualizind-data-in-r-with-ggplot2-part-3)**

## Part 2

In Part 1, we discussed 3 elements of the grammar of graphics: data, aesthetics, & geometries. We will continue our understanding of data viz by focusing our attention on other important layers: 

* Statistics 
* Coordinates
* Facets 
* Themes 

Let's begin by loading the required packages.

```r
# load required packages
library(tidyverse)
library(MASS) # for datasets
library(forcats)
library(ggthemes)
```

## Statistics

Some statistics functions and geom functions can be used synonymously in ggplot2. An example of this is the `geom_bar`, `geom_histogram` and `geom_freqpoly` functions. Under the hood, these functions are using the `stat_bin` function to plot the data. 


```r
# assign plot object
p <- ggplot(iris, aes(x = Sepal.Width))

# plot with geom_histogram
p + geom_histogram()
```

![plot of chunk unnamed-chunk-2](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-2-1.png)

```r
# plot with geom_bar
p + geom_bar()
```

![plot of chunk unnamed-chunk-2](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-2-2.png)

```r
# plot with stat_bin
p + stat_bin()
```

![plot of chunk unnamed-chunk-2](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-2-3.png)

Similarly, we can apply the smoothing statistics applied by the `stat_smooth` function with `geom_smooth`.


```r
# assign plot object
p <- ggplot(iris, aes(Petal.Length, Sepal.Length, color = factor(Species)))

# scatter plot with least squares modeling for each individual Species, and the dataset as a whole.
# we can determine whether the confidence interval ribbon appears by setting the 'se' argument.
p + geom_point() +
  geom_smooth(method = "lm") +
  geom_smooth(method = "lm", se = FALSE, aes(group = 1))
```

![plot of chunk unnamed-chunk-3](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-3-1.png)

LOESS smoothing is a non-parametric form of regression that uses a weighted, sliding-window, average to calculate a line of best fit. We can control the size of this window with the span argument

 

```r
# set individual models to loess (default) and adjust the span
p + 
  geom_point() +
  geom_smooth(se = F, span = 0.7) 
```

![plot of chunk unnamed-chunk-4](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-4-1.png)

```r
# add overall model layer (loess) change individual model layers to 'lm'.
p + 
  geom_point()+
  geom_smooth(method = "lm") +
  stat_smooth(aes(group = 1), method = "loess", se = F, col = "black")
```

![plot of chunk unnamed-chunk-4](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-4-2.png)

Notice in the plot above that I used both `geom_smooth` and `stat_smooth`. As mentioned before, these functions are interchangeable. 

Another nice feature of the smoothing functions is that you can extend the model to the full range of the plot by calling the logical (T or F) `fullrange ` argument. Notice how the further from the data you get, the se ribbon gets wider and wider.


```r
# apply fullrange of predictions for the individual Species linear regression models.
p + 
  geom_point()+
  geom_smooth(method = "lm", fullrange = T) +
  stat_smooth(aes(group = 1), method = "loess", se = F, col = "black")
```

![plot of chunk unnamed-chunk-5](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-5-1.png)

In the plot above, the overall model is not included in the legend even though we applied the attribute `color = "black` to it. We can fix this by adding the color as an aesthetic, but we lose our control over the color.


```r
# add color as an aesthetic named 'All'
p + 
  geom_point()+
  geom_smooth(method = "lm") +
  stat_smooth(aes(group = 1, color = "All"), method = "loess", se = F)
```

![plot of chunk unnamed-chunk-6](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-6-1.png)

Now the 'All' model appears in the legend but as I mentioned, we lost control over the color. We can fix this!


```r
# create a color vector with 4 colors, one for each color we will use in our plot
 
colors <- c("black", wesanderson::wes_palette(name = 'Darjeeling', 3))

# add manual color scale to change the colors.
p + 
  geom_point()+
  geom_smooth(method = "lm") +
  stat_smooth(aes(group = 1, color = "All"), method = "loess", se = F)+
  scale_color_manual("Species Colors", values = colors)
```

![plot of chunk unnamed-chunk-7](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-7-1.png)

With `stat_quantile()`, we can apply quantile regression to a dataset. By default, the 1st, 2nd, and 3rd quantiles are modeled as a response to the predictor variable. Speciic quantiles can be specified with the quantiles argument. For example, to show only the median quantile, we can set `quantiles = 0.5`


```r
# examine the dataset
str(txhousing)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	8602 obs. of  9 variables:
##  $ city     : chr  "Abilene" "Abilene" "Abilene" "Abilene" ...
##  $ year     : int  2000 2000 2000 2000 2000 2000 2000 2000 2000 2000 ...
##  $ month    : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ sales    : num  72 98 130 98 141 156 152 131 104 101 ...
##  $ volume   : num  5380000 6505000 9285000 9730000 10590000 ...
##  $ median   : num  71400 58700 58100 68600 67300 66900 73500 75000 64500 59300 ...
##  $ listings : num  701 746 784 785 794 780 742 765 771 764 ...
##  $ inventory: num  6.3 6.6 6.8 6.9 6.8 6.6 6.2 6.4 6.5 6.6 ...
##  $ date     : num  2000 2000 2000 2000 2000 ...
```

```r
# create plot object sales vs. listings
p <- ggplot(txhousing, aes(x = listings, y = sales))

# scatterplot with quantile models
p + geom_point() + stat_quantile()
```

![plot of chunk unnamed-chunk-8](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-8-1.png)

```r
# group by year
p + 
  geom_point() +
  stat_quantile(aes(color = year))
```

![plot of chunk unnamed-chunk-8](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-8-2.png)

Changing the color aesthetic did not produce the desired effect. That's because the `year` variable is an integer and we need it to be a factor.


```r
# make year a factor and adjust aesthetics/attributes
p +
  geom_point() +
  stat_quantile(aes(color = factor(year)), alpha = 0.6, size = 2)
```

![plot of chunk unnamed-chunk-9](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-9-1.png)

While it's pretty, this plot is messy and not very readable. Let's clean it up by limiting which quantiles are plotted and adjusting our color scale to something more intuitive.

Even though we made year a factor, time is really a continuous variable and so we want to treat it as such when we choose our color scale. We can do this by making the `color = year` a continuous color scale, but keeping our quantile model grouped for each year separately with `group = factor(year)`.

```r
# create plot object as before. Add color and group aesthetics
p <- ggplot(txhousing, aes(x = listings, y = sales, color = year, group = factor(year)))

# Plot point and quantile models for the median quantile. Modify the color scheme.
colors <- RColorBrewer::brewer.pal(11, 'RdYlBu')

p + geom_point(color = "black", size = .75) +
  stat_quantile(alpha = 0.75, size = 2, quantiles = 0.5) +
  scale_color_gradientn(colours = colors)
```

![plot of chunk unnamed-chunk-10](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-10-1.png)

The `stat_sum` function is useful for calculating the counts for each group in a dataset. 


```r
# create diamonds plot object clarity vs. cut
p <- ggplot(diamonds, aes(cut, clarity))

# make scatterplot
p + geom_point()
```

![plot of chunk unnamed-chunk-11](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-11-1.png)

```r
# reveal overplotting
p + geom_jitter(width = 0.3)
```

![plot of chunk unnamed-chunk-11](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-11-2.png)

```r
# apply stat_sum 
p + stat_sum()
```

![plot of chunk unnamed-chunk-11](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-11-3.png)

```r
# adjust scale_size
p + stat_sum() +
  scale_size(range = c(1,10))
```

![plot of chunk unnamed-chunk-11](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-11-4.png)

## Stat Summary

`Stat_summary` can be used to perform summary statistics in conjunction with various `ggplot2` and `hmisc` functions. 

For example, the `mean_cl_normal` function can be used to generate the mean and the lower and upper confidence limits on a variable. 


```r
# examine the Rabbit dataset
str(Rabbit)
```

```
## 'data.frame':	60 obs. of  5 variables:
##  $ BPchange : num  0.5 4.5 10 26 37 32 1 1.25 4 12 ...
##  $ Dose     : num  6.25 12.5 25 50 100 200 6.25 12.5 25 50 ...
##  $ Run      : Factor w/ 10 levels "C1","C2","C3",..: 1 1 1 1 1 1 2 2 2 2 ...
##  $ Treatment: Factor w/ 2 levels "Control","MDL": 1 1 1 1 1 1 1 1 1 1 ...
##  $ Animal   : Factor w/ 5 levels "R1","R2","R3",..: 1 1 1 1 1 1 2 2 2 2 ...
```

```r
# create plot object BPchange vs. Dose using Rabbit dataset
p <- ggplot(Rabbit, aes(x = factor(Dose), y = BPchange, color = Treatment))

# take a look at the plot
p + geom_point(position = position_jitter(0.2))
```

![plot of chunk unnamed-chunk-12](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-12-1.png)

```r
# use stat_summary function to generate mean for each BPchange per Dose
p +
  stat_summary(geom = 'point', fun.y = mean)
```

![plot of chunk unnamed-chunk-12](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-12-2.png)

```r
# examine mean_cl_normal function
mean_cl_normal(Rabbit$BPchange)
```

```
##          y     ymin     ymax
## 1 11.21833 8.253206 14.18346
```

```r
# assign position dodge function
posn.d <- position_dodge(width = 0.5)

# use stat_summary to generate confidence intervals of the mean
p + stat_summary(geom = 'errorbar', position = posn.d, fun.data = mean_cl_normal, size = 1) +
  stat_summary(geom = 'point', position = posn.d, fun.y = mean, shape = "X", size = 3)
```

![plot of chunk unnamed-chunk-12](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-12-3.png)

You can even create custom functions to generate stats. The only caveat is that the variable names need to match the agrguments of the geometry being called.


```r
# create min and max range function
range_function <- function(x){
  data.frame(ymin = min(x),
             ymax = max(x))
}

# demonstrate range function
range_function(Rabbit$BPchange)
```

```
##   ymin ymax
## 1  0.5   37
```

```r
# create median interquartile range function (calculates the median, 25% and 75% quartiles)
med_IQR <- function(x){
  data.frame( y = median(x),
              ymin = quantile(x)[2],
              ymax = quantile(x)[4])
}

# demonstarte quantile and med_IQR function
quantile(Rabbit$BPchange)
```

```
##    0%   25%   50%   75%  100% 
##  0.50  1.65  4.75 20.50 37.00
```

```r
med_IQR(Rabbit$BPchange)
```

```
##        y ymin ymax
## 25% 4.75 1.65 20.5
```

```r
# use functions in stat_summary to plot the data
# redundancy of Treatment variable is necessary to adjust the attributes of the stat_summary functions 
p <- ggplot(Rabbit, aes(x = factor(Dose), y = BPchange, color = Treatment, group = Treatment, fill = Treatment))

p + 
  stat_summary(geom = 'linerange', fun.data = med_IQR, size = 2, position = posn.d) +
  stat_summary(geom = 'linerange', fun.data = range_function, size = 1.5, alpha = 0.5, position = posn.d)+
  stat_summary(geom = 'point', fun.y = median, shape = "X", color = 'black', size = 2, position = posn.d)
```

![plot of chunk unnamed-chunk-13](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-13-1.png)


## Coordinates

You can adjust the scales in various ways. There is a series of function beginning with `scale` that allow you to set the breaks and limits, among other arguments. There are also `coordinate` functions which allow you to manipulate the scales as well. It is important to understand the consequences of the functions as the can lead to different plotting results.

For instance, you can zoom in on a section of a plot using the `scale_x_continuous` function, but this may cut off portions of your plot as in the example below.


```r
#create plot object using iris dataset
p <- ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point() +
  geom_smooth()

#view plot
p
```

![plot of chunk unnamed-chunk-14](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-14-1.png)

```r
#zoom in using scale function
p + scale_x_continuous(limits = c(3.5, 5.5))
```

![plot of chunk unnamed-chunk-14](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-14-2.png)

In the plot above, the loess smoothing for the `virginica` species does not appear because only one data point exists due to the limits we set.

What we really want is to get a zoomed in snapshot of this section of the plot as it is. For this we can use the `coord_cartesian` function to adjust the plot without losing the actual information.


```r
#apply coord_cartesian to plot object
p + coord_cartesian(xlim = c(3.5,5.5))
```

![plot of chunk unnamed-chunk-15](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-15-1.png)

**As a rule of thumb, it is good practice to use a 1:1 aspect ratio when your axes show the same scales.**


```r
p + coord_equal()
```

![plot of chunk unnamed-chunk-16](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-16-1.png)

The `coord_polar` function converts planar x-y cartesian plots into polar coordinates. This can be useful for making pie charts. In general, it is best practice to avoid pie charts. Other plots can capture the same information in much more meaningful ways. 


```r
p <- ggplot(diamonds, aes(x = 1, fill = clarity))+
  geom_bar(width = 2)

p + coord_polar(theta = 'y')
```

![plot of chunk unnamed-chunk-17](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-17-1.png)

## Facets

Facets split up the overall data according to the levels of the categorical variable specified. Faceting is based on the concept of small multiples *(Edward Tufte)* in which we take a large complex plot and split it up into smaller plots to be able to compare more easily.

**Faceting take a formula argument where rows are specified on the left of the tilde (~) and columns are specified on the right of the tilde (~).**

Let's explore faceting using the `crabs` data set which comes from the `MASS` package. The RW refers to measurement of rear width (mm) and the CW refers to the measurement of carpace width (mm), or the upper segement of the crab.


```r
# examine the crabs dataset
str(crabs)
```

```
## 'data.frame':	200 obs. of  8 variables:
##  $ sp   : Factor w/ 2 levels "B","O": 1 1 1 1 1 1 1 1 1 1 ...
##  $ sex  : Factor w/ 2 levels "F","M": 2 2 2 2 2 2 2 2 2 2 ...
##  $ index: int  1 2 3 4 5 6 7 8 9 10 ...
##  $ FL   : num  8.1 8.8 9.2 9.6 9.8 10.8 11.1 11.6 11.8 11.8 ...
##  $ RW   : num  6.7 7.7 7.8 7.9 8 9 9.9 9.1 9.6 10.5 ...
##  $ CL   : num  16.1 18.1 19 20.1 20.3 23 23.8 24.5 24.2 25.2 ...
##  $ CW   : num  19 20.8 22.4 23.1 23 26.5 27.1 28.4 27.8 29.3 ...
##  $ BD   : num  7 7.4 7.7 8.2 8.2 9.8 9.8 10.4 9.7 10.3 ...
```

```r
# create plot object using crabs dataset
mycol <- c(pals::brewer.blues(4)[c(3,4)], pals::brewer.oranges(4)[c(3,4)])

p <- ggplot(crabs, aes(x = CW, y = RW, color = interaction(sex, sp))) +
  geom_point() +
  scale_colour_manual("Sex.Species", values = mycol) +
  coord_equal()

# view plot
p
```

![plot of chunk unnamed-chunk-18](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-18-1.png)

```r
# facet status by rows
p + facet_grid(sex~.)
```

![plot of chunk unnamed-chunk-18](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-18-2.png)

```r
# facet species by column
p + facet_grid(~sp)
```

![plot of chunk unnamed-chunk-18](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-18-3.png)

```r
# facet both sex and species, add smoothing line, adjust the aspect ratio
p + facet_grid(sex~ sp) +
  geom_line(stat = 'smooth', method = 'lm', size = 1.2, alpha = 0.4)  +
  coord_equal()
```

![plot of chunk unnamed-chunk-18](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-18-4.png)

Sometimes it may be necessary to adjust the x and/or y axis scales in conjunction with facets. 
This could be due to redundancy of factors appearing in plots where there is no data for that particular factor. Here's an example using the  
`UScereal` dataset from the `MASS` package.


```r
# make rownames a column
UScereal <- rownames_to_column(UScereal, 'cereal')

# make cereal variable a factor
UScereal$cereal <- as_factor(UScereal$cereal)

# examine the UScereal dataset
glimpse(UScereal)
```

```
## Observations: 65
## Variables: 12
## $ cereal    <fct> 100% Bran, All-Bran, All-Bran with Extra Fiber, Appl...
## $ mfr       <fct> N, K, K, G, K, G, R, P, Q, G, G, G, G, R, K, K, G, K...
## $ calories  <dbl> 212.1212, 212.1212, 100.0000, 146.6667, 110.0000, 17...
## $ protein   <dbl> 12.121212, 12.121212, 8.000000, 2.666667, 2.000000, ...
## $ fat       <dbl> 3.030303, 3.030303, 0.000000, 2.666667, 0.000000, 2....
## $ sodium    <dbl> 393.9394, 787.8788, 280.0000, 240.0000, 125.0000, 28...
## $ fibre     <dbl> 30.303030, 27.272727, 28.000000, 2.000000, 1.000000,...
## $ carbo     <dbl> 15.15152, 21.21212, 16.00000, 14.00000, 11.00000, 24...
## $ sugars    <dbl> 18.181818, 15.151515, 0.000000, 13.333333, 14.000000...
## $ shelf     <int> 3, 3, 3, 1, 2, 3, 1, 3, 2, 1, 2, 3, 2, 1, 1, 2, 2, 3...
## $ potassium <dbl> 848.48485, 969.69697, 660.00000, 93.33333, 30.00000,...
## $ vitamins  <fct> enriched, enriched, enriched, enriched, enriched, en...
```

```r
# create plot object using UScereal dataset
p <- ggplot(UScereal, aes(x = calories, y = cereal)) +
  geom_point()

# examine plot
p
```

![plot of chunk unnamed-chunk-19](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-19-1.png)

```r
# facet plot by manufacturer
p +facet_grid(mfr ~.)
```

![plot of chunk unnamed-chunk-19](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-19-2.png)

As you can see the plot above is unreadable. This can be fixed by calling some arguments to the `facet_grid` function. 
We can also adjust the ranking of the cereals using the `forcats` package. Right now they are alphabetical but it would be more useful to rank the cereals in order of the amount of calories.


```r
# rank cereals based on calorie amount
my_breaks <- seq(from = min(UScereal$calories), to = max(UScereal$calories), by = 25)

# plot the object
ggplot(UScereal, aes(x = calories, y = fct_reorder(f = cereal, x = calories, .desc = T), color = vitamins))+
  geom_point() + 
  facet_grid(mfr~., scales = 'free_y', space = 'free_y') +
  scale_x_continuous(breaks = my_breaks) +
  theme(axis.text.y = element_text(size = 8))
```

<img src="/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-20-1.png" title="plot of chunk unnamed-chunk-20" alt="plot of chunk unnamed-chunk-20" style="display: block; margin: auto;" />

## Themes

In the plot above, you may have noticed the `theme` argument in which the y axis text size was modified. **The theme function can modify many non data elements of the plot.** These elements can be classified into three groups: 
 
* text - titles, axis labels, and legend or strip text. 
* line - major and minor grid lines within the plot panel, as well as axis ticks and lines. 
* rectangle - backgrounds of the legend, panel (main plot area), and strip (facets) area. 
  
Each argument takes on a sub-argument `element_[text, rectangle, line, blank]` which controls such features as the family (font), face, color, size, fill, angle, etc...


```r
# convert Titanic table to data frame
titanic <- as.data.frame(Titanic)

# examine titanic dataset
str(titanic)
```

```
## 'data.frame':	32 obs. of  5 variables:
##  $ Class   : Factor w/ 4 levels "1st","2nd","3rd",..: 1 2 3 4 1 2 3 4 1 2 ...
##  $ Sex     : Factor w/ 2 levels "Male","Female": 1 1 1 1 2 2 2 2 1 1 ...
##  $ Age     : Factor w/ 2 levels "Child","Adult": 1 1 1 1 1 1 1 1 2 2 ...
##  $ Survived: Factor w/ 2 levels "No","Yes": 1 1 1 1 1 1 1 1 1 1 ...
##  $ Freq    : num  0 0 35 0 0 0 17 0 118 154 ...
```

```r
p <- ggplot(titanic, aes(x = factor(Class), y = Freq, fill = factor(Survived))) +
  geom_bar(stat = 'identity', position = 'dodge') +
  facet_wrap(Sex ~ Age, scales = "free") +
  labs(title = 'The Fate of Passengers on the Titanic', x = "Class", y = "Count") +
  scale_fill_manual("Survived", values = c('tomato3', 'dodgerblue2')) +
  scale_y_continuous()

# examine default plot
p
```

![plot of chunk unnamed-chunk-21](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-21-1.png)

```r
# adjust plot elements using theme layer
p + theme(axis.title = element_text(family = 'serif', size = 14, face = 'bold'), 
          axis.text = element_text(face = 'italic', color = 'black'),
          legend.background = element_blank(),
          legend.key = element_blank(),
          legend.position = 'bottom',
          panel.border = element_rect(fill = NA, color = 'black'), 
          panel.background = element_rect(fill = 'whitesmoke'),
          panel.grid = element_blank(),
          panel.spacing = unit(0.5, 'mm'),
          plot.background = element_rect(fill = "lightgray", color = 'black'),
          plot.title = element_text(face = 'bold', family = 'serif', hjust = 0.5, size = 20),
          strip.background = element_blank(),
          strip.text = element_text(face = 'bold.italic', family = 'serif', size = 10)
          )
```

![plot of chunk unnamed-chunk-21](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-21-2.png)

If you have multiple plots, adjusting the themes for each plot would be a lot of work. Luckily, there are more efficient ways of handling this. 

Themes can be recycled by making the theme an object which is called in conjunction with your plot object. 


```r
theme_smoke <- theme(panel.background = element_blank(),
                    legend.key = element_blank(),
                    legend.background = element_blank(),
                    strip.background = element_blank(),
                    plot.background = element_rect(fill = 'whitesmoke', color = "black", size = 3),
                    panel.grid = element_blank(),
                    axis.line = element_line(color = "black"),
                    axis.ticks = element_line(color = "black"),
                    strip.text = element_text(size = 16, color = "steelblue"),
                    axis.title.y = element_text(color = "steelblue", hjust = 0, face = "italic"),
                    axis.title.x = element_text(color = "steelblue", hjust = 0, face = "italic"),
                    axis.text = element_text(color = "black"),
                    legend.position = "none")

# plot titanic plot object with theme_smoke object
p + theme_smoke
```

![plot of chunk unnamed-chunk-22](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-22-1.png)

The default theme is`theme_gray` but there are a variety of themes that come with `ggplot2`. In addition, the `ggthemes` package has many more themes ready for use.


```r
# plot using classic ggplot2 theme 
p + theme_classic()
```

![plot of chunk unnamed-chunk-23](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-23-1.png)

```r
# plot using the wall street journal ggtheme 
p + theme_wsj()
```

![plot of chunk unnamed-chunk-23](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-23-2.png)

You can use `theme_update` and `theme_set` to update elements or change the default theme for all plots.

Assigning the `theme_set()` to an object will allow you to switch back to the previously used theme.

```r
# change the theme and apply to an object
old <- theme_set(theme_fivethirtyeight())

# plot with the new default theme
p
```

![plot of chunk unnamed-chunk-24](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-24-1.png)

```r
# update element of the default theme
modified_theme <- theme_update(axis.text = element_text(size = 14),
                    panel.background = element_rect(fill = 'honeydew3'))

# plot modified default theme
p
```

![plot of chunk unnamed-chunk-24](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-24-2.png)

```r
# show different plot uses the new updated theme
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  facet_grid(~cyl)
```

![plot of chunk unnamed-chunk-24](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-24-3.png)

```r
# revert back to original default theme  
theme_set(old)

#plot with original default theme
p
```

![plot of chunk unnamed-chunk-24](/figure/source/2018-11-27-visualizing-data-in-r-with-ggplot2-part-2/unnamed-chunk-24-4.png)
