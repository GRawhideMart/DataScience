library(shiny)

shinyServer(function(input, output) {
    output$plot1 <- renderPlot({
        set.seed(20193)
        nOfPoints <- input$numeric
        minX <- input$sliderX[1]
        maxX <- input$sliderX[2]
        minY <- input$sliderY[1]
        maxY <- input$sliderY[2]
        meanX <- input$xmean
        meanY <- input$ymean
        sdX <- input$xsd
        sdY <- input$ysd
        dataX <- rnorm(n = nOfPoints, mean = meanX, sd = sdX)
        dataY <- rnorm(n = nOfPoints, mean = meanY, sd = sdY)
        xlab <- ifelse(input$show_xlab, 'X Axis','')
        ylab <- ifelse(input$show_ylab, 'Y Axis','')
        main <- ifelse(input$show_title, 'Random Normal Numbers','')
        plot(dataX, dataY, 
             xlab = xlab, 
             ylab = ylab, 
             main = main, 
             xlim = c(-100,100), 
             ylim = c(-100,100)) 
    })
})
