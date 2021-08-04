# Create a data frame from all combinations of factor variables
full_factorial_design <- expand.grid(Daily_expenditure_per_person = c("50", "75", "100", "150"),
                                     Length_of_stay = c("From 1 to 5 nights","More than 5 nights"),
                                     Accommodation = c("Hotel","Resort"),
                                     Environment =c("Sun and Beach", "City", "Rural", "Nature"),
                                     Transportation = c("Included as a service", "Public or private"),
                                     Recreational_activities_offer = c("Independent", "Scheduled"),
                                     Gastronomy = c("International", "National"))

# Generate an orthogonal experimental design(16 product profiles)
library(AlgDesign)
set.seed(100)               
orthogonal_design <- optFederov( ~ ., data = full_factorial_design, nTrials = 16) 

# Build a data frame with the orthogonal experimental design
library(tidyverse)
orthogonal_design <- tibble(orthogonal_design$design)                                  

# Create a model matrix by expanding factors to a set of dummy variables
profiles.model <- model.matrix(~ Daily_expenditure_per_person + 
                                 Length_of_stay + 
                                 Accommodation +
                                 Environment +
                                 Transportation +
                                 Recreational_activities_offer +
                                 Gastronomy,
                               data = orthogonal_design)[,-1]

# Generate random consumer evaluation for profiles in the orthogonal experimental design  
consumer.id <- 1:400
profiles <- 16

## Generate samples from a multivariate normal distribution.
library(MASS)
set.seed(100)
weights <- mvrnorm(length(consumer.id),
                   mu=c(2, 1, 0, -2, 0.5, 1.5, 2, 3, 1, 0, -0.5),
                   Sigma=diag(c(0.2, 0.1, 0.5, 0.2, 0.1, 0.1, 0.1, 0.2, 0.3, 1, 1)))

## Create a rating per respondent for each of the 16 profiles
data <- NULL
for (i in seq_along(consumer.id)) {
    utility <- profiles.model %*% weights[i, ] + rnorm(16) # preference + error
    rating <- as.numeric(cut(utility , 10)) # put on a 10-point scale
    data.0 <- cbind(consumer.id = rep(i, each = profiles), rating, orthogonal_design)
    data <- rbind(data, data.0)
}

View(data)  





