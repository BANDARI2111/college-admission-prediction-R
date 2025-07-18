# College Admission Prediction Model

## 🎯 Objective
This project predicts a student's chance of college admission based on their profile, including GRE scores, TOEFL scores, and CGPA. It implements and compares two models: **Linear Regression** and **Random Forest**. An interactive prediction tool is also included as a Shiny app.

## ✨ Key Features
-   **Data Cleaning:** Handles missing values and prepares data for modeling.
-   **Exploratory Data Analysis (EDA):** Uses `ggplot2` and `plotly` to visualize data distributions and correlations.
-   **Statistical Inference:** A t-test is used to check for significant differences in CGPA between admitted and non-admitted students.
-   **Dual-Model Prediction:**
    -   **Linear Regression:** A straightforward, interpretable model.
    -   **Random Forest:** A powerful ensemble model for potentially higher accuracy.
-   **Model Evaluation:** Compares models using RMSE, R-squared, and MAE.
-   **Interactive Shiny App:** Allows users to input their own scores and get an instant admission chance prediction.

## 🚀 How to Run

1.  Clone the repository:
    ```bash
    git clone [https://github.com/BANDARI2111/college-admission-prediction-R.git](https://github.com/BANDARI2111/college-admission-prediction-R.git)
    ```
2.  Open the project in RStudio.
3.  Install the required libraries:
    ```R
    install.packages(c("tidyverse", "ggplot2", "plotly", "caret", "randomForest", "shiny"))
    ```
4.  Run `analysis.R` to see the full data analysis and model comparison.
5.  Run `app.R` to launch the interactive Shiny prediction tool.

## 📊 Model Comparison Results

The models were evaluated on a held-out test set (20% of the data). The Random Forest model demonstrated slightly better performance with a lower RMSE, making it the recommended model for this task.

| Model               | RMSE   | R-squared | MAE    |
| ------------------- | ------ | --------- | ------ |
| Linear Regression   | 0.0632 | 0.8143    | 0.0451 |
| **Random Forest** | **0.0594** | **0.8354** | **0.0415** |
