---
title: "An Introduction to `forcats`"
author: JW
tags:
- tidy
- factors
- tutorials
categories:
- tidy
- R
---



### Defining Factors
The `forcats` package is part of the tidyverse and is useful for dealing with factors. Factors are simply categorical variables, useful for controlling the levels and order of a vector.

Categorical or discrete variables, as opposed to continuous variables, are often qualitiative and can take on a finite number of values.

Examples of categorical variables: types of fruit, locations, party preference, ethnicity.


```r
#colors is a character vector of length nine consisting of colors: red, blue, & green

colors <- c("red","blue","green","green","red","blue","red","green","blue")
class(colors)
```

```
## [1] "character"
```

```r
#The factor() function works by assigning integers (number values) to the categorical values (red, blue, green) of the vector or variable. 

colors <- factor(colors)
print(colors)
```

```
## [1] red   blue  green green red   blue  red   green blue 
## Levels: blue green red
```

```r
class(colors)
```

```
## [1] "factor"
```

```r
str(colors)
```

```
##  Factor w/ 3 levels "blue","green",..: 3 1 2 2 3 1 3 2 1
```

```r
#Each color is a level, and underlying each level is an integer associated with that level; red = 3, green = 2, blue = 1. The order of the levels is assigned alphabetically to the integer: b = 1, g = 2, r = 3.

#We can reorder the levels if we want to:
colors <- factor(colors, levels = c("red","blue", "green"))
print(colors)
```

```
## [1] red   blue  green green red   blue  red   green blue 
## Levels: red blue green
```

```r
#The order of the vector stays the same, but now the order of the levels has changed so that red = 1, blue = 2, green = 3
str(colors)
```

```
##  Factor w/ 3 levels "red","blue","green": 1 2 3 3 1 2 1 3 2
```

Factors are a useful data structure that allow you to have more control over how you analyze and visualize your data.

```r
#Let's compare the summary function for colors as a character vector and as a factor.
colors <- c("red","blue","green","green","red","blue","red","green","blue")

summary(colors)
```

```
##    Length     Class      Mode 
##         9 character character
```

```r
colors <- factor(colors, levels = c("red","blue", "green"))

summary(colors)
```

```
##   red  blue green 
##     3     3     3
```

```r
#As factors, each color becomes a distinct group and summarized separately.
```

### The Forcats Package
As useful as factors are, they can be quite a pain to work with at times. Luckily, `forcats` has functions that allow you to manipulate factors. 


First, let's install the package using:
`install.packages("forcats")`

`forcats` also comes installed as part of the `tidyverse` suite of packages. It is not part of the core group of `tidyverse` packages so we must load it explicitly.


```r
library(tidyverse)
library(forcats)
```

### Function: Factor Recode
One useful function of `forcats` is `fct_recode`. This allows you to change the levels (or name/identity) of a factor. Here's an example:


```r
#Let's use the airquality data set that comes pre-installed in R
glimpse(airquality)
```

```
## Observations: 153
## Variables: 6
## $ Ozone   <int> 41, 36, 12, 18, NA, 28, 23, 19, 8, NA, 7, 16, 11, 14, ...
## $ Solar.R <int> 190, 118, 149, 313, NA, NA, 299, 99, 19, 194, NA, 256,...
## $ Wind    <dbl> 7.4, 8.0, 12.6, 11.5, 14.3, 14.9, 8.6, 13.8, 20.1, 8.6...
## $ Temp    <int> 67, 72, 74, 62, 56, 66, 65, 59, 61, 69, 74, 69, 66, 68...
## $ Month   <int> 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, ...
## $ Day     <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,...
```

```r
#The month column is data type integer, let's change it to a factor 
airquality$Month <- factor(airquality$Month)

levels(airquality$Month)
```

```
## [1] "5" "6" "7" "8" "9"
```

```r
#Let's rename the months using the fct_recode function. 
airquality$Month <- fct_recode(airquality$Month, May = '5', June = '6', July = '7', Aug = '8', Sept = '9')
glimpse(airquality$Month)
```

```
##  Factor w/ 5 levels "May","June","July",..: 1 1 1 1 1 1 1 1 1 1 ...
```

```r
ggplot(airquality, aes(Month, Temp)) +
  geom_boxplot(aes(fill = Month)) +
  ggtitle(label = "Daily Temperatures Aggregated by Month")
```

![plot of chunk change level values](/figure/source/2018-11-07-forcats_tutorial/change level values-1.png)

### The Factor Reverse Function
If you just want to reverse the order, there's the `fct_rev` function. You can even use it in line when defining your aesthetics in ggplot like so:

```r
ggplot(airquality, aes(fct_rev(Month), Temp)) +
  geom_boxplot(aes(fill = Month)) +
  labs(x = "Month") +
  ggtitle(label = "Our plot now has the x-axis in reverse order")
```

![plot of chunk reverse the order](/figure/source/2018-11-07-forcats_tutorial/reverse the order-1.png)

### The Factor Relevel Function
Another useful function is `fct_relevel`. This function allows us to change any number of levels to any position.

```r
airquality$Month <- fct_relevel(airquality$Month, 'Sept', 'July', 'May', 'Aug', 'June')

levels(airquality$Month)
```

```
## [1] "Sept" "July" "May"  "Aug"  "June"
```

```r
# This may not seem useful at first, but when you need to visualize your data in a particular way, the fct_relevel function is extremely useful...

ggplot(airquality, aes(Month, Temp)) +
  geom_boxplot(aes(fill = Month)) +
  ggtitle(label = "Notice how the order of the level 'Month' has changed")
```

![plot of chunk change level position](/figure/source/2018-11-07-forcats_tutorial/change level position-1.png)

### The Factor Reorder Function

And finally, it is often useful to reorder the factor in a way that is useful for visualization. For this, we can use the `fct_reorder` function.

For this example, let's use the mtcars data set:

```r
mtcars$model <- row.names(mtcars)

glimpse(mtcars)
```

```
## Observations: 32
## Variables: 12
## $ mpg   <dbl> 21.0, 21.0, 22.8, 21.4, 18.7, 18.1, 14.3, 24.4, 22.8, 19...
## $ cyl   <dbl> 6, 6, 4, 6, 8, 6, 8, 4, 4, 6, 6, 8, 8, 8, 8, 8, 8, 4, 4,...
## $ disp  <dbl> 160.0, 160.0, 108.0, 258.0, 360.0, 225.0, 360.0, 146.7, ...
## $ hp    <dbl> 110, 110, 93, 110, 175, 105, 245, 62, 95, 123, 123, 180,...
## $ drat  <dbl> 3.90, 3.90, 3.85, 3.08, 3.15, 2.76, 3.21, 3.69, 3.92, 3....
## $ wt    <dbl> 2.620, 2.875, 2.320, 3.215, 3.440, 3.460, 3.570, 3.190, ...
## $ qsec  <dbl> 16.46, 17.02, 18.61, 19.44, 17.02, 20.22, 15.84, 20.00, ...
## $ vs    <dbl> 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1,...
## $ am    <dbl> 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,...
## $ gear  <dbl> 4, 4, 4, 3, 3, 3, 3, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 4, 4,...
## $ carb  <dbl> 4, 4, 1, 1, 2, 1, 4, 2, 2, 4, 4, 3, 3, 3, 4, 4, 4, 1, 2,...
## $ model <chr> "Mazda RX4", "Mazda RX4 Wag", "Datsun 710", "Hornet 4 Dr...
```

```r
mtcars$model <- factor(mtcars$model)

ggplot(mtcars, aes(mpg, model)) +
  geom_point() +
  ggtitle(label = "MPG vs. Car Model")
```

![plot of chunk fct_reorder setup](/figure/source/2018-11-07-forcats_tutorial/fct_reorder setup-1.png)

It's difficult to make comparisons when the data is scattered. But we're in luck! We can use the `fct_reorder` function to clean it up.


```r
#fct_reorder takes three arguments: f = factor you want to reorder, x = the variable in which the order will be based upon, and optionally fun (a function to  be used if there are multiple values of x for each value of f.) Here we focus on only the first two arguments.

ggplot(mtcars, aes(mpg, fct_reorder(f = model, x = mpg))) +
  geom_point() +
  labs(y = "model") +
  ggtitle(label = "We can make better comparison by reordering the levels based on the mpg values!") +
  theme(plot.title = element_text(size = 10, face = 'bold'))
```

```
## Error in check_factor(.f): argument ".f" is missing, with no default
```

![plot of chunk fct_reorder](/figure/source/2018-11-07-forcats_tutorial/fct_reorder-1.png)



