set.seed(2026)

n <- 120

patient_id <- 1:n
age <- round(rnorm(n, mean = 62, sd = 8))
sex <- sample(c("Male", "Female"), n, replace = TRUE)
disease_duration <- round(rnorm(n, mean = 11, sd = 4))
dbs_target <- sample(c("STN", "GPi"), n, replace = TRUE)

baseline_updrs <- round(rnorm(n, mean = 45, sd = 10))

# Simulate improvement
improvement_percent <- round(rnorm(n, mean = 35, sd = 15))

# Simulate complication probability influenced by age and disease duration
logit_p <- -5 + 0.04*age + 0.08*disease_duration
prob_complication <- exp(logit_p)/(1+exp(logit_p))

complication <- rbinom(n, 1, prob_complication)

dbs_data <- data.frame(
  patient_id,
  age,
  sex,
  disease_duration,
  dbs_target,
  baseline_updrs,
  improvement_percent,
  complication
)

write.csv(dbs_data, "dbs_simulated_data.csv", row.names = FALSE)

# Logistic regression
model <- glm(complication ~ age + disease_duration + dbs_target,
             data = dbs_data,
             family = binomial)

summary(model)

# Odds ratios
exp(cbind(OR = coef(model), confint(model)))

