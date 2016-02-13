#Have downloaded dataset and saved it to work directory

###Load required packages
library(dplyr)
library(data.table)
library(tidyr)

Path <- "D:/work/R/g_c_data/project/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset"

# Read subject files
train_sub <- tbl_df(read.table(file.path(Path, "train", "subject_train.txt")))
test_sub  <- tbl_df(read.table(file.path(Path, "test" , "subject_test.txt" )))

# Read activity files
train_act <- tbl_df(read.table(file.path(Path, "train", "Y_train.txt")))
test_act  <- tbl_df(read.table(file.path(Path, "test" , "Y_test.txt" )))

#Read data files.
Train <- tbl_df(read.table(file.path(Path, "train", "X_train.txt" )))
Test  <- tbl_df(read.table(file.path(Path, "test" , "X_test.txt" )))

# merge the Activity and Subject files by row binding function
# rename variables "subject" and "activity"
combined_sub <- rbind(train_sub, test_sub)
setnames(combined_sub, "V1", "subject")
combined_act<- rbind(train_act, test_act)
setnames(combined_act, "V1", "activity")

#combine the training and test files
combined_data <- rbind(Train, Test)

# name variables according to features.txt
Features <- tbl_df(read.table(file.path(Path, "features.txt")))
setnames(Features, names(Features), c("feature_#", "feature_Name"))
colnames(combined_data) <- Features$feature_Name

#column names for activity labels
act_Labels<- tbl_df(read.table(file.path(Path, "activity_labels.txt")))
setnames(act_Labels, names(act_Labels), c("activity","activity_Name"))

# Merge columns
all_in_one<- cbind(combined_sub, combined_act)
combined_data <- cbind(all_in_one, combined_data)

# Reading "features.txt" and extracting only the mean and standard deviation
Mean_Std <- grep("mean\\(\\)|std\\(\\)",Features$feature_Name,value=TRUE)

# extracting measurements for the mean and standard deviation 
# add "subject","activity"

Mean_Std <- union(c("subject","activity"), Mean_Std)
combined_data<- subset(combined_data,select=Mean_Std) 

##enter activity name into combined_data
combined_data <- merge(act_Labels, combined_data , by="activity", all.x=TRUE)
combined_data$activity_Name <- as.character(combined_data$activity_Name)

## create combined_data with variable means
combined_data$activity_Name <- as.character(combined_data$activity_Name)
Aggreg<- aggregate(. ~ subject - activity_Name, data = combined_data, mean) 
combined_data<- tbl_df(arrange(Aggreg,subject,activity_Name))

#the previous name
head(str(combined_data),2)

names(combined_data)<-gsub("std()", "SD", names(combined_data))
names(combined_data)<-gsub("mean()", "MEAN", names(combined_data))
names(combined_data)<-gsub("^t", "time", names(combined_data))
names(combined_data)<-gsub("^f", "frequency", names(combined_data))
names(combined_data)<-gsub("Acc", "Accelerometer", names(combined_data))
names(combined_data)<-gsub("Gyro", "Gyroscope", names(combined_data))
names(combined_data)<-gsub("Mag", "Magnitude", names(combined_data))
names(combined_data)<-gsub("BodyBody", "Body", names(combined_data))

# modified name
head(str(combined_data),6)

##write files

write.csv(combined_data, "TidyData.csv")
write.table(combined_data, "TidyData.txt", row.name=FALSE)