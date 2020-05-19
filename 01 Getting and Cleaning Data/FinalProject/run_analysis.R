## PRELIMINARY PHASE, GETTING DATA
library(dplyr)
library(lubridate)

if(!dir.exists('./UCI HAR Dataset/')) {
    url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
    download.file(url, destfile = './dataset.zip', method = 'curl')
    downloadDate <- now()
    unzip('./dataset.zip')
}

## NOW THERE IS A SUBFOLDER, UCI HAR Dataset, WHICH CONTAINS THE DATASET
activities <- tibble(read.table('./UCI HAR Dataset/activity_labels.txt', col.names = c('activityCode','activityName')))
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
dataset$activityName <- factor(dataset$activityName, labels = activities$activityName)

dataset <- group_by(dataset, subject, activityName)
tidydata <- summarise_all(dataset, mean)
names(tidydata)<-gsub("std()", "SD", names(tidydata))
names(tidydata)<-gsub("mean()", "MEAN", names(tidydata))
names(tidydata)<-gsub("^t", "time", names(tidydata))
names(tidydata)<-gsub("^f", "frequency", names(tidydata))
names(tidydata)<-gsub("Acc", "Accelerometer", names(tidydata))
names(tidydata)<-gsub("Gyro", "Gyroscope", names(tidydata))
names(tidydata)<-gsub("Mag", "Magnitude", names(tidydata))
names(tidydata)<-gsub("BodyBody", "Body", names(tidydata))

write.table(tidydata, file = "tidy.txt", row.names=FALSE)
write.csv(tidydata, file = "tidy.csv", row.names=FALSE)