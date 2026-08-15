# Bike Sharing Demand Prediction
# Reproducible analysis comparing multiple regression models in R.

required_packages <- c(
  "caret",
  "corrplot",
  "dplyr",
  "e1071",
  "ggplot2",
  "rpart",
  "rpart.plot"
)

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    paste0(
      "Missing R packages: ",
      paste(missing_packages, collapse = ", "),
      ". Install them before running the analysis."
    )
  )
}

library(caret)
library(corrplot)
library(dplyr)
library(e1071)
library(ggplot2)
library(rpart)
library(rpart.plot)

DATA_PATH <- file.path("data", "day_preparado.csv")
SEED <- 123
TRAIN_RATIO <- 0.70

required_columns <- c(
  "season", "yr", "mnth", "holiday", "weekday", "workingday",
  "weathersit", "temp", "atemp", "hum", "windspeed", "cnt"
)

categorical_columns <- c(
  "season", "yr", "mnth", "holiday",
  "weekday", "workingday", "weathersit"
)

numeric_predictors <- c("temp", "atemp", "hum", "windspeed")

calculate_metrics <- function(actual, predicted) {
  data.frame(
    RMSE = sqrt(mean((actual - predicted)^2)),
    MAE = mean(abs(actual - predicted)),
    # Preserved from the original project for metric continuity.
    # This is squared Pearson correlation, not 1 - SSE/SST.
    R2 = cor(actual, predicted)^2
  )
}

validate_dataset <- function(data) {
  missing_columns <- setdiff(required_columns, names(data))

  if (length(missing_columns) > 0) {
    stop(
      paste0(
        "Dataset is missing required columns: ",
        paste(missing_columns, collapse = ", ")
      )
    )
  }

  if (anyNA(data[required_columns])) {
    stop("Dataset contains missing values in required columns.")
  }

  invisible(TRUE)
}

prepare_dataset <- function(path = DATA_PATH) {
  if (!file.exists(path)) {
    stop(paste0("Dataset not found: ", path))
  }

  data <- read.csv(path)
  validate_dataset(data)

  data[categorical_columns] <- lapply(
    data[categorical_columns],
    as.factor
  )

  data
}

split_dataset <- function(data, train_ratio = TRAIN_RATIO, seed = SEED) {
  set.seed(seed)

  train_index <- sample(
    seq_len(nrow(data)),
    size = round(train_ratio * nrow(data))
  )

  list(
    train = data[train_index, , drop = FALSE],
    test = data[-train_index, , drop = FALSE]
  )
}

scale_numeric_predictors <- function(train, test) {
  preprocessor <- preProcess(
    train[, numeric_predictors],
    method = c("center", "scale")
  )

  train_scaled <- train
  test_scaled <- test

  train_scaled[, numeric_predictors] <- predict(
    preprocessor,
    train[, numeric_predictors]
  )

  test_scaled[, numeric_predictors] <- predict(
    preprocessor,
    test[, numeric_predictors]
  )

  list(
    train = train_scaled,
    test = test_scaled,
    preprocessor = preprocessor
  )
}

train_linear_model <- function(train) {
  lm(
    cnt ~ temp + hum + windspeed + workingday +
      season + mnth + weathersit,
    data = train
  )
}

train_cart_model <- function(train) {
  rpart(
    cnt ~ season + yr + mnth + holiday + weekday +
      workingday + weathersit + temp + atemp + hum + windspeed,
    data = train,
    method = "anova"
  )
}

train_svm_model <- function(train) {
  svm(
    cnt ~ .,
    data = train,
    kernel = "radial"
  )
}

evaluate_model <- function(model_name, model, test) {
  predictions <- predict(model, newdata = test)
  metrics <- calculate_metrics(test$cnt, predictions)

  cbind(
    data.frame(Model = model_name),
    metrics
  )
}

run_analysis <- function() {
  data <- prepare_dataset()
  split <- split_dataset(data)

  train <- split$train
  test <- split$test

  linear_model <- train_linear_model(train)
  linear_results <- evaluate_model(
    "Multiple Linear Regression",
    linear_model,
    test
  )

  # Scaling is retained here to reproduce the original project workflow,
  # although CART models do not generally require feature scaling.
  cart_data <- scale_numeric_predictors(train, test)
  cart_model <- train_cart_model(cart_data$train)
  cart_results <- evaluate_model(
    "CART",
    cart_model,
    cart_data$test
  )

  svm_data <- scale_numeric_predictors(train, test)
  svm_model <- train_svm_model(svm_data$train)
  svm_results <- evaluate_model(
    "Radial SVM",
    svm_model,
    svm_data$test
  )

  results <- rbind(
    linear_results,
    cart_results,
    svm_results
  )

  print(results)

  best_model <- results$Model[which.min(results$RMSE)]
  message("Best model by RMSE: ", best_model)

  prediction_plot <- data.frame(
    actual = svm_data$test$cnt,
    predicted = predict(svm_model, newdata = svm_data$test)
  )

  print(
    ggplot(prediction_plot, aes(x = actual, y = predicted)) +
      geom_point(alpha = 0.7) +
      geom_abline(slope = 1, intercept = 0) +
      theme_minimal() +
      labs(
        title = "Radial SVM: actual vs predicted demand",
        x = "Actual daily rentals",
        y = "Predicted daily rentals"
      )
  )

  climate_variables <- data |>
    select(temp, atemp, hum, windspeed, cnt)

  correlation_matrix <- cor(
    climate_variables,
    use = "complete.obs"
  )

  print(round(correlation_matrix, 2))

  invisible(
    list(
      data = data,
      train = train,
      test = test,
      models = list(
        linear = linear_model,
        cart = cart_model,
        svm = svm_model
      ),
      results = results
    )
  )
}

if (sys.nframe() == 0) {
  run_analysis()
}
