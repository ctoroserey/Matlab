%%% just to put some analyses together, nothing specific
%%% Claudio 5/2/17
% /Users/ctoro/git_clones/lab_tasks/Claudio/SONA/cog/data (work)

prompt = input('Plot stats? (y/n)','s');
promptTwo = input('Plot acceptance rate for each subject? (y/n)','s');

%% Basic setups
cMatrix = setAll(cMatrix); % for model fit script
wMatrix = setAll(wMatrix);

format short g
condition = [cfiles;wfiles]; 
condition(1:length(cfiles)) = {'Cognitive'};
condition((length(cfiles)+1):end) = {'Wait'};
% condition = {'Cog', 'Cog', 'Cog', 'Cog', 'Wait', 'Wait', 'Wait',
% 'Wait'}'; DURING SIMULATIONS
[xC, yC, zC] = size(cMatrix);
[xW, yW, zW] = size(wMatrix);

handling = [2 10 14];
rwds = [5 10 25];
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
   b.FaceColor = [0,.45,.74];    
   hold on
   h = errorbar(x,e); set(h,'LineStyle','none'); set(h,'color','r');
   title({'Total points earned'},'FontSize',24);
   ylim([0,2400]); 
   xlabel('Condition','FontSize',24); set(gca,'XTick', 1:2); set(gca,'XTickLabels',unique(condition)); set(gca,'FontSize',24);
   ylabel('Points earned','FontSize',24);
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
   b.FaceColor = [0,.45,.74];    
   hold on
   h = errorbar(x,e); set(h,'LineStyle','none'); set(h,'color','r');
   title({'Total proportion completed'},'FontSize',24);
   ylim([0,1.25]); 
   xlabel('Condition'); set(gca,'XTick', 1:2); set(gca,'XTickLabels',unique(condition)); set(gca,'FontSize',24);
   ylabel('Proportion completed','FontSize',24);
   hold off
   clear h x e b
end   

clear i completedC completedW

%% reaction times

compMatrixW = [];
compMatrixC = [];

for i = 1:zC
    for j = 1:3
        index = find(cMatrix(:,1,i)==handling(j));
        indexHandling = cMatrix(index,4,i); % array indicating the RT for a handling type
        indexChoice = cMatrix(index,3,i);
        if indexChoice(:)~=0
            compMatrixC(i,j) = 0;
        else    
            indexChoice = find(indexChoice==0);
            compMatrixC(i,j) = mean(indexHandling(indexChoice));
        end    
    end
end

clearvars i j

for i = 1:zW
    for j = 1:3
        index = find(wMatrix(:,1,i)==handling(j));
        indexHandling = wMatrix(index,4,i); % array indicating the completed/uncompleted trials for a handling type
        indexChoice = wMatrix(index,3,i);
        if indexChoice(:)~=0
            compMatrixW(i,j) = 0;
        else    
            indexChoice = find(indexChoice==0);
            compMatrixW(i,j) = mean(indexHandling(indexChoice));
        end    
    end
end


% two sample t-test
RT.cog = compMatrixC;
RT.wait = compMatrixW;
RT.cog(RT.cog(:,3)==0,:) = [];
RT.wait(RT.wait(:,3)==0,:) = [];
[RT.Tstat,RT.Pval,RT.CI,RT.Stats] = ttest2(compMatrixC,compMatrixW);

if prompt == 'y'
   figure
   x = [(mean(compMatrixC(:,1))) (mean(compMatrixW(:,1)));...
       (mean(compMatrixC(:,2))) (mean(compMatrixW(:,2)));...
       (mean(compMatrixC(:,3))) (mean(compMatrixW(:,3)))];
   e = [(std(compMatrixC(:,1))) (std(compMatrixW(:,1)));...
       (std(compMatrixC(:,2))) (std(compMatrixW(:,2)));...
       (std(compMatrixC(:,3))) (std(compMatrixW(:,3)))];
   b = bar(x);
   hold on
   h1 = errorbar(x(:,1),e(:,1));
   h2 = errorbar(x(:,2),e(:,2));
   set(h1,'LineStyle','none'); set(h1,'color','r'); set(h1,'XData',[0.86,1.86, 2.86]);
   set(h2,'LineStyle','none'); set(h2,'color','r'); set(h2,'XData',[1.14,2.14, 3.14]);
   title({'RTs per condition and handling time','Cognitive vs Wait'},'FontSize',24);
   legend('Cognitive','Wait');set(gca,'FontSize',24);
   b(1).FaceColor = [0.4,0.6,0.4];
   b(2).FaceColor = [0,.45,.74];
   ylim([0,1.25]); 
   xlabel('Handling Time'); set(gca,'XTick',1:3); set(gca,'XTickLabels',handling);set(gca,'FontSize',24);
   ylabel('Reaction Time (Sec)','FontSize',24);
   hold off
   clear h x e b   
end   

clear i j compMatrixC compMatrixW indexHandling indexChoice

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
   e = [(std(compMatrixC(:,1))) (std(compMatrixW(:,1))) 0;
        (std(compMatrixC(:,2))) (std(compMatrixW(:,2))) 0;
        (std(compMatrixC(:,3))) (std(compMatrixW(:,3))) 0];
   b = bar(x);
   hold on
   h1 = errorbar(x(:,1),e(:,1));
   h2 = errorbar(x(:,2),e(:,2));
   h3 = errorbar(x(:,3),e(:,3));
   set(h1,'LineStyle','none'); set(h1,'color','r'); set(h1,'XData',[0.77,1.77,2.77]);
   set(h2,'LineStyle','none'); set(h2,'color','r'); set(h2,'XData',[1,2,3]);
   set(h3,'LineStyle','none'); set(h3,'color','r'); set(h3,'XData',[1.23,2.23,3.23]);
   title({'Proportion completed for each handling time','Cognitive vs Wait'},'FontSize',24);
   legend('Cognitive','Wait','Optimal');set(gca,'FontSize',24);
   b(1).FaceColor = [0.4,0.6,0.4];
   b(2).FaceColor = [0,.45,.74];
   b(3).FaceColor = [.85,.33,.1];
   ylim([0,1.25]); 
   xlabel('Handling time','FontSize',24); set(gca,'XTick', 1:3); set(gca,'XTickLabels',handling);set(gca,'FontSize',24);
   ylabel('Proportion completed','FontSize',24);
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
   h1 = errorbar(x(:,1),e(:,1));
   h2 = errorbar(x(:,2),e(:,2));
   h3 = errorbar(x(:,3),e(:,3));
   set(h1,'LineStyle','none'); set(h1,'color','r'); set(h1,'XData',[0.77,1.77,2.77]);
   set(h2,'LineStyle','none'); set(h2,'color','r'); set(h2,'XData',[1,2,3]);
   set(h3,'LineStyle','none'); set(h3,'color','r'); set(h3,'XData',[1.23,2.23,3.23]);
   title({'Proportion completed for each reward amount','Cognitive vs Wait'},'FontSize',24);
   legend('Cognitive','Wait','Optimal');set(gca,'FontSize',24);
   b(1).FaceColor = [0.4,0.6,0.4];
   b(2).FaceColor = [0,.45,.74];
   b(3).FaceColor = [.85,.33,.1];
   ylim([0,1.25]); 
   xlabel('Reward amount'); set(gca,'XTick',1:3); set(gca,'XTickLabels',rwds);set(gca,'FontSize',24);
   ylabel('Proportion completed','FontSize',24);
   hold off
   clear h x e b   
end    

% taking advantage of the compMatrix to update 'completed' with handling ttests
completed.rewardComparison.five = ttest2(compMatrixC(:,1),compMatrixW(:,1));
completed.rewardComparison.ten = ttest2(compMatrixC(:,2),compMatrixW(:,2));
completed.rewardComparison.twntyfive = ttest2(compMatrixC(:,3),compMatrixW(:,3));

clear i j Meas compMatrixC compMatrixW compMatrix b indexRwds

%% repeated measures before and after break for each condition separately
% graphing showed that differences will be very unlikely

compMatrixWpre = [];
compMatrixWpost = [];
compMatrixCpre = [];
compMatrixCpost = [];
    
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
   title({'Proportion completed for each handling time pre/post break','Wait'},'FontSize',24);
   legend('Pre','Post');set(gca,'FontSize',24);
   b(1).FaceColor = [0.4,0.6,0.4];
   b(2).FaceColor = [0,.45,.74];
   ylim([0,1.25]); 
   xlabel('Handling time','FontSize',24); set(gca,'XTick', 1:3); set(gca,'XTickLabels',handling);set(gca,'FontSize',24);
   ylabel('Proportion completed','FontSize',24);
   
   figure
   b = bar([(mean(compMatrixCpre(:,1))) (mean(compMatrixCpost(:,1)));...
       (mean(compMatrixCpre(:,2))) (mean(compMatrixCpost(:,2)));...
       (mean(compMatrixCpre(:,3))) (mean(compMatrixCpost(:,3)))]);
   title({'Proportion completed for each handling time pre/post break','Cognitive'},'FontSize',24);
   legend('Pre','Post');set(gca,'FontSize',24);
   b(1).FaceColor = [0.4,0.6,0.4];
   b(2).FaceColor = [0,.45,.74];
   ylim([0,1.25]); 
   xlabel('Handling time','FontSize',24); set(gca,'XTick', 1:3); set(gca,'XTickLabels',handling);set(gca,'FontSize',24);
   ylabel('Proportion completed','FontSize',24);
end    

clear i j Meas compMatrixCpre compMatrixCpost compMatrixWpre compMatrixWpost pre post indexPre indexPost b

%% model OR overall

wModelOR = [];
wModelPredicted = [];
cModelOR = [];
cModelPredicted = [];

% structs containing each subject's model results
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
    SubjectCOR(i) = foragingOCModel(cMatrix(:,3,i),cMatrix(:,6,i),cMatrix(:,2,i),cMatrix(:,1,i),0);
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
    SubjectWOR(i) = foragingOCModel(wMatrix(:,3,i),wMatrix(:,6,i),wMatrix(:,2,i),wMatrix(:,1,i),0);
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
[ModelORt.Pval,ModelORt.Tstat,ModelORt.Stats] = ranksum(ModelOR.CognitiveAll(:,1),ModelOR.WaitAll(:,1));

if prompt == 'y'
    figure
    x = [mean(ModelOR.CognitiveAll(:,1)); mean(ModelOR.WaitAll(:,1))];
    e = [std(ModelOR.CognitiveAll(:,1)); std(ModelOR.WaitAll(:,1))];
    b = bar(x,0.5);
    b.FaceColor = [0,.45,.74];    
    hold on
    h = errorbar(x,e); set(h,'LineStyle','none'); set(h,'color','r');    
    title('Average estimated opportunity rate','FontSize',24);
    ylim([0,1.5]); 
    xlabel('Condition','FontSize',24); set(gca,'XTick',1:3); set(gca,'XTickLabels',unique(condition));set(gca,'FontSize',24);
    ylabel('Mean opportunity cost','FontSize',24);
    hold off
    clear h x e b     
end    

clear i cModelOR cModelPredicted wModelOR wModelPredicted

%% model OR per handling
% this seems wrong: of course the OR will be different, because k will have
% to be different between handling times. Better to z-score them.

wModelOR = [];
wModelPredicted = [];
cModelOR = [];
cModelPredicted = [];

for i = 1:zC
    for j = 1:3
        index = find(cMatrix(:,1,i)==handling(j));
        tempOutput = foragingOCModel(cMatrix(index,3,i),cMatrix(index,6,i),cMatrix(index,2,i),cMatrix(index,1,i),1);
        cModelOR(i,j) = tempOutput.beta;
        cModelPredicted(i,j) = tempOutput.percentPredicted;
    end
end   

clear i j

for i = 1:zW
    for j = 1:3
        index = find(wMatrix(:,1,i)==handling(j));
        tempOutput = foragingOCModel(wMatrix(index,3,i),wMatrix(index,6,i),wMatrix(index,2,i),wMatrix(index,1,i),1);
        wModelOR(i,j) = tempOutput.beta;
        wModelPredicted(i,j) = tempOutput.percentPredicted;
    end
end    

ModelOR.CognitiveHandlingOR = cModelOR;
ModelOR.WaitHandlingOR = wModelOR;
ModelOR.CognitiveHandlingPR = cModelPredicted;
ModelOR.WaitHandlingPR = wModelPredicted;

clear i cModelOR cModelPredicted wModelOR wModelPredicted tempOutput

% rmANOVA
compMatrix = [ModelOR.CognitiveHandlingOR; ModelOR.WaitHandlingOR];
rmORxHandling = struct('table',zeros(1,length(condition)));
rmORxHandling.table = table(condition,compMatrix(:,1),compMatrix(:,2),compMatrix(:,3),...
'VariableNames',{'Condition','TwoSec','TenSec','FourteenSec'});
Meas = dataset([1 2 3]','VarNames',{'Handling'});
rmORxHandling.rm = fitrm(rmORxHandling.table,'TwoSec-FourteenSec~Condition','WithinDesign',Meas);
rmORxHandling.summary = ranova(rmORxHandling.rm);
rmORxHandling.TwovTen = ttest(compMatrix(:,1),compMatrix(:,2));
rmORxHandling.TwovFourt = ttest(compMatrix(:,1),compMatrix(:,3));
rmORxHandling.TenvFourt = ttest(compMatrix(:,2),compMatrix(:,3));

% T-Tests comparing ORs between groups per handling
[ModelORt.handlingComparison2.Pval,ModelORt.handlingComparison2.Tstat,ModelORt.handlingComparison2.Stats] = ranksum(ModelOR.CognitiveHandlingOR(:,1),ModelOR.WaitHandlingOR(:,1));
[ModelORt.handlingComparison10.Pval,ModelORt.handlingComparison10.Tstat,ModelORt.handlingComparison10.Stats] = ranksum(ModelOR.CognitiveHandlingOR(:,2),ModelOR.WaitHandlingOR(:,2));
[ModelORt.handlingComparison14.Pval,ModelORt.handlingComparison14.Tstat,ModelORt.handlingComparison14.Stats] = ranksum(ModelOR.CognitiveHandlingOR(:,3),ModelOR.WaitHandlingOR(:,3));

if prompt == 'y'
   figure
   x = [(mean(ModelOR.CognitiveHandlingOR(:,1))) (mean(ModelOR.WaitHandlingOR(:,1))) 2.49;...
       (mean(ModelOR.CognitiveHandlingOR(:,2))) (mean(ModelOR.WaitHandlingOR(:,2))) 0.51;...
       (mean(ModelOR.CognitiveHandlingOR(:,3))) (mean(ModelOR.WaitHandlingOR(:,3))) 0.72];
   e = [(std(ModelOR.CognitiveHandlingOR(:,1))) (std(ModelOR.WaitHandlingOR(:,1))) 0;
        (std(ModelOR.CognitiveHandlingOR(:,2))) (std(ModelOR.WaitHandlingOR(:,2))) 0;
        (std(ModelOR.CognitiveHandlingOR(:,3))) (std(ModelOR.WaitHandlingOR(:,3))) 0];
   b = bar(x);
   hold on
   h1 = errorbar(x(:,1),e(:,1));
   h2 = errorbar(x(:,2),e(:,2));
   h3 = errorbar(x(:,3),e(:,3));
   set(h1,'LineStyle','none'); set(h1,'color','r'); set(h1,'XData',[0.77,1.77,2.77]);
   set(h2,'LineStyle','none'); set(h2,'color','r'); set(h2,'XData',[1,2,3]);
   set(h3,'LineStyle','none'); set(h3,'color','r'); set(h3,'XData',[1.23,2.23,3.23]);
   title({'Mean subjective-ORs for each handling time','Cognitive vs Wait'},'FontSize',24);
   legend('Cognitive','Wait','Smallest Opt.');set(gca,'FontSize',24);
   b(1).FaceColor = [0.4,0.6,0.4];
   b(2).FaceColor = [0,.45,.74];
   b(3).FaceColor = [.85,.33,.1];
   ylim([0,4.5]); 
   xlabel('Handling time'); set(gca,'XTick', 1:3); set(gca,'XTickLabels',handling);
   ylabel('Subjective-OR');
   hold off
   clear h x e b
end  

clear i cModelOR cModelPredicted wModelOR wModelPredicted tempOutput compMatrix Meas

% %% NEW VERSION WITHOUT 25 PTS
% 
% wModelOR = [];
% wModelPredicted = [];
% cModelOR = [];
% cModelPredicted = [];
% 
% for i = 1:zC
%     for j = 1:3
%         index = find(cMatrix(:,1,i)==handling(j) & cMatrix(:,2,i)~=25);
%         tempOutput = foragingOCModel(cMatrix(index,3,i),cMatrix(index,6,i),cMatrix(index,2,i),cMatrix(index,1,i),1);
%         cModelOR(i,j) = tempOutput.beta;
%         cModelPredicted(i,j) = tempOutput.percentPredicted;
%     end
% end   
% 
% clear i j
% 
% for i = 1:zW
%     for j = 1:3
%         index = find(wMatrix(:,1,i)==handling(j) & wMatrix(:,2,i)~=25);
%         tempOutput = foragingOCModel(wMatrix(index,3,i),wMatrix(index,6,i),wMatrix(index,2,i),wMatrix(index,1,i),1);
%         wModelOR(i,j) = tempOutput.beta;
%         wModelPredicted(i,j) = tempOutput.percentPredicted;
%     end
% end    
% 
% ModelOR2.CognitiveHandlingOR = cModelOR;
% ModelOR2.WaitHandlingOR = wModelOR;
% ModelOR2.CognitiveHandlingPR = cModelPredicted;
% ModelOR2.WaitHandlingPR = wModelPredicted;
% 
% clear i cModelOR cModelPredicted wModelOR wModelPredicted tempOutput
% 
% % T-Tests comparing ORs between groups per handling
% [ModelORt2.handlingComparison2.Pval,ModelORt2.handlingComparison2.Tstat,ModelORt2.handlingComparison2.Stats] = ranksum(ModelOR2.CognitiveHandlingOR(:,1),ModelOR2.WaitHandlingOR(:,1));
% [ModelORt2.handlingComparison10.Pval,ModelORt2.handlingComparison10.Tstat,ModelORt2.handlingComparison10.Stats] = ranksum(ModelOR2.CognitiveHandlingOR(:,2),ModelOR2.WaitHandlingOR(:,2));
% [ModelORt2.handlingComparison14.Pval,ModelORt2.handlingComparison14.Tstat,ModelORt2.handlingComparison14.Stats] = ranksum(ModelOR2.CognitiveHandlingOR(:,3),ModelOR2.WaitHandlingOR(:,3));
% 
% if prompt == 'y'
%    figure
%    x = [(mean(ModelOR2.CognitiveHandlingOR(:,1))) (mean(ModelOR2.WaitHandlingOR(:,1))) 0.74;...
%        (mean(ModelOR2.CognitiveHandlingOR(:,2))) (mean(ModelOR2.WaitHandlingOR(:,2))) 0.79;...
%        (mean(ModelOR2.CognitiveHandlingOR(:,3))) (mean(ModelOR2.WaitHandlingOR(:,3))) 0.96];
%    e = [(std(ModelOR2.CognitiveHandlingOR(:,1))) (std(ModelOR2.WaitHandlingOR(:,1))) 0;
%         (std(ModelOR2.CognitiveHandlingOR(:,2))) (std(ModelOR2.WaitHandlingOR(:,2))) 0;
%         (std(ModelOR2.CognitiveHandlingOR(:,3))) (std(ModelOR2.WaitHandlingOR(:,3))) 0];
%    b = bar(x);
%    hold on
%    h1 = errorbar(x(:,1),e(:,1));
%    h2 = errorbar(x(:,2),e(:,2));
%    h3 = errorbar(x(:,3),e(:,3));
%    set(h1,'LineStyle','none'); set(h1,'color','r'); set(h1,'XData',[0.77,1.77,2.77]);
%    set(h2,'LineStyle','none'); set(h2,'color','r'); set(h2,'XData',[1,2,3]);
%    set(h3,'LineStyle','none'); set(h3,'color','r'); set(h3,'XData',[1.23,2.23,3.23]);
%    title({'Mean subjective-ORs for each handling time','Cognitive vs Wait'},'FontSize',24);
%    legend('Cognitive','Wait','Optimal');set(gca,'FontSize',24);
%    b(1).FaceColor = [0.4,0.6,0.4];
%    b(2).FaceColor = [0,.45,.74];
%    b(3).FaceColor = [.85,.33,.1];
%    ylim([0,4.5]); 
%    xlabel('Handling time'); set(gca,'XTick', 1:3); set(gca,'XTickLabels',handling);
%    ylabel('Subjective-OR');
%    hold off
%    clear h x e b
% end  
% 
% clear i cModelOR cModelPredicted wModelOR wModelPredicted tempOutput compMatrix Meas


%% fit plots (keep working on this)

% cognitive
probMatrix = [];

for i = 1:length(rwds)
   for j = 1:length(handling)
       handlingTemp = [];
       for k = 1:zC
        index1 = find(cMatrix(:,1,k)==handling(j));
        index2 = cMatrix(index1,2,k)==rwds(i);
        index3 = unique(index1.*index2);
        prob = SubjectCOR(k).prob(index3(4));
        handlingTemp(k) = prob;
       end
       probMatrix(i,j) = mean(handlingTemp);
   end    
end    

ModelOR.probMatrixC = probMatrix;

clear i j k probMatrix

% wait
probMatrix = [];

for i = 1:length(rwds)
   for j = 1:length(handling)
       handlingTemp = [];
       for k = 1:zW
        index1 = find(wMatrix(:,1,k)==handling(j));
        index2 = wMatrix(index1,2,k)==rwds(i);
        index3 = unique(index1.*index2);
        prob = SubjectWOR(k).prob(index3(4));
        handlingTemp(k) = prob;
       end
       probMatrix(i,j) = mean(handlingTemp);
   end    
end    

ModelOR.probMatrixW = probMatrix;

clear i j k probMatrix index1 index2 index3 prob handlingTemp

%% Consider
% model Hyperbolic 
% think about it, might not be necessary

% use mnrfit to quantify the contributions of handling and travel in a
% logistic regression per participant

%% acceptance rate plots, save in a 3D matrix (only if plots are requested)
cCompletion = zeros(3,3,zC);
wCompletion = zeros(3,3,zW);

if promptTwo == 'y'
    for i = 1:zC
       figure
       cCompletion(:,:,i) = plotForage(cMatrix(:,:,i),'cogn',cfiles{i});
    end   

    clear i

    for i = 1:zW
       figure
       wCompletion(:,:,i) = plotForage(wMatrix(:,:,i),'wait',wfiles{i});
    end   
    
    % Get a reward x handling matrix indicating the mean proportion completed
    cog = zeros(3,3);
    wait = zeros(3,3);
    combined = zeros(3,3);
    allSubj = cCompletion;
    allSubj(:,:,12:22) = wCompletion;

    for i = 1:3 % row (points)
        for j = 1:3 % columns (handling)
            combined(i,j) = mean(allSubj(i,j,:));
        end
    end
    
    figure;
    surf([1:3],[1:3],combined')
    xlabel('Rewards'); set(gca,'XTick', 1:3); set(gca,'XTickLabels',rwds);
    ylabel('Handling'); set(gca,'YTick', 1:3); set(gca,'YTickLabels',handling);
    zlabel('Proportion completed');
    title({'Mean proportion completed for each reward x handling combo','All subjects'});
    clear i j

    for i = 1:3 % row (points)
        for j = 1:3 % columns (handling)
            cog(i,j) = mean(cCompletion(i,j,:));
        end      
    end
    
    figure;
    surf([1:3],[1:3],cog')
    xlabel('Rewards'); set(gca,'XTick', 1:3); set(gca,'XTickLabels',rwds);
    ylabel('Handling'); set(gca,'YTick', 1:3); set(gca,'YTickLabels',handling);
    zlabel('Proportion completed'); 
    title({'Mean proportion completed for each reward x handling combo','Cognitive group'});    
    clear i j

    for i = 1:3 % row (points)
        for j = 1:3 % columns (handling)
            wait(i,j) = mean(wCompletion(i,j,:));
        end     
    end  
    
    figure;
    surf([1:3],[1:3],wait')
    xlabel('Rewards'); set(gca,'XTick', 1:3); set(gca,'XTickLabels',rwds);
    ylabel('Handling'); set(gca,'YTick', 1:3); set(gca,'YTickLabels',handling);
    zlabel('Proportion completed');      
    title({'Mean proportion completed for each reward x handling combo','Wait group'});    
end

    clear i j

%% create a simple summary for basic measures
summary = [mean(completed.cog) mean(earned.cog); mean(completed.wait) mean(earned.wait)];

clearvars xC yC zC xW yW zW szeC szeW i j index indexHandling handling rwds prompt promptTwo b ans e1 e2 e3 h1 h2 h3 x

%% to sumarize a subject's results

%forageresults(cMatrix(:,:,3),SubjectCOR(3).predictedChoice,SubjectCOR(3).SOC) % inside the function there is a sort that's commented out