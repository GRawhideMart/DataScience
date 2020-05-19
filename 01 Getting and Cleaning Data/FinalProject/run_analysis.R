## PRELIMINARY PHASE, GETTING DATA
library(dplyr)
library(lubridate)

url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(url, destfile = './dataset.zip', method = 'curl')
downloadDate <- now()
unzip('./dataset.zip')

## NOW THERE IS A SUBFOLDER, UCI HAR Dataset, WHICH CONTAINS THE DATASET
features <- tibble(read.table('./UCI HAR Dataset/features.txt', col.names = c('classCode','featureName')))
wantedFeatures <- filter(features, grepl('(mean|std)\\(\\)', featureName))
levels(wantedFeatures$featureName) <- gsub('[()]', '', levels(wantedFeatures$featureName)) #Feature names are factors, so what has to be manipulated are the levels

train <- tibble(read.table('./UCI HAR Dataset/train/X_train.txt'))[wantedFeatures$classCode]
colnames(train) <- wantedFeatures$featureName
trainSubject <- tibble(read.table('./UCI HAR Dataset/train/subject_train.txt'))
colnames(trainSubject) <- 'subject'
trainActivities <- tibble(read.table('./UCI HAR Dataset/train/y_train.txt'))
colnames(trainActivities) <- 'activityName'
train <- as_tibble(cbind(trainSubject,trainActivities,train))

test <- tibble(read.table('./UCI HAR Dataset/test/X_test.txt'))[wantedFeatures$classCode]
colnames(test) <- wantedFeatures$featureName
testSubject <- tibble(read.table('./UCI HAR Dataset/test/subject_test.txt'))
colnames(testSubject) <- 'subject'
testActivities <- tibble(read.table('./UCI HAR Dataset/test/y_test.txt'))
colnames(testActivities) <- 'activityName'
test <- as_tibble(cbind(testSubject,testActivities,test))

dataset <- rbind(train,test)