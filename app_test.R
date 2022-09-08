library(shiny)

ui <- fluidRow(title = 'Minimal app',
               numericInput("num_input", "Please insert a number n:", 0),
               textOutput('text_out')
)

server <- function(input, output, session) {
    result <- reactive(input$num_input^2)
    output$text_out <- renderText(
        paste("The square of the number n is: n² =", result())
    )
}

shinyApp(ui, server)