%%% just to put some analyses together, nothing specific
%%% Claudio 4/23/17


prompt = input('Plot acceptance rate for each subject? (y/n)','s');

%% Basic setups

condition = [cfiles;wfiles];
condition(1:length(cfiles)) = {'Cognitive'};
condition((length(cfiles)+1):end) = {'Wait'};
szeC = size(cMatrix);
szeW = size(wMatrix);
xC = szeC(1);
yC = szeC(2);
zC = szeC(3);
xW = szeW(1);
yW = szeW(2);
zW = szeW(3);

%% reward amounts, possibly convert to functions
earnedC = [];
earnedW = [];

for i = 1:zC
   earnedC(i) = totalEarned(cMatrix(:,:,i));
end    

for j = 1:zW
    earnedW(j) = totalEarned(wMatrix(:,:,j));
end    

% two sample t-test
[earned.Tstat,earned.Pval,earned.CI,earned.Stats] = ttest2(earnedC,earnedW);
earned.cog = earnedC;
earned.wait = earnedW;

clear i j earnedC earnedW

%% proportion completed
completedC = [];
completedW = [];

for i = 1:zC
    completedC(i) = sum(cMatrix(:,3,i)==1)./(sum(~isnan(cMatrix(:,3,i))) - sum(cMatrix(:,3,i)==2)); % minus forced travels
end

for i = 1:zW
    completedW(i) = sum(wMatrix(:,3,i)==1)./sum(~isnan(wMatrix(:,3,i)));
end

% two sample t-test
[completed.Tstat,completed.Pval,completed.CI,completed.Stats] = ttest2(completedC,completedW);
completed.cog = completedC;
completed.wait = completedW;

clear i completedC completedW

%% check the number of mistakes (forced travels)

mistakesTotalC = [];
mistakesPropC = [];
for i = 1:zC
    mistakesPropC(i) = sum(cMatrix(:,3,i)==2)./sum(~isnan(cMatrix(:,3,i))); 
    mistakesTotalC(i) = sum(cMatrix(:,3,i)==2);
end

% One-sample t-test
[mistakes.Tstat,mistakes.Pval,mistakes.CI,mistakes.Stats] = ttest(mistakesPropC);
mistakes.total = mistakesTotalC;
mistakes.prop = mistakesPropC;

clear i mistakesTotalC mistakesPropC

%% effort x handling for completed trials

compMatrixW = [];
compMatrixC = [];

handling = [2 10 14];
for i = 1:zC
    for j = 1:3
        index = find(cMatrix(:,1,i)==handling(j));
        indexHandling = cMatrix(index,3,i); % array indicating the completed/uncompleted trials for a handling type
        compMatrixC(i,j) = sum(indexHandling==1)./(length(indexHandling) - sum(indexHandling==2)); % 
    end
end

clearvars i j

for i = 1:zW
    for j = 1:3
        index = find(wMatrix(:,1,i)==handling(j));
        indexHandling = wMatrix(index,3,i); % array indicating the completed/uncompleted trials for a handling type
        compMatrixW(i,j) = sum(indexHandling==1)./length(indexHandling); % 
    end
end

% putting them together. 1 = cog, 0 = wait
compMatrix = [compMatrixC;compMatrixW];
compMatrix = [[ones(1,length(compMatrixC)) zeros(1,length(compMatrixW))]' compMatrix];

% rmANOVA EffortxHandling
rmEffortxHandling = struct('table',zeros(1,length(condition)));
rmEffortxHandling.table = table(condition,compMatrix(:,2),compMatrix(:,3),compMatrix(:,4),...
'VariableNames',{'Condition','TwoSec','TenSec','FourteenSec'});
Meas = dataset([1 2 3]','VarNames',{'Handling'});
rmEffortxHandling.rm = fitrm(rmEffortxHandling.table,'TwoSec-FourteenSec~Condition','WithinDesign',Meas);
rmEffortxHandling.summary = ranova(rm);
%[EffortxHandling.P, EffortxHandling.Table, EffortxHandling.Stats] = anova2(compMatrix(:,2:4),length(compMatrixC));

clear i j Meas compMatrixC compMatrixW

%% check if the quit time evolved


%% effort x money for completed trials
% (try doing it with multiple regression too, should be simple but more
% time consuming)
% completed5 completed10 completed25 cost
% 
% wcompmatrix = [];
% ccompmatrix = [];
% rwds = [5 10 25];
% for i = 1:zC
%     for j = 1:3
%         ccompmatrix(i,j) = sum((cMatrix(:,1,i)==rwds(j))  )
%     end
% end

%% acceptance rate plots

if prompt == 'y'
    for i = 1:zC
       figure
       plotForage(cMatrix(:,:,i),'cogn',cfiles{i});
    end   

    clear i

    for i = 1:zW
       figure
       plotForage(wMatrix(:,:,i),'wait',wfiles{i});
    end   
end

%% create a simple summary for basic measures
summary = [mean(completed.cog) mean(earned.cog); mean(completed.wait) mean(earned.wait)];

clearvars xC yC zC xW yW zW szeC szeW i j index indexHandling handling prompt
