## Course 3 // Task 3
## Wi-Fi Fingerprinting
##Interior Location Tracking

install.packages("readr")
library(readr)
install.packages("lattice")
install.packages("ggplot2")
library(caret)

#load entire training data file
CompleteTrainingDF <- read.csv("trainingdata.csv")
#inspect
head(CompleteTrainingDF)
str(CompleteTrainingDF)
#change numeric attributes into factor
CompleteTrainingDF$FLOOR <- as.factor(CompleteTrainingDF$FLOOR)
CompleteTrainingDF$BUILDINGID <- as.factor(CompleteTrainingDF$BUILDINGID)
CompleteTrainingDF$SPACEID <- as.factor(CompleteTrainingDF$SPACEID)
CompleteTrainingDF$RELATIVEPOSITION <- as.factor(CompleteTrainingDF$RELATIVEPOSITION)
CompleteTrainingDF$USERID <- as.factor(CompleteTrainingDF$USERID)
CompleteTrainingDF$PHONEID <- as.factor(CompleteTrainingDF$PHONEID)

##Pre-Processing
#isolate building 0 for analysis 
building0train <- read.csv("building0train.csv")
View(building0train)
str(building0train)
building0train$FLOOR <- as.factor(building0train$FLOOR)
building0train$BUILDINGID <- as.factor(building0train$BUILDINGID)
building0train$SPACEID <- as.factor(building0train$SPACEID)
building0train$RELATIVEPOSITION <- as.factor(building0train$RELATIVEPOSITION)
building0train$USERID <- as.factor(building0train$USERID)
building0train$PHONEID <- as.factor(building0train$PHONEID)

filteredbuilding0 <- read.csv("filterbuilding0new.csv")

#createDataPartition for building 0 DF
inTraining0 <- createDataPartition(filteredbuilding0$FL_SPACE_POS, p = 0.7, list = FALSE)
training0 <- filteredbuilding0[inTraining0,]
testing0 <- filteredbuilding0[-inTraining0,]


###identify and remove near zero variances
##Use this one, works
building0traindf <- data.frame(building0train)
nzv <- nearZeroVar(building0traindf, saveMetrics = TRUE)
filteredbuilding0 <- building0traindf[,!(nzv$zeroVar)]

write.csv(filteredbuilding0, "filterbuilding0new.csv")

#10 fold cross validation
fitControl <- trainControl(method = "repeatedcv", number = 10)

#open cores of parallel processing to run fatser algorithms
install.packages("foreach")
install.packages("iterators")
install.packages("parallel")
library(doParallel)
#find how many cores on machine
  detectCores()
  #create cluster with desired number of cores
  cl <- makeCluster(2)
  #register cluster
  registerDoParallel(cl)
  #find out how many cores are being used
  getDoParWorkers()
#STOP CLUSTER
stopCluster(cl)

#train model KNN
set.seed(2727)
knnfit1building0 <- train(FL_SPACE_POS ~ ., 
                          data = training0,
                          method = "knn",
                          #preProcess = c("center", "scale"),
                          trControl = fitControl
                          #tuneLength = 1
                          )
knnfit1building0
varImp(knnfit1building0)
#predict
predictraining0 <- training0
predictknnfit1 <- predict(knnfit1building0, predictraining0)
predictknnfit1
summary(predictknnfit1)

#confusion matrix
cmclassknnfit1 <- predict(knnfit1building0, newdata = testing0)
corchartknnfit1 <- confusionMatrix(cmclassknnfit1, testing0$FL_SPACE_POS)
corchartknnfit1
#add in predictions to compare
trainingwithPredKNN <- training0
trainingwithPredKNN$predictions <- predictknnfit1
View(trainingwithPredKNN)
write.csv(trainingwithPredKNN, file = "FINALbuilding0KNNpredictions.csv", row.names = TRUE)
postResample(pred = predictknnfit1, obs = training0$FL_SPACE_POS)


#notes
train()
predict()
postResample()
confusionMatrix(knnfit1building0, positive = NULL, dnn = c("Predicition", "Reference"))


#train model Random Forest
set.seed(2727)
rfGrid <- expand.grid(mtry = 202)
system.time(rffit1 <- train(FL_SPACE_POS~., data = training0, method = "rf", trControl = fitControl,
                                    tunegrid = rfGrid
                                    #, preProc = c("center", "scale")
                                    ))
rffit1

#predict
predicttraining0rf <- training0
predictrffit1 <- predict(rffit1, predicttraining0rf)
predictrffit1
summary(predictrffit1)
#confusion matrix
cmclassrffit1 <- predict(rffit1, newdata = testing0)
corchartrffit1 <- confusionMatrix(cmclassrffit1, testing0$FL_SPACE_POS)
corchartrffit1
#add in predictions to compare
trainingwithPredrf <- training0
trainingwithPredrf$predictions <- predictrffit1
View(trainingwithPredrf)
write.csv(trainingwithPredrf, file = "testRFpredictions4.csv", row.names = TRUE)
postResample(pred = predictrffit1, obs = training0$FL_SPACE_POS)

#train C50
install.packages("C50")
install.packages("inum")
library(C50)

#### winnow adjustment and new c50 model ####
c50grid <- expand.grid(.winnow = c(TRUE, FALSE))
c50grid 
set.seed(2727)
c50fit1 <- train(FL_SPACE_POS~., data = training0, method = "C5.0", 
                 trControl = fitControl, 
                 tunegrid = c50grid
                 #tuneLength = 1
                 #preProc = c("center", "scale")
                 )
c50fit1

#Confusion matrix
predicttraining0 <- training0
predictc50fit1 <- predict(c50fit1, predicttraining0)
predictc50fit1
summary(predictc50fit1) 
#confusion matrix
cmclassc50fit1 <- predict(c50fit1, newdata = testing0)
corchartc50fit1 <- confusionMatrix(cmclassc50fit1, testing0$FL_SPACE_POS)
corchartc50fit1
#add predictions to document 
trainingwithPredc50 <- training0
trainingwithPredc50$predictions <- predictc50fit1
View(trainingwithPredc50)
write.csv(trainingwithPredc50, file = "FINALbuilding0C50predictions.csv", row.names = TRUE)
postResample(pred = trainingwithPredc50, obs = training0$FL_SPACE_POS)

#Create Resample chart
ModelData <- resamples(list(KNN = knnfit1building0, RF = rffit1, C50 = c50fit1))
ModelData
summary(ModelData)

##bagging
library(ipred)
set.seed(2727)
mybag <- bagging(BLDG_FL_SPACE_POS ~ ., data = training0, nbagg = 25)



train()
predict()
postResample()
