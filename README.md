# dbs-outcomes-logistic-regression
Deep Brain Stimulation (DBS) Complication Risk Analysis

Author

Ömer Tarık Çiçek
UNIMI IMS Medical Student
ORCID: 0009-0003-0818-0560

Project Overview

This project simulates a clinical dataset of patients undergoing Deep Brain Stimulation (DBS) and evaluates predictors of postoperative complications using logistic regression modeling.

The objective was to demonstrate reproducible clinical data simulation, regression modeling, and visualization workflows in R.

Methods

Simulated cohort: n = 120 DBS patients

Variables included:

Age

Sex

Disease duration

DBS target (STN vs GPi)

Baseline UPDRS

Improvement percentage

Postoperative complication (binary outcome)

Logistic regression was performed to assess predictors of complications.

Odds ratios (OR) with 95% Wald confidence intervals were calculated.

Key Findings (Simulated Data)

Increasing age showed a trend toward higher complication risk.

Longer disease duration showed moderate association with complications.

DBS target (STN vs GPi) showed no statistically strong effect in this simulation.

Tools Used

R

ggplot2

broom

Logistic regression (glm, binomial family)

Reproducibility

All analyses can be reproduced by running analysis.R.
The simulated dataset and exported figures are included.
