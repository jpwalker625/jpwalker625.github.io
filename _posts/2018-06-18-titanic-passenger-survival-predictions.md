---
title: Titanic Passenger Survival Predictions
author: JW
categories:
- R Programming
tags:
- logistic regression
- '2018'
---




# Introduction

Kaggle is a web based platform for data science competitions emphasizing machine learning and predictive analytics. The site provides hundreds (maybe even thousands) of challenges spanning various categories and industries. Many of the challenges are submitted by real companies and offer cash prizes to the individual or team that comes up with the best solution to the challenge. 

In this post, I'm going to tackle my very first competition: "Titanic: Machine Learning from Disaster". This is one of the first Kaggle competitions and serves as a great starting point if you're new to Kaggle or machine learning and data science.

I have included most of the information for the challenge below, but you can visit the [Kaggle website](https://www.kaggle.com/c/titanic) for more information. 

And before I move on, I want to acknowledge **Megan Risdal** for her excellent R tutorial which provided the inspiration and framework for this post. While there are many kernels/notebooks/tutorials focused on the Titanic challenge, few focus on R and even fewer are as clean and intuitive as hers. [Click here to see for yourself](https://www.kaggle.com/mrisdal/exploring-survival-on-the-titanic). Thanks Megan!

# The Competition

As stated in the competition description, the goal of this challenge is to "apply the tools of machine learning to predict which passengers survived the tragedy". 
  
Three data sets are provided: a training set, a test set, and an example submission set. 

We are also given a **Data Dictionary** which defines the variables used in the data sets:

Variable | Definition 
---------|-----------
Survived | 0 = No, 1 = Yes
Pclass	 | Ticket class: 1 = 1st, 2 = 2nd, 3 = 3rd
Sex	     | sex
Age	     | Age in years
Sibsp	   | # of siblings/spouses aboard the Titanic
Parch	   | # of parents/children aboard the Titanic
Ticket	 | Ticket number
Fare	   | Passenger fare
Cabin	   | Cabin number
Embarked | Port of Embarkation: C = Cherbourg, Q = Queenstown, S = Southampton
  
Finally, the overview indicates we can use **feature engineering** to create new variables. This will be an important step for the **exploratory data analysis** portion of this challenge. These new variables (spoiler alert!) will lead to improved performance of the model. 

# Exploratory Data Analysis

Let's get started! If you haven't already done so, download the datasets. Next, set your working directory to the folder where your datasets are using the `setwd()` function or by specifying the path of the file using the `read_csv()` function from the `tidyverse` package.


```r
#Load Required Packages
library(forcats) #for dealing with factors
library(scales) #for various axis formatting
library(mice) #for imputation of missing values
library(randomForest) #for modeling
library(tidyverse) # for everything else

#import training set
train <-read_csv(file = "../_data/train.csv")

#import test set
test <- read_csv(file = "../_data/test.csv")
```

First, I'm going to combine the training and test sets and I'll the combine data set using `glimpse` This is a good way to start any data science exercise and allows you to get a feel for the data.


```r
#combine train and test data
full <- bind_rows(train, test)

#examine the data set
glimpse(full)
```

```
## Observations: 1,309
## Variables: 12
## $ PassengerId <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,...
## $ Survived    <int> 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0,...
## $ Pclass      <int> 3, 1, 3, 1, 3, 3, 1, 3, 3, 2, 3, 1, 3, 3, 3, 2, 3,...
## $ Name        <chr> "Braund, Mr. Owen Harris", "Cumings, Mrs. John Bra...
## $ Sex         <chr> "male", "female", "female", "female", "male", "mal...
## $ Age         <dbl> 22, 38, 26, 35, 35, NA, 54, 2, 27, 14, 4, 58, 20, ...
## $ SibSp       <int> 1, 1, 0, 1, 0, 0, 0, 3, 0, 1, 1, 0, 0, 1, 0, 0, 4,...
## $ Parch       <int> 0, 0, 0, 0, 0, 0, 0, 1, 2, 0, 1, 0, 0, 5, 0, 0, 1,...
## $ Ticket      <chr> "A/5 21171", "PC 17599", "STON/O2. 3101282", "1138...
## $ Fare        <dbl> 7.2500, 71.2833, 7.9250, 53.1000, 8.0500, 8.4583, ...
## $ Cabin       <chr> NA, "C85", NA, "C123", NA, NA, "E46", NA, NA, NA, ...
## $ Embarked    <chr> "S", "C", "S", "S", "S", "Q", "S", "S", "S", "C", ...
```

Based on the information provided in the data dictionary I am going to change the classes of some of the variables.


```r
full <- within(full, {
  Survived <- factor(Survived)
  Pclass <- factor(Pclass)
  Sex <- factor(Sex)
  Age <- as.integer(Age)
  Embarked <- factor(Embarked)
})
```

Now I'll summarize the *full* data set set and see if anything jumps out.


```r
#sumarize the data
summary(full)
```

```
##   PassengerId   Survived   Pclass      Name               Sex     
##  Min.   :   1   0   :549   1:323   Length:1309        female:466  
##  1st Qu.: 328   1   :342   2:277   Class :character   male  :843  
##  Median : 655   NA's:418   3:709   Mode  :character               
##  Mean   : 655                                                     
##  3rd Qu.: 982                                                     
##  Max.   :1309                                                     
##                                                                   
##       Age            SibSp            Parch          Ticket         
##  Min.   : 0.00   Min.   :0.0000   Min.   :0.000   Length:1309       
##  1st Qu.:21.00   1st Qu.:0.0000   1st Qu.:0.000   Class :character  
##  Median :28.00   Median :0.0000   Median :0.000   Mode  :character  
##  Mean   :29.86   Mean   :0.4989   Mean   :0.385                     
##  3rd Qu.:39.00   3rd Qu.:1.0000   3rd Qu.:0.000                     
##  Max.   :80.00   Max.   :8.0000   Max.   :9.000                     
##  NA's   :263                                                        
##       Fare            Cabin           Embarked  
##  Min.   :  0.000   Length:1309        C   :270  
##  1st Qu.:  7.896   Class :character   Q   :123  
##  Median : 14.454   Mode  :character   S   :914  
##  Mean   : 33.295                      NA's:  2  
##  3rd Qu.: 31.275                                
##  Max.   :512.329                                
##  NA's   :1
```

The first thing that catches my attention is the variables with *NA's*: **Survived, Age, Fare, Cabin, and Embarked**. We can ignore **Survived** since this is what we're going to be predicting and we know the test set is the portion that contains all of the missing values.

**Age** contains 263 missing values, **Embarked** has 2, **Fare** has 1, and we're not sure how many **Cabin** has since it was classified as a character variable (though we were able to easily identify the *NAs* in the glimpse view). I'll start with this variable.

## Cabin

Let's find out how many *NAs* this variable contains.


```r
#Count NA rows in Cabin
sum(is.na(full$Cabin))
```

```
## [1] 1014
```

**Cabin** seems like an important predictor variable as it would indicate where the passenger(s) were staying on the boat. One could imagine that those with cabins higher up on the ship may have had a higher chance of survival than those staying in a cabin on the lower decks. What we're really concerned with then is not the actual cabin number but the level of the ship, or **Deck**, denoted by the first letter for each entry.  Because there is so much missing information, it doesn't make sense to impute the missing values but I'll show the next step I would take to extract the **Deck** as a new variable.


```r
#Create variable Deck
cabin_deck <- full %>%
  select(Cabin, Pclass) %>%
  mutate(Deck = factor(str_extract(Cabin, pattern = "^.")))

#Examine the Deck variable
cabin_deck %>%
  select(-Pclass) %>%
  filter(!Cabin == 'NA') %>%
  head(10)
```

```
## # A tibble: 10 x 2
##    Cabin       Deck 
##    <chr>       <fct>
##  1 C85         C    
##  2 C123        C    
##  3 E46         E    
##  4 G6          G    
##  5 C103        C    
##  6 D56         D    
##  7 A6          A    
##  8 C23 C25 C27 C    
##  9 B78         B    
## 10 D33         D
```

```r
#Compare the passenger Class with their position on the Deck
table(cabin_deck$Deck, cabin_deck$Pclass)
```

```
##    
##      1  2  3
##   A 22  0  0
##   B 65  0  0
##   C 94  0  0
##   D 40  6  0
##   E 34  4  3
##   F  0 13  8
##   G  0  0  5
##   T  1  0  0
```

```r
#Calculate the correlation of the 2 variables
cabin_deck %>% select(Pclass, Deck) %>%
  map_df(as.numeric) %>%
  cor(., use = 'complete.obs',method = 'pearson')
```

```
##           Pclass      Deck
## Pclass 1.0000000 0.6108429
## Deck   0.6108429 1.0000000
```

As you see, I extracted the first letter from each row of **Cabin** as the deck which the passenger was staying on. With the complete observations in mind, there does seem to be a trend between the class of the passenger and where they stayed on the ship.
  
## Embarked

Now, let's have a look at the **Embarked** variable. 


```r
#Find rows with missing Embarked data
missing_embarked <- print(which(is.na(full$Embarked)))
```

```
## [1]  62 830
```

```r
#examine the rows with missing data
full[missing_embarked, ]
```

```
## # A tibble: 2 x 12
##   PassengerId Survived Pclass Name    Sex     Age SibSp Parch Ticket  Fare
##         <int> <fct>    <fct>  <chr>   <fct> <int> <int> <int> <chr>  <dbl>
## 1          62 1        1      Icard,… fema…    38     0     0 113572  80.0
## 2         830 1        1      Stone,… fema…    62     0     0 113572  80.0
## # ... with 2 more variables: Cabin <chr>, Embarked <fct>
```

It looks like our passengers were cabin mates in B28 although there does not seem to be any relation to each other as noted by the **SibSp** or **Parch** variables. More useful to us is that both passengers are females in the first class and they're fares were the same, $80. We also know that they were travelling alone.

First I'll subset the data based on the existing information of our passengers with missing values to see whether the resulting data is large enough to make inference on.

```r
#Subset data based on row of interest
missing_embarked_subset <- full %>%
  filter(Pclass == 1 & !PassengerId %in% missing_embarked & Sex == 'female' & Parch == 0 & SibSp == 0)

#Count # of observations
missing_embarked_subset %>%
  count()
```

```
## # A tibble: 1 x 1
##       n
##   <int>
## 1    50
```

50 observations isn't a lot, but it's something we can work with. I'll continue by visualizing this data.


```r
#plot the data
ggplot(data = missing_embarked_subset, aes(x = Embarked, y = Fare)) +
  geom_boxplot(fill = 'steelblue') +
  scale_y_continuous(labels = dollar_format()) +
  geom_hline(yintercept = 80, color = 'firebrick2', size = 0.5, linetype = 5) +
  ggtitle(label = "Fares of 1st Class Female Passengers Traveling Alone by Point of Embarkation", subtitle = "n = 50")
```

![plot of chunk unnamed-chunk-10](/figure/source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-10-1.png)

It's a close call but it seems like our ladies align more closely to the average value of Cherbourg than Southampton. I'm confident in filling their missing values in with *C*.


```r
#assign C to rows with missing 'Embarked' values
full[missing_embarked, "Embarked"] <- "C"
```

## Fare
Next up is the missing **Fare** observation. Let's see who it is.


```r
#Which passenger is missing Fare data
missing_fare <- print(which(is.na(full$Fare)))
```

```
## [1] 1044
```

```r
#Examine passengerId = 1044 data
full[missing_fare, ]
```

```
## # A tibble: 1 x 12
##   PassengerId Survived Pclass Name    Sex     Age SibSp Parch Ticket  Fare
##         <int> <fct>    <fct>  <chr>   <fct> <int> <int> <int> <chr>  <dbl>
## 1        1044 <NA>     3      Storey… male     60     0     0 3701      NA
## # ... with 2 more variables: Cabin <chr>, Embarked <fct>
```

Mr. Storey is a 3rd class passenger who embarked from Southampton (S). Let's see what others similar to him paid for their perilous voyage on the Titanic.


```r
#subset data based on row of interest
missing_fare_subset <- full %>%
  filter(Pclass == 3 & Embarked == 'S' & Sex == 'male' & !PassengerId == missing_fare)

#count # of observations in subset
missing_fare_subset %>%
  count()
```

```
## # A tibble: 1 x 1
##       n
##   <int>
## 1   365
```

```r
#plot the data  
ggplot(missing_fare_subset, aes(x = Fare)) +
  geom_density(fill = 'forestgreen') +
  scale_x_continuous(label = dollar_format(), breaks = seq(0, 60, by = 10)) +
  ggtitle("Density Distribution of Fares for 3rd Class Male Passengers Embarking from Southampton", subtitle = "n = 365")
```

![plot of chunk unnamed-chunk-13](/figure/source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-13-1.png)

```r
#Calculate the mode
fare_mode <- missing_fare_subset %>%
  group_by(Fare) %>%
  summarise(n()) %>%
  top_n(1) %>%
  select(Fare) %>%
  as.integer()

#Observe the mode of the Fare variable from the data subset
fare_mode
```

```
## [1] 8
```

The density plot above indicates the majority of passengers similar to Mr. Storey paid **$8**. I'm confident in filling his fare in with this price.


```r
full[missing_fare, "Fare"] <- 8
```

The only variable with missing values left is **Age**. I'll come back to this variable after exploring some feature engineering.

# Feature Engineering

## Name

The **Name** variable can be broken down into a few different categories. I'll start by extracting the **Surname** so that we can further explore how many families and the family sizes aboard the Titanic. 


```r
#Create new variable 'Surname'
full$Surname <- str_replace(string = full$Name, pattern = ",.*", replacement = "")

#Ensure we extracted the correct information
full %>%
  select(Name, Surname) %>%
  head(10)
```

```
## # A tibble: 10 x 2
##    Name                                                Surname  
##    <chr>                                               <chr>    
##  1 Braund, Mr. Owen Harris                             Braund   
##  2 Cumings, Mrs. John Bradley (Florence Briggs Thayer) Cumings  
##  3 Heikkinen, Miss. Laina                              Heikkinen
##  4 Futrelle, Mrs. Jacques Heath (Lily May Peel)        Futrelle 
##  5 Allen, Mr. William Henry                            Allen    
##  6 Moran, Mr. James                                    Moran    
##  7 McCarthy, Mr. Timothy J                             McCarthy 
##  8 Palsson, Master. Gosta Leonard                      Palsson  
##  9 Johnson, Mrs. Oscar W (Elisabeth Vilhelmina Berg)   Johnson  
## 10 Nasser, Mrs. Nicholas (Adele Achem)                 Nasser
```

```r
#Count the number of families
full %>%
  select(Surname) %>%
  distinct() %>%
  count()
```

```
## # A tibble: 1 x 1
##       n
##   <int>
## 1   875
```

Now, I'll gather the family size for each passenger adding 1 to ensure the passenger is counted in their family.


```r
#Create new variable 'Fam_size'
full <- full %>%
  mutate(Fam_size = SibSp + Parch + 1)

#Ensure the families and their sizes are correct
full %>%
  select(Surname, SibSp, Parch, Fam_size) %>%
   arrange(Surname)%>%
  head(10)
```

```
## # A tibble: 10 x 4
##    Surname     SibSp Parch Fam_size
##    <chr>       <int> <int>    <dbl>
##  1 Abbing          0     0     1.00
##  2 Abbott          1     1     3.00
##  3 Abbott          1     1     3.00
##  4 Abbott          0     2     3.00
##  5 Abelseth        0     0     1.00
##  6 Abelseth        0     0     1.00
##  7 Abelson         1     0     2.00
##  8 Abelson         1     0     2.00
##  9 Abrahamsson     0     0     1.00
## 10 Abrahim         0     0     1.00
```

Does the family size have an affect on the passenger's chance of survival? Let's have a look. (Note that we're only looking at the training portion of the full dataset since the Survival data is missing for the test set.)


```r
#How many of each family size are there?
full %>%
  filter(!Survived == 'NA') %>%
  group_by(Fam_size) %>%
  summarise(Fam_size_count = n())
```

```
## # A tibble: 9 x 2
##   Fam_size Fam_size_count
##      <dbl>          <int>
## 1     1.00            537
## 2     2.00            161
## 3     3.00            102
## 4     4.00             29
## 5     5.00             15
## 6     6.00             22
## 7     7.00             12
## 8     8.00              6
## 9    11.0               7
```

```r
#create table of family size vs. survival
fam_survival <- table(Fam_size = full$Fam_size, Survival = full$Survived)

#create proportion table 1 = row-wise proportions
prop.table(x = fam_survival, margin = 1)
```

```
##         Survival
## Fam_size         0         1
##       1  0.6964618 0.3035382
##       2  0.4472050 0.5527950
##       3  0.4215686 0.5784314
##       4  0.2758621 0.7241379
##       5  0.8000000 0.2000000
##       6  0.8636364 0.1363636
##       7  0.6666667 0.3333333
##       8  1.0000000 0.0000000
##       11 1.0000000 0.0000000
```

After breaking down the family size and count, we know that solo passengers constitute a signficant portion of the dataset (537, 41%) and were less likely to survive. Larger families, those having 5 members or more, were few and were highly likely to perish. Passengers with 2-4 family members were at an advantage compared to the rest and were more likely to survive than not.

Let's check to see if the distribution of family sizes in the test set reflects that of the training data from above.


```r
#subset data of interest
famS_train <- full$Fam_size[1:891]
famS_test <- full$Fam_size[892: 1309]

#define plot parameters
colors <- c("steelblue", "seagreen")
par(mfrow = c(1,2))

#output plots
pwalk(.l = list(x = list(famS_train, famS_test),
           main = c("Train", "Test"),
           col = colors,
           freq = F), .f = hist, xlab ="Family Size")
```

![plot of chunk unnamed-chunk-18](/figure/source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-18-1.png)

As exepected, the distributions of the family sizes are about the same. With that said, I'm going to make a variable (**FamCat**) categorizing the family size (now for the entire **full** dataset). 


```r
full <- full %>%
  mutate(FamCat = factor(case_when(Fam_size == 1 ~ 'single'
                            ,Fam_size > 1 & Fam_size < 5 ~ 'small'
                            ,Fam_size >= 5 ~ 'large')))

#exmaine the family categories
full %>%
  filter(!is.na(Survived)) %>%
  ggplot(aes(x = FamCat, fill = Survived)) +
  geom_bar(position = 'dodge', color = "black") +
  ggtitle(label = "Counts of Categorized Family Sizes", subtitle = "small family: 2-4, large family: 5 or more")
```

![plot of chunk unnamed-chunk-19](/figure/source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-19-1.png)

## Title

Another feature we can extract from the **Name** variable is the person's **Title**.


```r
#Extract all titles from Names
full$Title <- str_replace_all(pattern = '(^.*, )|(\\..*)', replacement = '', string= full$Name)

#Examine the frequencies of the titles
table(full$Sex, full$Title)
```

```
##         
##          Capt Col Don Dona  Dr Jonkheer Lady Major Master Miss Mlle Mme
##   female    0   0   0    1   1        0    1     0      0  260    2   1
##   male      1   4   1    0   7        1    0     2     61    0    0   0
##         
##           Mr Mrs  Ms Rev Sir the Countess
##   female   0 197   2   0   0            1
##   male   757   0   0   8   1            0
```

The majority of titles fall under *Miss, Mr., and Mrs.* However, there are some other titles to look into. After doing a little research, I found out the following:  

**Dona** is the female form of of *Dom* or *Don*, a title of respect and nobility in Spanish, Portuguese, Brazilian, and Southern Italian culture.  
**Master** is a term for politely addressing boys too youung to be called 'Mister'.  
**Mme** is a French term for Madam, which refers to Mrs.  
**Mlle** is also French for a single woman, the equivalent of Miss.  
**Jonkheer** is a medieval term of the European low countries denoting the lowest rank of nobility, which translates to *young lord* or *young lady*.  

I'll take one more step and lump the titles into as few factors as possible.

```r
#factor the Title variable
full$Title <- factor(full$Title)

#recode levels known to be the same
full$Title <- fct_recode(full$Title, Miss = 'Mlle', Mrs = "Mme", Miss = 'Ms')

#lump the other terms - any titles with a frequency less than 10 - into a single factor
full$Title <- fct_lump(f = full$Title, n = 4, other_level = 'Other')

#reexamine the title levels
table(full$Title)
```

```
## 
## Master   Miss    Mrs     Mr  Other 
##     61    264    198    757     29
```

Now that we have the **Title** variable straightened out, let's see if we can infer anything about Survival based on one's title.


```r
full %>%
  filter(!Survived == 'NA') %>%
  ggplot(aes(x = Title, fill = Survived)) +
  geom_bar(position = 'dodge', color = 'black') +
  ggtitle(label = "Survival Count by Title")
```

![plot of chunk unnamed-chunk-22](/figure/source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-22-1.png)

Regardless of whether a woman was single or married, she was more likely to survive than a male passenger.   

## Fare
It would be beneficial to convert *Fare** into a categorical (factored) variable to improve the modeling process, but there are too many discrete values so I'll need to bin the data into subsets. One way we could do this is by looking at the quantiles of the Fare data.


```r
#tally the number of distinct fare values
length(unique(full$Fare))
```

```
## [1] 282
```

```r
#Create quantile with 5 probability cuts
quantile(x = full$Fare, probs = c(0, 0.2, 0.4, 0.6, 0.8, 1))
```

```
##        0%       20%       40%       60%       80%      100% 
##   0.00000   7.85420  10.50000  21.55836  41.57920 512.32920
```

```r
#use cuts to create Categorical bins
full <- full %>%
  mutate(Fare_bin = factor(case_when(Fare <= 7.85420 ~ 0,
                              Fare > 7.85420 & Fare <= 10.5 ~ 1,
                              Fare > 10.5 & Fare <= 21.55836 ~ 2,
                              Fare > 21.55836 & Fare <= 41.5792~ 3,
                              Fare> 41.57920 ~ 4)))

#Visualize the binned fare variable
full %>%
  filter(!Survived == 'NA') %>%
ggplot(aes(x = Fare_bin, fill = Survived))+
  geom_bar(position = 'dodge', color = 'black') +
  facet_wrap(~Sex)
```

![plot of chunk unnamed-chunk-23](/figure/source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-23-1.png)

Generally, the survival rate seems to increase as the Fare increases.

## Age Imputation

Now it's time to tackle the **Age** variable. Recall there are 263 missing values. This is a significant amount but we still have the majority of the data intact. There are a few ways we can tackle missing values. 

1) We already saw thar variables with only a few missing values can be approached in a strategic manner. We were able to make an educated guess as to what the Fare and Embark location was based on similar data. This is a particularly useful strategy when data is abundant.  
2) A quick and dirty way to impute missing values is to use a summary statistic; commonly the **mean**, **median**, or **mode**. This is generally a poor way to handle missing values and should only be used in situations where the variance of the variable you're trying to impute is low. In our case, the distribution of ages is broad and using these summary statistics is not ideal. Let's see what that looks like.


```r
#Calculate Grand Average of Age
age_mean <- mean(full$Age, na.rm = T)
age_median <- median(full$Age, na.rm = T)
age_mode <- full %>%
  group_by(Age) %>%
  filter(!Age == 'NA') %>%
  summarise(n()) %>%
  top_n(1) %>%
  select(Age) %>%
  as.integer()

ggplot(full, aes(Age)) +
  geom_density(fill = 'orchid', alpha =0.7) +
  geom_vline(aes(xintercept = age_mean, color = 'mean'), linetype = 5) +
  geom_vline(aes(xintercept = age_median, color = 'median'), linetype = 5) +
  geom_vline(aes(xintercept = age_mode, color = 'mode'), linetype = 5) +
  scale_color_manual(name = "stats", values = c(mean = 'indianred', median = 'steelblue', mode = 'forestgreen')) +
  ggtitle(label ="Density Distribution of Ages")
```

![plot of chunk unnamed-chunk-24](/figure/source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-24-1.png)

The mean is 30, the median is 28, and the mode is 24. This is a rudimentary method but could be used if the data set was relatively small and/or the variable being imputed had little to no variation (ideally).

3) Building off #2, we can utilize some other variables to break down the data into categories. With these subsets of data, we can then compute the statistic of interest to come up with a value that is more characteristic of that group. We know that the passenger Titles are Sex specific so using these may be redundant but we can get more specific about the various age groups from the title (remember Master is for young boys, and miss is for unmarried women). Let's go with this and see what what we can get. 


```r
#Use Title to break down missing age groups
age_by_title <- full %>%
  filter(!Age == 'NA') %>%
  group_by(Title) %>%
  summarise(average_age = mean(Age),
            median_age = median(Age))


print(age_by_title)
```

```
## # A tibble: 5 x 3
##   Title  average_age median_age
##   <fct>        <dbl>      <dbl>
## 1 Master        5.36       4.00
## 2 Miss         21.8       22.0 
## 3 Mrs          36.9       35.0 
## 4 Mr           32.2       29.0 
## 5 Other        45.2       47.5
```

There's not much difference between the average and median age for each group. Now let's see what the distributions for each of these groups look like compared to the statistics we computed.


```r
full %>%
  filter(!Age == 'NA') %>%
  ggplot(aes(x = Age))+
  geom_density(fill = 'orchid', alpha = 0.7) +
  facet_wrap(~Title, scales = "free") +
  geom_vline(data = age_by_title, aes(xintercept = average_age, color = "mean"), linetype = 5) +
  geom_vline(data = age_by_title, aes(xintercept = median_age, color = 'median'), linetype = 5)+
  scale_colour_manual(values = c(mean = "blue", median = "red"))
```

![plot of chunk unnamed-chunk-26](/figure/source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-26-1.png)

These statistics are much better suited to their respective populations and would be acceptable to use.

And finally,

4) Let's explore **Multivariate Imputation by Chained Equations** using the `MICE` package. The package provides a robust tool set for handling the complex problem of missing values and has the folowing advantages:

* Takes into account the uncertainty of each missing value by creating multiple imputed values for each missing observation
* Ability to apply different imputation methods to different columns with missing values
* Fleixibile at handling different variable types
* Can be used in a broad range of settings

MICE operates under the assumption that values are *Missing At Random*. Unlike other imputation methods, MICE runs a series of regression models where each variable with missing data is modeled conditional upon other variables in the data. 

There are three essential steps for imputing missing values:  

1) Use the `mice` function to impute missing values for a data set. This returns an object with class `mids` that contains a lot of useful information. Different methods (algorithms) can be used. Also, one can adjust the number of imputed data sets as well as the iterations for each imputation that are created in this step. By default, the function defaults to 5 for each.

2) Inspect the imputed datasets using various plotting techniques. This is to check for any anomalies and to ensure the distributions of the imputations match the original data.

3) Use the `complete` function to replace the missing values with the imputed values. 

While this process seems relatively simple and straight forward, the mouse hole goes much deeper. To gain a better understanding of *MICE* and the capabilities of the package, I recommend the following resources: 

 [Multiple Imputation by Chained Equations: What is it and how does it work?](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3074241/)  
 
 [MICE: Multivariate Imputation by Chained Equations](http://stefvanbuuren.github.io/mice/)
 
 

```r
#look at the pattern of missing data in the dataset
md.pattern(full)
```

```
##     PassengerId Pclass Sex SibSp Parch Fare Embarked Fam_size FamCat Title
## 521           1      1   1     1     1    1        1        1      1     1
## 232           1      1   1     1     1    1        1        1      1     1
## 140           1      1   1     1     1    1        1        1      1     1
## 193           1      1   1     1     1    1        1        1      1     1
##  64           1      1   1     1     1    1        1        1      1     1
## 100           1      1   1     1     1    1        1        1      1     1
##  37           1      1   1     1     1    1        1        1      1     1
##  22           1      1   1     1     1    1        1        1      1     1
##               0      0   0     0     0    0        0        0      0     0
##     Fare_bin Age Ticket Survived Name Cabin Surname     
## 521        1   1      1        1    0     0       0    3
## 232        1   1      1        0    0     0       0    4
## 140        1   0      1        1    0     0       0    4
## 193        1   1      0        1    0     0       0    4
##  64        1   0      1        0    0     0       0    5
## 100        1   1      0        0    0     0       0    5
##  37        1   0      0        1    0     0       0    5
##  22        1   0      0        0    0     0       0    6
##            0 263    352      418 1309  1309    1309 4960
```

For each column 1 indicates a complete case where 0 indicates a missing value. The total number of missing cases is indicated at the bottom. On the right hand side, the value indicates the number of missing cases for that particular row and on the left hand side the value indicates how many rows contain that particular pattern of missing cases. To put this into context, the second row indicates there are 529 rows in the dataset that are missing only one obervation coming from the Cabin column. The fourth row indicates there are 245 rows in the dataset where the Survived and Cabin variables are both missing values. 

Now, I'll using the `imp` function using the *Random Forest* method with 5 imputations and 5 iterations. Another nice feature is that the seed can be set within the function for reproducibility purposes. 


```r
#create imp object
imp <- full %>%
  select(-PassengerId, -Survived, -Name, -Ticket, -Cabin, -Surname) %>%
    mice(m = 5, method = 'rf', seed = 1419)
```

```
## 
##  iter imp variable
##   1   1  Age
##   1   2  Age
##   1   3  Age
##   1   4  Age
##   1   5  Age
##   2   1  Age
##   2   2  Age
##   2   3  Age
##   2   4  Age
##   2   5  Age
##   3   1  Age
##   3   2  Age
##   3   3  Age
##   3   4  Age
##   3   5  Age
##   4   1  Age
##   4   2  Age
##   4   3  Age
##   4   4  Age
##   4   5  Age
##   5   1  Age
##   5   2  Age
##   5   3  Age
##   5   4  Age
##   5   5  Age
```

```r
#examine the method used for each variable
imp$method
```

```
##   Pclass      Sex      Age    SibSp    Parch     Fare Embarked Fam_size 
##     "rf"     "rf"     "rf"     "rf"     "rf"     "rf"     "rf"     "rf" 
##   FamCat    Title Fare_bin 
##     "rf"     "rf"     "rf"
```

We can see that the *Random Forest* method was used for the Age column. As mentioned earlier, the `imp` function is flexible to allow different methods to be used for different variables depending on its type (numerical, categorical, binary, etc...). And it may be obvious but I'll mention that variables with complete cases are left as is.

Now let's check the predictor matrix to see which variables (the independent variables) were used to regress the variable of interest (dependent variable). 1's running along each column indicate that variable was used as a predictor for the variable in the row it corresponds to. 



```r
#examine the predictor matrix
imp$predictorMatrix
```

```
##          Pclass Sex Age SibSp Parch Fare Embarked Fam_size FamCat Title
## Pclass        0   0   0     0     0    0        0        0      0     0
## Sex           0   0   0     0     0    0        0        0      0     0
## Age           1   1   0     1     1    1        1        1      1     1
## SibSp         0   0   0     0     0    0        0        0      0     0
## Parch         0   0   0     0     0    0        0        0      0     0
## Fare          0   0   0     0     0    0        0        0      0     0
## Embarked      0   0   0     0     0    0        0        0      0     0
## Fam_size      0   0   0     0     0    0        0        0      0     0
## FamCat        0   0   0     0     0    0        0        0      0     0
## Title         0   0   0     0     0    0        0        0      0     0
## Fare_bin      0   0   0     0     0    0        0        0      0     0
##          Fare_bin
## Pclass          0
## Sex             0
## Age             1
## SibSp           0
## Parch           0
## Fare            0
## Embarked        0
## Fam_size        0
## FamCat          0
## Title           0
## Fare_bin        0
```

Now it's time to explore the **Age** variable for each of the imputed data sets using various visualization tools. 


```r
#Observe missing vs. imputed values as points
stripplot(x = imp, data = Age ~ .imp)
```

![plot of chunk unnamed-chunk-30](/figure/source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-30-1.png)

The stripplot is a nice way to visualize each point. The blue points indicate the  original observed data and the pink points are the imputed values. You may have noticed there are 6 imputations even though we only specified 5 in the function. That's becaue the imputation on the left is the original data set without any imputed values. 

While this is one way of looking at the distribution of the imputed values, we can also examine them by looking at a good old fashioned histogram or density plot. 
First I'll create a dataframe containing all 5 imputd datasets in a long format. New variables .imp and .id are introduced to identify which imputation number the data belongs to.


```r
#complete the datasets in long format with original data included
com <- mice::complete(x = imp, action = 'long', include = T)

#examine the data
glimpse(bind_rows(head(com), tail(com)))
```

```
## Observations: 12
## Variables: 13
## $ .imp     <fct> 0, 0, 0, 0, 0, 0, 5, 5, 5, 5, 5, 5
## $ .id      <fct> 1, 2, 3, 4, 5, 6, 1304, 1305, 1306, 1307, 1308, 1309
## $ Pclass   <fct> 3, 1, 3, 1, 3, 3, 3, 3, 1, 3, 3, 3
## $ Sex      <fct> male, female, female, female, male, male, female, mal...
## $ Age      <int> 22, 38, 26, 35, 35, NA, 28, 24, 39, 38, 23, 9
## $ SibSp    <int> 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1
## $ Parch    <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
## $ Fare     <dbl> 7.2500, 71.2833, 7.9250, 53.1000, 8.0500, 8.4583, 7.7...
## $ Embarked <fct> S, C, S, S, S, Q, S, S, C, S, S, C
## $ Fam_size <dbl> 2, 2, 1, 2, 1, 1, 1, 1, 1, 1, 1, 3
## $ FamCat   <fct> small, small, single, small, single, single, single, ...
## $ Title    <fct> Mr, Mrs, Miss, Mrs, Mr, Mr, Miss, Mr, Other, Mr, Mr, ...
## $ Fare_bin <fct> 0, 4, 1, 4, 1, 1, 0, 1, 4, 0, 1, 3
```

Looking at the first and last 5 rows of the data set we can see the values associated with the original data (.imp = 0) and the 5th imputed dataset(.imp = 5). Now, I'll plot the histograms of the Age variable since this is what we really care about.


```r
ggplot(com, aes(Age, group = .imp, fill = factor(.imp))) + 
  geom_histogram(alpha = 0.76, show.legend = F, color = 'black') + 
  facet_wrap(~.imp, scales = 'free')
```

![plot of chunk unnamed-chunk-32](/figure/source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-32-1.png)

It appears that the imputations are all similarly distributed to the original data set only there are more compared to the original since each imputed dataset now includes both the original and imputed values.

In the last step, I am going to use the 4th imputation to replace the missing **Age** values in the *full* dataset.


```r
#Replace Original Age with RF imputations from the 5th imputed set
complete_age <- mice::complete(imp, 4) %>%
  select(Age)

full$Age <- complete_age$Age

#Check if there are any missing values
sum(is.na(full$Age))
```

```
## [1] 0
```

Although there are no more missing values I'm not quite finished with the Age variable. To improve the modeling process, I want to convert *Age* to a categorical just as I did with the Fare variable.


```r
quantile(full$Age, probs = c(0.2,0.4, 0.6, 0.8, 1))
```

```
##  20%  40%  60%  80% 100% 
##   19   25   31   41   80
```

```r
full <- full %>%
  mutate(Age_bin = factor(case_when(Age <= 19 ~ 0
                                   ,Age > 19 & Age <= 25 ~ 1
                                   ,Age > 25 & Age <= 31 ~ 2
                                   ,Age > 31 & Age <= 42 ~ 3
                                   ,Age > 42 ~ 4)
                          )
         )
```

# Modeling
Let's review the variables in our data set and get rid of some we no longer need.

**Name** - We were able to extract the title for each passenger which proved to be much more valuable than the name feature  
**Age** - We have converted the ages into categorical bins so we can drop this variable  
**SibSp, Parch** The family size and category variables were built off of these  
**Ticket** - As far as I know these values are random character strings and don't serve much purpose  
**Fare** - We have converted the values into a binned categorical variable so we can drop this one  
**Cabin** - Too many NA values to be meaningful or to attempt imputation  
**Surname** - Was used to calculate the family size so this can be dropped as well  


```r
#remove unneeded vars
full_subset <- full %>%
  select(-Name, -Age, -SibSp, -Parch, -Ticket, -Fare, -Cabin, -Surname)

#examine remaining column names
names(full_subset)
```

```
##  [1] "PassengerId" "Survived"    "Pclass"      "Sex"         "Embarked"   
##  [6] "Fam_size"    "FamCat"      "Title"       "Fare_bin"    "Age_bin"
```

Now it's time to split the data back into the training and test set. 


```r
#split data back intro train and test set
train <- full_subset[1:891, ]
test <- full_subset[892:1309, ]
```

Finally, it's time to build a model. I've decided to use the Random Forest algorithm which is great for classification problems, easy  to use, has relatively few hyperparameters, and also makes it easy to view the importance of the variables used in the modeling process. 


```r
#build model using random forest
rf_model <- train %>%
  select(-PassengerId) %>%
  randomForest(Survived ~ ., data = .)

#examine the results of the model
rf_model
```

```
## 
## Call:
##  randomForest(formula = Survived ~ ., data = .) 
##                Type of random forest: classification
##                      Number of trees: 500
## No. of variables tried at each split: 2
## 
##         OOB estimate of  error rate: 16.95%
## Confusion matrix:
##     0   1 class.error
## 0 498  51  0.09289617
## 1 100 242  0.29239766
```

```r
#plot the model
plot(rf_model)
```

![plot of chunk unnamed-chunk-37](/figure/source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-37-1.png)

The plot indicates that the overall error rate flattens out after about 125 trees or so. The black line represents the sample error, more commonly referred to as Out of Bag error which is the overall error rate of the model (~18%). The error rate in predicting survivors is signficantly higher (green line, ~30%) than predicting non-survivors (red line, ~10%). 

Let's take a look at the variable importance.


```r
#plot the variable importance 
randomForest::varImpPlot(rf_model, main = 'Variable Importance of Random Forest Model')
```

![plot of chunk unnamed-chunk-38](/figure/source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-38-1.png)

And now it's time to use the model to make predictions on the test set. 



```r
#make predictions on test set
test$Survived <- predict(rf_model, newdata = test)

#assign parameters
names <- c("Train Set", "Test Set")
colors <- c("steelblue", "seagreen")

#Set up plot dimensions
par(mfrow=c(1,2))

pwalk(.l = list(x = list(train$Survived, test$Survived),
               xlab = "Survived",
               col = colors,
               main = names), .f = plot)
```

![plot of chunk unnamed-chunk-39](/figure/source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-39-1.png)

We can see that the proportion of outcomes in the test set reflects that of the training set. That's exactly what we'd expect our model to do. And how well did the model do at actually predicting the correct Survivors? After submitting my answers, I got a score of 0.77511. Not too bad! Certainly there are other opportunities to improve the prediction score; perhaps another time.

This concludes our journey through the **Titanic: Machine Learning From Disaster** Kaggle challenge. I hope you enjoyed this post and learned a thing or two along the way. Thanks for reading!



