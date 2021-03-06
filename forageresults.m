function [Results] = forageresults(SubjMatrix,ModelPrediction,ModelSOC)
%% Generata a matrix with the important results to check behavior
% Order: 
% - Handling 
% - Reward
% - Opportunity Cost
% - ModelSOC
% - Modeled Prediction
% - Basic Prediction (Rwd>OC)
% - Actual Choice

index = find(isnan(SubjMatrix));
SubjMatrix = SubjMatrix(1:index(1)-1,:);
index = find(SubjMatrix(:,3)==2);
SubjMatrix(index,:)=[];

Results = [SubjMatrix(:,1:2) SubjMatrix(:,7) ModelSOC ModelPrediction (SubjMatrix(:,2)>SubjMatrix(:,7)) SubjMatrix(:,3)];
%Results = sortrows(Results, [1 2]);

end