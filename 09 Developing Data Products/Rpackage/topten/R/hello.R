# Some useful keyboard shortcuts for package authoring:
#
#   Install Package:           'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

#' Building a Model with Top Ten Features
#'
#' This function develops an algorithm based on the top ten features in 'x' that are most predictive of 'y'
#'
#' @param x a matrix of n observations of p variables
#' @param y a vector of n representing the response
#' @return a vector of coefficients from the final fitted model
#' @author Giulio Mario Martena
#' @details
#' This function runs a univariate regression of y on each predictor in x and calculates a p-value indicating the significance of the association. The final set of 10 predictors is taken from the smallest 10 p-values.
#' @seealso \code{lm}
#' @export
#' @importFrom stats lm
#'

topten <- function(x,y) {
    p <- ncol(x)
    if(p < 10) stop('There are less than 10 predictors')
    pvalues <- numeric(p)
    for (i in seq_len(p)) {
        fit <- lm(y ~ x[,i])
        summ <- summary(fit)
        pvalues[i] <- summ$coefficients[2,4]
    }
    ord <- order(pvalues)[1:10]
    x10 <- x[,ord]
    fit <- lm(y ~ x10)
    coef(fit)
}

#' Prediction from top 10 features
#'
#' This function takes a set of coefficients produced by \code{topten} function and makes a prediction for each of the values provided in the input matrix.
#'
#' @param X a n x 10 matrix containing n NEW observations
#' @param b a vector of coefficients obtained from the \code{topten} function
#' @return a numeric vector containing the predicted values
#' @export
#'
predict10 <- function(X, b) {
    X <- cbind(1, X)
    drop(X %*% b)
}
