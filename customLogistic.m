function [summaryCon, summaryNom, nullDev] = customLogistic(subjectMatrix)

indx = subjectMatrix(:,3)~=2; % filter out the 2s from the cognitive group decision column
subj = subjectMatrix(indx,:);
notNan = ~isnan(subj(:,1)); % no need because mnrfit doesn't consider NaN
subj = subj(notNan,:);
y = subj(:,3);
x1 = subj(:,1); % handling
x2 = subj(:,2); % rewards
all = [y x1 x2];
all = sortrows(all,[2 3]);
x = [all(:,2) all(:,3)];
y = all(:,1);
xInt = [x x1.*x2]; % TEST: add an interaction term (meh)

% % "mean centering" (not really)
% x(:,1) = x(:,1) - 10;
% x(:,2) = x(:,2) - 10;

% for dummyvar setup
catx1 = categorical(x(:,1));
catx1 = dummyvar(catx1);
catx2 = categorical(x(:,2));
catx2 = dummyvar(catx2);
catx = [catx1(:,1:2) catx2(:,1:2)];

% logistic model
[~,nullDev] = mnrfit([],2-y);
% continuous
[~,devH,statsH] = mnrfit(x(:,1),2-y);
[~,devR,statsR] = mnrfit(x(:,2),2-y);
[~,dev,stats] = mnrfit(x,2-y);
[~,devInt,statsInt] = mnrfit(xInt,2-y);
% discrete
[~,devHNom,statsHNom] = mnrfit(catx1(:,1:2),2-y);
[~,devRNom,statsRNom] = mnrfit(catx2(:,1:2),2-y);
[~,devNom,statsNom] = mnrfit(catx,2-y);

% linear function for 2 features + intercept
g = @(h,r) stats.beta(1) + stats.beta(2).*h + stats.beta(3).*r; 
g2 = @(h1,h2,r1,r2) stats.beta(1) + statsNom.beta(2).*h1 + statsNom.beta(3).*h2 + statsNom.beta(4).*r1 + statsNom.beta(5).*r2; 
g3 = @(h,r,i) statsInt.beta(1) + statsInt.beta(2).*h + statsInt.beta(3).*r + statsInt.beta(4).*i;

% probability of accepting a trial based on continuous (does pretty well)
probH = 1./(1 + exp(-(statsH.beta(1) + statsH.beta(2).*14)));
probR = 1./(1 + exp(-(statsR.beta(1) + statsR.beta(2).*25)));
probBoth = 1./(1 + exp(-(g(14,25)))); % probability for the combo 
probInt = 1./(1 + exp(-(g3(1,1,1)))); % probability for the interaction

% probability of accepting a trial based on continuous (does pretty well)
probNH = 1./(1 + exp(-(statsHNom.beta(1) + statsHNom.beta(3).*0)));
probNR = 1./(1 + exp(-(statsRNom.beta(1) + statsRNom.beta(3).*0)));
probNBoth = 1./(1 + exp(-(g2(0,0,0,0)))); % probability for the combo

% check with matlab function dedicated to it: first number is the prob of accepting
%mnrval(stats.beta,[10 10]) 

% tables
con = {'Handling','Reward','bothH','bothR','InteractionH','InteractionR','Interaction'}'; % labels for continuous
nom = {'H2','H10','R5','R10','bothH2','bothH10','bothR5','bothR10'}'; % labels for nominal

summaryCon = table(con,[statsH.beta(2),statsR.beta(2),stats.beta(2),stats.beta(3),statsInt.beta(2),statsInt.beta(3),statsInt.beta(4)]',...
    [statsH.p(2),statsR.p(2),stats.p(2),stats.p(3),statsInt.p(2),statsInt.p(3),statsInt.p(4)]',...
    [devH,devR,dev,0,devInt,0,0]',...
    'VariableNames',{'Condition','Betas','Pvals','Model_deviance'});

summaryNom = table(nom,[statsHNom.beta(2),statsHNom.beta(3),statsRNom.beta(2),statsRNom.beta(3),statsNom.beta(2),statsNom.beta(3),statsNom.beta(4),statsNom.beta(5)]',...
    [statsHNom.p(2),statsHNom.p(3),statsRNom.p(2),statsRNom.p(3),statsNom.p(2),statsNom.p(3),statsNom.p(4),statsNom.p(5)]',...
    [devHNom,0,devRNom,0,devNom,0,0,0]',...
    'VariableNames',{'Condition','Betas','Pvals','Model_deviance'});


clear subj notNan x1 x2 x y catx1 catx2 xInt g g2 g3 con nom index

%% testing side, incorporating nominal predictors


% % interaction (NOT CONVERGING)
% designMatrix = [catx (catx(:,1).*catx(:,3)) (catx(:,1).*catx(:,4)) ...
%     (catx(:,2).*catx(:,3)) (catx(:,2).*catx(:,4))];
% [~,devInt,statsInt] = mnrfit(designMatrix,2-y);
% 1./(1 + exp(-(statsNom.beta(1) + statsNom.beta(2).*1 + statsNom.beta(3).*0)))


end