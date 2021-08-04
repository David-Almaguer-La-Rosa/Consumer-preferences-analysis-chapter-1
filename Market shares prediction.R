# Obtain the partial utility coefficients by consumer (include heterogeneity to the model)
library(lme4)
model_by_consumer <- lmer(rating ~ Daily_expenditure_per_person+Length_of_stay+Accommodation+Environment+Transportation +Recreational_activities_offer+Gastronomy+
                            (Daily_expenditure_per_person+Length_of_stay+Accommodation+Environment+Transportation+Recreational_activities_offer+Gastronomy | consumer.id),
                        data=data,
                        control=lmerControl(optCtrl=list(maxfun =100000)))

summary(model_by_consumer)

coefficients_by_consumer <- coef(model_by_consumer)$consumer.id

# Predict market shares for any given set of profiles (maximum utility method)
## Select product profiles
(new.data <- full_factorial_design[c(12, 45, 76, 135, 302), ])

## Create a model matrix by expanding factors to a set of dummy variables
profiles_model_with_intercept <- model.matrix(~ Daily_expenditure_per_person+Length_of_stay+Accommodation+Environment+Transportation+Recreational_activities_offer+Gastronomy,
                                              data = new.data)
## Obtain the preferred profile by consumer
coefficients_for_all_profiles <- coefficients_by_consumer[rep(seq_len(nrow(coefficients_by_consumer)), each=5),] 
coefficients_by_profiles <- coefficients_for_all_profiles*profiles_model_with_intercept

utilities_by_individual <- apply(coefficients_by_profiles,1,sum)
utilities_by_individual <- matrix(utilities_by_individual, nrow = 400, ncol = 5, byrow = TRUE)

max_utility_by_individual <- apply(utilities_by_individual, 1, which.max)
preference <- table(max_utility_by_individual)

## Calculate the market share of each product profile
market_shares <- data.frame(profile = row.names(new.data), preference = as.numeric(preference)) %>% 
  mutate(market_share = preference/sum(preference)*100)

# Generate a function to predict market shares for any given set of product profiles
## Select 10 profiles randomly 
new.data.random <- full_factorial_design[sample(row.names(full_factorial_design), 10, replace = FALSE), ] # note that the random profiles are selected from the full factorial design

## Function for prediction
predict.max.utility <- function(model, profiles) {
  coefficients_by_consumer <- coef(model)$consumer.id # note that consumer.id is a column name in the initial data frame: data
  profiles_model_with_intercept <- model.matrix(~ Daily_expenditure_per_person+Length_of_stay+Accommodation+Environment+Transportation+Recreational_activities_offer+Gastronomy, data=new.data.random)
  coefficients_for_all_profiles <- coefficients_by_consumer[rep(seq_len(nrow(coefficients_by_consumer)), each=nrow(new.data.random)),] 
  coefficients_by_profiles <- coefficients_for_all_profiles*profiles_model_with_intercept
  utilities_by_individual <- apply(coefficients_by_profiles,1,sum)
  utilities_by_individual_matrix <- matrix(utilities_by_individual, nrow = nrow(coefficients_by_consumer), ncol = nrow(new.data.random), byrow = TRUE)
  max_utility_by_individual <- apply(utilities_by_individual_matrix, 1, which.max)
  preference <- table(max_utility_by_individual)
  market_shares<- data.frame(profile = row.names(new.data.random[as.numeric(names(preference)), ]), preference = as.numeric(preference))
  market_shares$market_share <-market_shares$preference/sum(market_shares$preference)*100
  print(market_shares)
}

predict <- predict.max.utility(model_by_consumer, new.data.random) 

# Generate a market shares graph of each product profile
library(ggplot2)
library(ggthemes)

ggplot(predict, aes(x=profile, y=market_share, fill=market_share, color=market_share)) +
  geom_col(alpha=0.7) +
  ggtitle("Selected profiles market shares")+
  xlab("Product profiles")+
  ylab("Market share (%)")+
  geom_text(aes(label=market_share, vjust=-1), colour="black", size=3)+
  theme_hc()+
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5, size=13))+
  scale_y_continuous(limits = c(0, 41))






  
         

































