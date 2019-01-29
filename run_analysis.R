setwd("D:/JHU/Data cleaning/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset")

rm(list = ls())
features <- read.table("./features.txt",stringsAsFactors = F)


# Combining Training Datasets
X_train <- data.table::fread("./train/X_train.txt")
y_train <- data.table::fread("./train/y_train.txt")
subject_train <- data.table::fread("./train/subject_train.txt")

names(subject_train) <- 'Subjects'
names(y_train) <- 'Labels'
names(X_train) <- features$V2

training_set <- cbind(subject_train,y_train,X_train)



# Combining Testing Datasets
X_test <- data.table::fread("./test/X_test.txt")
y_test <- data.table::fread("./test/y_test.txt")
subject_test <- data.table::fread("./test/subject_test.txt")

names(subject_test) <- 'Subjects'
names(y_test) <- 'Labels'
names(X_test) <- features$V2

testing_set <- cbind(subject_test,y_test,X_test)


# Creating the final Dataset

Final_DataSet <- rbind(training_set,testing_set)


# ==================================================================================================
# ==================================================================================================
require(dplyr)

reqColumns <- c(1,2,grep('mean|std',names(Final_DataSet),ignore.case = TRUE))

Final_DataSet <- as.data.frame(Final_DataSet)
MasterDataset <- Final_DataSet[,reqColumns]

# ==================================================================================================
activity_labels <- read.table("./activity_labels.txt")

MasterDataset <- activity_labels %>% 
    right_join(MasterDataset, by = c('V1' = 'Labels')) %>% 
    select(-V1) %>% 
    rename('Activity' = 'V2')

MasterDataset$Activity <- as.character(MasterDataset$Activity)
MasterDataset <- as.data.frame(MasterDataset)


# ==================================================================================================
namescol = names(MasterDataset)
namescol = gsub("mean","Mean",namescol, fixed = TRUE)
namescol = gsub("std","Std",namescol, fixed = TRUE)
namescol = gsub("-","",namescol, fixed = TRUE)
namescol = gsub("\\(\\)","",namescol)

names(MasterDataset) <- namescol


# ==================================================================================================

AvgMasterDataset = MasterDataset %>% group_by(Activity,Subjects) %>% summarise_all(mean)
avgnamescol = namescol
avgnamescol[3:88] = paste0("Avg_",namescol[3:88])
names(AvgMasterDataset) = avgnamescol

AvgMasterDataset <- as.data.frame(AvgMasterDataset)


write.table(MasterDataset,"FinalADS.txt",row.names = F)
write.table(AvgMasterDataset,"AvgSummarised.txt",row.names = F)

