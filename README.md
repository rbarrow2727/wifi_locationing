# wifi_locationing
Predicting Interior Location Tracking using Wifi Fingerprinting

Project Goals:
Determine user location by their smartphones wireless access points and their signal strength

Data Description:
Data collected at UJI Campus includes:
 - 3 buildings
 - 108,703 square meters
 - 4 or 5 floors depending on building
 - 21,049 individual location sample points
 - 520 WAPs (wireless access points)
 - Collected by more than 20 different users

Data Management:
 - A unique location identifier will be created for each observation
 - Objective is to compare algorithms and positioning systems to observe accuracy between the actual user 
   location and the predictive model’s results
 - Individual buildings will be evaluated in models, specifically Building 0 for this analysis

Complications and Resolutions:
 - For computational efficiency, individual building data subsets were created
 - Observed accuracy when training models with samples from multiple building’s data performed poorly, for this 
   reason the analysis focuses on one specific building
 - Zero Variance Predictors: some specific WAP attributes removed from analysis.  Zero variance predictors 
   are uninformative and can negatively affect model performance.
 - Roughly 300 WAP attributes removed due to zero variance and to improve model performance

Model Accuracy:

Algorithm           Accuracy            Kappa
knn                   0.53705             0.53507
Random Forest         0.7432              0.7421
C5.0                  0.6969              0.6956

Recommendation – Random Forest (best algrithm for wifi locationing):
By all accounts, Random Forest had the best performance of the three algorithms tested.   
The mtry value of the Random Forest model was 102. 
Accuracy in Random Forest confusion Matrix 0.7627
Error rate for predicting unique location identifier was 6.7%
I believe the reason Random Forest performed well and why I am recommending it is the amount of variables in the data set.  
Simply put, the other algorithms are not as good and handling the mass amount of variables (WAPs values) as the Random Forest 
model.  The mtry value (a tuning parameter) that yielded the best results was 102.  That means that there were 102 variables 
available for splitting at each tree node.  Mtry can have a strong influence on predictor variable importance and ultimately 
was a key factor in why this algorithm was chosen.  

Unique Identifier (FL_SPACE_POS) Error Rate
total obs         3728
# of errors       250
Error Rate %      6.706%

Project Recommendations:
1) WAP locations:  Prior to this study evaluation I think another case study on optimizing the locations of the WAP could be beneficial.  
Targeting locations for the WAPs that would improve signal strength and accuracy would increase efficiency and savings for installation. 
2) Evaluate the areas (floors, space) where the most errors occurred.  Why? Are there commonalities in these occurrences?  
3) Other factors such as wall composition, structure interference and user height can all be examined to optimize locationing efforts.
4) Use of accelerometers to detect motion to determine if user is moving or stagnant can improve data structure and yield more accurate 
results 
