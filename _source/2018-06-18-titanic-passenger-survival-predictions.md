---
title: "Titanic Passenger Survival Predictions"
author: "Joseph Walker"
date: '2018-06-18'
slug: titanic-passenger-survival-predictions
tags:
- data science
- datasets
- kaggle
- logistic regression
- machine leaning
- predictions
- R
categories:
- data science
- kaggle
- logistic regression
- R
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


{% highlight r %}
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
{% endhighlight %}

First, I'm going to combine the training and test sets and I'll the combine data set using `glimpse` This is a good way to start any data science exercise and allows you to get a feel for the data.


{% highlight r %}
#combine train and test data
full <- bind_rows(train, test)

#examine the data set
glimpse(full)
{% endhighlight %}



{% highlight text %}
## Observations: 1,309
## Variables: 12
## $ PassengerId <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14...
## $ Survived    <int> 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, ...
## $ Pclass      <int> 3, 1, 3, 1, 3, 3, 1, 3, 3, 2, 3, 1, 3, 3, 3, ...
## $ Name        <chr> "Braund, Mr. Owen Harris", "Cumings, Mrs. Joh...
## $ Sex         <chr> "male", "female", "female", "female", "male",...
## $ Age         <dbl> 22, 38, 26, 35, 35, NA, 54, 2, 27, 14, 4, 58,...
## $ SibSp       <int> 1, 1, 0, 1, 0, 0, 0, 3, 0, 1, 1, 0, 0, 1, 0, ...
## $ Parch       <int> 0, 0, 0, 0, 0, 0, 0, 1, 2, 0, 1, 0, 0, 5, 0, ...
## $ Ticket      <chr> "A/5 21171", "PC 17599", "STON/O2. 3101282", ...
## $ Fare        <dbl> 7.250, 71.283, 7.925, 53.100, 8.050, 8.458, 5...
## $ Cabin       <chr> NA, "C85", NA, "C123", NA, NA, "E46", NA, NA,...
## $ Embarked    <chr> "S", "C", "S", "S", "S", "Q", "S", "S", "S", ...
{% endhighlight %}

Based on the information provided in the data dictionary I am going to change the classes of some of the variables.


{% highlight r %}
full <- within(full, {
  Survived <- factor(Survived)
  Pclass <- factor(Pclass)
  Sex <- factor(Sex)
  Age <- as.integer(Age)
  Embarked <- factor(Embarked)
})
{% endhighlight %}

Now I'll summarize the *full* data set set and see if anything jumps out.


{% highlight r %}
#sumarize the data
summary(full)
{% endhighlight %}



{% highlight text %}
##   PassengerId   Survived   Pclass      Name               Sex     
##  Min.   :   1   0   :549   1:323   Length:1309        female:466  
##  1st Qu.: 328   1   :342   2:277   Class :character   male  :843  
##  Median : 655   NA's:418   3:709   Mode  :character               
##  Mean   : 655                                                     
##  3rd Qu.: 982                                                     
##  Max.   :1309                                                     
##                                                                   
##       Age           SibSp           Parch          Ticket         
##  Min.   : 0.0   Min.   :0.000   Min.   :0.000   Length:1309       
##  1st Qu.:21.0   1st Qu.:0.000   1st Qu.:0.000   Class :character  
##  Median :28.0   Median :0.000   Median :0.000   Mode  :character  
##  Mean   :29.9   Mean   :0.499   Mean   :0.385                     
##  3rd Qu.:39.0   3rd Qu.:1.000   3rd Qu.:0.000                     
##  Max.   :80.0   Max.   :8.000   Max.   :9.000                     
##  NA's   :263                                                      
##       Fare          Cabin           Embarked  
##  Min.   :  0.0   Length:1309        C   :270  
##  1st Qu.:  7.9   Class :character   Q   :123  
##  Median : 14.5   Mode  :character   S   :914  
##  Mean   : 33.3                      NA's:  2  
##  3rd Qu.: 31.3                                
##  Max.   :512.3                                
##  NA's   :1
{% endhighlight %}

The first thing that catches my attention is the variables with *NA's*: **Survived, Age, Fare, Cabin, and Embarked**. We can ignore **Survived** since this is what we're going to be predicting and we know the test set is the portion that contains all of the missing values.

**Age** contains 263 missing values, **Embarked** has 2, **Fare** has 1, and we're not sure how many **Cabin** has since it was classified as a character variable (though we were able to easily identify the *NAs* in the glimpse view). I'll start with this variable.

## Cabin

Let's find out how many *NAs* this variable contains.


{% highlight r %}
#Count NA rows in Cabin
sum(is.na(full$Cabin))
{% endhighlight %}



{% highlight text %}
## [1] 1014
{% endhighlight %}

**Cabin** seems like an important predictor variable as it would indicate where the passenger(s) were staying on the boat. One could imagine that those with cabins higher up on the ship may have had a higher chance of survival than those staying in a cabin on the lower decks. What we're really concerned with then is not the actual cabin number but the level of the ship, or **Deck**, denoted by the first letter for each entry.  Because there is so much missing information, it doesn't make sense to impute the missing values but I'll show the next step I would take to extract the **Deck** as a new variable.


{% highlight r %}
#Create variable Deck
cabin_deck <- full %>%
  select(Cabin, Pclass) %>%
  mutate(Deck = factor(str_extract(Cabin, pattern = "^.")))

#Examine the Deck variable
cabin_deck %>%
  select(-Pclass) %>%
  filter(!Cabin == 'NA') %>%
  head(10)
{% endhighlight %}



{% highlight text %}
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
{% endhighlight %}



{% highlight r %}
#Compare the passenger Class with their position on the Deck
table(cabin_deck$Deck, cabin_deck$Pclass)
{% endhighlight %}



{% highlight text %}
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
{% endhighlight %}



{% highlight r %}
#Calculate the correlation of the 2 variables
cabin_deck %>% select(Pclass, Deck) %>%
  map_df(as.numeric) %>%
  cor(., use = 'complete.obs',method = 'pearson')
{% endhighlight %}



{% highlight text %}
##        Pclass   Deck
## Pclass 1.0000 0.6108
## Deck   0.6108 1.0000
{% endhighlight %}

As you see, I extracted the first letter from each row of **Cabin** as the deck which the passenger was staying on. With the complete observations in mind, there does seem to be a trend between the class of the passenger and where they stayed on the ship.
  
## Embarked

Now, let's have a look at the **Embarked** variable. 


{% highlight r %}
#Find rows with missing Embarked data
missing_embarked <- print(which(is.na(full$Embarked)))
{% endhighlight %}



{% highlight text %}
## [1]  62 830
{% endhighlight %}



{% highlight r %}
#examine the rows with missing data
full[missing_embarked, ]
{% endhighlight %}



{% highlight text %}
## # A tibble: 2 x 12
##   PassengerId Survived Pclass Name     Sex     Age SibSp Parch Ticket
##         <int> <fct>    <fct>  <chr>    <fct> <int> <int> <int> <chr> 
## 1          62 1        1      Icard, … fema…    38     0     0 113572
## 2         830 1        1      Stone, … fema…    62     0     0 113572
## # ... with 3 more variables: Fare <dbl>, Cabin <chr>, Embarked <fct>
{% endhighlight %}

It looks like our passengers were cabin mates in B28 although there does not seem to be any relation to each other as noted by the **SibSp** or **Parch** variables. More useful to us is that both passengers are females in the first class and they're fares were the same, $80. We also know that they were travelling alone.

First I'll subset the data based on the existing information of our passengers with missing values to see whether the resulting data is large enough to make inference on.

{% highlight r %}
#Subset data based on row of interest
missing_embarked_subset <- full %>%
  filter(Pclass == 1 & !PassengerId %in% missing_embarked & Sex == 'female' & Parch == 0 & SibSp == 0)

#Count # of observations
missing_embarked_subset %>%
  count()
{% endhighlight %}



{% highlight text %}
## # A tibble: 1 x 1
##       n
##   <int>
## 1    50
{% endhighlight %}

50 observations isn't a lot, but it's something we can work with. I'll continue by visualizing this data.


{% highlight r %}
#plot the data
ggplot(data = missing_embarked_subset, aes(x = Embarked, y = Fare)) +
  geom_boxplot(fill = 'steelblue') +
  scale_y_continuous(labels = dollar_format()) +
  geom_hline(yintercept = 80, color = 'firebrick2', size = 0.5, linetype = 5) +
  ggtitle(label = "Fares of 1st Class Female Passengers Traveling Alone by Point of Embarkation", subtitle = "n = 50")
{% endhighlight %}

![plot of chunk unnamed-chunk-10](/figure/./_source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-10-1.png)

It's a close call but it seems like our ladies align more closely to the average value of Cherbourg than Southampton. I'm confident in filling their missing values in with *C*.


{% highlight r %}
#assign C to rows with missing 'Embarked' values
full[missing_embarked, "Embarked"] <- "C"
{% endhighlight %}

## Fare
Next up is the missing **Fare** observation. Let's see who it is.


{% highlight r %}
#Which passenger is missing Fare data
missing_fare <- print(which(is.na(full$Fare)))
{% endhighlight %}



{% highlight text %}
## [1] 1044
{% endhighlight %}



{% highlight r %}
#Examine passengerId = 1044 data
full[missing_fare, ]
{% endhighlight %}



{% highlight text %}
## # A tibble: 1 x 12
##   PassengerId Survived Pclass Name     Sex     Age SibSp Parch Ticket
##         <int> <fct>    <fct>  <chr>    <fct> <int> <int> <int> <chr> 
## 1        1044 <NA>     3      Storey,… male     60     0     0 3701  
## # ... with 3 more variables: Fare <dbl>, Cabin <chr>, Embarked <fct>
{% endhighlight %}

Mr. Storey is a 3rd class passenger who embarked from Southampton (S). Let's see what others similar to him paid for their perilous voyage on the Titanic.


{% highlight r %}
#subset data based on row of interest
missing_fare_subset <- full %>%
  filter(Pclass == 3 & Embarked == 'S' & Sex == 'male' & !PassengerId == missing_fare)

#count # of observations in subset
missing_fare_subset %>%
  count()
{% endhighlight %}



{% highlight text %}
## # A tibble: 1 x 1
##       n
##   <int>
## 1   365
{% endhighlight %}



{% highlight r %}
#plot the data  
ggplot(missing_fare_subset, aes(x = Fare)) +
  geom_density(fill = 'forestgreen') +
  scale_x_continuous(label = dollar_format(), breaks = seq(0, 60, by = 10)) +
  ggtitle("Density Distribution of Fares for 3rd Class Male Passengers Embarking from Southampton", subtitle = "n = 365")
{% endhighlight %}

![plot of chunk unnamed-chunk-13](/figure/./_source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-13-1.png)

{% highlight r %}
#Calculate the mode
fare_mode <- missing_fare_subset %>%
  group_by(Fare) %>%
  summarise(n()) %>%
  top_n(1) %>%
  select(Fare) %>%
  as.integer()

#Observe the mode of the Fare variable from the data subset
fare_mode
{% endhighlight %}



{% highlight text %}
## [1] 8
{% endhighlight %}

The density plot above indicates the majority of passengers similar to Mr. Storey paid **$8**. I'm confident in filling his fare in with this price.


{% highlight r %}
full[missing_fare, "Fare"] <- 8
{% endhighlight %}

The only variable with missing values left is **Age**. I'll come back to this variable after exploring some feature engineering.

# Feature Engineering

## Name

The **Name** variable can be broken down into a few different categories. I'll start by extracting the **Surname** so that we can further explore how many families and the family sizes aboard the Titanic. 


{% highlight r %}
#Create new variable 'Surname'
full$Surname <- str_replace(string = full$Name, pattern = ",.*", replacement = "")

#Ensure we extracted the correct information
full %>%
  select(Name, Surname) %>%
  head(10)
{% endhighlight %}



{% highlight text %}
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
{% endhighlight %}



{% highlight r %}
#Count the number of families
full %>%
  select(Surname) %>%
  distinct() %>%
  count()
{% endhighlight %}



{% highlight text %}
## # A tibble: 1 x 1
##       n
##   <int>
## 1   875
{% endhighlight %}

Now, I'll gather the family size for each passenger adding 1 to ensure the passenger is counted in their family.


{% highlight r %}
#Create new variable 'Fam_size'
full <- full %>%
  mutate(Fam_size = SibSp + Parch + 1)

#Ensure the families and their sizes are correct
full %>%
  select(Surname, SibSp, Parch, Fam_size) %>%
   arrange(Surname)%>%
  head(10)
{% endhighlight %}



{% highlight text %}
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
{% endhighlight %}

Does the family size have an affect on the passenger's chance of survival? Let's have a look. (Note that we're only looking at the training portion of the full dataset since the Survival data is missing for the test set.)


{% highlight r %}
#How many of each family size are there?
full %>%
  filter(!Survived == 'NA') %>%
  group_by(Fam_size) %>%
  summarise(Fam_size_count = n())
{% endhighlight %}



{% highlight text %}
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
{% endhighlight %}



{% highlight r %}
#create table of family size vs. survival
fam_survival <- table(Fam_size = full$Fam_size, Survival = full$Survived)

#create proportion table 1 = row-wise proportions
prop.table(x = fam_survival, margin = 1)
{% endhighlight %}



{% highlight text %}
##         Survival
## Fam_size      0      1
##       1  0.6965 0.3035
##       2  0.4472 0.5528
##       3  0.4216 0.5784
##       4  0.2759 0.7241
##       5  0.8000 0.2000
##       6  0.8636 0.1364
##       7  0.6667 0.3333
##       8  1.0000 0.0000
##       11 1.0000 0.0000
{% endhighlight %}

After breaking down the family size and count, we know that solo passengers constitute a signficant portion of the dataset (537, 41%) and were less likely to survive. Larger families, those having 5 members or more, were few and were highly likely to perish. Passengers with 2-4 family members were at an advantage compared to the rest and were more likely to survive than not.

Let's check to see if the distribution of family sizes in the test set reflects that of the training data from above.


{% highlight r %}
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
{% endhighlight %}

![plot of chunk unnamed-chunk-18](/figure/./_source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-18-1.png)

As exepected, the distributions of the family sizes are about the same. With that said, I'm going to make a variable (**FamCat**) categorizing the family size (now for the entire **full** dataset). 


{% highlight r %}
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
{% endhighlight %}

![plot of chunk unnamed-chunk-19](/figure/./_source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-19-1.png)

## Title

Another feature we can extract from the **Name** variable is the person's **Title**.


{% highlight r %}
#Extract all titles from Names
full$Title <- str_replace_all(pattern = '(^.*, )|(\\..*)', replacement = '', string= full$Name)

#Examine the frequencies of the titles
table(full$Sex, full$Title)
{% endhighlight %}



{% highlight text %}
##         
##          Capt Col Don Dona  Dr Jonkheer Lady Major Master Miss Mlle
##   female    0   0   0    1   1        0    1     0      0  260    2
##   male      1   4   1    0   7        1    0     2     61    0    0
##         
##          Mme  Mr Mrs  Ms Rev Sir the Countess
##   female   1   0 197   2   0   0            1
##   male     0 757   0   0   8   1            0
{% endhighlight %}

The majority of titles fall under *Miss, Mr., and Mrs.* However, there are some other titles to look into. After doing a little research, I found out the following:  

**Dona** is the female form of of *Dom* or *Don*, a title of respect and nobility in Spanish, Portuguese, Brazilian, and Southern Italian culture.  
**Master** is a term for politely addressing boys too youung to be called 'Mister'.  
**Mme** is a French term for Madam, which refers to Mrs.  
**Mlle** is also French for a single woman, the equivalent of Miss.  
**Jonkheer** is a medieval term of the European low countries denoting the lowest rank of nobility, which translates to *young lord* or *young lady*.  

I'll take one more step and lump the titles into as few factors as possible.

{% highlight r %}
#factor the Title variable
full$Title <- factor(full$Title)

#recode levels known to be the same
full$Title <- fct_recode(full$Title, Miss = 'Mlle', Mrs = "Mme", Miss = 'Ms')

#lump the other terms - any titles with a frequency less than 10 - into a single factor
full$Title <- fct_lump(f = full$Title, n = 4, other_level = 'Other')

#reexamine the title levels
table(full$Title)
{% endhighlight %}



{% highlight text %}
## 
## Master   Miss    Mrs     Mr  Other 
##     61    264    198    757     29
{% endhighlight %}

Now that we have the **Title** variable straightened out, let's see if we can infer anything about Survival based on one's title.


{% highlight r %}
full %>%
  filter(!Survived == 'NA') %>%
  ggplot(aes(x = Title, fill = Survived)) +
  geom_bar(position = 'dodge', color = 'black') +
  ggtitle(label = "Survival Count by Title")
{% endhighlight %}

![plot of chunk unnamed-chunk-22](/figure/./_source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-22-1.png)

Regardless of whether a woman was single or married, she was more likely to survive than a male passenger.   

## Fare
It would be beneficial to convert *Fare** into a categorical (factored) variable to improve the modeling process, but there are too many discrete values so I'll need to bin the data into subsets. One way we could do this is by looking at the quantiles of the Fare data.


{% highlight r %}
#tally the number of distinct fare values
length(unique(full$Fare))
{% endhighlight %}



{% highlight text %}
## [1] 282
{% endhighlight %}



{% highlight r %}
#Create quantile with 5 probability cuts
quantile(x = full$Fare, probs = c(0, 0.2, 0.4, 0.6, 0.8, 1))
{% endhighlight %}



{% highlight text %}
##      0%     20%     40%     60%     80%    100% 
##   0.000   7.854  10.500  21.558  41.579 512.329
{% endhighlight %}



{% highlight r %}
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
{% endhighlight %}

![plot of chunk unnamed-chunk-23](/figure/./_source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-23-1.png)

Generally, the survival rate seems to increase as the Fare increases.

## Age Imputation

Now it's time to tackle the **Age** variable. Recall there are 263 missing values. This is a significant amount but we still have the majority of the data intact. There are a few ways we can tackle missing values. 

1) We already saw thar variables with only a few missing values can be approached in a strategic manner. We were able to make an educated guess as to what the Fare and Embark location was based on similar data. This is a particularly useful strategy when data is abundant.  
2) A quick and dirty way to impute missing values is to use a summary statistic; commonly the **mean**, **median**, or **mode**. This is generally a poor way to handle missing values and should only be used in situations where the variance of the variable you're trying to impute is low. In our case, the distribution of ages is broad and using these summary statistics is not ideal. Let's see what that looks like.


{% highlight r %}
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
{% endhighlight %}

![plot of chunk unnamed-chunk-24](/figure/./_source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-24-1.png)

The mean is 30, the median is 28, and the mode is 24. This is a rudimentary method but could be used if the data set was relatively small and/or the variable being imputed had little to no variation (ideally).

3) Building off #2, we can utilize some other variables to break down the data into categories. With these subsets of data, we can then compute the statistic of interest to come up with a value that is more characteristic of that group. We know that the passenger Titles are Sex specific so using these may be redundant but we can get more specific about the various age groups from the title (remember Master is for young boys, and miss is for unmarried women). Let's go with this and see what what we can get. 


{% highlight r %}
#Use Title to break down missing age groups
age_by_title <- full %>%
  filter(!Age == 'NA') %>%
  group_by(Title) %>%
  summarise(average_age = mean(Age),
            median_age = median(Age))


print(age_by_title)
{% endhighlight %}



{% highlight text %}
## # A tibble: 5 x 3
##   Title  average_age median_age
##   <fct>        <dbl>      <dbl>
## 1 Master        5.36       4.00
## 2 Miss         21.8       22.0 
## 3 Mrs          36.9       35.0 
## 4 Mr           32.2       29.0 
## 5 Other        45.2       47.5
{% endhighlight %}

There's not much difference between the average and median age for each group. Now let's see what the distributions for each of these groups look like compared to the statistics we computed.


{% highlight r %}
full %>%
  filter(!Age == 'NA') %>%
  ggplot(aes(x = Age))+
  geom_density(fill = 'orchid', alpha = 0.7) +
  facet_wrap(~Title, scales = "free") +
  geom_vline(data = age_by_title, aes(xintercept = average_age, color = "mean"), linetype = 5) +
  geom_vline(data = age_by_title, aes(xintercept = median_age, color = 'median'), linetype = 5)+
  scale_colour_manual(values = c(mean = "blue", median = "red"))
{% endhighlight %}

![plot of chunk unnamed-chunk-26](/figure/./_source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-26-1.png)

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
 
 

{% highlight r %}
#look at the pattern of missing data in the dataset
md.pattern(full)
{% endhighlight %}



{% highlight text %}
##     PassengerId Pclass Sex SibSp Parch Fare Embarked Fam_size FamCat
## 521           1      1   1     1     1    1        1        1      1
## 232           1      1   1     1     1    1        1        1      1
## 140           1      1   1     1     1    1        1        1      1
## 193           1      1   1     1     1    1        1        1      1
##  64           1      1   1     1     1    1        1        1      1
## 100           1      1   1     1     1    1        1        1      1
##  37           1      1   1     1     1    1        1        1      1
##  22           1      1   1     1     1    1        1        1      1
##               0      0   0     0     0    0        0        0      0
##     Title Fare_bin Age Ticket Survived Name Cabin Surname     
## 521     1        1   1      1        1    0     0       0    3
## 232     1        1   1      1        0    0     0       0    4
## 140     1        1   0      1        1    0     0       0    4
## 193     1        1   1      0        1    0     0       0    4
##  64     1        1   0      1        0    0     0       0    5
## 100     1        1   1      0        0    0     0       0    5
##  37     1        1   0      0        1    0     0       0    5
##  22     1        1   0      0        0    0     0       0    6
##         0        0 263    352      418 1309  1309    1309 4960
{% endhighlight %}

For each column 1 indicates a complete case where 0 indicates a missing value. The total number of missing cases is indicated at the bottom. On the right hand side, the value indicates the number of missing cases for that particular row and on the left hand side the value indicates how many rows contain that particular pattern of missing cases. To put this into context, the second row indicates there are 529 rows in the dataset that are missing only one obervation coming from the Cabin column. The fourth row indicates there are 245 rows in the dataset where the Survived and Cabin variables are both missing values. 

Now, I'll using the `imp` function using the *Random Forest* method with 5 imputations and 5 iterations. Another nice feature is that the seed can be set within the function for reproducibility purposes. 


{% highlight r %}
#create imp object
imp <- full %>%
  select(-PassengerId, -Survived, -Name, -Ticket, -Cabin, -Surname) %>%
    mice(m = 5, method = 'rf', seed = 1419)
{% endhighlight %}



{% highlight text %}
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
{% endhighlight %}



{% highlight r %}
#examine the method used for each variable
imp$method
{% endhighlight %}



{% highlight text %}
##   Pclass      Sex      Age    SibSp    Parch     Fare Embarked 
##     "rf"     "rf"     "rf"     "rf"     "rf"     "rf"     "rf" 
## Fam_size   FamCat    Title Fare_bin 
##     "rf"     "rf"     "rf"     "rf"
{% endhighlight %}

We can see that the *Random Forest* method was used for the Age column. As mentioned earlier, the `imp` function is flexible to allow different methods to be used for different variables depending on its type (numerical, categorical, binary, etc...). And it may be obvious but I'll mention that variables with complete cases are left as is.

Now let's check the predictor matrix to see which variables (the independent variables) were used to regress the variable of interest (dependent variable). 1's running along each column indicate that variable was used as a predictor for the variable in the row it corresponds to. 



{% highlight r %}
#examine the predictor matrix
imp$predictorMatrix
{% endhighlight %}



{% highlight text %}
##          Pclass Sex Age SibSp Parch Fare Embarked Fam_size FamCat
## Pclass        0   0   0     0     0    0        0        0      0
## Sex           0   0   0     0     0    0        0        0      0
## Age           1   1   0     1     1    1        1        1      1
## SibSp         0   0   0     0     0    0        0        0      0
## Parch         0   0   0     0     0    0        0        0      0
## Fare          0   0   0     0     0    0        0        0      0
## Embarked      0   0   0     0     0    0        0        0      0
## Fam_size      0   0   0     0     0    0        0        0      0
## FamCat        0   0   0     0     0    0        0        0      0
## Title         0   0   0     0     0    0        0        0      0
## Fare_bin      0   0   0     0     0    0        0        0      0
##          Title Fare_bin
## Pclass       0        0
## Sex          0        0
## Age          1        1
## SibSp        0        0
## Parch        0        0
## Fare         0        0
## Embarked     0        0
## Fam_size     0        0
## FamCat       0        0
## Title        0        0
## Fare_bin     0        0
{% endhighlight %}

Now it's time to explore the **Age** variable for each of the imputed data sets using various visualization tools. 


{% highlight r %}
#Observe missing vs. imputed values as points
stripplot(x = imp, data = Age ~ .imp)
{% endhighlight %}

![plot of chunk unnamed-chunk-30](/figure/./_source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-30-1.png)

The stripplot is a nice way to visualize each point. The blue points indicate the  original observed data and the pink points are the imputed values. You may have noticed there are 6 imputations even though we only specified 5 in the function. That's becaue the imputation on the left is the original data set without any imputed values. 

While this is one way of looking at the distribution of the imputed values, we can also examine them by looking at a good old fashioned histogram or density plot. 
First I'll create a dataframe containing all 5 imputd datasets in a long format. New variables .imp and .id are introduced to identify which imputation number the data belongs to.


{% highlight r %}
#complete the datasets in long format with original data included
com <- mice::complete(x = imp, action = 'long', include = T)

#examine the data
glimpse(bind_rows(head(com), tail(com)))
{% endhighlight %}



{% highlight text %}
## Observations: 12
## Variables: 13
## $ .imp     <fct> 0, 0, 0, 0, 0, 0, 5, 5, 5, 5, 5, 5
## $ .id      <fct> 1, 2, 3, 4, 5, 6, 1304, 1305, 1306, 1307, 1308, ...
## $ Pclass   <fct> 3, 1, 3, 1, 3, 3, 3, 3, 1, 3, 3, 3
## $ Sex      <fct> male, female, female, female, male, male, female...
## $ Age      <int> 22, 38, 26, 35, 35, NA, 28, 24, 39, 38, 23, 9
## $ SibSp    <int> 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1
## $ Parch    <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
## $ Fare     <dbl> 7.250, 71.283, 7.925, 53.100, 8.050, 8.458, 7.77...
## $ Embarked <fct> S, C, S, S, S, Q, S, S, C, S, S, C
## $ Fam_size <dbl> 2, 2, 1, 2, 1, 1, 1, 1, 1, 1, 1, 3
## $ FamCat   <fct> small, small, single, small, single, single, sin...
## $ Title    <fct> Mr, Mrs, Miss, Mrs, Mr, Mr, Miss, Mr, Other, Mr,...
## $ Fare_bin <fct> 0, 4, 1, 4, 1, 1, 0, 1, 4, 0, 1, 3
{% endhighlight %}

Looking at the first and last 5 rows of the data set we can see the values associated with the original data (.imp = 0) and the 5th imputed dataset(.imp = 5). Now, I'll plot the histograms of the Age variable since this is what we really care about.


{% highlight r %}
ggplot(com, aes(Age, group = .imp, fill = factor(.imp))) + 
  geom_histogram(alpha = 0.76, show.legend = F, color = 'black') + 
  facet_wrap(~.imp, scales = 'free')
{% endhighlight %}

![plot of chunk unnamed-chunk-32](/figure/./_source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-32-1.png)

It appears that the imputations are all similarly distributed to the original data set only there are more compared to the original since each imputed dataset now includes both the original and imputed values.

In the last step, I am going to use the 4th imputation to replace the missing **Age** values in the *full* dataset.


{% highlight r %}
#Replace Original Age with RF imputations from the 5th imputed set
complete_age <- mice::complete(imp, 4) %>%
  select(Age)

full$Age <- complete_age$Age

#Check if there are any missing values
sum(is.na(full$Age))
{% endhighlight %}



{% highlight text %}
## [1] 0
{% endhighlight %}

Although there are no more missing values I'm not quite finished with the Age variable. To improve the modeling process, I want to convert *Age* to a categorical just as I did with the Fare variable.


{% highlight r %}
quantile(full$Age, probs = c(0.2,0.4, 0.6, 0.8, 1))
{% endhighlight %}



{% highlight text %}
##  20%  40%  60%  80% 100% 
##   19   25   31   41   80
{% endhighlight %}



{% highlight r %}
full <- full %>%
  mutate(Age_bin = factor(case_when(Age <= 19 ~ 0
                                   ,Age > 19 & Age <= 25 ~ 1
                                   ,Age > 25 & Age <= 31 ~ 2
                                   ,Age > 31 & Age <= 42 ~ 3
                                   ,Age > 42 ~ 4)
                          )
         )
{% endhighlight %}

# Modeling
Let's review the variables in our data set and get rid of some we no longer need.

**Name** - We were able to extract the title for each passenger which proved to be much more valuable than the name feature  
**Age** - We have converted the ages into categorical bins so we can drop this variable  
**SibSp, Parch** The family size and category variables were built off of these  
**Ticket** - As far as I know these values are random character strings and don't serve much purpose  
**Fare** - We have converted the values into a binned categorical variable so we can drop this one  
**Cabin** - Too many NA values to be meaningful or to attempt imputation  
**Surname** - Was used to calculate the family size so this can be dropped as well  


{% highlight r %}
#remove unneeded vars
full_subset <- full %>%
  select(-Name, -Age, -SibSp, -Parch, -Ticket, -Fare, -Cabin, -Surname)

#examine remaining column names
names(full_subset)
{% endhighlight %}



{% highlight text %}
##  [1] "PassengerId" "Survived"    "Pclass"      "Sex"        
##  [5] "Embarked"    "Fam_size"    "FamCat"      "Title"      
##  [9] "Fare_bin"    "Age_bin"
{% endhighlight %}

Now it's time to split the data back into the training and test set. 


{% highlight r %}
#split data back intro train and test set
train <- full_subset[1:891, ]
test <- full_subset[892:1309, ]
{% endhighlight %}

Finally, it's time to build a model. I've decided to use the Random Forest algorithm which is great for classification problems, easy  to use, has relatively few hyperparameters, and also makes it easy to view the importance of the variables used in the modeling process. 


{% highlight r %}
#build model using random forest
rf_model <- train %>%
  select(-PassengerId) %>%
  randomForest(Survived ~ ., data = .)

#examine the results of the model
rf_model
{% endhighlight %}



{% highlight text %}
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
## 0 498  51      0.0929
## 1 100 242      0.2924
{% endhighlight %}



{% highlight r %}
#plot the model
plot(rf_model)
{% endhighlight %}

![plot of chunk unnamed-chunk-37](/figure/./_source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-37-1.png)

The plot indicates that the overall error rate flattens out after about 125 trees or so. The black line represents the sample error, more commonly referred to as Out of Bag error which is the overall error rate of the model (~18%). The error rate in predicting survivors is signficantly higher (green line, ~30%) than predicting non-survivors (red line, ~10%). 

Let's take a look at the variable importance.


{% highlight r %}
#plot the variable importance 
randomForest::varImpPlot(rf_model, main = 'Variable Importance of Random Forest Model')
{% endhighlight %}

![plot of chunk unnamed-chunk-38](/figure/./_source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-38-1.png)

And now it's time to use the model to make predictions on the test set. 



{% highlight r %}
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
{% endhighlight %}

![plot of chunk unnamed-chunk-39](/figure/./_source/2018-06-18-titanic-passenger-survival-predictions/unnamed-chunk-39-1.png)

We can see that the proportion of outcomes in the test set reflects that of the training set. That's exactly what we'd expect our model to do. And how well did the model do at actually predicting the correct Survivors? After submitting my answers, I got a score of 0.77511. Not too bad! Certainly there are other opportunities to improve the prediction score; perhaps another time.

This concludes our journey through the **Titanic: Machine Learning From Disaster** Kaggle challenge. I hope you enjoyed this post and learned a thing or two along the way. Thanks for reading!



