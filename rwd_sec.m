function ERT = rwd_sec(Reward, Travel, Handling)
%% Function used to calculate the optimal trial acceptance behavior.
% It returns the expected reward per second, given a reward array, travel
% time, and handling time (originally made for foraging experiments).

    trvl = Travel;
    hndlng = Handling;
    rwdlen = length(Reward);
    ET = []; % accruing expected time
    ER = []; % accruing expected reward
    for i = 1:rwdlen
        temprwd = Reward(i:end); % temporary array for delimiting threshold
        trvlength = rwdlen - length(temprwd); % number of rejections expressed in travel times
        ER(i) = (sum(temprwd)./rwdlen); 
        ET(i) = (((length(temprwd))./rwdlen).*(trvl + hndlng)) + (trvlength.*trvl./rwdlen);
    end 
    
    ERT = ER./ET; % final division: reward per second
    
    %% optional plotting options, usually obviated because op_params does it
    
    %ERT = ERT.*60; % change to minutes
    %ERT = ERT.*10 % Max for experiment session of 10 mins
    % plotting
    %plot(ERT,'ko--')
    %hold on
    %axis([1,rwdlen,0,(max(ERT)+min(ERT))]); %max(ERT)]);
    %title('Expected Reward Rate for Different Acceptance Thresholds (oportunity rate)');
    %xlabel('Reward Acceptance Threshold'); set(gca,'XTick', [1:1:rwdlen]); set(gca,'XTickLabels',Reward);
    %ylabel('Dollars per Second');
    %legend(strcat('Travel time:',' ',num2str(trvl),', Handling time:',' ',num2str(hndlng)));
    
    % legend('Handling = 2s; Travel = 14s', ...
    % 'Handling = 6s; Travel = 10s',...
    % 'Handling = 10s; Travel = 6s',...
    % 'Handling = 14s; Travel = 2s')
end