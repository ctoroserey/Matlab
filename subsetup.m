function [submatrix] = subsetup(Matrix)
%% Update a subject's matrix to get the optimal rate and optimal reward rate
% parameters for the modified ITC fmin script.
% The script assumes that each subject's matrix will be ordered as follows:
% handling, reward, choice, RT, overall time
% The result is an updated subject matrix with opportunity rate and cost
% arrays.
%
% 02/20/17 - Claudio
% Handling and travel times were slightly changed so they can be divided by
% two when prepping the psychopy parameters. The trials now add to 16s.
% The current optimal rate outs are:
%
%       two: [0.0094 0.0087 0.0057] (H=2;T=14)
%       six: [0.0094 0.0095 0.0069] (H=6;T=10)
%       ten: [0.0094 0.0105 0.0089] (H=10;T=6)
%  fourteen: [0.0094 0.0118 0.0125] (H=14;T=2)
%
% This yielded a surprisingly more defined strategy than the previous
% setup (fortunately).

% remove NaN rows. Used so discounting estimator doesn't count it as miss
%if ~isempty(isnan(Matrix))

if isnan(Matrix(end,:))
    extras = find(isnan(Matrix))'; % get indexes for extras
    Matrix = Matrix(1:extras(1)-1,:); 
end

delay = Matrix(1:end,1);

% optimal reward rates for different thresholds, number in name = handling time
% calculated here so they can be modified if needed (rwd_sec func needs to
% be in path)

% update in the future: do something like unique(Matrix(:,2)) to automate
% the creation of the reward array below.
rewardArray = unique(Matrix(:,2));
rateTwo = rwd_sec([0.05,0.15,0.25],14,2);
rateSix = rwd_sec([0.05,0.15,0.25],10,6);
rateTen = rwd_sec([0.05,0.15,0.25],6,10);
rateFourt = rwd_sec([0.05,0.15,0.25],2,14);

% optimal rate
optRate = delay;
optRate(optRate==2)= max(rateTwo);
optRate(optRate==6)= max(rateSix);
optRate(optRate==10)= max(rateTen);
optRate(optRate==14)= max(rateFourt);

% opportunity cost
opportCost = delay.*optRate;


% this will add columns for optrate and optcost to the original matrix
submatrix = [Matrix, optRate, opportCost];

end
