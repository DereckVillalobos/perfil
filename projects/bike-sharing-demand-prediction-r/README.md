# Bike Sharing Demand Prediction in R

Predictive analytics workflow for estimating **daily bike-sharing demand** from temporal and weather-related variables. The project compares three regression approaches—multiple linear regression, CART and radial SVM—and evaluates them on the same holdout set.

## What this project demonstrates

- Exploratory analysis of daily bike-sharing demand.
- Data validation and categorical feature preparation.
- Reproducible 70/30 train-test split using a fixed random seed.
- Feature centering and scaling for the radial SVM workflow.
- Comparison using RMSE, MAE and the squared correlation metric used in the original analysis.
- Model selection based on out-of-sample performance.

## Model comparison

The original reproducible analysis reported:

| Model | RMSE | MAE | R²* |
|---|---:|---:|---:|
| Multiple Linear Regression | 1317.80 | 1126.50 | 0.5813 |
| CART | 909.83 | 656.02 | 0.7994 |
| Radial SVM | **680.59** | **471.22** | **0.8919** |

The radial SVM produced the lowest prediction error among the three evaluated models.

\* The original project calculated `R²` as squared Pearson correlation (`cor(actual, predicted)^2`). The source code keeps that definition to preserve comparability with the original results. A future revision can also report the standard out-of-sample coefficient of determination, `1 - SSE/SST`.

## Dataset

The project uses the daily portion of the **UCI Bike Sharing** dataset. The analysis expects a prepared `data/day_preparado.csv` file with 731 daily observations and the variables used by the models. The dataset is intentionally kept outside version control; see `data/README.md` for the expected schema and source attribution.

Target:

- `cnt`: total number of daily bicycle rentals.

Predictors include:

- temporal variables: season, year, month, holiday, weekday and working-day indicator;
- weather variables: weather situation, temperature, apparent temperature, humidity and wind speed.

The prepared dataset excludes `casual` and `registered`, because those variables directly compose the target (`cnt`) and would introduce target leakage.

## Repository structure

```text
.
├── data/
│   └── README.md
├── src/
│   └── bike_demand_analysis.R
├── .gitignore
├── NOTICE.md
└── README.md
```

## Requirements

R and the following packages:

```r
install.packages(c(
  "caret",
  "corrplot",
  "dplyr",
  "e1071",
  "ggplot2",
  "rpart",
  "rpart.plot"
))
```

## Run

From this project directory:

```bash
cd projects/bike-sharing-demand-prediction-r
Rscript src/bike_demand_analysis.R
```

Before running, place `day_preparado.csv` inside `data/`. The script validates the dataset, recreates the train-test split, trains the three models and prints their evaluation metrics.

## Engineering notes

This repository intentionally keeps the original modeling logic while improving code organization, validation and maintainability.

Two limitations are documented rather than hidden:

1. The models do not use exactly the same feature set. The linear regression uses a reduced formula, while CART and SVM use a broader set of predictors.
2. The data are randomly split even though the observations represent consecutive days. For a production forecasting system, a chronological holdout or time-series cross-validation strategy would provide a stronger estimate of future performance.

The initial analysis was developed collaboratively and was later reorganized and refactored for portfolio presentation. Personal and academic identifiers are intentionally omitted.

## Data attribution

Fanaee-T, H. (2013). *Bike Sharing* [Dataset]. UCI Machine Learning Repository. DOI: 10.24432/C5W894.

The UCI dataset is distributed under the **Creative Commons Attribution 4.0 International (CC BY 4.0)** license. See `NOTICE.md` for attribution details.
