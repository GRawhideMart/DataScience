library(shiny)

shinyUI(fluidPage(

    # Application title
    titlePanel("Plot Random Numbers"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            numericInput('numeric', 'Numbers to plot',
                         value = 1000,
                         min = 1,
                         max = 1000,
                         step = 1),
            sliderInput('sliderX', 'X values',
                        min = -100,
                        max = 100,
                        step = 1,
                        animate = TRUE,
                        value = c(-50,50)),
            sliderInput('sliderY', 'Y values',
                        min = -100,
                        max = 100,
                        step = 1,
                        animate = TRUE,
                        value = c(-50,50)),
            numericInput('xmean', 'Mean of X',
                         value = 0,
                         min = -750,
                         max = 750,
                         step = 1),
            numericInput('xsd', 'Standard deviation of X',
                         value = 1,
                         min = 0.5,
                         max = 50,
                         step = 1),
            numericInput('ymean', 'Mean of Y',
                         value = 0,
                         min = -750,
                         max = 750,
                         step = 1),
            numericInput('ysd', 'Standard deviation of Y',
                         value = 1,
                         min = 0.5,
                         max = 50,
                         step = 1),
            checkboxInput('show_xlab','Show/Hide x title',
                          value = TRUE),
            checkboxInput('show_ylab','Show/Hide y title',
                          value = TRUE),
            checkboxInput('show_title','Show/Hide main title',
                          value = TRUE)
        ),

        # Show a plot of the generated distribution
        mainPanel(
            h3('Graph of Random Points'),
            plotOutput('plot1')
        )
    )
))
