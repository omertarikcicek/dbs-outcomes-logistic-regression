# --------------------------------------------------
# Deep Brain Stimulation (DBS) Complication Analysis
# Author: Ömer Tarık Çiçek
# Date: 2026
# Purpose: Full logistic regression workflow including
#          diagnostics, discrimination, calibration,
#          and cross-validation
# --------------------------------------------------

library(ggplot2)
library(broom)
library(car)
library(caret)
library(pROC)
library(dplyr)

set.seed(2026)

# -------------------------------
# Simulate dataset
# -------------------------------
n <- 120

patient_id <- 1:n
age <- round(rnorm(n, mean = 62, sd = 8))
sex <- sample(c("Male", "Female"), n, replace = TRUE)
disease_duration <- round(rnorm(n, mean = 11, sd = 4))
dbs_target <- sample(c("STN", "GPi"), n, replace = TRUE)
baseline_updrs <- round(rnorm(n, mean = 45, sd = 10))
improvement_percent <- round(rnorm(n, mean = 35, sd = 15))

logit_p <- -5 + 0.04*age + 0.08*disease_duration
prob_complication <- exp(logit_p)/(1+exp(logit_p))
complication <- rbinom(n, 1, prob_complication)

dbs_data <- data.frame(
  patient_id, age, sex, disease_duration, dbs_target,
  baseline_updrs, improvement_percent, complication
)

write.csv(dbs_data, "dbs_simulated_data.csv", row.names = FALSE)

# -------------------------------
# Logistic regression
# -------------------------------
model <- glm(complication ~ age + disease_duration + dbs_target,
             data = dbs_data,
             family = binomial)

cat("\n--- Logistic Regression Summary ---\n")
print(summary(model))

# Odds ratios
exp(cbind(OR = coef(model), confint.default(model)))

# -------------------------------
# Plots
# -------------------------------
# Age histogram
ggplot(dbs_data, aes(x = age, fill = factor(complication))) +
  geom_histogram(binwidth = 5, position = "dodge") +
  labs(title = "Age Distribution by Complication Status",
       fill = "Complication") +
  theme_minimal()
ggsave("age_complication_plot.png", width = 6, height = 4)

# Forest plot
tidy_model <- tidy(model, conf.int = TRUE, conf.method = "wald", exponentiate = TRUE)
tidy_model_no_intercept <- tidy_model[-1, ]

ggplot(tidy_model_no_intercept, aes(x = term, y = estimate, ymin = conf.low, ymax = conf.high)) +
  geom_pointrange() +
  geom_hline(yintercept = 1, linetype = "dashed") +
  coord_flip() +
  labs(title = "Predictors of DBS Complications",
       y = "Odds Ratio (95% CI)", x = "") +
  theme_minimal()
ggsave("forest_plot.png", width = 6, height = 4)

# -------------------------------
# Model performance: ROC & AUC
# -------------------------------
dbs_data$predicted_prob <- predict(model, type = "response")
roc_obj <- roc(dbs_data$complication, dbs_data$predicted_prob)

cat("\n--- Model Discrimination ---\n")
print(auc(roc_obj))
cat("\n--- Model Fit Statistics ---\n")
cat("AIC:", AIC(model), "\n")

png("roc_curve.png", width = 600, height = 500)
plot(roc_obj, main = "ROC Curve for DBS Complication Model")
dev.off()

# -------------------------------
# Multicollinearity (VIF)
# -------------------------------
cat("\n--- Variance Inflation Factors (VIF) ---\n")
print(vif(model))

# -------------------------------
# 10-Fold Cross-Validation
# -------------------------------
train_control <- trainControl(
  method = "cv", number = 10,
  classProbs = TRUE,
  summaryFunction = twoClassSummary
)

dbs_data$complication_factor <- factor(ifelse(dbs_data$complication == 1, "Yes", "No"))

cv_model <- train(
  complication_factor ~ age + disease_duration + dbs_target,
  data = dbs_data,
  method = "glm",
  family = "binomial",
  trControl = train_control,
  metric = "ROC"
)
cat("\n--- Cross-Validated AUC ---\n")
print(cv_model)

# -------------------------------
# Binned Calibration Plot
# -------------------------------
dbs_data$bin <- ntile(dbs_data$predicted_prob, 10)
calibration_table <- dbs_data %>%
  group_by(bin) %>%
  summarise(mean_predicted = mean(predicted_prob),
            mean_observed = mean(complication))

cal_plot <- ggplot(calibration_table,
                   aes(x = mean_predicted, y = mean_observed)) +
  geom_point(size = 3) +
  geom_line() +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  labs(title = "Binned Calibration Plot",
       x = "Mean Predicted Probability",
       y = "Observed Event Rate") +
  theme_minimal()
cal_plot
ggsave("calibration_plot.png", cal_plot, width = 6, height = 4)

# --------------------------------------------------
# Automated Clinical Interpretation (Polished)
# --------------------------------------------------

cat("\n--- Automated Clinical Interpretation ---\n\n")

for (i in 1:nrow(tidy_model)) {
  term_name <- tidy_model$term[i]
  or <- round(tidy_model$estimate[i], 2)
  ci_low <- round(tidy_model$conf.low[i], 2)
  ci_high <- round(tidy_model$conf.high[i], 2)
  pval <- round(tidy_model$p.value[i], 3)
  
  # Decide significance label
  sig_label <- ifelse(pval < 0.05, "SIGNIFICANT", "not significant")
  
  # Add unit info for continuous vs categorical
  unit_note <- ifelse(term_name %in% c("age", "disease_duration"),
                      "per year/unit", 
                      "reference vs other category")
  
  cat(paste0(
    term_name, " (", unit_note, "): OR = ", or,
    " [", ci_low, "-", ci_high, "], p = ", pval,
    " → ", sig_label, "\n"
  ))
}

cat("\nInterpretation: Odds ratios >1 indicate increased risk; <1 indicate reduced risk.\n")
cat("All outputs successfully generated and saved.\n")
