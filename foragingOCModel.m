function [out] = foragingOCModel(Choice,OpportRate,Reward,Handling,Type)
%% Simple model that predicts the foraging behavior of my first task.
%
% Variables:
%
%   - Choice = 1 if delayed option is chosen, 0 if immediate option is
%               chosen. Others are no choices.
%
%   - OpportRate = the optimal per-second reward amount, as calculated
%                   using the rwd_sec() function (used to calculate the
%                   opportunity cost using handling time).
%
%   - Reward = reward given upon completion of trial.
%
%   - Handling = time until end of trial.
%
%   - Type = 0 if overall, 1 if per handling
%
% All inputs must be column vectors. 
%
% The function returns a structure "out" with the main parameters.

% Ideas for the future:
% 1) output the SV and prediction vectors within the out structure.

% 3/14/17 notes:
% - Added a scaling parameter akin to the KableLab script and Joe's
% suggestion (still need to plot). This fixed the probability dist (plot
% unique vals).
%- Limited the beta parameters based on the ground truth OC
%

%% sort some variables
out.percentNow = (sum(Choice == 0) / length(Choice)) * 100;
out.percentDelayed = (sum(Choice == 1) / length(Choice)) * 100;
miss = Choice ~= 0 & Choice ~= 1;
out.percentMissed = (sum(miss)/length(Choice)) * 100;
choice = Choice(~miss); % choice data for valid trials
OR = OpportRate(~miss); % opportunity rate for valid trials (not opportunity cost yet)
Rwd = Reward(~miss); % reward for valid trials
Handle = Handling(~miss); % handle time for valid trials
OC = OR.*Handle; % opportunity cost

if Type == 0
    mnOC = log(5/14 * 0.99);
    mxOC = log(25/2 * 1.01);
else
    mnOC = log(5/unique(Handling) * 0.99);
    mxOC = log(25/unique(Handling) * 1.01);
end


if (sum(choice) == length(choice)) || (sum(choice) == 0) % if choices are one-sided
    if sum(choice) == length(choice)
        out.beta=exp(mnOC);
    else
        out.beta=exp(mxOC);
    end
    out.scale = nan;   
    out.LL = 0;    

else
    [noise,ks] = meshgrid([-1, 1], linspace(mnOC,mxOC,3)); % search grid
    b = [noise(:) ks(:)];    
    %b = [-1, 1]; % noise to weight the choice estimation
    info.negLL = inf;
    for i = 1:length(b)
        % tried using fminsearch per Ilona's recommendation. Could work.
        % [new.b,new.negLL] = fminsearch(@negLL,b(i),optimset('Algorithm','interior-point','Display','off'),choice,IA,DA,D);
        [new.b,new.negLL] = fmincon(@negLL,b(i,:),[],[],[],[],[log(eps),mnOC],[-log(eps),mxOC],[],optimset('Algorithm','interior-point','Display','iter'),choice,Handle,Rwd);
        if new.negLL < info.negLL
            info = new;
        end
    end
    out.beta = exp(info.b(2));
    out.scale = exp(info.b(1));
    out.LL = -info.negLL;
    % add plotting options
end
out.LL0 = log(0.5)*length(choice);
out.r2 = 1 - out.LL/out.LL0;
out.SOC = out.beta.*Handle; % subjective opportunity cost (weighted)
out.prob = 1 ./ (1 + exp(-(out.scale.*(Rwd - out.SOC))));
out.predictedChoice = Rwd > out.SOC; % 1 if delayed option is greater
out.percentPredicted = sum(out.predictedChoice == choice) / length(choice) * 100;

if out.beta==exp(mnOC)
    out.prob = ones(1,length(choice));
elseif out.beta==exp(mxOC)
    out.prob = zeros(1,length(choice));
end    

end

%% sub-functions to calculate the probability of a decision and overall -log-likelihood

function negLL = negLL(beta,choice,Handle,Rwd)
p = probcalc(beta,Handle,Rwd);
negLL = -sum((choice==1).*log(p) + (choice==0).*log(1-p));
end

function p = probcalc(beta,Handle,Rwd)  
sOC = (exp(beta(2)).*Handle); % opportunity cost
reg = exp(beta(1)).*(Rwd - sOC); % get the logodds with weighted noise
p = 1 ./ (1 + exp(-reg)); % sigmoidal function
p(p == 1) = 1-eps;
p(p == 0) = eps;
end

