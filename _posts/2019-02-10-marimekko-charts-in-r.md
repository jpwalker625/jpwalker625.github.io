---
title: Marimekko Charts in R
author: JW
date: '2019-02-10'
slug: marimekko-charts-in-r
categories: []
tags:
  - R
  - ggplot2
  - visualization
  - marimekko
---



Hello! In this post we're going to explore some data using a Marimekko chart. This type of visualization is also referred to as a mosaic plot or variable-width chart. The chart functions as a two-dimensional plot encoding two categorical variables. The y-axis is split into stacked bars encoding one variable, each adding up to %100. The variable along the x-axis is divided into segments of varying widths. The chart got its name from the Finnish design company popular for its brightly colored prints and fabrics for which it resmebles in aesthetic and design. Marimekko has been widely adopted within business and management consultancy industries and is generally used to display financial data. This visualization can be difficult to interpret if there are too many segments or making comparisons across boxes since there is no common baseline. As such, it is best to use this chart for displaying a general overview of the data you are working with.

Rather than working with financial data, we're going to be looking at data gathered from the OECD - The Organisation for Economic Co-operation and Development - on global meat consumption. Meat consumption is considered to be the leading cause of global climate change and is a topic I am passionate about. As a result, I thought this would be an interesting topic to explore. Let's get started!

First, load the tidyverse package and read in the data. [^1] 

```r
#load tidyverse package
library(tidyverse)

#read in the data
meat <- read_csv("../_data/meat_consumption.csv")

#examine the dataset
glimpse(meat)
```

```
## Observations: 13,039
## Variables: 8
## $ LOCATION     <chr> "AUS", "AUS", "AUS", "AUS", "AUS", "AUS", "AUS", ...
## $ INDICATOR    <chr> "MEATCONSUMP", "MEATCONSUMP", "MEATCONSUMP", "MEA...
## $ SUBJECT      <chr> "BEEF", "BEEF", "BEEF", "BEEF", "BEEF", "BEEF", "...
## $ MEASURE      <chr> "KG_CAP", "KG_CAP", "KG_CAP", "KG_CAP", "KG_CAP",...
## $ FREQUENCY    <chr> "A", "A", "A", "A", "A", "A", "A", "A", "A", "A",...
## $ TIME         <int> 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1...
## $ Value        <dbl> 27.83349, 26.15241, 25.97048, 25.63061, 25.45058,...
## $ `Flag Codes` <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
```

ALL CAPS...How frightening! Let's fix that first.

```r
# lowercase column names
colnames(meat) <- tolower(colnames(meat))
```

There are 4 main columnms we'll be working with. The *location* column includes countries, the *subject* includes the 4 types of animals consumed, the *measure* column contains two types of measurement values for meat consumption, and *time* which indicates the year of the measurement.


```r
meat %>%
  select(location, subject, measure, time) %>%
  map(unique)
```

```
## $location
##  [1] "AUS"   "CAN"   "JPN"   "KOR"   "MEX"   "NZL"   "TUR"   "USA"  
##  [9] "DZA"   "ARG"   "BGD"   "BRA"   "CHL"   "CHN"   "COL"   "EGY"  
## [17] "ETH"   "GHA"   "HTI"   "IND"   "IDN"   "IRN"   "ISR"   "KAZ"  
## [25] "MYS"   "MOZ"   "NGA"   "PAK"   "PRY"   "PER"   "PHL"   "RUS"  
## [33] "SAU"   "ZAF"   "SDN"   "TZA"   "THA"   "UKR"   "URY"   "VNM"  
## [41] "ZMB"   "WLD"   "SSA"   "OECD"  "BRICS" "EU28"  "NOR"   "CHE"  
## 
## $subject
## [1] "BEEF"    "PIG"     "POULTRY" "SHEEP"  
## 
## $measure
## [1] "KG_CAP"     "THND_TONNE"
## 
## $time
##  [1] 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004
## [15] 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018
## [29] 2019 2020 2021 2022 2023 2024 2025 1990
```
As I mentioned in the introduction, marimekko charts are better suited when there's less going on. It would be impratical to visualize this entire dataset. Instead, I'm going to pick just 4 countries and I'll use the kilograms per capita measurement `"KG_CAP"`. Along with USA, I'll pick 3 countries I've visited in recent years: Peru (PER), Japan (JPN), and New Zealand (NZL). Feel free to explore countries of your own interest.

In addition, we're dealing with data spanning from 1991-2027. Since the latest report came out in 2018, I am only going to use actual reported data (not projected years) between 1991-2017. We can't look at the data from every individual year so I will also summarize the data, taking the mean value for each *location* - *subject* pair. 


```r
# filter the data
top4 <- meat %>%
  filter(location %in% c("USA", "JPN", "PER", "NZL") & 
           measure == "KG_CAP" & time %in% 1991:2017)

# compute the mean cosumption for each country by type of meat
top4_summary <- top4 %>%
  group_by(location, subject) %>%
  summarise(mean_consumption = mean(value))
```

Just so we're on the same page, what we're working with is a dataframe containing our 4 countries of interest. For each of those countries we have the 4 categories of animals consumed. Within each of those categories, we have taken the average value (meat consumed in kilograms / capita) spanning the years 1991-2017. Got it? Good!

Now let's calculate the proportion of meat consumption for each country as a percentage. 

```r
#calculate global total consumption 
(total <- sum(top4_summary$mean_consumption))
```

```
## [1] 242.521
```

```r
#calculate proportion as a percentage of total
location_pct <- top4_summary %>%
  group_by(location) %>%
  summarise(location_prop = (sum(mean_consumption)/total) * 100)
```

In the next part, we need to calculate coordinates for plotting purposes. We will do this by calculating the x-axis min and max in terms of the cumulative sum of the location proportions from above.


```r
# calculate xmin and xmax for each country
location_pct$xmax <- cumsum(location_pct$location_prop)
location_pct$xmin <- location_pct$xmax - location_pct$location_prop
```

Now we'll join this data in with the `top4_summary` data frame. Next we'll calculate the total average annual meat consumption for each country and use this to calculate the meat category proportions on the y-axis.


```r
# join the data frames
top4_summary <- left_join(top4_summary, location_pct)

# sum the total mean_consumption values by location
total_consumption_by_location <- top4_summary %>%
  group_by(location) %>%
  summarise(total_consumption = sum(mean_consumption))

# join the data frames
top4_summary <- left_join(top4_summary, total_consumption_by_location)

# calculate the y-axis min and max values for each type of meat as a proportion of respective country
top4_summary <- top4_summary %>%
  mutate(subject_prop = (mean_consumption/total_consumption) * 100,
         ymax = cumsum(subject_prop),
         ymin = ymax - subject_prop)
```

Before we begin to plot, we need to create coordinates for the text. The following we'll make everything centered in its respective box on the chart.


```r
# calculate text coordinates
top4_summary <- top4_summary %>%
  mutate(xtext = xmin + (xmax - xmin)/2,
         ytext = ymin + (ymax - ymin) /2)
```

And now we're ready to plot the chart! We'll put it together in a series of plots so it's easier to understand all the parts we just calculated.


```r
# create base plot
p <- ggplot(top4_summary, aes(ymin = ymin, ymax = ymax, 
                         xmin = xmin, xmax = xmax, fill = subject))

# add in geometry
p1 <- p + geom_rect(colour = ('grey'))

p1
```

![plot of chunk unnamed-chunk-9](/figure/source/2019-02-10-marimekko-charts-in-r/unnamed-chunk-9-1.png)

In the plot above, we can see we have 4 columns each representing a different country. Within each column, we have the different meat categories. On both the x and y axes, the boxes are scaled to the proportion as a percentage of the overall total consumption of meat type (x-axis) or country (y-axis).

Now, let's add in the some text so we can better understand the chart.


```r
# adding in proportion data
p2 <- p1 + geom_text(aes(x = xtext, y = ytext,
     label = ifelse(location == "JPN", paste(subject,
         " - ", round(subject_prop, 2), "%", sep = ""), paste(round(subject_prop, 2),
         "%", sep = ""))), size = 3)

# adding in country labels
p3 <- p2 + geom_text(aes(x = xtext, y = 103,
     label = paste(location)), size = 4)

# Adding the finishing touches
p3 + theme_bw() + 
  labs(x = NULL, y = NULL, fill = NULL) + 
  scale_x_continuous(expand = c(0,0)) +
  scale_y_continuous(limits = c(0, 105), expand = c(0,0)) +
  theme(legend.position = "none", 
     panel.grid.major = element_line(colour = NA),
     panel.grid.minor = element_line(colour = NA))
```

![plot of chunk unnamed-chunk-10](/figure/source/2019-02-10-marimekko-charts-in-r/unnamed-chunk-10-1.png)

And there you have the **marimekko chart**. Here are a few points we can take away from this chart:

* Sheep is the least consumed meat overall. New Zealand consumes the most sheep meat in kg/capita compared to the other countries and accounts for 21.8% of the countries' overall meat consumption.  
* Pig is consumed most prominently in Japan accounting for 41.38% of its total meat consumption. Japan also has the highest proportion of pig consumption compared to the other countries. 
* Overall, poultry is greatly consumed across all contries and leads in proportion in New Zealand, Peru, and the USA. Peru's proprotion of poultry consumed is much greater than the other countries.
* In terms of total meat consumption, USA is the largest consumer of the 4, followed by New Zealand (as indicated by the width of each column). 

While it is possible to gather useful information from this chart, there are still some challenges. For instance, we don't know the absolute values since we've plotted the proportion as a percentage. Additionally, it's difficult to compare the width of the boxes to determine which countries consume more meat as a function of kilograms per capita. We know that USA and New Zealand consume more meat overall compared to Peru and Japan, however, it's impossible to say how much since we're not dealing with absolute values and furthermore, it's difficult to compare the respective widths of the boxes.

Here is the data displayed differently. 

![plot of chunk unnamed-chunk-11](/figure/source/2019-02-10-marimekko-charts-in-r/unnamed-chunk-11-1.png)

Feedback, questions, or thoughts? Leave a comment below! Thanks for reading!

[^1]: OECD (2019), Meat consumption (indicator). doi: 10.1787/fa290fd0-en (Accessed on 04 February 2019). Source: <https://data.oecd.org/agroutput/meat-consumption.htm>
