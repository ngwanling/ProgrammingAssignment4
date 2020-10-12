currdir <- "./data"
if(!dir.exists("./data")) dir.create("./data")
setwd(currdir)

downloadurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipfile <- "UCI HAR Dataset.zip"
download.file(downloadurl, zipfile)

if(file.exists(zipfile)) unzip(zipfile)

basedir <- "UCI HAR Dataset"
featuresfile <- paste(basedir, "features.txt", sep="/")
activitylabelsfile <- paste(basedir, "activity_labels.txt", sep="/")
testvariablesfile <- paste(basedir, "test/X_test.txt", sep="/")
testactivityfile <- paste(basedir, "test/y_test.txt", sep="/")
testsubjectfile <- paste(basedir, "test/subject_test.txt", sep="/")
trainvariablesfile <- paste(basedir, "train/X_train.txt", sep="/")
trainactivityfile <- paste(basedir, "train/y_train.txt", sep="/")
trainsubjectfile <- paste(basedir, "train/subject_train.txt", sep="/")

neededfiles <- c(featuresfile,
                 activitylabelsfile,
                 testvariablesfile,
                 testactivityfile,
                 testsubjectfile,
                 trainvariablesfile,
                 trainactivityfile,
                 trainsubjectfile
)
sapply(neededfiles, function(f) if(!file.exists(f)) stop(paste("Needed file ", f, " doesn't exist. Exitting ...", sep="")))
features <- read.table(featuresfile, col.names=c("rownumber","variablename"))
install.packages("tidyverse")
library(tidyverse)
allvariables <- mutate(features, variablename = gsub("BodyBody", "Body", variablename))
neededvariables <- filter(allvariables, grepl("mean\\(\\)|std\\(\\)", variablename))
allvariables <- mutate(allvariables, variablename = gsub("-", "", variablename),variablename = gsub("\\(", "", variablename), variablename = gsub("\\)", "", variablename), variablename = tolower(variablename))
neededvariables <- mutate(neededvariables, variablename = gsub("-", "", variablename),variablename = gsub("\\(", "", variablename),variablename = gsub("\\)", "", variablename), variablename = tolower(variablename))
activitylabels <- read.table(activitylabelsfile, col.names=c("activity", "activitydescription"))
testvalues <- read.table(testvariablesfile, col.names = allvariables$variablename)
testneededvalues <- testvalues[ , neededvariables$variablename]
testactivities <- read.table(testactivityfile, col.names=c("activity"))
testsubjects <- read.table(testsubjectfile, col.names=c("subject"))
testactivitieswithdescr <- merge(testactivities, activitylabels)
testdata <- cbind(testactivitieswithdescr, testsubjects, testneededvalues)
trainvalues <- read.table(trainvariablesfile, col.names = allvariables$variablename)
trainneededvalues <- trainvalues[ , neededvariables$variablename]
trainactivities <- read.table(trainactivityfile, col.names=c("activity"))
trainsubjects <- read.table(trainsubjectfile, col.names=c("subject"))
trainactivitieswithdescr <- merge(trainactivities, activitylabels)
traindata <- cbind(trainactivitieswithdescr, trainsubjects, trainneededvalues)
alldata <- rbind(testdata, traindata) %>% select( -activity )
alldata <- mutate(alldata, subject = as.factor(alldata$subject))
write.table(alldata, "Mean_And_StdDev_For_Activity_Subject.txt")
allgroupeddata <- group_by(alldata,activitydescription,subject)
summariseddata <- summarise_each(allgroupeddata, funs(mean))
write.table(summariseddata, "Average_Variable_By_Activity_Subject.txt", row.names = FALSE)
