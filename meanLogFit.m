
%% Note! This version removes outliers at lines 25:27 and 45:47. This produces notably better estimates.
% However, since outliers were not removed for other analyses (per Joe's
% suggestion, given this is a pilot), I don't think it's a good idea to
% remove them at this step.

matrix = cLogMatrix; % wLogMatrix stores the log regression data for w and c
%rwds = [0 5 15];
rwds = [-5:0.1:20];
MeanProbMatrixW = []; % column order: 2s, 10s, 14s
MeanProbMatrixC = [];

% calculate the probabilities for each handling time per subject
% remember that the intercepts are interpretable since the predictors were
% centered at the lowest values (i.e. handling = 2s). That's why the
% handling coefficients are multiplied by the handling times - 2s.
for i = 1:11
    logBetas.cogIntrcpt(i,1) = matrix(3,1,i);
    logBetas.cogRwds(i,1) = matrix(4,2,i);
    logBetas.cogHndl(i,1) = matrix(3,2,i);
    logBetas.allCogHnl(i,1) = matrix(3,2,i);
    logBetas.allCogRwd(i,1) = matrix(4,2,i);
end

logBetas.cogIntrcpt = logBetas.cogIntrcpt(~isnan(logBetas.cogIntrcpt));
logBetas.cogRwds = logBetas.cogRwds(~isnan(logBetas.cogRwds));
logBetas.cogHndl = logBetas.cogHndl(~isnan(logBetas.cogHndl));

meanBeta.cogIntrcpt = mean(logBetas.cogIntrcpt(2:end));
meanBeta.cogRwds = mean(logBetas.cogRwds(2:end));
meanBeta.cogHndl = mean(logBetas.cogHndl(2:end));

MeanProbMatrixC(:,1) = 1./(1+exp(-(meanBeta.cogIntrcpt + meanBeta.cogRwds.*rwds))); % 2s
MeanProbMatrixC(:,2) = 1./(1+exp(-(meanBeta.cogIntrcpt + meanBeta.cogRwds.*rwds + meanBeta.cogHndl.*8)));
MeanProbMatrixC(:,3) = 1./(1+exp(-(meanBeta.cogIntrcpt + meanBeta.cogRwds.*rwds + meanBeta.cogHndl.*12)));

matrix = wLogMatrix;

for i = 1:11
    logBetas.waitIntrcpt(i,1) = matrix(3,1,i);
    logBetas.waitRwds(i,1) = matrix(4,2,i);
    logBetas.waitHndl(i,1) = matrix(3,2,i);
end

logBetas.waitIntrcpt = logBetas.waitIntrcpt(~isnan(logBetas.waitIntrcpt));
logBetas.waitRwds = logBetas.waitRwds(~isnan(logBetas.waitRwds));
logBetas.waitHndl = logBetas.waitHndl(~isnan(logBetas.waitHndl));

meanBeta.waitIntrcpt = mean(logBetas.waitIntrcpt(logBetas.waitIntrcpt<60));
meanBeta.waitRwds = mean(logBetas.waitRwds(logBetas.waitIntrcpt<60));
meanBeta.waitHndl = mean(logBetas.waitHndl(logBetas.waitIntrcpt<60));

MeanProbMatrixW(:,1) = 1./(1+exp(-(meanBeta.waitIntrcpt + meanBeta.waitRwds.*rwds)));
MeanProbMatrixW(:,2) = 1./(1+exp(-(meanBeta.waitIntrcpt + meanBeta.waitRwds.*rwds + meanBeta.waitHndl.*8)));
MeanProbMatrixW(:,3) = 1./(1+exp(-(meanBeta.waitIntrcpt + meanBeta.waitRwds.*rwds + meanBeta.waitHndl.*12)));


figure
hold on
plot(MeanProbMatrixC(:,1),'r')
plot(MeanProbMatrixC(:,2),'g')
plot(MeanProbMatrixC(:,3),'b')
ylabel('Probability of completing a trial')
ylim([0 1.1]);
xlabel('Rewards'); set(gca,'XTick', [1 51 101 251]); 
set(gca,'XTickLabels',[0 5 10 25]);
legend('Handling = 2s','Handling = 10s','Handling = 14s');

%figure
%hold on
plot(MeanProbMatrixW(:,1),'--r')
plot(MeanProbMatrixW(:,2),'--g')
plot(MeanProbMatrixW(:,3),'--b')
%ylim([0 1.1]);
%xlabel('Rewards'); %set(gca,'XTick', [11 16 31]); 
%set(gca,'XTickLabels',[5 10 25]);
%legend('Handling = 2s','Handling = 10s','Handling = 14s');
legend('Effort: 2s','Effort: 10s','Effort: 14s','Wait: 2s','Wait: 10s','Wait: 14s')

figure 
%boxplot([logBetas.cogRwds(2:end) logBetas.cogHndl(2:end) logBetas.waitRwds(logBetas.waitIntrcpt<60) logBetas.waitHndl(logBetas.waitIntrcpt<60)])
