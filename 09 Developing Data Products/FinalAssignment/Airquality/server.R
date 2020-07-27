library(shiny)
require(caret)
require(ggplot2)
require(gridExtra)

attach(airquality)

# Define server logic required to generate a model
shinyServer(function(input, output) {

    
    output$distPlot <- renderPlot({
        
        
        partition <- input$p
        impute <- input$impute
        kFolds <- input$folds
        
        if(impute == 1) {
            airquality <- predict(preProcess(airquality, 'medianImpute'), airquality)
        } 
        if(impute == 0) {
            airquality <- airquality[complete.cases(airquality),]
        }
        
        inTrain <- createDataPartition(y = airquality$Ozone, p = partition, list = FALSE)
        training <- airquality[inTrain,]
        testing <- airquality[-inTrain,]
        
        modelControl <- trainControl(method = 'cv', number = kFolds)
        modelLinear <- train(Ozone ~ ., data = training, method = 'lm', trControl = modelControl)
        prediction <- predict(modelLinear, newdata = testing)
        pl1 <- qplot(testing$Temp, testing$Ozone) + geom_smooth() + xlab('') + ylab('Testing')
        pl2 <- qplot(testing$Temp, prediction) + geom_smooth() + xlab('Temperature') + ylab('Prediction')
        grid.arrange(pl1, pl2, ncol = 1, nrow = 2)
    })
})
