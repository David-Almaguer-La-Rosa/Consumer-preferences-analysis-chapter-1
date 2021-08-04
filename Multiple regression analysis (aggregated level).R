# Convert attributes to factors
data$Daily_expenditure_per_person <- factor(data$Daily_expenditure_per_person)
data$Length_of_stay <- factor(data$Length_of_stay)
data$Accommodation <- factor(data$Accommodation)
data$Environment <- factor(data$Environment)
data$Transportation <- factor(data$Transportation)
data$Recreational_activities_offer <- factor(data$Recreational_activities_offer)
data$Gastronomy <- factor(data$Gastronomy)

# Generate multiple linear regression model
aggregate_model <- lm(rating ~ Daily_expenditure_per_person +
                        Length_of_stay +
                        Accommodation +
                        Environment +
                        Transportation +
                        Recreational_activities_offer +
                        Gastronomy,
                      data=data)

summary(aggregate_model)

# Generate graph with partial components of utility (regression coefficients)
aggregate_model$coefficients <- round(aggregate_model$coefficients,2)

coefficients <- data.frame(attribute = c(rep("DEP", 4), rep("LS", 2), rep("ACC", 2), rep("ENV", 4), rep("TRA", 2), rep("RAO", 2), rep("GAS", 2)),
                           levels = c("Daily_expenditure_per_person-50", "Daily_expenditure_per_person-75", "Daily_expenditure_per_person-100", "Daily_expenditure_per_person-150", 
                                      "Length_of_stay-From 1 to 5 nights", "Length_of_stay-More than 5 nights",
                                      "Accommodation-Hotel", "Accommodation-Resort",
                                      "Environment-Sun and Beach", "EnvironmentCity", "EnvironmentRural", "EnvironmentNature",
                                      "Transportation-Included as a service", "Transportation-Public or private",
                                      "Recreational_activities_offer-Independent", "Recreational_activities_offer-Scheduled",
                                      "Gastronomy-International", "Gastronomy-National"),
                           coefficients = c(0, 2.38, 1.35, 0.12, 0, -2.38, 0, 0.56, 0, 1.83, 2.49, 3.60,  0, 1.19, 0, 0.04, 0, -0.57)) 

library(ggthemes)

ggplot(data=coefficients, aes(x=coefficients, y=levels, fill=levels))+
  geom_col(alpha=0.8)+
  ggtitle("Consumers preferences structure")+
  xlab("Partial utility components")+
  ylab("Levels by attributes")+
  geom_text(aes(label=coefficients, hjust = ifelse(coefficients >= 0, -0.1, 1.1)), vjust=0.4, colour="black", size=3)+
  theme_hc()+
  theme(legend.position = "none")+
  scale_x_continuous(limits = c(-2.8, 3.6))


# Calculate the relative importance of each attribute in consumer choices
coefficients <- coefficients %>%  mutate(coefficients, absolute_value = abs(coefficients))
attributes_rank <- coefficients %>% group_by(attribute) %>% summarize(rank = max(absolute_value))

attributes_importance <- attributes_rank %>% mutate(importance = rank/sum(rank)*100) 
attributes_importance$importance <- round(attributes_importance$importance, 1) 
attributes_importance$attribute <- c("Accommodation",
                                     "Daily_expenditure_per_person",
                                     "Environment",
                                     "Gastronomy",
                                     "Length_of_stay",
                                     "Recreational_activities_offer",
                                     "Transportation")

# Generate chart with relative importance by attribute
ggplot(attributes_importance, aes(x = importance, y = attribute, color = attribute, fill = attribute))+
  geom_col(alpha=0.6)+
  ggtitle("Relative importance by attribute")+
  xlab("Relative importance (%)")+
  ylab("Attributes")+
  geom_text(aes(label=importance, hjust=-0.2), color="black", size=3.5)+
  scale_x_continuous(limits = c(0, 35))+
  theme_hc()+
  theme(legend.position = "none")
  







  








  

