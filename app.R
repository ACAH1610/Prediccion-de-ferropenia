#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinyFeedback)
library(shinyalert)
library(caret)
library(dplyr)
library(kernlab) 
library(ranger)

# Cargar los datos y el modelo de machine learning
load("datos_ferropenia.RData")

# Definir la interfaz de usuario
ui <- dashboardPage(
  skin = "red",
  dashboardHeader(
    title = "Predicción ferropenia",
    titleWidth = 340,
    tags$li(class = "dropdown", shinyjs::hidden(downloadLink("downloadReport", "Generate report")))
  ),
  dashboardSidebar(
    width = 340,
    div(id = "form",
        textInput("Id", label = "ID:", placeholder = "Ejemplo: 1, Paciente 1,...", width = 340),
        sliderInput("Edad", label = "Edad", min = 1, max = 18, value = 10, width = 340),
        radioButtons("Sexo", label = "Género", choices = list("Femenino" = 1, "Masculino" = 0), selected = integer(0), inline = TRUE, width = 340),
        div(style = "display: flex; justify-content: space-between;",
            div(style = "width: 43%;", numericInput("HTIE", label = "Hematíes (mill/uL)", value = NA)),
            div(style = "width: 43%;", numericInput("VCM", label = "VCM (fL)", value = NA))
        ),
        div(style = "display: flex; justify-content: space-between;",
            div(style = "width: 43%;", numericInput("ADE", label = "ADE (%)", value = NA)),
            div(style = "width: 43%;", numericInput("CHCM", label = "CHCM (g/dL)", value = NA))
        ),
        numericInput("HTCO", label = "Hematocrito (%)", value = NA, width = 146.2),
        tags$style(HTML(".shiny-input-container {overflow: visible;}"))
    ),
    div(class = "form-buttons",
        div(style = "display: flex; justify-content: space-between;",  
            actionButton("clear", "Limpiar"),             
            actionButton("submit", "Predicción")
        )
    )
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "icon", href = "favicon.svg"),
      tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    ),
    shinyjs::useShinyjs(),
    shinyalert::useShinyalert(),
    shinyFeedback::useShinyFeedback(), 
    
    div(class = "boxMain",
        fluidRow(
          box(title = "Predicción", status = "danger", solidHeader = TRUE,
              collapsible = TRUE, width = 12,
              uiOutput("resultsUI")
          )
        ),
        fluidRow(
          box(title = "Datos", status = "danger", solidHeader = TRUE,
              collapsible = TRUE, width = 12,
              uiOutput("tablesUI") 
          )
        )
    ),
    
    tags$footer(p("Predicción del estado de ferropenia by Andrea C. Atúncar Huamán"),
                div(class = "footerLinks",
                    actionLink("linkedin", label = a(href = "https://www.linkedin.com/in/andrea-carolina-at%C3%BAncar-huam%C3%A1n-671a9a266/", 
                                                     div(class = "linkedinLink", icon("linkedin"), p("Andrea C.Atúncar Huamán")), target = "_blank")),
                    actionLink("github", label = a(href = "https://github.com/ACAH1610", 
                                                   div(icon("github"), p("Andrea C.Atúncar Huamán")), target = "_blank"))
                ),
                HTML('<div class="CreativeCommons"><a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/" target="_blank">
                     <img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" />
                     </a>This work is licensed under a<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/" target="_blank">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>
                     </div>'),
    )
  )
)


# Define server logic
server <- function(input, output, session) {
  
  # Comprobamos que los inputs son correctos
  # Check success and warnings
  
  ## Input ID
  observeEvent(input$Id, {
    if (nchar(input$Id) > 0) {
      hideFeedback("Id")
      showFeedbackSuccess(inputId = "Id")
    } else {
      hideFeedback("Id")
    }
  })
  
  ## Input Género
  observeEvent(input$Sexo, {
    if (!is.na(input$Sexo)) {
      hideFeedback("Sexo")
      showFeedbackSuccess(inputId = "Sexo")
    } else {
      hideFeedback("Sexo")
    }
  })
  
  
  ## Input HTIE
  observeEvent(input$HTIE, {
    if (!is.na(input$HTIE) & input$HTIE > 0) {
      hideFeedback("HTIE")
      showFeedbackSuccess(inputId = "HTIE")
    } else if (!is.na(input$HTIE) & input$HTIE <= 0) {
      hideFeedback("HTIE")
      showFeedbackWarning(inputId = "HTIE", text = "Debe ser un número positivo")
    } else {
      hideFeedback("HTIE")
    }
  })
  
  ## Input VCM
  observeEvent(input$VCM, {
    if (!is.na(input$VCM) & input$VCM > 0) {
      hideFeedback("VCM")
      showFeedbackSuccess(inputId = "VCM")
    } else if (!is.na(input$VCM) & input$VCM <= 0) {
      hideFeedback("VCM")
      showFeedbackWarning(inputId = "VCM", text = "Debe ser un número positivo")
    } else {
      hideFeedback("VCM")
    }
  })
  
  ## Input ADE
  observeEvent(input$ADE, {
    if (!is.na(input$ADE) & input$ADE > 0) {
      hideFeedback("ADE")
      showFeedbackSuccess(inputId = "ADE")
    } else if (!is.na(input$ADE) & input$ADE <= 0) {
      hideFeedback("ADE")
      showFeedbackWarning(inputId = "ADE", text = "Debe ser un número positivo")
    } else {
      hideFeedback("ADE")
    }
  })
  
  ## Input CHCM
  observeEvent(input$CHCM, {
    if (!is.na(input$CHCM) & input$CHCM > 0) {
      hideFeedback("CHCM")
      showFeedbackSuccess(inputId = "CHCM")
    } else if (!is.na(input$CHCM) & input$CHCM <= 0) {
      hideFeedback("CHCM")
      showFeedbackWarning(inputId = "CHCM", text = "Debe ser un número positivo")
    } else {
      hideFeedback("CHCM")
    }
  })
  
  ## Input HTCO
  observeEvent(input$HTCO, {
    if (!is.na(input$HTCO) & input$HTCO > 0) {
      hideFeedback("HTCO")
      showFeedbackSuccess(inputId = "HTCO")
    } else if (!is.na(input$HTCO) & input$HTCO <= 0) {
      hideFeedback("HTCO")
      showFeedbackWarning(inputId = "HTCO", text = "Debe ser un número positivo")
    } else {
      hideFeedback("HTCO")
    }
  })
  
  # Check required inputs
  observeEvent(input$submit, {
    # Input ID
    if (nchar(input$Id) == 0) { 
      showFeedbackDanger(inputId = "Id", text = "ID es requerido")
    }
    # Input Edad     
    if (is.na(input$Edad)) { 
      showFeedbackDanger(inputId = "Edad", text = "Edad es requerida")
    }
    # Input Género    
    if (is.null(input$Sexo))  { 
      showFeedbackDanger(inputId = "Sexo", text = "Género es requerido")
    }
    # Input HTIE      
    if (is.na(input$HTIE)) { 
      showFeedbackDanger(inputId = "HTIE", text = "Hematíes es requerido")
    }
    # Input VCM    
    if (is.na(input$VCM)) { 
      showFeedbackDanger(inputId = "VCM", text = "VCM es requerido")
    }
    # Input ADE    
    if (is.na(input$ADE)) { 
      showFeedbackDanger(inputId = "ADE", text = "ADE es requerido")
    }
    # Input CHCM     
    if (is.na(input$CHCM)) { 
      showFeedbackDanger(inputId = "CHCM", text = "CHCM es requerido")
    }
    # Input HTCO      
    if (is.na(input$HTCO)) {
      showFeedbackDanger(inputId = "HTCO", text = "Hematocrito es requerido")
    }
  })
  
  # Storage Data 
  storageData <- reactiveValues(data = NULL)
  
  # Save data
  observeEvent(input$submit, {
    req( input$Id, input$Sexo,input$Edad, input$HTIE, input$VCM, input$ADE, input$CHCM, input$HTCO) 
    
    storageData$data <- data.frame(
      ID= input$Id,
      Sexo = as.numeric(input$Sexo),
      Edad = as.numeric(input$Edad),
      HTIE = as.numeric(input$HTIE),
      VCM = as.numeric(input$VCM),
      ADE = as.numeric(input$ADE),
      CHCM = as.numeric(input$CHCM),
      HTCO = as.numeric(input$HTCO)
    )
  })
  
  # Clear data  
  observeEvent(input$clear, {
    shinyjs::reset("form")
  })
  
  # Prediction #
  prediction <- eventReactive(input$submit, {
    req(storageData$data)
    
    # Excluir la primera columna (ID)
    dataWithoutID <- storageData$data[,-1]
    
    # Normalización de los nuevos datos con los datos de normalización del entrenamiento 
    testTransformed <- predict(preProcValues, dataWithoutID)
    
    # Prediction/s
    predict(modelo_forest, newdata = testTransformed)
  })
 
  
  # Dataframe with data and predictions
  data_pred <- eventReactive(input$submit, {
    req(prediction())
    storageData$data
  })
  
  # Data and predictions:
  observeEvent(input$submit, {
    req(prediction(), data_pred())
    
 
    # different UI components and outputs:
    
    output$resultsUI <- renderUI({
      textOutput("uni_class_predict")
    })
    
    output$tablesUI <- renderUI({
      tableOutput("unitable")
    })
    
    # Result unique
    output$uni_class_predict <- renderText({paste("El resultado de la predicción es:", prediction()[1],"(AF: Anemia Ferropénica, FF/FL: Ferropenia funcional o ferropenia Latente, NF: Ausencia de Ferropenia)")})
    
    # Table unique
    output$unitable <- renderTable({storageData$data[1,]})
  })
}

shinyApp(ui, server)
