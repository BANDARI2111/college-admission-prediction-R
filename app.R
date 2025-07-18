# Load required libraries
library(shiny)
library(shinythemes)
library(shinyWidgets)
library(randomForest)
library(dplyr)

# =================== Data and Model Training ===================
# Load dataset using your specified path
student_data <- read.csv("data/student_data.csv", header = TRUE)

# Ensure column names are correct
colnames(student_data) <- c("Serial_No", "GRE.Score", "TOEFL.Score", "University.Rating",
                            "SOP", "LOR", "CGPA", "Research", "Chance_of_Admit")

# The model is trained on these specific data types
student_data$Research <- as.factor(student_data$Research)

# Train a Random Forest model
set.seed(123) # For reproducibility
rf_model <- randomForest(Chance_of_Admit ~ GRE.Score + TOEFL.Score + University.Rating +
                           SOP + LOR + CGPA + Research, data = student_data, ntree = 100)

# =================== Shiny UI ===================
ui <- fluidPage(
  theme = shinytheme("cerulean"),
  titlePanel("University Admission Predictor"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Applicant Profile"),
      hr(),
      sliderInput("gre", "GRE Score (260-340)", min = 260, max = 340, value = 320),
      sliderInput("toefl", "TOEFL Score (80-120)", min = 80, max = 120, value = 105),
      sliderInput("rating", "University Rating (1-5)", min = 1, max = 5, value = 3, step = 1),
      sliderInput("sop", "SOP Strength (1-5)", min = 1, max = 5, value = 3.5, step = 0.5),
      sliderInput("lor", "LOR Strength (1-5)", min = 1, max = 5, value = 3.5, step = 0.5),
      numericInput("cgpa", "CGPA (6-10)", value = 8.5, min = 6, max = 10, step = 0.01),
      radioButtons("research", "Has Research Experience?", choices = list("Yes" = 1, "No" = 0), selected = 1, inline = TRUE)
    ),
    
    mainPanel(
      h3("Prediction Results"),
      hr(),
      div(
        style = "border: 1px solid #ddd; padding: 20px; border-radius: 5px; text-align: center;",
        h4("Predicted Chance of Admission (Random Forest)"),
        h2(strong(textOutput("rf_prediction_text"))),
        progressBar(
          id = "admission_progress",
          value = 0,
          title = "",
          display_pct = TRUE,
          status = "info"
        )
      )
    )
  )
)

# =================== Shiny Server ===================
server <- function(input, output, session) {
  
  prediction_chance <- reactive({
    # THE FIX: Explicitly cast each variable to the correct data type
    user_input <- data.frame(
      GRE.Score = as.integer(input$gre),
      TOEFL.Score = as.integer(input$toefl),
      University.Rating = as.integer(input$rating),
      SOP = as.numeric(input$sop),
      LOR = as.numeric(input$lor),
      CGPA = as.numeric(input$cgpa),
      Research = factor(input$research, levels = levels(student_data$Research))
    )
    predict(rf_model, user_input)
  })
  
  output$rf_prediction_text <- renderText({
    paste0(round(prediction_chance() * 100, 1), "%")
  })
  
  observe({
    updateProgressBar(
      session = session,
      id = "admission_progress",
      value = round(prediction_chance() * 100, 1)
    )
  })
}

# Run the app
shinyApp(ui = ui, server = server)
