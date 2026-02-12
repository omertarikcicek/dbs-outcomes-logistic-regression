library(ggplot2)
library(broom)



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

cat("\n--- Logistic Regression Summary ---\n")
print(summary(model))

cat("\n--- P-values ---\n")
print(coef(summary(model))[,4])

p_values <- coef(summary(model))[,4]

cat("\n--- P-values for Predictors ---\n")
print(round(p_values, 4))


# Odds ratios
exp(cbind(
  OR = coef(model),
  confint.default(model)
))


library(ggplot2)

ggplot(dbs_data, aes(x = age, fill = factor(complication))) +
  geom_histogram(binwidth = 5, position = "dodge") +
  labs(title = "Age Distribution by Complication Status",
       fill = "Complication") +
  theme_minimal()

ggsave("age_complication_plot.png", width = 6, height = 4)

# Logistic regression model

tidy_model <- tidy(model,
                   conf.int = TRUE,
                   conf.method = "wald",
                   exponentiate = TRUE)

tidy_model


tidy_model <- tidy_model[-1, ]  # remove intercept

ggplot(tidy_model, aes(x = term, y = estimate, ymin = conf.low, ymax = conf.high)) +
  geom_pointrange() +
  geom_hline(yintercept = 1, linetype = "dashed") +
  coord_flip() +
  labs(title = "Predictors of DBS Complications",
       y = "Odds Ratio (95% CI)",
       x = "") +
  theme_minimal()

ggsave("forest_plot.png", width = 6, height = 4)
