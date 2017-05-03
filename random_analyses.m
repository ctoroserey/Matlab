%%% just to put some analyses together, nothing specific
%%% Claudio 5/2/17

prompt = input('Plot stats? (y/n)','s');
promptTwo = input('Plot acceptance rate for each subject? (y/n)','s');

%% Basic setups
cMatrix = setAll(cMatrix); % for model fit script
wMatrix = setAll(wMatrix);

format short g
condition = [cfiles;wfiles];
condition(1:length(cfiles)) = {'Cognitive'};
condition((length(cfiles)+1):end) = {'Wait'};
[xC, yC, zC] = size(cMatrix);
[xW, yW, zW] = size(wMatrix);


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

if prompt == 'y'
   figure
   x = [mean(earned.cog); mean(earned.wait)];
   e = [std(earned.cog); std(earned.wait)];
   b = bar(x,0.5);
   hold on
   h = errorbar(x,e); set(h,'LineStyle','none'); set(h,'color','r');
   title({'Total points earned'});
   ylim([0,2200]); 
   xlabel('Condition'); set(gca,'XTick', 1:2); set(gca,'XTickLabels',unique(condition));
   ylabel('Points earned');
   hold off
   clear h x e b
end    

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

if prompt == 'y'
   figure
   x = [mean(completed.cog); mean(completed.wait)];
   e = [std(completed.cog); std(completed.wait)];
   b = bar(x,0.5);
   hold on
   h = errorbar(x,e); set(h,'LineStyle','none'); set(h,'color','r');
   title({'Total proportion completed'});
   ylim([0,1.25]); 
   xlabel('Condition'); set(gca,'XTick', 1:2); set(gca,'XTickLabels',unique(condition));
   ylabel('Proportion completed');
   hold off
   clear h x e b
end   

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
   x = [(mean(compMatrixC(:,1))) (mean(compMatrixW(:,1))) 1;...
       (mean(compMatrixC(:,2))) (mean(compMatrixW(:,2))) 0.66;...
       (mean(compMatrixC(:,3))) (mean(compMatrixW(:,3))) 0.33];
   e = [(std(compMatrixC(:,1))) (std(compMatrixW(:,1))) 0;...
       (std(compMatrixC(:,2))) (std(compMatrixW(:,2))) 0;...
       (std(compMatrixC(:,3))) (std(compMatrixW(:,3))) 0];
   b = bar(x);
   hold on
   h = errorbar(x,e); set(h,'LineStyle','none'); set(h,'color','r');
   title({'Mean proportion completed for each condition across handling times','Cognitive vs Wait'});
   legend('Cognitive','Wait');
   b(1).FaceColor = 'green';
   b(2).FaceColor = 'blue';
   b(3).FaceColor = 'red';
   ylim([0,1.25]); 
   xlabel('Handling time'); set(gca,'XTick', 1:3); set(gca,'XTickLabels',handling);
   ylabel('Proportion completed');
   hold off
   clear h x e b
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
   x = [(mean(compMatrixC(:,1))) (mean(compMatrixW(:,1))) 0.33;...
       (mean(compMatrixC(:,2))) (mean(compMatrixW(:,2))) 0.66;...
       (mean(compMatrixC(:,3))) (mean(compMatrixW(:,3))) 1];
   e = [(std(compMatrixC(:,1))) (std(compMatrixW(:,1))) 0;...
       (std(compMatrixC(:,2))) (std(compMatrixW(:,2))) 0;...
       (std(compMatrixC(:,3))) (std(compMatrixW(:,3))) 0];
   b = bar(x);
   hold on
   h = errorbar(x,e); set(h,'LineStyle','none'); set(h,'color','r');
   title({'Mean proportion completed for each condition across reward amounts','Cognitive vs Wait'});
   legend('Cognitive','Wait');
   b(1).FaceColor = 'green';
   b(2).FaceColor = 'blue';
   b(3).FaceColor = 'red';
   ylim([0,1.25]); 
   xlabel('Reward amount'); set(gca,'XTick',1:3); set(gca,'XTickLabels',rwds);
   ylabel('Proportion completed');
   hold off
   clear h x e b   
end    

% taking advantage of the compMatrix to update 'completed' with handling ttests
completed.rewardComparison.five = ttest2(compMatrixC(:,1),compMatrixW(:,1));
completed.rewardComparison.ten = ttest2(compMatrixC(:,2),compMatrixW(:,2));
completed.rewardComparison.twntyfive = ttest2(compMatrixC(:,3),compMatrixW(:,3));

clear i j Meas compMatrixC compMatrixW compMatrix b rwds indexRwds

%% repeated measures before and after break for each condition separately
% graphing showed that differences will be very unlikely

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

clear i j Meas compMatrixCpre compMatrixCpost compMatrixWpre compMatrixWpost pre post indexPre indexPost b

%% model OR overall

wModelOR = [];
wModelPredicted = [];
cModelOR = [];
cModelPredicted = [];
SubjectCOR = struct('percentNow',{},'percentDelayed',{},'percentMissed',{},...
    'beta',{},'scale',{},'LL',{},...
    'LL0',{},'r2',{},'SOC',{},'prob',...
    {},'predictedChoice',{},'percentPredicted',{});

SubjectWOR = struct('percentNow',{},'percentDelayed',{},'percentMissed',{},...
    'beta',{},'scale',{},'LL',{},...
    'LL0',{},'r2',{},'SOC',{},'prob',...
    {},'predictedChoice',{},'percentPredicted',{});

% figure
% hold on
% title('Probability of completion for cognitive, unspecified');
% ylabel('Probability of completing trial')

for i = 1:zC
    SubjectCOR(i) = foragingOCModel(cMatrix(:,3,i),cMatrix(:,6,i),cMatrix(:,2,i),cMatrix(:,1,i));
    cModelOR(i) = SubjectCOR(i).beta;
    cModelPredicted(i) = SubjectCOR(i).percentPredicted;

%     plot(unique(SubjectCOR(i).prob));
end   

hold off
clear i 

% figure
% hold on
% title('Probability of completion for wait, unspecified');
% ylabel('Probability of completing trial')

for i = 1:zW
    SubjectWOR(i) = foragingOCModel(wMatrix(:,3,i),wMatrix(:,6,i),wMatrix(:,2,i),wMatrix(:,1,i));
    wModelOR(i) = SubjectWOR(i).beta;
    wModelPredicted(i) = SubjectWOR(i).percentPredicted;

%     plot(unique(SubjectWOR(i).prob));    
end    

cModelOR(isnan(cModelOR)) = [];
wModelOR(isnan(wModelOR)) = [];
cModelPredicted(cModelPredicted==0) = [];
wModelPredicted(wModelPredicted==0) = [];

ModelOR.CognitiveAll = [cModelOR;cModelPredicted]';
ModelOR.WaitAll = [wModelOR;wModelPredicted]';

% T-test comparing estimated opportunity rate values
[ModelORt.Tstat,ModelORt.Pval,ModelORt.CI,ModelORt.Stats] = ttest2(ModelOR.CognitiveAll(:,1),ModelOR.WaitAll(:,1));

if prompt == 'y'
    figure
    x = [mean(ModelOR.CognitiveAll(:,1)); mean(ModelOR.WaitAll(:,1))];
    e = [std(ModelOR.CognitiveAll(:,1)); std(ModelOR.WaitAll(:,1))];
    b = bar(x,0.5);
    hold on
    h = errorbar(x,e); set(h,'LineStyle','none'); set(h,'color','r');    
    title('Average estimated opportunity rate');
    ylim([0,1.5]); 
    xlabel('Condition'); set(gca,'XTick',1:3); set(gca,'XTickLabels',unique(condition));
    ylabel('Mean opportunity cost');
    hold off
    clear h x e b     
end    

clear i cModelOR cModelPredicted wModelOR wModelPredicted

%% model OR per handling

wModelOR = [];
wModelPredicted = [];
cModelOR = [];
cModelPredicted = [];

handling = [2 10 14];

for i = 1:zC
    for j = 1:3
        index = find(cMatrix(:,1,i)==handling(j));
        tempOutput = foragingOCModel(cMatrix(index,3,i),cMatrix(index,6,i),cMatrix(index,2,i),cMatrix(index,1,i));
        cModelOR(i,j) = tempOutput.beta;
        cModelPredicted(i,j) = tempOutput.percentPredicted;
    end
end   

clear i j

for i = 1:zW
    for j = 1:3
        index = find(wMatrix(:,1,i)==handling(j));
        tempOutput = foragingOCModel(wMatrix(index,3,i),wMatrix(index,6,i),wMatrix(index,2,i),wMatrix(index,1,i));
        wModelOR(i,j) = tempOutput.beta;
        wModelPredicted(i,j) = tempOutput.percentPredicted;
    end
end    

ModelOR.CognitiveHandlingOR = cModelOR;
ModelOR.WaitHandlingOR = wModelOR;
ModelOR.CognitiveHandlingPR = cModelPredicted;
ModelOR.WaitHandlingPR = wModelPredicted;

clear i cModelOR cModelPredicted wModelOR wModelPredicted tempOutput

%% model Hyperbolic 
% think about it, might not be necessary


%% acceptance rate plots

if promptTwo == 'y'
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

clearvars xC yC zC xW yW zW szeC szeW i j index indexHandling handling prompt b ans e h x

%% to sumarize a subject's results

%forageresults(cMatrix(:,:,3),SubjectCOR(3).predictedChoice,SubjectCOR(3).SOC) % inside the function there is a sort that's commented out