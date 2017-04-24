function [Parameters] = opt_params(Reward_vector,Handling_vector,Travel_vector)
%% Calculates the optimal behavior for a combination of reward, travel times, and handling times
% The output is a matrix whose columns correspond to each timing combination.
% It currently estimates the optimal rate at dollars per second.

Rwd = Reward_vector;
Handle = Handling_vector;
Travel = Travel_vector + 2; % to account for 'next reward' notification
Parameters = zeros(length(Rwd),length(Handle));
lgnd = {}; % to assign any number of legends for plotting

    for i = 1:length(Handle)
        
        Parameters(:,i) = rwd_sec(Rwd,Travel(i),Handle(i));
        lgnd{i} = strcat('Handling time: ',num2str(Handle(i)),';','Travel time: ',' ',num2str(Travel(i)-2)); % note "Travel(i)-2, should I use the extended travel times?
  
    end

plot(Parameters,'o-')
%axis([1,length(Rwd),0,(Parameters(end,end)+Parameters(end,1))]); 
axis([1,length(Rwd),0,(Parameters(1,1)+mean(Parameters(:,3)))]);
title('Expected Reward Rate for Different Acceptance Thresholds (oportunity rate)');
xlabel('Reward Acceptance Threshold'); set(gca,'XTick', [1:1:length(Rwd)]); set(gca,'XTickLabels',Rwd);
ylabel('Dollars per Second'); % should be changed depending on the context
legend(lgnd)

end