# This script downloads a zipfile with data concerning an experiment for human activity recognition. 
# 1. Download the zipfile and unzip the file. To do this, set the boolean downloaded to 'FALSE'
# 2. Read the data and the labels
# 3. Merge the test and train data
# 4. Select only the mean and the standard deviation of each variable of interest
# 5. Melt and cast the data to retain only the average of each variable for each activity and each subject
# 6. Write the data to csv. 

library(reshape2)

# Settings
downloaded <- TRUE # Set to FALSE to download the file

# Specify the files to read
features.file <- "features.txt"
activityLabels.file <- "activity_labels.txt"
dirDataset <- "./data/UCI HAR Dataset"
dirTestData <- paste(dirDataset, "test", sep = "/")
dirTrainData <- paste(dirDataset, "train", sep = "/")


# Download the zipfile to the folder 'data' and unzip the file. (Works on Windows 8,
# for other platforms you might need to change to https and set method = "curl" and use https)
if (!downloaded){
    fileUrl <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    if (!file.exists("./data")){
        dir.create("./data")
    }
    dir <- "./data"
    file <- tempfile(tmpdir=dir, fileext=".zip")
    download.file(fileUrl, file)
    fname = unzip(file,list=TRUE)$Name[]
    unzip(file, files=fname, exdir = dir, overwrite = TRUE)
}

# The directory that contains the data. Change this if the data is somewhere else. 
dir <- "./data"

# Read the activity and features labels and label them
features <- read.table(paste(dirDataset, features.file, sep = "/"))
activityLabels <- read.table(paste(dirDataset, activityLabels.file, sep = "/"))
names(features) <- c("featureId", "feature")
names(activityLabels) <- c("activityId", "activity")

# Read the test data 
x <- read.table(paste(dirTestData,"x_test.txt",sep="/"))
y <- read.table(paste(dirTestData,"y_test.txt",sep="/"))
subject <- read.table(paste(dirTestData,"subject_test.txt",sep="/"))

# Bind the train data to the test data
x <- rbind(x, read.table(paste(dirTrainData,"x_train.txt",sep="/")))
y <- rbind(y, read.table(paste(dirTrainData,"y_train.txt",sep="/")))
subject <- rbind(subject, read.table(paste(dirTrainData,"subject_train.txt",sep="/")))

# Name the datasets
names(x) <- features$feature
names(y) <- "activity"
names(subject) <- "subjectId"

# Select only the measurements on the mean and standard deviation for each measure
cols <- sapply(names(x), function(y) any(grep("mean()|std()|meanFreq()", y, ignore.case=FALSE)))
x <- x[,cols]

# replace activityId by activity
y$activity <- activityLabels[y$activity,]$activity

# Bind the three datasets together by columns
dataSet <- cbind(subject, y, x)

# Melt the dataframe: specify which variables are id's and which variables are measures
meltData <- melt(dataSet, id = c("subjectId", "activity"), measure.vars = names(x))

# Cast the data to get the average of each variable for each activity and each subject. 
tidyData <- dcast (meltData, subjectId + activity ~ variable, mean)

# write to csv
write.table(tidyData, paste(dir, "tidyData.txt", sep = "/"), row.names=FALSE)

# Clean up workspace
rm(x); rm(y); rm(subject); rm(activityLabels); rm(features); rm(dataSet); rm(meltData)                       
                       