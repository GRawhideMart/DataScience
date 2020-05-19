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
activities <- tibble(read.table('./UCI HAR Dataset/activity_labels.txt', col.names = c('ActivityCode','ActivityName')))
features <- tibble(read.table('./UCI HAR Dataset/features.txt', col.names = c('ClassCode','FeatureName')))
wantedFeatures <- filter(features, grepl('(mean|std)\\(\\)', FeatureName))
levels(wantedFeatures$FeatureName) <- gsub('[()]', '', levels(wantedFeatures$FeatureName)) #Feature names are factors, so what has to be manipulated are the levels

train <- tibble(read.table('./UCI HAR Dataset/train/X_train.txt'))[wantedFeatures$ClassCode]
colnames(train) <- wantedFeatures$FeatureName
trainSubject <- tibble(read.table('./UCI HAR Dataset/train/subject_train.txt'))
colnames(trainSubject) <- 'Subject'
trainActivities <- tibble(read.table('./UCI HAR Dataset/train/y_train.txt'))
colnames(trainActivities) <- 'ActivityName'
train <- as_tibble(cbind(trainSubject,trainActivities,train))

test <- tibble(read.table('./UCI HAR Dataset/test/X_test.txt'))[wantedFeatures$ClassCode]
colnames(test) <- wantedFeatures$FeatureName
testSubject <- tibble(read.table('./UCI HAR Dataset/test/subject_test.txt'))
colnames(testSubject) <- 'Subject'
testActivities <- tibble(read.table('./UCI HAR Dataset/test/y_test.txt'))
colnames(testActivities) <- 'ActivityName'
test <- as_tibble(cbind(testSubject,testActivities,test))

dataset <- rbind(train,test)
dataset$ActivityName <- factor(dataset$ActivityName, labels = activities$ActivityName)

dataset <- group_by(dataset, Subject, ActivityName)
tidydata <- summarise_all(dataset, mean)
names(tidydata)<-gsub("std()", "SD", names(tidydata))
names(tidydata)<-gsub("mean()", "MEAN", names(tidydata))
names(tidydata)<-gsub("^t", "Time", names(tidydata))
names(tidydata)<-gsub("^f", "Frequency", names(tidydata))
names(tidydata)<-gsub("Acc", "Accelerometer", names(tidydata))
names(tidydata)<-gsub("Gyro", "Gyroscope", names(tidydata))
names(tidydata)<-gsub("Mag", "Magnitude", names(tidydata))
names(tidydata)<-gsub("BodyBody", "Body", names(tidydata))

write.table(tidydata, file = "tidy.txt", row.names=FALSE)
write.csv(tidydata, file = "tidy.csv", row.names=FALSE)