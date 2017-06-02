%% temp
x1 = ~isnan(wMatrix(:,1,1));
x2 = ~isnan(wMatrix(:,2,1));
y = ~isnan(wMatrix(:,3,1)); % no need because mnrfit doesn't consider NaN
y = wMatrix(y,3,1);
x1 = wMatrix(x1,1,1); % handling
x2 = wMatrix(x2,2,1); % rewards
all = [y x1 x2];
all = sortrows(all,[2 3]);
x = [all(:,2) all(:,3)];
y = all(:,1);

% for dummyvar setup
catx1 = categorical(x(:,1));
catx1 = dummyvar(catx1);
catx2 = categorical(x(:,2));
catx2 = dummyvar(catx2);
catx = [catx1(:,1:2) catx2(:,1:2)];

% logistic model
[~,devNull] = mnrfit([],2-y);
[~,dev,stats] = mnrfit(x,2-y);
% linear function for 2 features + intercept
g = @(h,r) stats.beta(1) + stats.beta(2).*h + stats.beta(3).*r; 
% probability of accepting a trial
1./(1 + exp(-(g(10,10)))); % probability for the combo
% check with matlab function dedicated to it: first number is the prob of accepting
mnrval(stats.beta,[10 10]); 


%% testing side, incorporating nominal predictors
% x = [x x1.*x2]; % TEST: add an interaction term (NOPE)
% [~,devInt,statsInt] = mnrfit(x,2-y);
% 1./(1 + exp(-(g(10,10))))

% simple
[~,devNom,statsNom] = mnrfit(catx,2-y);
mnrval(statsNom.beta,[0 0 0 0]) 
% % interaction (NOT CONVERGING)
% designMatrix = [catx (catx(:,1).*catx(:,3)) (catx(:,1).*catx(:,4)) ...
%     (catx(:,2).*catx(:,3)) (catx(:,2).*catx(:,4))];
% [~,devInt,statsInt] = mnrfit(designMatrix,2-y);
% 1./(1 + exp(-(statsNom.beta(1) + statsNom.beta(2).*1 + statsNom.beta(3).*0)))


