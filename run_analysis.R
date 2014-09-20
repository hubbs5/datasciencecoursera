#Getting and Merging Data Project

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("dplyr")) {
  install.packages("dplyr")
}

#Apply packages
library(data.table)
library(dplyr)

#Download data from repository
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = "~/R/UCI_HAR_dat.zip")
#Extract test and train data from the zip file as well as labels
y_test <- read.table(unz("~/R/UCI_HAR_dat.zip", "UCI HAR Dataset/test/y_test.txt"))
x_test <- read.table(unz("~/R/UCI_HAR_dat.zip", "UCI HAR Dataset/test/X_test.txt"))
x_train <- read.table(unz("~/R/UCI_HAR_dat.zip", "UCI HAR Dataset/train/X_train.txt"))
y_train <- read.table(unz("~/R/UCI_HAR_dat.zip", "UCI HAR Dataset/train/y_train.txt"))
sub_train <- read.table(unz("~/R/UCI_HAR_dat.zip", "UCI HAR Dataset/train/subject_train.txt"))
sub_test <- read.table(unz("~/R/UCI_HAR_dat.zip", "UCI HAR Dataset/test/subject_test.txt"))
label <-read.table(unz("~/R/UCI_HAR_dat.zip", "UCI HAR Dataset/features.txt"))

#Bind test and training data for X, Y and subjects
x_bind <- rbind(x_test,x_train)   #Data
y_bind_a <- rbind(y_test,y_train) #Activities
sub_bind <- rbind(sub_test, sub_train) #Subjects

#Name Columns for Activities and Subjects
colnames(y_bind_a) <- paste("ActivityDescription")
colnames(sub_bind) <- paste("Subject")

#Add Test Subject Data to y_bind
y_bind <- cbind(sub_bind,y_bind_a)

#Find the measurements that contain means and standard deviations
names <- label$V2 #Extracts the vector of names
names_means <- grep("mean", names) #Finds the numbers corresponding to mean measurements
names_std <- grep("std", names)  #Finds the numbers corresponding to stand dev measurements
names_ext <- sort(c(names_std,names_means), decreasing = FALSE) #Combines and orders the extracted column numbers
meas <- x_bind[,c(names_ext)] #Extracts only the columns that correspond to mean and std measurements
labels <- label[names_ext,2] #Creates vector of labels containing only mean and std

#Clean the labels by removing non-alphanumeric characters and abbreviations
labels <- gsub("\\(", "", labels)
labels <- gsub(")", "", labels)
labels <- gsub("-", "", labels)
labels <-sub("t", "Time", labels)
labels <- sub("Acc", "Acceleration", labels)
labels <- sub("BodyBody", "Body", labels)
labels <- sub("mean", "Mean", labels)
labels <- sub("Freq", "", labels)
labels <- sub("f", "Frequency", labels)
labels <- sub("std", "StandardDev", labels)

#Rename Column Names According to Tidied Data
colnames(meas) <- labels

#Bind test data and activity values into single dataframe
data <- cbind(y_bind,meas)

#Summarize data and average over the values in the columns
data_summary <- ddply(data, .(Subject, ActivityDescription), numcolwise(mean))

