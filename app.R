
# Load required libraries
library(shiny)
library(randomForest)
library(dplyr)

# Load dataset
student_data <- read.csv("data/student_data.csv",header = TRUE)

# Ensure column names are correct
colnames(student_data) <- c("Serial_No", "GRE.Score", "TOEFL.Score", "University.Rating",
                            "SOP", "LOR", "CGPA", "Research", "Chance_of_Admit")

# Train a Random Forest model
set.seed(123) # For reproducibility
rf_model <- randomForest(Chance_of_Admit ~ GRE.Score + TOEFL.Score + University.Rating + 
                           SOP + LOR + CGPA + Research, data = student_data, ntree = 100)

# Train a Linear Regression model
lm_model <- lm(Chance_of_Admit ~ GRE.Score + TOEFL.Score + University.Rating + 
                 SOP + LOR + CGPA + Research, data = student_data)

# Define UI
ui <- fluidPage(
  titlePanel("University Admission Prediction"),
  sidebarLayout(
    sidebarPanel(
      numericInput("gre", "GRE Score", value = 320, min = 260, max = 340),
      numericInput("toefl", "TOEFL Score", value = 105, min = 80, max = 120),
      sliderInput("rating", "University Rating", min = 1, max = 5, value = 3),
      sliderInput("sop", "SOP Strength", min = 1, max = 5, value = 3),
      sliderInput("lor", "LOR Strength", min = 1, max = 5, value = 3),
      numericInput("cgpa", "CGPA", value = 8.5, min = 6, max = 10),
      radioButtons("research", "Research Experience", choices = list("Yes" = 1, "No" = 0), selected = 1),
      actionButton("predict", "Predict")
    ),
    mainPanel(
      h3("Predicted Chance of Admission"),
      verbatimTextOutput("rf_pred"),
      verbatimTextOutput("lm_pred")
    )
  )
)

# Define server logic
server <- function(input, output) {
  observeEvent(input$predict, {
    user_input <- data.frame(
      GRE.Score = input$gre,
      TOEFL.Score = input$toefl,
      University.Rating = input$rating,
      SOP = input$sop,
      LOR = input$lor,
      CGPA = input$cgpa,
      Research = as.integer(input$research)
    )
    
    # Predict using trained models
    rf_prediction <- predict(rf_model, user_input)
    lm_prediction <- predict(lm_model, user_input)
    
    output$rf_pred <- renderText(paste("Random Forest Prediction:", round(rf_prediction, 2)))
    output$lm_pred <- renderText(paste("Linear Regression Prediction:", round(lm_prediction, 2)))
  })
}

# Run the app
shinyApp(ui = ui, server = server)

