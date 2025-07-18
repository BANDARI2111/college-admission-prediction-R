
##############################
# 1. Data Acquisition & Preparation
##############################

# Load necessary libraries
library(tidyverse)    # Data manipulation and visualization
library(ggplot2)      # Static plotting
library(dplyr)        # Data manipulation
library(plotly)       # Interactive visualizations
library(caret)        # Data partitioning and evaluation
library(randomForest) # Random Forest modeling

# Load the dataset from CSV.
# The dataset should have columns:
# Serial No., GRE Score, TOEFL Score, University Rating, SOP, LOR, CGPA, Research, Chance of Admit
data <- read.csv("data/student_data.csv",header = TRUE)

# Remove the Serial No. column as it is not a predictor.
data <- data %>% select(-Serial.No.)

# Inspect the first few rows
head(data)

# Data Cleaning: Remove missing values and adjust variable types
data <- na.omit(data)  # Remove rows with missing values
data$Research <- as.factor(data$Research)  # Convert Research into a factor

##############################
# 2. Exploratory Data Analysis (EDA)
##############################

# Display summary statistics
summary(data)

# Visualization 1: Histogram of CGPA distribution
p1 <- ggplot(data, aes(x = CGPA)) +
  geom_histogram(binwidth = 0.1, fill = "steelblue", color = "black", alpha = 0.7) +
  labs(title = "Distribution of CGPA", x = "CGPA", y = "Count") +
  theme_minimal()
print(p1)

# Visualization 2: Scatter Plot of GRE Score vs. Chance of Admit
p2 <- ggplot(data, aes(x = GRE.Score, y = Chance.of.Admit)) +
  geom_point(color = "firebrick", alpha = 0.7) +
  labs(title = "GRE Score vs. Chance of Admit", x = "GRE Score", y = "Chance of Admit") +
  theme_minimal()
print(p2)

# Visualization 3: Boxplot of TOEFL Score by Research Experience
p3 <- ggplot(data, aes(x = Research, y = TOEFL.Score, fill = Research)) +
  geom_boxplot() +
  labs(title = "TOEFL Score by Research Experience", x = "Research Experience", y = "TOEFL Score") +
  theme_minimal()
print(p3)

# Optional: Compute a correlation matrix for key numerical variables
cor_matrix <- cor(data[, c("GRE.Score", "TOEFL.Score", "University.Rating", "SOP", "LOR", "CGPA", "Chance.of.Admit")])
print("Correlation Matrix:")
print(cor_matrix)

##############################
# 3. Data Analysis & Statistical Inference
##############################

# Create a binary classification for admission status
data <- data %>% 
  mutate(Admission_Status = ifelse(Chance.of.Admit >= 0.5, "Admitted", "Not Admitted"))
data$Admission_Status <- as.factor(data$Admission_Status)

# Conduct a t-test comparing CGPA between admitted and not admitted groups
t_test_result <- t.test(CGPA ~ Admission_Status, data = data)
print("T-Test Result for CGPA between Admission Groups:")
print(t_test_result)
# Interpretation: A significant p-value indicates a difference in CGPA between groups.

##############################
# 4. Predictive Modeling: Linear Regression & Random Forest
##############################

# Split the data into training (80%) and testing (20%) sets
set.seed(123)  # For reproducibility
trainIndex <- createDataPartition(data$Chance.of.Admit, p = 0.8, list = FALSE)
trainData <- data[trainIndex, ]
testData  <- data[-trainIndex, ]

### Model 1: Linear Regression
lm_model <- lm(Chance.of.Admit ~ GRE.Score + TOEFL.Score + University.Rating + SOP + LOR + CGPA + Research, data = trainData)
summary(lm_model)

# Prediction using Linear Regression
lm_predictions <- predict(lm_model, newdata = testData)

### Model 2: Random Forest Regression
rf_model <- randomForest(Chance.of.Admit ~ GRE.Score + TOEFL.Score + University.Rating + SOP + LOR + CGPA + Research,
                         data = trainData, ntree = 500, importance = TRUE)
print(rf_model)

# Prediction using Random Forest
rf_predictions <- predict(rf_model, newdata = testData)

##############################
# 5. Model Evaluation
##############################

# Function to calculate evaluation metrics
evaluate_model <- function(actual, predicted, model_name = ""){
  rmse <- sqrt(mean((predicted - actual)^2))
  r2 <- 1 - sum((predicted - actual)^2) / sum((mean(actual) - actual)^2)
  mae <- mean(abs(predicted - actual))
  cat(paste(model_name, "RMSE:", round(rmse, 4), "\n"))
  cat(paste(model_name, "Test R-squared:", round(r2, 4), "\n"))
  cat(paste(model_name, "MAE:", round(mae, 4), "\n\n"))
  return(list(RMSE = rmse, R2 = r2, MAE = mae))
}

# Evaluate Linear Regression Model
cat("Linear Regression Evaluation:\n")
lm_metrics <- evaluate_model(testData$Chance.of.Admit, lm_predictions, "Linear Regression")

# Evaluate Random Forest Model
cat("Random Forest Evaluation:\n")
rf_metrics <- evaluate_model(testData$Chance.of.Admit, rf_predictions, "Random Forest")

# Optional: Residual Plots for Visual Diagnosis
par(mfrow = c(1, 2))
plot(lm_predictions - testData$Chance.of.Admit,
     main = "Linear Regression Residuals",
     ylab = "Residuals", xlab = "Index",
     col = "blue", pch = 16)
abline(h = 0, col = "red", lwd = 2)

plot(rf_predictions - testData$Chance.of.Admit,
     main = "Random Forest Residuals",
     ylab = "Residuals", xlab = "Index",
     col = "green", pch = 16)
abline(h = 0, col = "red", lwd = 2)
par(mfrow = c(1, 1))

##############################
# 6. Model Comparison & Recommendation
##############################

if(lm_metrics$RMSE < rf_metrics$RMSE){
  recommendation <- "Linear Regression has a lower RMSE and is simpler, making it more suitable for this dataset."
} else if(lm_metrics$RMSE > rf_metrics$RMSE){
  recommendation <- "Random Forest has a lower RMSE, indicating better predictive performance. It is recommended for deployment."
} else {
  recommendation <- "Both models perform similarly. Choose based on interpretability vs. complexity."
}
cat("\nModel Recommendation:\n", recommendation, "\n")
