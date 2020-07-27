library(shiny)

# Define UI for application
shinyUI(fluidPage(

    # Application title
    titlePanel("Machine Learning model of Ozone level"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            sliderInput("p",
                        "Training partition",
                        min = 0.60,
                        max = 0.75,
                        value = .7,
                        step = .05),
            checkboxInput('impute', 'Impute NAs', TRUE),
            numericInput('folds', 'N. of folds for cross-validation',
                         value = 2,
                         min = 2,
                         max = 5,
                         step = 1)#,
            #actionButton('submit', 'Recalculate')
        ),
        

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("distPlot"),
            h3('Docs'),
            p('This little app performs a little and very (too very) basic machine learning on the dataset regarding the levels of ozone in New York City.'),
            p('The data partition lets the user choose how much of the 153 observations to allocate to the training part.'),
            p('The impute NAs option lets the user decide to impute NAs with the median method. If unchecked, the dataset will be shrunk to just exclude incomplete cases altogether.'),
            p('The last option lets the user set the k parameter for k-folds cross validation.'),
            h3('Disclaimer'),
            p('This does not want to be an actual exercise on machine learning, so I took some liberties. Never ever machine learning would be actually performed on such a low number of observations; I chose to do so because a reactive recalculation of a huge dataset would take too much to refresh.')
        
        )
    )
))
