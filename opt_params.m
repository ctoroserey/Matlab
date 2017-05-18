function [Parameters] = opt_params(Reward_vector,Handling_vector,Travel_vector)
%% Calculates the optimal behavior for a combination of reward, travel times, and handling times
% The output is a matrix whose columns correspond to each timing combination.


Rwd = Reward_vector;
Handle = Handling_vector;
Travel = Travel_vector + 2; % to account for 'next reward' notification
Parameters = zeros(length(Rwd),length(Handle));
lgnd = {}; % to assign any number of legends for plotting

    for i = 1:length(Handle)
        
        Parameters(:,i) = rwd_sec(Rwd,Travel(i),Handle(i));
        lgnd{i} = strcat('Handling time: ',num2str(Handle(i)),';','Travel time: ',' ',num2str(Travel(i)-2)); % note "Travel(i)-2, should I use the extended travel times?
  
    end

%Parameters = [zeros(1,3); Parameters];
plot(Parameters,'o-')
%axis([1,length(Rwd),0,(Parameters(end,end)+Parameters(end,1))]); 
axis([1,length(Rwd),0,(Parameters(1,1)+mean(Parameters(:,3)))]);
title({'Expected Reward Rate for Different Acceptance Thresholds','(opportunity rate)'},'FontSize',22);
xlabel('Reward Acceptance Threshold'); set(gca,'XTick', [1:1:length(Rwd)]); set(gca,'XTickLabels',Rwd); set(gca,'FontSize',22)
ylabel('Points per Second','FontSize',22); % should be changed depending on the context
legend(lgnd); set(gca,'FontSize',18)

end