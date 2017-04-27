%%% just to put some analyses together, nothing specific
%%% Claudio 4/23/17

%% reward amounts, possibly convert to functions
szeC = size(cMatrix);
szeW = size(wMatrix);
xC = szeC(1);
yC = szeC(2);
zC = szeC(3);
xW = szeW(1);
yW = szeW(2);
zW = szeW(3);
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

clear i j
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

clear i 
%% check the number of mistakes (forced travels)

mistakesTotalC = [];
mistakesPropC = [];
for i = 1:zC
    mistakesPropC(i) = sum(cMatrix(:,3,i)==2)./sum(~isnan(cMatrix(:,3,i))); 
    mistakesTotalC(i) = sum(cMatrix(:,3,i)==2);
end

% One-sample t-test
[mistakesProp.Tstat,mistakesProp.Pval,mistakesProp.CI,mistakesProp.Stats] = ttest(mistakesPropC);

clear i 
%% effort x handling for completed trials
% double check
compMatrixW = [];
compMatrixC = [];

handling = [2 10 14];
for i = 1:zC
    for j = 1:3
        index = find(cMatrix(:,1,i)==handling(j));
        indexHandling = cMatrix(index,3); % array indicating the completed/uncompleted trials for a handling type
        compMatrixC(i,j) = sum(indexHandling==1)./(length(index) - sum(indexHandling==2)); % 
    end
end

clearvars i j

for i = 1:zW
    for j = 1:3
        index = find(wMatrix(:,1,i)==handling(j));
        indexHandling = wMatrix(index,3); % array indicating the completed/uncompleted trials for a handling type
        compMatrixW(i,j) = sum(indexHandling==1)./length(index); % 
    end
end

% putting them together. 1 = cog, 0 = wait
compMatrix = [compMatrixC;compMatrixW];
compMatrix = [[ones(1,length(compMatrixC)) zeros(1,length(compMatrixW))]' compMatrix];
    
% ANOVA
[EffortxHandling.P, EffortxHandling.Table, EffortxHandling.Stats] = anova2(compMatrix(:,2:4),length(compMatrixC));
clear i j

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

% for i = 1:zC
%    figure
%    plotForage(cMatrix(:,:,
%     
% end    

summary = [mean(completedC) mean(earnedC); mean(completedW) mean(earnedW)];

clearvars xC yC zC xW yW zW szeC szeW i j index indexHandling handling
