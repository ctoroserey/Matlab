function [plotSummary] = plotForage(SubjMatrix,Condition,SubjID)
%% plots an individuals acceptance behavior
% Assumes that the matrix columns' are organized as:
% Delay, Reward, Choice, RT, Total Time, Opportunity Rate, Opportunity Cost
% If the matrix was generated using the 'subsetup' function, it should be
% good to go.
% Plots will be displayed per reward amount with 'x = delay' 
%
% plotSummary matrix:
% 
%         | 2s | 10s | 14s |
%    5pts |    |     |     |
%   10pts |    |     |     |
%   25pts |    |     |     |
%   

x = SubjMatrix;
rwds = unique(x(:,2)); % get the reward amounts
rwds = rwds(1:3);
handling = unique(x(:,1)); % get the handling times
handling = handling(1:3);
plotSummary = [];
for i = 1:length(rwds)
    for j = 1:length(handling)
        index = find((x(:,2)==rwds(i)) & (x(:,1)==handling(j))); % finds the trials with each reward type
        plotSummary(i,j) = sum(x(index,3)==1)./(length(index) - sum(x(index,3)==2));
    end 
end

ID = [SubjID(1:4) SubjID(6:8)];
if Condition == 'wait'
  participantName = {'Proportion completed for each handling time for each reward amount','Condition: wait',ID};
else 
  participantName = {'Proportion completed for each handling time for each reward amount','Condition: cognitive',ID};
end 

plot(plotSummary);
axis([1,length(rwds),0,1.25]); 
title(participantName);
xlabel('Reward amount'); set(gca,'XTick', [1:1:length(rwds)]); set(gca,'XTickLabels',rwds);
ylabel('Proportion completed');
legend('Handling = 2s; Travel = 14s', ...
'Handling = 10s; Travel = 6s',...
'Handling = 14s; Travel = 2s')

end