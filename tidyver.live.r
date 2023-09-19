# Step one, always,install and load needed packages

install.packages("tidyverse")
install.packages("palmerpenguins") # this should work as well as the next one 
data(package = 'palmerpenguins')

library(tidyverse) # note the packages loaded in with tidyverse
library(palmerpenguins)

penguins_raw <- penguins_raw # let's bring these data into our environment


test_raw <- penguins_raw # I always make a new copy of the df to have the OG if needed
tibble::as_tibble(test_raw) # let's take a look 

# this will tell us where there are NAs in the df
base::which(is.na(test_raw), arr.ind = TRUE) #checking for NA locations in penguins_raw

test_raw <-
  na.omit(test_raw) #I must add this because there are NAs within this data set and these functions will not work otherwise 

# let's now check to see if there are any left
base::which(is.na(test_raw), arr.ind = TRUE)


base::colnames(test_raw) # which columns do we want to mess with? this df is too wide to view fully on the console

# we will not be working with the whole df right now, so let's choose which columns we want to work with
#let's choose species, culmen length, Date Egg
# select()
df_select <- test_raw %>% #From the penguins data set
  dplyr::select(Species, 'Culmen Length (mm)', 'Date Egg', 'Individual ID') # selecting columns species, bill_length, and      year 
# I do not want to include ID anymore, so let's get rid of it
df_deselect <- df_select %>% 
  select(-'Individual ID')

# change the names with rename
# notice, can use quotes or not
# the quotes will be important if your column names have numbers or spaces
penguins_almost_clean <- df_deselect %>% 
  dplyr::rename(species = Species,
         bill_length_mm = 'Culmen Length (mm)',
         year = "Date Egg")
penguins_almost_clean
# now, let's clean up our species names 
# how many species are there? 
# count()
penguins_almost_clean %>% 
  dplyr::count(species)
#do not show this in class
base::unique(penguins_almost_clean$species) # will also work if you just want the names

# Several options to rename ROWS: We will follow the case_when and BASE R versions in class, NOT case_match

penguins_case_when <- penguins_almost_clean %>%
  dplyr::mutate(species = case_when(species == "Adelie Penguin (Pygoscelis adeliae)" ~ "Adelie",
                            species =="Gentoo penguin (Pygoscelis papua)" ~ "Gentoo",
                            species =="Chinstrap penguin (Pygoscelis antarctica)" ~ "Chinstrap",                
            .default = as.character(species)))
# %>% 
#   select(species, bill_length_mm, year) 
print(penguins_case_when, n = Inf)

# BASE R
penguins_almost_clean$species[penguins_almost_clean$species == "Adelie Penguin (Pygoscelis adeliae)"] <- "Adelie"
penguins_almost_clean$species[penguins_almost_clean$species == "Gentoo penguin (Pygoscelis papua)"] <- "Gentoo"
penguins_almost_clean$species[penguins_almost_clean$species == "Chinstrap penguin (Pygoscelis antarctica)"] <- "Chinstrap"

print(penguins_almost_clean, n = Inf) #why inf? So I can see all of the name changes. This df is short enough that it is OK!
         

# IF you like case_match, this will work similar to case_when
# IF you wish you run this, highlight the code and then press Ctrl/ Command + Shift + C
# case_match_example <- penguins_almost_clean %>%
#   mutate(this = case_match(species,
#              "Adelie Penguin (Pygoscelis adeliae)" ~ "Adelie", # only one species change in this example
#              .default = as.character(Species))) %>%
#   select(this)
# print(case_match_example, n = Inf)


# Function note, let's look at what the syntax for functions are 
?mean

# Date change, last step before 'clean'

# change date to include just the year with a function

year_function <- function (x) (as.numeric(format(x, "%Y"))) # x is the place holder variable for our df

# mutate_at: allows for targeted transposing, rather than a new column
clean_penguin <- penguins_case_when %>% 
  dplyr::mutate_at(c("year"), year_function) # year here is x above. 

#and without a function
clean_penguin$year <- as.numeric(format(clean_penguin$year, "%Y"))


## This df is now clean, let's explore!!

clean_penguin

clean_penguin %>% 
  dplyr::arrange(bill_length_mm) # default small to large 

# add this above 
test_factor <- clean_penguin 
test_factor$year <- as.factor(test_factor$year)
test_factor %>% 
  arrange(year, desc(bill_length_mm))

### Challenge
# How about looking at bill length in desc order BY year?
clean_penguin %>% 
  arrange(year, desc(bill_length_mm))

# What if I want to look at just one year?
# does anyone remember that verb from the ppt? 
clean_penguin %>% 
  dplyr::filter(year == 2007)

### Challenge 
# How about looking at bill lengths from 2007 that are greater than the mean? 

clean_penguin %>% 
  filter(
    year == 2007,#using the '==' operator to show everything with the year 2007
    bill_length_mm > mean(bill_length_mm), # using '>' to view every row where the bill length is greater than the avg bill length 
  ) 

# let's get a little more complex 
# I want to see year 2007 when bill length is > the mean, but I do not want to see Adelie
# TWO options... either | OR != 
  # show both 

clean_penguin %>%
  filter(
    year == 2007,#using the '==' operator to show everything with the year 2007
    bill_length_mm > mean(bill_length_mm),# using '>' to view every row where the bill length is greater than the avg bill length
    species == "Chinstrap" | species == "Gentoo" # look in species and pull out chinstrap and gentoo. | allows to command two species, similar to 'or'
  ) 

## Challenge, how else can we do this? !=
clean_penguin %>%
  filter(
    year == 2007,#using the '==' operator to show everything with the year 2007
    bill_length_mm > mean(bill_length_mm),# using '>' to view every row where the bill length is greater than the avg bill length 
    species != "Adelie" #does not equal operator
  ) 

# let's now do some column manipulation
# for whatever reason I want to add year and species to the same column
  # on top of that, I want to round bill length 
# select(), mutate(), select()
clean_penguin %>%
  dplyr::mutate( 
    sp_year = paste(species, "-", year), #adding a new column named 'sp_year' and pasting the species column and year column with a dash between them. 
    rn_bill_length_mm = round(bill_length_mm) #creating a column of rounded bill lengths, default round
  ) %>% 
  select(sp_year,rn_bill_length_mm) #placing these new columns an order I would like 

# one more column manipulation with mutate
# going to add a log transformation 
clean_penguin %>% 
  mutate(
    log_bill_length = log(bill_length_mm)
  ) %>% 
  select(year, log_bill_length)

#summary stats!!

# summarize ()
clean_penguin %>% 
  dplyr::summarize( #summarize to run summary stats 
  bill_length_mean = mean(bill_length_mm), #new column with mean value of bill length
  bill_length_sd = sd(bill_length_mm) #new column with standard deviation value of bill length
  )

# group_by() and summarize()
clean_penguin %>% 
  group_by(species) %>% #grouping by one column, species 
  summarize( #summarize to run summary stats 
    bill_length_mean = mean(bill_length_mm), #new column with mean value of bill length
    bill_length_sd = sd(bill_length_mm) #new column with standard deviation value of bill length
  )

# group_by() and summarize()
clean_penguin %>% 
  group_by(species, year) %>% #grouping by two columns, species and year 
  summarize( #summarize to run summary stats 
    bill_length_mean = mean(bill_length_mm), #new column with mean value of bill length
    bill_length_sd = sd(bill_length_mm) #new column with standard deviation value of bill length
  )

