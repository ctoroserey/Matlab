%%% just to put some analyses together, nothing specific
%%% Claudio 5/1/17


prompt = input('Plot acceptance rate for each subject? (y/n)','s');

%% Basic setups
cMatrix = setAll(cMatrix); % for model fit script
wMatrix = setAll(wMatrix);

format short g
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

% putting them together. 1 = cog, 0 = wait (phase out at some point)
compMatrix = [compMatrixC;compMatrixW];
compMatrix = [[ones(1,length(compMatrixC)) zeros(1,length(compMatrixW))]' compMatrix];

% rmANOVA EffortxHandling
rmEffortxHandling = struct('table',zeros(1,length(condition)));
rmEffortxHandling.table = table(condition,compMatrix(:,2),compMatrix(:,3),compMatrix(:,4),...
'VariableNames',{'Condition','TwoSec','TenSec','FourteenSec'});
Meas = dataset([1 2 3]','VarNames',{'Handling'});
rmEffortxHandling.rm = fitrm(rmEffortxHandling.table,'TwoSec-FourteenSec~Condition','WithinDesign',Meas);
rmEffortxHandling.summary = ranova(rmEffortxHandling.rm);
rmEffortxHandling.TwovTen = ttest(compMatrix(:,2),compMatrix(:,3));
rmEffortxHandling.TwovFourt = ttest(compMatrix(:,2),compMatrix(:,4));
rmEffortxHandling.TenvFourt = ttest(compMatrix(:,3),compMatrix(:,4));
%[EffortxHandling.P, EffortxHandling.Table, EffortxHandling.Stats] = anova2(compMatrix(:,2:4),length(compMatrixC));

if prompt == 'y'
   figure
   b = bar([(mean(compMatrixC(:,1))) (mean(compMatrixW(:,1)));...
       (mean(compMatrixC(:,2))) (mean(compMatrixW(:,2)));...
       (mean(compMatrixC(:,3))) (mean(compMatrixW(:,3)))]);
   title({'Mean proportion completed for each condition across handling times','Cognitive vs Wait'});
   legend('Cognitive','Wait');
   b(1).FaceColor = 'green';
   b(2).FaceColor = 'blue';
   ylim([0,1.25]); 
   xlabel('Handling time'); set(gca,'XTick', 1:3); set(gca,'XTickLabels',handling);
   ylabel('Proportion completed');
end    

% taking advantage of the compMatrix to update 'completed' with handling ttests
completed.handlingComparison.two = ttest2(compMatrixC(:,1),compMatrixW(:,1));
completed.handlingComparison.ten = ttest2(compMatrixC(:,2),compMatrixW(:,2));
completed.handlingComparison.fourteen = ttest2(compMatrixC(:,3),compMatrixW(:,3));

clear i j Meas compMatrixC compMatrixW compMatrix b

%% effort x money for completed trials

compMatrixW = [];
compMatrixC = [];

rwds = [5 10 25];

for i = 1:zC
    for j = 1:3
        index = find(cMatrix(:,2,i)==rwds(j));
        indexRwds = cMatrix(index,3,i); % array indicating the completed/uncompleted trials for a handling type
        compMatrixC(i,j) = sum(indexRwds==1)./(length(indexRwds) - sum(indexRwds==2)); % 
    end
end

clearvars i j

for i = 1:zW
    for j = 1:3
        index = find(wMatrix(:,2,i)==rwds(j));
        indexRwds = wMatrix(index,3,i); % array indicating the completed/uncompleted trials for a handling type
        compMatrixW(i,j) = sum(indexRwds==1)./length(indexRwds); 
    end
end

% putting them together. 1 = cog, 0 = wait (phase out at some point)
compMatrix = [compMatrixC;compMatrixW];
compMatrix = [[ones(1,length(compMatrixC)) zeros(1,length(compMatrixW))]' compMatrix];

% rmANOVA EffortxRewards
rmEffortxRewards = struct('table',zeros(1,length(condition)));
rmEffortxRewards.table = table(condition,compMatrix(:,2),compMatrix(:,3),compMatrix(:,4),...
'VariableNames',{'Condition','FivePoints','TenPoints','TwntyfivePoints'});
Meas = dataset([1 2 3]','VarNames',{'Rewards'});
rmEffortxRewards.rm = fitrm(rmEffortxRewards.table,'FivePoints-TwntyfivePoints~Condition','WithinDesign',Meas);
rmEffortxRewards.summary = ranova(rmEffortxRewards.rm);
rmEffortxRewards.FivevTen = ttest(compMatrix(:,2),compMatrix(:,3));
rmEffortxRewards.FivevTwntyfive = ttest(compMatrix(:,2),compMatrix(:,4));
rmEffortxRewards.TenvTwntyfive = ttest(compMatrix(:,3),compMatrix(:,4));


if prompt == 'y'
   figure
   b = bar([(mean(compMatrixC(:,1))) (mean(compMatrixW(:,1)));...
       (mean(compMatrixC(:,2))) (mean(compMatrixW(:,2)));...
       (mean(compMatrixC(:,3))) (mean(compMatrixW(:,3)))]);
   title({'Mean proportion completed for each condition across reward amounts','Cognitive vs Wait'});
   legend('Cognitive','Wait');
   b(1).FaceColor = 'green';
   b(2).FaceColor = 'blue';
   ylim([0,1.25]); 
   xlabel('Reward amount'); set(gca,'XTick',1:3); set(gca,'XTickLabels',rwds);
   ylabel('Proportion completed');
end    

% taking advantage of the compMatrix to update 'completed' with handling ttests
completed.rewardComparison.five = ttest2(compMatrixC(:,1),compMatrixW(:,1));
completed.rewardComparison.ten = ttest2(compMatrixC(:,2),compMatrixW(:,2));
completed.rewardComparison.twntyfive = ttest2(compMatrixC(:,3),compMatrixW(:,3));

clear i j Meas compMatrixC compMatrixW compMatrix b rwds

%% check if the quit time evolved

%% repeated measures before and after break for each condition separately

compMatrixWpre = [];
compMatrixWpost = [];
compMatrixCpre = [];
compMatrixCpost = [];

handling = [2 10 14];
    
for i = 1:zC
    for j = 1:3
        index = find(cMatrix(:,1,i)==handling(j)); % finds the trials with a specific handling time
        pre = index<mean(index); % divides them into pre/post break
        post = ~pre;
        pre = index((index .* pre)~=0);
        post = index((index .* post)~=0);
        indexPre = cMatrix(pre,3,i); % array indicating the completed/uncompleted trials for a handling type
        indexPost = cMatrix(post,3,i);
        compMatrixCpre(i,j) = sum(indexPre==1)./(length(indexPre) - sum(indexPre==2)); 
        compMatrixCpost(i,j) = sum(indexPost==1)./(length(indexPost) - sum(indexPost==2));
    end
end

clearvars i j

for i = 1:zW
    for j = 1:3
        index = find(wMatrix(:,1,i)==handling(j)); % finds the trials with a specific handling time
        pre = index<mean(index); % divides them into pre/post break
        post = ~pre;
        pre = index((index .* pre)~=0);
        post = index((index .* post)~=0);
        indexPre = wMatrix(pre,3,i); % array indicating the completed/uncompleted trials for a handling type
        indexPost = wMatrix(post,3,i);
        compMatrixWpre(i,j) = sum(indexPre==1)./(length(indexPre) - sum(indexPre==2)); 
        compMatrixWpost(i,j) = sum(indexPost==1)./(length(indexPost) - sum(indexPost==2));
    end
end

if prompt == 'y'
   figure
   b = bar([(mean(compMatrixWpre(:,1))) (mean(compMatrixWpost(:,1)));...
       (mean(compMatrixWpre(:,2))) (mean(compMatrixWpost(:,2)));...
       (mean(compMatrixWpre(:,3))) (mean(compMatrixWpost(:,3)))]);
   title({'Mean proportion completed at each handling time pre/post break','Wait'});
   legend('Pre','Post');
   b(1).FaceColor = 'green';
   b(2).FaceColor = 'blue';
   ylim([0,1.25]); 
   xlabel('Handling time'); set(gca,'XTick', 1:3); set(gca,'XTickLabels',handling);
   ylabel('Proportion completed');
   
   figure
   b = bar([(mean(compMatrixCpre(:,1))) (mean(compMatrixCpost(:,1)));...
       (mean(compMatrixCpre(:,2))) (mean(compMatrixCpost(:,2)));...
       (mean(compMatrixCpre(:,3))) (mean(compMatrixCpost(:,3)))]);
   title({'Mean proportion completed at each handling time pre/post break','Cognitive'});
   legend('Pre','Post');
   b(1).FaceColor = 'green';
   b(2).FaceColor = 'blue';
   ylim([0,1.25]); 
   xlabel('Handling time'); set(gca,'XTick', 1:3); set(gca,'XTickLabels',handling);
   ylabel('Proportion completed');
end    

clear i j Meas compMatrixCpre compMatrixCpost compMatrixWpre compMatrixWpost pre post b

%% model (not doing very well (lazy version for now)

cost001 = foraging(cMatrix(:,3,1),cMatrix(:,6,1),cMatrix(:,2,1),cMatrix(:,1,1));
cost002 = foraging(wMatrix(:,3,1),wMatrix(:,6,1),wMatrix(:,2,1),wMatrix(:,1,1));
cost003 = foraging(wMatrix(:,3,2),wMatrix(:,6,2),wMatrix(:,2,2),wMatrix(:,1,2));
cost004 = foraging(cMatrix(:,3,2),cMatrix(:,6,2),cMatrix(:,2,2),cMatrix(:,1,2));
cost005 = foraging(wMatrix(:,3,3),wMatrix(:,6,3),wMatrix(:,2,3),wMatrix(:,1,3));
cost006 = foraging(cMatrix(:,3,3),cMatrix(:,6,3),cMatrix(:,2,3),cMatrix(:,1,3));
cost007 = foraging(wMatrix(:,3,4),wMatrix(:,6,4),wMatrix(:,2,4),wMatrix(:,1,4));
cost008 = foraging(cMatrix(:,3,4),cMatrix(:,6,4),cMatrix(:,2,4),cMatrix(:,1,4));
cost009 = foraging(wMatrix(:,3,5),wMatrix(:,6,5),wMatrix(:,2,5),wMatrix(:,1,5));
cost010 = foraging(cMatrix(:,3,5),cMatrix(:,6,5),cMatrix(:,2,5),cMatrix(:,1,5));
cost011 = foraging(wMatrix(:,3,6),wMatrix(:,6,6),wMatrix(:,2,6),wMatrix(:,1,6));
cost012 = foraging(cMatrix(:,3,6),cMatrix(:,6,6),cMatrix(:,2,6),cMatrix(:,1,6));
cost013 = foraging(wMatrix(:,3,7),wMatrix(:,6,7),wMatrix(:,2,7),wMatrix(:,1,7));
cost014 = foraging(cMatrix(:,3,7),cMatrix(:,6,7),cMatrix(:,2,7),cMatrix(:,1,7));
cost015 = foraging(wMatrix(:,3,8),wMatrix(:,6,8),wMatrix(:,2,8),wMatrix(:,1,8));
cost016 = foraging(cMatrix(:,3,8),cMatrix(:,6,8),cMatrix(:,2,8),cMatrix(:,1,8));


% wModel = [];
% cModel = [];
% 
% for i = 1:zC
%     cModel.i = foraging(cMatrix(:,3,i),cMatrix(:,6,i),cMatrix(:,2,i),cMatrix(:,1,i));
% end   
% 
% for i = 1:zW
%     wModel.i = foraging(wMatrix(:,3,i),wMatrix(:,6,i),wMatrix(:,2,i),wMatrix(:,1,i));
% end    

%% acceptance rate plots
% 
% if prompt == 'y'
%     for i = 1:zC
%        figure
%        plotForage(cMatrix(:,:,i),'cogn',cfiles{i});
%     end   
% 
%     clear i
% 
%     for i = 1:zW
%        figure
%        plotForage(wMatrix(:,:,i),'wait',wfiles{i});
%     end   
% end

%% create a simple summary for basic measures
summary = [mean(completed.cog) mean(earned.cog); mean(completed.wait) mean(earned.wait)];

clearvars xC yC zC xW yW zW szeC szeW i j index indexHandling handling prompt
