# dbs-outcomes-logistic-regression
Deep Brain Stimulation (DBS) Complication Risk Analysis

Author

Ömer Tarık Çiçek
UNIMI IMS Medical Student
ORCID: 0009-0003-0818-0560

Project Overview

This project simulates a clinical dataset of patients undergoing Deep Brain Stimulation (DBS) and evaluates predictors of postoperative complications using logistic regression modeling in R.

The goal is to demonstrate reproducible clinical data simulation, regression modeling, and visualization workflows.

Methods

Simulated Cohort: n = 120 DBS patients

Variables included:

Age

Sex

Disease duration

DBS target (STN vs GPi)

Baseline UPDRS

Improvement percentage

Postoperative complication (binary outcome)

Analyses performed:

Logistic regression to assess predictors of complications

Calculation of odds ratios (OR) with 95% Wald confidence intervals

Model performance evaluation using ROC/AUC

Multicollinearity check (VIF)

10-fold cross-validation

Binned calibration plot

Automated clinical interpretation

Tools and Packages:

R (version ≥ 4.5.2)

ggplot2

broom

car

caret

pROC

dplyr

Key Findings (Simulated Data)

Age: Slight trend toward higher complication risk (OR 1.04 per year, 95% CI 0.98–1.11, p = 0.17)

Disease duration: Slight inverse association (OR 0.90, 95% CI 0.78–1.04, p = 0.16)

DBS target (STN vs GPi): No statistically meaningful effect (OR 0.74, 95% CI 0.26–2.10, p = 0.57)

Note: This is simulated data; results are for methodological demonstration purposes only.

Reproducibility

All analyses can be reproduced by running analysis.R.
The simulated dataset (dbs_simulated_data.csv) and exported figures are included in the project folder.

Interpretation of Results

Odds ratios >1 indicate increased risk; <1 indicate reduced risk.

Automated interpretation provides clinical-style outputs for each predictor with statistical significance labeling.

This workflow demonstrates a full R-based logistic regression pipeline for clinical research simulation.
