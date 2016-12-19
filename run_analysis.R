## run_analysis.R

## Download zip file
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "uci.zip")

## Read data files from zip file
con <- unz(description="uci.zip", filename="UCI HAR Dataset/train/subject_train.txt")
subjTrain <- read.table(con, header=FALSE)

con <- unz(description="uci.zip", filename="UCI HAR Dataset/test/subject_test.txt")
subjTest <- read.table(con, header=FALSE)

con <- unz(description="uci.zip", filename="UCI HAR Dataset/train/y_train.txt")
yTrain <- read.table(con, header=FALSE)

con <- unz(description="uci.zip", filename="UCI HAR Dataset/test/y_test.txt")
yTest <- read.table(con, header=FALSE)

con <- unz(description="uci.zip", filename="UCI HAR Dataset/train/X_train.txt")
xTrain <- read.table(con, header=FALSE)

con <- unz(description="uci.zip", filename="UCI HAR Dataset/test/X_test.txt")
xTest <- read.table(con, header=FALSE)

con <- unz(description="uci.zip", filename="UCI HAR Dataset/features.txt")
features <- read.table(con, header=FALSE)

## 1. Merges the training and the test sets to create one data set
# Combine test and train sets

subj <- rbind(subjTrain, subjTest)
y <- rbind(yTrain, yTest)
x <- rbind(xTrain, xTest)

names(subj)<-c("subject")
names(y)<- c("activity")
names(x)<- features$V2

# Merge above three sets to create one dataset
subj_y <- cbind(subj, y)
uci <- cbind(x, subj_y)

## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
nm_mean_sd <- features$V2[grep("mean\\(\\)|std\\(\\)", features$V2)]
nm_mean_sd <- as.character(nm_mean_sd)
uci <- subset(uci, select=c(nm_mean_sd, "subject", "activity"))

## 3. Uses descriptive activity names to name the activities in the data set
con <- unz(description="uci.zip", filename="UCI HAR Dataset/activity_labels.txt")
activity_labels <- read.table(con, header=FALSE)

# Assign labels to activities by factoring
uci$activity <- factor(uci$activity, levels = activity_labels[,1], labels = activity_labels[,2])

## 4. Appropriately labels the data set with descriptive variable names.
names(uci)<-gsub("^f", "frequency", names(uci))
names(uci)<-gsub("^t", "time", names(uci))
names(uci)<-gsub("Acc", "Accelerometer", names(uci))
names(uci)<-gsub("Gyro", "Gyroscope", names(uci))
names(uci)<-gsub("Mag", "Magnitude", names(uci))

## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
library(plyr);
uci2<-aggregate(.~subject + activity, uci, mean)
write.table(uci2, file = "tidydata_uci.txt",row.name=FALSE)
