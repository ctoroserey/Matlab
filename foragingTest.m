function [out] = foragingTest(Choice,OpportRate,Reward,Handling,Type)
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
rwdTypes = unique(Reward);
rwdTypes = rwdTypes(1:3);
handleTypes = unique(Handling);
Handle = Handling(~miss); % handle time for valid trials
travel = 16 - Handle;
OC = OR.*Handle; % opportunity cost

if Type == 0
    handleTypes = handleTypes(1:3);
    mnOC = log(0.1);
    mxOC = log(10);
else
    mnOC = log(0.1);
    mxOC = log(10);
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
        [new.b,new.negLL] = fmincon(@negLL,b(i,:),[],[],[],[],[log(eps),mnOC],[-log(eps),mxOC],[],optimset('Algorithm','interior-point','Display','iter'),choice,Handle,Rwd,rwdTypes,handleTypes);
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
out.R = Rwd ./ (1 + out.beta.*Handle); % hyp-discounted reward
out.RR = (out.R ./ (1 + Handle)).*Handle; % reward rate for the current trial (Stephens, 1986)
out.OC = (sum(unique(out.R))./(1 + sum(handleTypes))).*Handle - travel; % OC per Stephens, minus prob rates 
reg = exp(out.scale.*(out.RR - out.OC)); % get the logodds with weighted noise
out.prob = 1 ./ (1 + exp(-reg)); % shouldn't the probability be p = (exp(-reg)) ./ (1 + exp(-reg))?
out.predictedChoice = out.R > out.OC; % 1 if delayed option is greater
out.percentPredicted = sum(out.predictedChoice == choice) / length(choice) * 100;

if out.beta==exp(mnOC)
    out.prob = ones(1,length(choice));
elseif out.beta==exp(mxOC)
    out.prob = zeros(1,length(choice));
end    

end

%% sub-functions to calculate the probability of a decision and overall -log-likelihood

function negLL = negLL(beta,choice,Handle,Rwd,rwdTypes,handleTypes)
p = probcalc(beta,Handle,Rwd,rwdTypes,handleTypes);
negLL = -sum((choice==1).*log(p) + (choice==0).*log(1-p));
end

function p = probcalc(beta,Handle,Rwd,rwdTypes,handleTypes) 
dummy = rwdTypes.*handleTypes;
travel = 16 - Handle;
R = Rwd ./ (1 + beta(2).*Handle); % hyp-discounted reward
RR = (R ./ (1 + Handle)).*Handle; % reward rate for the current trial
OC = (sum(unique(R))./(1 + sum(handleTypes))).*Handle - travel; % OC per Stephens, minus prob rates 
%sOC = (exp(beta(2)).*Handle); % weighted opportunity cost
reg = exp(beta(1)).*(RR - OC); % get the logodds with weighted noise
p = 1 ./ (1 + exp(-reg)); % shouldn't the probability be p = (exp(-reg)) ./ (1 + exp(-reg))?
p(p == 1) = 1-eps;
p(p == 0) = eps;
end



% notes:
% 
% - Add travel as cost

















