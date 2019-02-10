---
title: Lists & Iterations with Purrr
author: JW
date: '2019-01-12'
slug: lists-iterations-with-purrr
categories: []
tags:
  - R
  - purrr
  - lists
  - iterations
  - tidy
---




# Part 1: Introduction to Purrr

Hello and welcome to the tutorial on *Lists and Iterations with `Purrr`*. `Purrr` is a tidyverse package that makes iterating over lists easier, more efficient, and more human readable compared to the base R functions. In the first section, we will learn the principal functions of `purrr` that will allow us to iterate over lists, how to troubleshoot lists, and dive into some more complex examples utilizing other tidyverse principals. In the second section of this tutorial, we will dive into more advanced topics including: lambda functions, partials, and predicate functions that will allow us to write cleaner code. Let's begin!



```r
#load required libraries
library(tidyverse)
library(repurrrsive)
```

```
## Error in library(repurrrsive): there is no package called 'repurrrsive'
```

```r
#load sw_species dataset from repurrrsive
data("sw_species")

#examine the first element in sw_species
glimpse(sw_species[[2]])
```

```
## Error in glimpse(sw_species[[2]]): object 'sw_species' not found
```

As shown above, we can use double brackets to subset an item or element in a list. In the case of the `sw_species` list, the second element corresponds to another list composed of information for Yoda's species.

Another way to subset a list is by name using the `$` followed by the *list name*, similar to how we subset dataframes. However, the `sw_species` list is unnamed.


```r
#Get the names of the list elements
names(sw_species)
```

```
## Error in eval(expr, envir, enclos): object 'sw_species' not found
```

## Mapping
Our first task will be to apply names to each element using the `$name` subelement from each species sublist. One way to do this is by going through each list individually.


```r
#get the name element from the first list in sw_species
(names(sw_species)[[1]] <- sw_species[[1]]$name)
```

```
## Error in eval(expr, envir, enclos): object 'sw_species' not found
```

```r
#examines the names of the sw_species once again
names(sw_species)
```

```
## Error in eval(expr, envir, enclos): object 'sw_species' not found
```

This is painstakingly tedious and inefficent. One could use a for loop to do this, but there's an even better way. 

`Purrr` has a `map` function which works similarly to the base R `apply` functions. Map takes a `.x` argument - a vector or list, and a `.f` argument - a function. `Map` acts as a loop iterating the function over each element in the list. Let's utilize map and the `set_names` function to give the `sw_species` dataset names.

First, we'll create a list of species names. Map is useful in that the .f argument can be used to subset an element of the list as so:

```r
#create a vector of names of the species
species_names <- map(sw_species, "name")
```

```
## Error in map(sw_species, "name"): object 'sw_species' not found
```

Now we'll apply the species names to the `sw_species` list.


```r
sw_species <- set_names(sw_species, species_names)
```

```
## Error in typeof(x): object 'sw_species' not found
```

```r
#examine the names of sw_species
names(sw_species)
```

```
## Error in eval(expr, envir, enclos): object 'sw_species' not found
```

```r
#subset one of the lists using the $listelementname
sw_species$Ewok %>%
  simplify()
```

```
## Error in eval(expr, envir, enclos): object 'sw_species' not found
```

By default, the map function returns elements in the form of a list. However, there are various *flavors* of map which will return different outputs:

map_* | output
----- | ------
map_chr() | character vector
map_lgl() | logical vector [T or F]
map_int() | integer vector
map_dbl() | double vector (numeric)
map_df()  | as data frame

As an example, let's use the `map_chr` function to grab the `$language` element from each species list which will return a character vector of the languages. Then we will use this character vector to create a data frame linking the languages back to the names of each species.

In order to do so we need to clarify a few things first:

**To specify how the list is used in the function, use the argument .x to denote where the list element goes inside the function. When you want to use .x to show where the element goes in the function, you need to put a ~ in front of the function in the second argument of map().**


```r
data.frame(culture = map_chr(sw_species, ~.x$language)) %>%
  rownames_to_column(var = "character") %>%
  head(10)
```

```
## Error in map_chr(sw_species, ~.x$language): object 'sw_species' not found
```

## More Complex Operations

### Piping

In the examples above, we saw that it is possible to using piping with the map function. The pipe allows us to streamline our code and makes it more human readable. Here's another example.


```r
#create a numeric list
(numlist <- list(c(1:10), c(11:20), c(21:30)))
```

```
## [[1]]
##  [1]  1  2  3  4  5  6  7  8  9 10
## 
## [[2]]
##  [1] 11 12 13 14 15 16 17 18 19 20
## 
## [[3]]
##  [1] 21 22 23 24 25 26 27 28 29 30
```

```r
#use pipes to perform multiple operations
numlist %>%
  map(~.x %>% 
      sum %>% 
      sqrt %>% 
      sin)
```

```
## [[1]]
## [1] 0.9056937
## 
## [[2]]
## [1] -0.1162079
## 
## [[3]]
## [1] -0.2578112
```

Simple mathematical operations are just the tip of the iceberg to what is possible. In this example, we'll create some simulated data for housing around the bay area.


```r
#create a list of areas
area <- list("San Francisco", "Oakland", "San Jose")

#create a list of dataframes with simulated housing data for each area
housing_list <- map(area,
                  ~data.frame(area = .x,
                              price = rnorm(mean = 800000,
                                            n = 100,
                                            sd = 800000/2.5),
                              sq_ft = rnorm(mean = 1200,
                                             n = 100,
                                             sd = 1200/4)
                  )
)

#examine a portion of the simulated data
map(.x = housing_list, .f = ~.x %>% head)
```

```
## [[1]]
##            area      price     sq_ft
## 1 San Francisco  646921.45 1085.0951
## 2 San Francisco  755517.52 1051.7969
## 3 San Francisco 1134824.51 1112.1738
## 4 San Francisco  569618.42 1103.2617
## 5 San Francisco 1225399.32  763.9747
## 6 San Francisco   24070.41 1568.5822
## 
## [[2]]
##      area     price    sq_ft
## 1 Oakland  532545.6 1542.220
## 2 Oakland  920377.7 1221.043
## 3 Oakland  543510.7 1109.990
## 4 Oakland  711821.3 1137.898
## 5 Oakland  997646.5 1597.105
## 6 Oakland 1708571.4 1708.333
## 
## [[3]]
##       area    price    sq_ft
## 1 San Jose 203398.1 1053.876
## 2 San Jose 458297.7 1164.127
## 3 San Jose 530487.8 1109.404
## 4 San Jose 209063.3 1117.105
## 5 San Jose 415793.1 1027.981
## 6 San Jose 803127.7  948.292
```

Now that we have the data let's model each area using the map function.


```r
#model the data using pipes and the map function
#notice that model function AND the summary function fall within the .f argument of the map function
housing_list %>%
  map(.f = ~.x %>% lm(price ~ sq_ft, data = .) %>% summary)
```

```
## [[1]]
## 
## Call:
## lm(formula = price ~ sq_ft, data = .)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -797438 -185796  -29833  248273  658877 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 723791.82  139329.30   5.195 1.12e-06 ***
## sq_ft           29.62     112.44   0.263    0.793    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 341600 on 98 degrees of freedom
## Multiple R-squared:  0.0007075,	Adjusted R-squared:  -0.009489 
## F-statistic: 0.06939 on 1 and 98 DF,  p-value: 0.7928
## 
## 
## [[2]]
## 
## Call:
## lm(formula = price ~ sq_ft, data = .)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -589720 -218907    7794  238216  795423 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 589136.0   133951.4   4.398 2.78e-05 ***
## sq_ft          189.7      105.4   1.800   0.0749 .  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 319900 on 98 degrees of freedom
## Multiple R-squared:  0.032,	Adjusted R-squared:  0.02212 
## F-statistic:  3.24 on 1 and 98 DF,  p-value: 0.07494
## 
## 
## [[3]]
## 
## Call:
## lm(formula = price ~ sq_ft, data = .)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -783525 -243018 -107590  267631 1155758 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)  
## (Intercept)   433411     183092   2.367   0.0199 *
## sq_ft            282        150   1.880   0.0631 .
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 364500 on 98 degrees of freedom
## Multiple R-squared:  0.03482,	Adjusted R-squared:  0.02497 
## F-statistic: 3.535 on 1 and 98 DF,  p-value: 0.06306
```

### Multiple Lists / Datasets

`Purrr` makes it easy to perform function(s) over multiple lists or datasets. For two lists, we can use `map2` which requuires `.x` and `.y`  as your list arguments. `pmap` handles more than two lists.

First let's create a few lists.

```r
#create a list of names
names_list <-map(sw_species, .f = ~.$name)
```

```
## Error in map(sw_species, .f = ~.$name): object 'sw_species' not found
```

```r
#create a list of lifespans
lifespan_list <- map(sw_species, .f = ~.$average_lifespan)
```

```
## Error in map(sw_species, .f = ~.$average_lifespan): object 'sw_species' not found
```

```r
#create a list of languages
language_list <- map(sw_species, .f = ~.$language)
```

```
## Error in map(sw_species, .f = ~.$language): object 'sw_species' not found
```

Now let's create a dataframe using two of the lists.

```r
#create a dataframe with the names and lifespan lists
map2_df(.x = names_list, .y = lifespan_list, .f = ~data.frame(names = .x, avg_lifespan = .y))
```

```
## Error in map2(.x, .y, .f, ...): object 'names_list' not found
```

`pmap` works a little differently. First, we need to create a master list, a *list of lists* so-to-speak.


```r
#create a master list
species_info_list <- list(names = names_list, avg_lifespan = lifespan_list, language = language_list)
```

```
## Error in eval(expr, envir, enclos): object 'names_list' not found
```

```r
pmap_df(.l = species_info_list, .f = function(names, avg_lifespan, language) data.frame(names = names, avg_lifespan = avg_lifespan, language = language))
```

```
## Error in is.data.frame(.l): object 'species_info_list' not found
```

Here's another example using `pmap`. Notice that we don't need to use the function argument to define the list elements.


```r
a <- list(1:100)
b <- list(rnorm(10, 25, 2))
c <- list(seq(from = 10, to = 1000, by = 3))

pmap(.l = list(a,b,c), .f = sum)
```

```
## [[1]]
## [1] 172448
```

## Troubleshooting Lists

### Safely
`safely` runs through a list returning result and error components making it easier to pinpoint issues. 


```r
#create a list 'foo'
foo <- list(3, -10, Inf, "a")

#use map function on foo
map(foo, log)
```

```
## Error in log(x = x, base = base): non-numeric argument to mathematical function
```

As you see, we get an error somewhere in the list. We know that we can't take the log of "a", but what if our list was much larger? It would be very difficult to troubleshoot. This is exactly what `safely` is designed for.


```r
#use safely with map function
map(foo, .f = safely(log, otherwise = NA_real_))
```

```
## [[1]]
## [[1]]$result
## [1] 1.098612
## 
## [[1]]$error
## NULL
## 
## 
## [[2]]
## [[2]]$result
## [1] NaN
## 
## [[2]]$error
## NULL
## 
## 
## [[3]]
## [[3]]$result
## [1] Inf
## 
## [[3]]$error
## NULL
## 
## 
## [[4]]
## [[4]]$result
## [1] NA
## 
## [[4]]$error
## <simpleError in log(x = x, base = base): non-numeric argument to mathematical function>
```

It is useful to use the `transpose` function in conjunction with troubleshooting functions such as `safely` to convert a list of pairs into a pair of lists for easier comprehension.


```r
#use transpose after function to split out results and errors
foo %>%
  map(safely(log, otherwise = NA_real_)) %>% 
  transpose()
```

```
## $result
## $result[[1]]
## [1] 1.098612
## 
## $result[[2]]
## [1] NaN
## 
## $result[[3]]
## [1] Inf
## 
## $result[[4]]
## [1] NA
## 
## 
## $error
## $error[[1]]
## NULL
## 
## $error[[2]]
## NULL
## 
## $error[[3]]
## NULL
## 
## $error[[4]]
## <simpleError in log(x = x, base = base): non-numeric argument to mathematical function>
```

### Possibly

Once we have figured out where the errors exist, we can replace `safely` with `possibly` to implement the change (e.g. inserting an 'NA' where all errors occur) without returning the error message.


```r
#use possibly to output list without errors
foo %>%
  map_dbl(possibly(log, otherwise = NA_real_))
```

```
## [1] 1.098612      NaN      Inf       NA
```

Let's take a look at one more example using the Star Wars Species data we're already familiar with. Within the species list, there is a height subelement indicating the height of each species in centimeters. Let's isolate this element and convertthe measurement to feet.


```r
#extract the height subelement
sw_species %>%
  map(~.$average_height) %>%
  map_dbl(as.numeric) %>%
  map_dbl(~.x * 0.0328084, otherwise = NA_real_)
```

```
## Error in eval(expr, envir, enclos): object 'sw_species' not found
```

### Walk

The `walk` function makes list outputs more human readable. It calls the function (.f) for its *'side-effect'* and returns the input (.x) removing all the unnecessary list bracketing.

In the example below we'll use the `population` dataset from the `tidyr` package to plot year vs. population for a selection of countries. 


```r
library(gridExtra) #for arranging plots

#select a random sample of countries
(countries <- unique(population$country) %>%
  sample(size = 5))
```

```
## [1] "Tokelau"                  "Montserrat"              
## [3] "Uzbekistan"               "United States of America"
## [5] "South Sudan"
```

```r
plots <- population %>%
  filter(country == countries) %>% # filter only countries of interest
  split(.$country) %>% # split the data by country
  map2(.x = .,
       .y = names(.),
       .f = ~ggplot(.x, aes(x = year, y = population)) +
         geom_line() +
         labs(title = .y))

plots %>%
  walk(grid.arrange(grobs = .))
```

```
## Error: Can't convert a list to function
```

![plot of chunk unnamed-chunk-20](/figure/source/2019-01-12-lists-iterations-with-purrr/unnamed-chunk-20-1.png)

## Problem Solving

Now that we have some experience working with various functions in R, let's put our new found skills to the test by solving some problems. The `gh_users` dataset is also from the `repurrrsive` package and provides some data on github users.

First, let's take a look at the dataset.

```r
#summarize the dataset
summary(gh_users)
```

```
## Error in summary(gh_users): object 'gh_users' not found
```

```r
#determine whether the dataset is named
names(gh_users)
```

```
## Error in eval(expr, envir, enclos): object 'gh_users' not found
```

The `gh_users` daatset is comprised of 6 lists each comprised of 30 elements. We also know that the lists do not contain names. Let's take a look at the elements from the first list to see what kind of information is included.


```r
#exmaine the structure of the first list
str(gh_users[[1]])
```

```
## Error in str(gh_users[[1]]): object 'gh_users' not found
```

Now, let's determine which of the users has the most public repositories.


```r
map_int(gh_users, ~.$public_repos) %>% #pull out the # of public repositories
  set_names(map_chr(gh_users, ~.$name)) %>% #assign names to each list element
  sort(decreasing = T) #sort the data
```

```
## Error in map_int(gh_users, ~.$public_repos): object 'gh_users' not found
```

And there you have it. Jennifer Bryan has the most repositories with a whopping 168.

And now for another example. Let's use the `sw_films` and `sw_people` data. Here, we want to join the two datasets so we can plot the height distributions of the characters according to the movies they appear in.


```r
# Turn data into correct dataframe format
film_by_character <- tibble(filmtitle = map_chr(sw_films, ~.$title)) %>%
    mutate(filmtitle, characters = map(sw_films, ~.$characters)) %>%
    unnest()
```

```
## Error in map_chr(sw_films, ~.$title): object 'sw_films' not found
```

```r
# Pull out elements from sw_people
sw_characters <- map_df(sw_people, `[`, c("height", "mass", "name", "url"))
```

```
## Error in map(.x, .f, ...): object 'sw_people' not found
```

```r
# Join the two new objects
character_data <- inner_join(film_by_character, sw_characters, by = c("characters" = "url")) %>%
    # Make sure the columns are numbers
    mutate(height = as.numeric(height), mass = as.numeric(mass))
```

```
## Error in inner_join(film_by_character, sw_characters, by = c(characters = "url")): object 'film_by_character' not found
```

```r
# Plot the heights, faceted by film title
ggplot(character_data, aes(x = height)) +
  geom_histogram(stat = "count") +
  facet_wrap(~ filmtitle)
```

```
## Error in ggplot(character_data, aes(x = height)): object 'character_data' not found
```

---

# Part 2

Now that we have a sense of how `purrr` uses the `map` to iterate over data, let's look at other functions that will make it easier to write more complex code. 

## Mappers

A classical function is also known as a *lambda* or *anonymous* function because it is unnamed and created in the context of the iteration.

There are three main advantages to using mappers: 

* concise
* easy to read 
* reusable

Mappers take on a one-sided formula. We start with a `~` followed by the formula and a `.x` to refer to the list input we want to iterate over in the function. We can also use a single dot `.` or `..1` in place of `.x`. 

Here's an example using the list *numlist* we created earlier in the tutorial.


```r
#examine the list 'numlist'
str(numlist)
```

```
## List of 3
##  $ : int [1:10] 1 2 3 4 5 6 7 8 9 10
##  $ : int [1:10] 11 12 13 14 15 16 17 18 19 20
##  $ : int [1:10] 21 22 23 24 25 26 27 28 29 30
```

```r
#a simple map function 
map(numlist, mean)
```

```
## [[1]]
## [1] 5.5
## 
## [[2]]
## [1] 15.5
## 
## [[3]]
## [1] 25.5
```

```r
# mapper with .
map(numlist, ~ mean(.) + 2)
```

```
## [[1]]
## [1] 7.5
## 
## [[2]]
## [1] 17.5
## 
## [[3]]
## [1] 27.5
```

```r
# mapper with ..1
map(numlist, ~ mean(..1) %>% sqrt)
```

```
## [[1]]
## [1] 2.345208
## 
## [[2]]
## [1] 3.937004
## 
## [[3]]
## [1] 5.049752
```

It is good practice to write a function for anything you have to do more than twice. 

Let's suppose the list *numlist* is temeprature readings in celsius and we want to convert them to farenheit. 


```r
# create a function to convert celsius to farnehit
c_to_f <- function(x){
  (x * 9/5) + 32
}

#iterate over numlist with c_to_f function
map(.x = numlist, .f = c_to_f)
```

```
## [[1]]
##  [1] 33.8 35.6 37.4 39.2 41.0 42.8 44.6 46.4 48.2 50.0
## 
## [[2]]
##  [1] 51.8 53.6 55.4 57.2 59.0 60.8 62.6 64.4 66.2 68.0
## 
## [[3]]
##  [1] 69.8 71.6 73.4 75.2 77.0 78.8 80.6 82.4 84.2 86.0
```

We can also create a mapper using the `as_mapper` function which requires less code.


```r
#create c_to_f function using as_mapper
c_to_f <- as_mapper(~ (.x * 9/5) + 32)

#iterate over numlist with mapper function
map(.x = numlist, .f = c_to_f)
```

```
## [[1]]
##  [1] 33.8 35.6 37.4 39.2 41.0 42.8 44.6 46.4 48.2 50.0
## 
## [[2]]
##  [1] 51.8 53.6 55.4 57.2 59.0 60.8 62.6 64.4 66.2 68.0
## 
## [[3]]
##  [1] 69.8 71.6 73.4 75.2 77.0 78.8 80.6 82.4 84.2 86.0
```

## Cleaning Data with Mappers & Predicates

**80% of data science is cleaning the data. It's not glamarous, but it's the truth.**

When dealing with lists, there are a few useful functions we can utilize in conjunction with mappers to help us clean up the data. We'll refer to these as **predicates**.

Predicate functions are those which test a condition and return either **True** or **False**. `is.numeric` is an example of a predicate function; so are the `>`, `<`, and `==` operators.

On the other hand, *predicate functionals* take an object and a predicate function and return some value. `keep`, `discard`, `every`, and `some` are examples of predicate functionals available in `purrr`.

### Keep & Discard

As the name suggests `keep` is a logical function which will return any data in which the condition is met. `Discard` will do the opposite. 


```r
#examine foo
foo
```

```
## [[1]]
## [1] 3
## 
## [[2]]
## [1] -10
## 
## [[3]]
## [1] Inf
## 
## [[4]]
## [1] "a"
```

```r
#keep character elements
keep(foo, is.character)
```

```
## [[1]]
## [1] "a"
```

Let's take a look at a more complex example. We'll use the `sw_species` list again. Here, we want to discard any species whose lifespan is unknown.


```r
discard(sw_species, ~.x$average_lifespan == 'unknown') %>%
  map("average_lifespan") %>%
  simplify()
```

```
## Error in map_lgl(.x, .p, ...): object 'sw_species' not found
```

Predicate functions work well in conjunction with mappers as in the following example:


```r
#examine numlist
numlist
```

```
## [[1]]
##  [1]  1  2  3  4  5  6  7  8  9 10
## 
## [[2]]
##  [1] 11 12 13 14 15 16 17 18 19 20
## 
## [[3]]
##  [1] 21 22 23 24 25 26 27 28 29 30
```

```r
#mapper for divisible by three
divisible_by_three <- as_mapper(~.x %% 3 == 0)

#map over numlist applying keep and mapper function
map(numlist, ~keep(.x, divisible_by_three))
```

```
## [[1]]
## [1] 3 6 9
## 
## [[2]]
## [1] 12 15 18
## 
## [[3]]
## [1] 21 24 27 30
```

## Writing cleaner code

As we've seen so far, `purrr` is a useful package for writing cleaner code and offers the following advantages:
  
* light - less code written overall
* readable - less repetition, focus on what's being executed
* interpretable - code becomes more specific and easier to understand in the long run
* maintainable - easier to fix if errors arise

In the last section of this tutorial, we'll look at a few more examples of how we can simplify what would otherwise be seemingly complex operations.

### Compose & Partial

The `compose` function allows us to utilize multiple functions. The caveat is that functions are applied right to left within the function itself.

The `partial` function allows us to write a function in which we specify some of the arguments. This could be useful if we know we'll be using a function repeatedly on different datasets where most of the arguments will remain the same.

We'll take a look at the `housing_list` data we created earlier in this tutorial. First, let's summarize the data to see what we're working with.

```r
#summary of housing_list
map(housing_list, summary)
```

```
## [[1]]
##             area         price             sq_ft       
##  San Francisco:100   Min.   : -45273   Min.   : 640.2  
##                      1st Qu.: 576518   1st Qu.: 956.3  
##                      Median : 727350   Median :1148.8  
##                      Mean   : 759373   Mean   :1201.4  
##                      3rd Qu.:1012176   3rd Qu.:1423.7  
##                      Max.   :1433928   Max.   :2230.9  
## 
## [[2]]
##       area         price             sq_ft       
##  Oakland:100   Min.   : 187174   Min.   : 220.7  
##                1st Qu.: 585089   1st Qu.:1027.3  
##                Median : 806553   Median :1233.5  
##                Mean   : 823269   Mean   :1234.5  
##                3rd Qu.:1075599   3rd Qu.:1445.2  
##                Max.   :1708571   Max.   :2185.9  
## 
## [[3]]
##        area         price             sq_ft       
##  San Jose:100   Min.   :-197118   Min.   : 542.6  
##                 1st Qu.: 521412   1st Qu.:1043.3  
##                 Median : 710602   Median :1216.9  
##                 Mean   : 770762   Mean   :1196.3  
##                 3rd Qu.:1059541   3rd Qu.:1319.2  
##                 Max.   :1806416   Max.   :1974.5
```

It appears there are some houses with negative prices. We can't have houses with negative sales prices, that just doesn't make sense. Let's create a `partial` function that discards these negative values.


```r
#partial function to discard negatives
discard_negatives <- partial(discard, .p = ~.x < 0)
```

Unfortunately, I can't use the function by itself because `housing_list` is a list of dataframes and the `discard` function, along with other predicate functions, only works on lists in an elementwise fashion. In the following example, we'll workaround this issue using two useful functions: `transpose` and `flatten`.

`transpose` will turn the list *'inside-out* converting the dataframes into lists. This will allow us to map over the list with the other functions we've composed. Finally, we'll use `flatten` to make the output more readable.


```r
#compose a function that will flatten the data,
#discard the negatives,
#and finally takes the mean of each list
get_means <- compose(round, mean, discard_negatives)

housing_list %>%
  set_names(area) %>%
  transpose() %>%
  map(. %>% map(get_means)) %>%
  map(flatten_df)
```

```
## $area
## # A tibble: 1 x 3
##   `San Francisco` Oakland `San Jose`
##             <dbl>   <dbl>      <dbl>
## 1              NA      NA         NA
## 
## $price
## # A tibble: 1 x 3
##   `San Francisco` Oakland `San Jose`
##             <dbl>   <dbl>      <dbl>
## 1          767501  823269     780539
## 
## $sq_ft
## # A tibble: 1 x 3
##   `San Francisco` Oakland `San Jose`
##             <dbl>   <dbl>      <dbl>
## 1            1201    1234       1196
```


## Putting It All Together

By know, you should have a solid understanding of how the `purrr` package makes writing code much more efficient. From iterating over lists, to troubleshooting,stringing together functions and cleaning data,there's little `purrr` can't handle.

In this final example, we'll use some of what we've learned to split up a dataset using grouping and nesting, create multiple models, and plot the data.


```r
library(modelr)

#compose the function
group_nest <- compose(nest, group_by)

nested_data <- group_nest(mtcars, cyl)

model1 <- function(x){
  lm(mpg ~ wt, data = x)
}


nested_data %>%
  mutate(model = map(data, model1)) %>%
  mutate(pred = map2(data, model, add_predictions)) %>%
  map2(.x = .$pred,
       .y = .$cyl,
       .f = ~ggplot(.x, aes(x = wt))+
         geom_point(aes(y = mpg, colour = "mpg"))+
         geom_point(aes(y = pred, colour = "predicted")) +
         scale_colour_manual("", values = c("mpg"= "black", "predicted" = "red")) +
         labs(title = paste("cylinders: ", .y)) +
         theme(plot.title = element_text(hjust = .5))) %>%
  walk(grid.arrange(grobs = .))
```

```
## Error: Can't convert a list to function
```

![plot of chunk unnamed-chunk-34](/figure/source/2019-01-12-lists-iterations-with-purrr/unnamed-chunk-34-1.png)
