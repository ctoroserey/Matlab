function [Results] = forageresults(SubjMatrix,ModelPrediction)
%% Generata a matrix with the important results to check behavior
% Order: 
% - Handling 
% - Reward
% - Opportunity Cost
% - Modeled Prediction
% - Basic Prediction (Rwd>OC)
% - Actual Choice

Results = [SubjMatrix(:,1:2) SubjMatrix(:,7) ModelPrediction (SubjMatrix(:,2)>SubjMatrix(:,7)) SubjMatrix(:,3)];
%Results = sortrows(Results, [1 2]);

end