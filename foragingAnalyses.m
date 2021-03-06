%%% just to put some analyses together, nothing specific
%%% Claudio 5/2/17
% /Users/ctoro/git_clones/lab_tasks/Claudio/SONA/cog/data (work)

% 9/13/17: small comment updates and fixes. Still have to include the mixed
% model or the regularized OR model.

prompt = input('Plot stats? (y/n)','s');
promptTwo = input('Plot acceptance rate for each subject? (y/n)','s');

%% Basic setups
cMatrix = setAll(cMatrix); % for model fit script
wMatrix = setAll(wMatrix);
pMatrix = setAll(pMatrix);

format short g
[xC, yC, zC] = size(cMatrix);
[xW, yW, zW] = size(wMatrix);
[xP, yP, zP] = size(pMatrix);

condition = [cfiles;wfiles;pfiles]; 
condition(1:zC) = {'Cognitive'};
condition((zC+1):(zC+zW)) = {'Wait'};
condition((zC+zW+1):end) = {'Physical'};

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
   e = [std(earned.cog)/sqrt(zC); std(earned.wait)/sqrt(zW)];
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
% the rmANOVA below will updaye this struct with CogvsWait ttests per
% handling time and reward amounts
completedC = [];
completedW = [];
completedP = [];

for i = 1:zC
    completedC(i) = sum(cMatrix(:,3,i)==1)./(sum(~isnan(cMatrix(:,3,i))) - sum(cMatrix(:,3,i)==2)); % minus forced travels
end

for i = 1:zW
    completedW(i) = sum(wMatrix(:,3,i)==1)./sum(~isnan(wMatrix(:,3,i)));
end

for i = 1:zP
    completedP(i) = sum(pMatrix(:,3,i)==1)./sum(~isnan(pMatrix(:,3,i)));
end

% Wilcoxon rank-sum
[completed.Pval,completed.Wstat] = ranksum(completedC,completedW);
completed.cog = completedC;
completed.wait = completedW;
completed.phys = completedP;

if prompt == 'y'
   figure
   x = [mean(completed.wait); mean(completed.cog); mean(completed.phys)];
   e = [std(completed.wait)/sqrt(zW); std(completed.cog)/sqrt(zC); std(completed.phys)/sqrt(zP)];
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
% resulting matrix: rows = subjects; columns = mean RT for each handling time
compMatrixW = [];
compMatrixC = [];

for i = 1:zC
    for j = 1:3
        index = find(cMatrix(:,1,i)==handling(j));
        indexHandling = cMatrix(index,4,i); % array indicating the RT for a handling type
        indexChoice = cMatrix(index,3,i);
        if indexChoice(:)~=0 % if a participant accepted all handling trials
            compMatrixC(i,j) = 0;
        else    
            indexChoice = find(indexChoice==0);
            compMatrixC(i,j) = mean(indexHandling(indexChoice)); % should this be median, since RT?
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
% CHANGE TO WILCOXON (did a KS instead, see in the plotting section).
RT.cog = compMatrixC;
RT.wait = compMatrixW;
RT.cog(RT.cog(:,3)==0,:) = []; % delete subjects who accepted everything (since they don't have RTs)
RT.wait(RT.wait(:,3)==0,:) = []; % delete subjects who accepted everything (since they don't have RTs)
[RT.Tstat,RT.Pval,RT.CI,RT.Stats] = ttest2(compMatrixC,compMatrixW);

if prompt == 'y'
   figure
   x = [(mean(compMatrixC(:,1))) (mean(compMatrixW(:,1)));...
       (mean(compMatrixC(:,2))) (mean(compMatrixW(:,2)));...
       (mean(compMatrixC(:,3))) (mean(compMatrixW(:,3)))];
   e = [(std(compMatrixC(:,1))/sqrt(zC)) (std(compMatrixW(:,1))/sqrt(zW));...
       (std(compMatrixC(:,2))/sqrt(zC)) (std(compMatrixW(:,2))/sqrt(zW));...
       (std(compMatrixC(:,3))/sqrt(zC)) (std(compMatrixW(:,3))/sqrt(zW))];
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
   
   % Plotting the survival curve for all reaction times within each group
   % using a 95% confidence band, easily dismissible
   % IMPORTANT: If you don't censor at >2s, the wait group shows some
   % development later in the trial lengths. These are forced quits, and
   % thus won't be counted as decision variables. The data otherwise
   % follows the expected survival differences between groups, so it's fine
   % to leave the censoring at >2s.
   RT.cogVecAll = [];
   RT.waitVecAll = [];
   RT.physVecAll = [];
   
   for i = 1:11
       
        vectorCog = cMatrix(:,4,i);
        vectorCog = vectorCog(~isnan(vectorCog));
        vectorWait = wMatrix(:,4,i);
        vectorWait = vectorWait(~isnan(vectorWait));   
        vectorPhys = pMatrix(:,4,i);
        vectorPhys = vectorPhys(~isnan(vectorPhys));         
        RT.cogVecAll = [RT.cogVecAll; vectorCog];
        RT.waitVecAll = [RT.waitVecAll; vectorWait];
        RT.physVecAll = [RT.physVecAll; vectorPhys];
        
   end
   
   ecdf(RT.cogVecAll,'censoring',(RT.cogVecAll>2),'function','survivor','alpha',0.05,'bounds','on');
   ylim([0,1])
   hold on
   ecdf(RT.waitVecAll,'censoring',(RT.waitVecAll>2),'function','survivor','alpha',0.05,'bounds','on');
   ecdf(RT.physVecAll,'censoring',(RT.physVecAll>2),'function','survivor','alpha',0.05,'bounds','on');
   [RT.KS_stat,RT.KS_p] = kstest2(RT.cogVecAll,RT.waitVecAll);
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
   e = [(std(compMatrixC(:,1))/sqrt(zC)) (std(compMatrixW(:,1))/sqrt(zW)) 0;...
       (std(compMatrixC(:,2))/sqrt(zC)) (std(compMatrixW(:,2))/sqrt(zW)) 0;...
       (std(compMatrixC(:,3))/sqrt(zC)) (std(compMatrixW(:,3))/sqrt(zW)) 0];
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
   e = [(std(compMatrixC(:,1))/sqrt(zC)) (std(compMatrixW(:,1))/sqrt(zW)) 0;...
       (std(compMatrixC(:,2))/sqrt(zC)) (std(compMatrixW(:,2))/sqrt(zW)) 0;...
       (std(compMatrixC(:,3))/sqrt(zC)) (std(compMatrixW(:,3))/sqrt(zW)) 0];
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

% taking advantage of the compMatrix to update 'completed' with reward ttests
completed.rewardComparison.five = ttest2(compMatrixC(:,1),compMatrixW(:,1));
completed.rewardComparison.ten = ttest2(compMatrixC(:,2),compMatrixW(:,2));
completed.rewardComparison.twntyfive = ttest2(compMatrixC(:,3),compMatrixW(:,3));

clear i j Meas compMatrixC compMatrixW compMatrix b indexRwds

%% repeated measures before and after break for each condition separately
% graphing showed that differences will be very unlikely, no formal
% analysis done

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

%% logistic regression (nested models)
% see customLogistic.m for a description of the resulting subject summaries.
% that script also contains code for calculating the probabilities of
% acceptance.
%
% beta coefficient will be used as parameters in multilevel-modeling (or
% mixed)
% preliminary inspection using hand-calc'd likelihood ratio tests shows that the logistic regression for each
% subject benefits significantly from using both handling and
% reward amounts, but the interaction is not significant. Hand-calculated R-sq so
% far, so a formal inclusion in the code will be needed.

% get per-subject results in structs
subjWLog = struct('Summary',{},'nullDev',{});
subjCLog = struct('Summary',{},'nullDev',{});
% 3D matrix with all the data
wLogMatrix = [];
cLogMatrix = [];

for i = 1:zW
   [subjWLog(i),wLogMatrix(1:7,1:5,i)] = customLogistic(wMatrix(:,:,i));
end

clear i;

for i = 1:zC
   [subjCLog(i),cLogMatrix(1:7,1:5,i)] = customLogistic(cMatrix(:,:,i));
end

% ranksum between groups
% this is wrong, so I'm looking into mixed model analyses for this
% handling coeffs
% w and c become vectors of betas from the non-interaction logistic model,
% these vectors can be useful to plot, but not to ranksum

w(1:zW) = wLogMatrix(3,2,:);
c(1:zC) = cLogMatrix(3,2,:);
[LogH.Pval,LogH.Tstat,LogH.Stats] = ranksum(w,c);

clear c w

% reward coeffs
w(1:zW) = wLogMatrix(4,2,:);
c(1:zC) = cLogMatrix(4,2,:);
[LogR.Pval,LogR.Tstat,LogR.Stats] = ranksum(w,c);

% plot coefficients


clear wZ cZ i c w

% model OR overall (updated with physical)

wModelOR = [];
wModelPredicted = [];
cModelOR = [];
cModelPredicted = [];
pModelOR = [];
pModelPredicted = [];

% structs containing each subject's model results
SubjectCOR = struct('percentNow',{},'percentDelayed',{},'percentMissed',{},...
    'beta',{},'scale',{},'LL',{},...
    'LL0',{},'r2',{},'SOC',{},'prob',...
    {},'predictedChoice',{},'percentPredicted',{});

SubjectWOR = struct('percentNow',{},'percentDelayed',{},'percentMissed',{},...
    'beta',{},'scale',{},'LL',{},...
    'LL0',{},'r2',{},'SOC',{},'prob',...
    {},'predictedChoice',{},'percentPredicted',{});

SubjectPOR = struct('percentNow',{},'percentDelayed',{},'percentMissed',{},...
    'beta',{},'scale',{},'LL',{},...
    'LL0',{},'r2',{},'SOC',{},'prob',...
    {},'predictedChoice',{},'percentPredicted',{});

estimate the OC per subject
for i = 1:zC
    SubjectCOR(i) = foragingOCModel(cMatrix(:,3,i),cMatrix(:,6,i),cMatrix(:,2,i),cMatrix(:,1,i),0);
    cModelOR(i) = SubjectCOR(i).beta;
    cModelPredicted(i) = SubjectCOR(i).percentPredicted;

    plot(unique(SubjectCOR(i).prob));
end   

clear i 

for i = 1:zW
    SubjectWOR(i) = foragingOCModel(wMatrix(:,3,i),wMatrix(:,6,i),wMatrix(:,2,i),wMatrix(:,1,i),0);
    wModelOR(i) = SubjectWOR(i).beta;
    wModelPredicted(i) = SubjectWOR(i).percentPredicted;

    plot(unique(SubjectWOR(i).prob));    
end    

clear i

for i = 1:zP
    SubjectPOR(i) = foragingOCModel(pMatrix(:,3,i),pMatrix(:,6,i),pMatrix(:,2,i),pMatrix(:,1,i),0);
    pModelOR(i) = SubjectPOR(i).beta;
    pModelPredicted(i) = SubjectPOR(i).percentPredicted;

    plot(unique(SubjectPOR(i).prob));
end   

clear i 

cModelOR(isnan(cModelOR)) = [];
wModelOR(isnan(wModelOR)) = [];
pModelOR(isnan(pModelOR)) = [];
cModelPredicted(cModelPredicted==0) = [];
wModelPredicted(wModelPredicted==0) = [];
pModelPredicted(pModelPredicted==0) = [];

ModelOR.CognitiveAll = [cModelOR; cModelPredicted]';
ModelOR.WaitAll = [wModelOR; wModelPredicted]';
ModelOR.PhysicalAll = [pModelOR; pModelPredicted]';

% Rank-sumcomparing estimated opportunity rate values
[ModelORt.Pval,ModelORt.Tstat,ModelORt.Stats] = ranksum(ModelOR.CognitiveAll(:,1),ModelOR.WaitAll(:,1));

if prompt == 'y'
    
      dotDist([wModelOR', cModelOR', pModelOR'],{'Wait','Cognitive','Physical'})
    figure
    x = [mean(ModelOR.CognitiveAll(:,1)); mean(ModelOR.WaitAll(:,1))];
    e = [std(ModelOR.CognitiveAll(:,1))/sqrt(zC); std(ModelOR.WaitAll(:,1))/sqrt(zW)];
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

%%%%%%%%%%%%%%%%%%%%%%%
% The first portion is the hyperbolic + OC model. The problem with regular
% hyperbolic is that there is no "immediate amount" to compare to, and it
% thus has a poor fit. The hyp + OC model (after Fawcett's paper) predicted
% the cognitive group well, but not the wait group. It also had tiny betas
% that made plotting impossible.
% wModelORscale = [];
% wModelORk = [];
% wModelORgamma = [];
% wModelPredicted = [];
% cModelORscale = [];
% cModelORk = [];
% cModelORgamma = [];
% cModelPredicted = [];
% 
% % structs containing each subject's model results
% SubjectCHYP = struct('percentNow',{},'percentDelayed',{},'percentMissed',{},...
%     'gamma',{},'k',{},'scale',{},'LL',{},...
%     'LL0',{},'r2',{},'SVdelayed',{},'prob',...
%     {},'predictedChoice',{},'percentPredicted',{});
% 
% SubjectWHYP = struct('percentNow',{},'percentDelayed',{},'percentMissed',{},...
%     'gamma',{},'k',{},'scale',{},'LL',{},...
%     'LL0',{},'r2',{},'SVdelayed',{},'prob',...
%     {},'predictedChoice',{},'percentPredicted',{});
% 
% % figure
% % hold on
% % title('Probability of completion for cognitive, unspecified');
% % ylabel('Probability of completing trial')
% 
% for i = 1:11
%     SubjectCHYP(i) = foragingTest(cMatrix(:,3,i),cMatrix(:,6,i),cMatrix(:,2,i),cMatrix(:,1,i),0);
%     cModelORscale(i) = SubjectCHYP(i).scale;
%     cModelORk(i) = SubjectCHYP(i).k;
%     cModelORgamma(i) = SubjectCHYP(i).gamma;
%     cModelPredicted(i) = SubjectCOR(i).percentPredicted;
% 
% %     plot(unique(SubjectCOR(i).prob));
% end   
% 
% 
% clear i 
% 
% % figure
% % hold on
% % title('Probability of completion for wait, unspecified');
% % ylabel('Probability of completing trial')
% 
% for i = 1:11
%     SubjectWHYP(i) = foragingTest(wMatrix(:,3,i),wMatrix(:,6,i),wMatrix(:,2,i),wMatrix(:,1,i),0);
%     wModelORscale(i) = SubjectWHYP(i).scale;
%     wModelORk(i) = SubjectWHYP(i).k;
%     wModelORgamma(i) = SubjectWHYP(i).gamma;
%     wModelPredicted(i) = SubjectWHYP(i).percentPredicted;
% 
% %     plot(unique(SubjectWOR(i).prob));    
% end    
% 
% cModelORscale(isnan(cModelORscale)) = 1;
% cModelORk(isnan(cModelORk)) = [];
% cModelORgamma(isnan(cModelORgamma)) = [];
% wModelORscale(isnan(wModelORscale)) = 1;
% wModelORk(isnan(wModelORk)) = [];
% wModelORgamma(isnan(wModelORgamma)) = [];
% cModelPredicted(cModelPredicted==0) = [];
% wModelPredicted(wModelPredicted==0) = [];
% 
% ModelHYP.CognitiveAll = [cModelORscale;cModelORk;cModelORgamma;cModelPredicted]';
% ModelHYP.WaitAll = [wModelORscale;wModelORk;wModelORgamma;wModelPredicted]';
% 
% clear i cModelORk cModelPredicted wModelORk wModelPredicted cModelORgamma wModelORgamma cModelORscale wModelORscale
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This portion shows what I used to plot the probabilities. Again, hyp+OC
% not working well, but OC-alone is fine.
%
% xW = mean(ModelOR.WaitAll(:,1));
% xC = mean(ModelOR.CognitiveAll(:,1));
% 
% for i = 1:11
% yW(i) = SubjectWOR(i).beta;
% yC(i) = SubjectCOR(i).beta;
% end
% 
% figure;
% hold on
% probs(:,1) = 1 ./ ( 1 + exp(-(mean(yC) .* ([5:0.1:25] - (xC .* 2)))));
% probs(:,2) = 1 ./ ( 1 + exp(-(mean(yC) .* ([5:0.1:25] - (xC .* 10)))));
% probs(:,3) = 1 ./ ( 1 + exp(-(mean(yC) .* ([5:0.1:25] - (xC .* 14)))));
% plot(probs)
% ylim([0,1.2]);
% 
% probs(:,1) = 1 ./ ( 1 + exp(-(mean(yW) .* ([5:0.1:25] - (xW .* 2)))));
% probs(:,2) = 1 ./ ( 1 + exp(-(mean(yW) .* ([5:0.1:25] - (xW .* 10)))));
% probs(:,3) = 1 ./ ( 1 + exp(-(mean(yW) .* ([5:0.1:25] - (xW .* 14)))));
% plot(probs,'--')
% legend('Effort: 2s','Effort: 10s','Effort: 14s','Wait: 2s','Wait: 10s','Wait: 14s');
% 
% clear probs
%%%% And for the hyp+OC model (betas way too small, not working)
% 
% meanHYP.wScale = mean(ModelHYP.WaitAll(:,1));
% meanHYP.wK = mean(ModelHYP.WaitAll(:,2));
% meanHYP.wGamma = mean(ModelHYP.WaitAll(:,3));
% 
% meanHYP.cScale = mean(ModelHYP.CognitiveAll(:,1));
% meanHYP.cK = mean(ModelHYP.CognitiveAll(:,2));
% meanHYP.cGamma = mean(ModelHYP.CognitiveAll(:,3));
% 
% hypDisc = @(k,D) [5:1:25] ./ (1 + k.*D);
% 
% figure;
% hold on
% probs(:,1) = 1 ./ ( 1 + exp(-(meanHYP.cScale .* (hypDisc(meanHYP.cK,2) - (meanHYP.cGamma .* 2)))));
% probs(:,2) = 1 ./ ( 1 + exp(-(meanHYP.cScale .* (hypDisc(meanHYP.cK,10) - (meanHYP.cGamma .* 10)))));
% probs(:,3) = 1 ./ ( 1 + exp(-(meanHYP.cScale .* (hypDisc(meanHYP.cK,14) - (meanHYP.cGamma .* 14)))));
% plot(probs)
% ylim([0,1.2]);
% 
% probs(:,1) = 1 ./ ( 1 + exp(-(meanHYP.wScale .* (hypDisc(meanHYP.wK,2) - (meanHYP.wGamma .* 2)))));
% probs(:,2) = 1 ./ ( 1 + exp(-(meanHYP.wScale .* (hypDisc(meanHYP.wK,10) - (meanHYP.wGamma .* 10)))));
% probs(:,3) = 1 ./ ( 1 + exp(-(meanHYP.wScale .* (hypDisc(meanHYP.wK,14) - (meanHYP.wGamma .* 14)))));
% plot(probs,'--')
% legend('Effort: 2s','Effort: 10s','Effort: 14s','Wait: 2s','Wait: 10s','Wait: 14s');
% 
% clear probs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% Wilcoxon tests comparing ORs between groups per handling
[ModelORt.handlingComparison2.Pval,ModelORt.handlingComparison2.Tstat,ModelORt.handlingComparison2.Stats] = ranksum(ModelOR.CognitiveHandlingOR(:,1),ModelOR.WaitHandlingOR(:,1));
[ModelORt.handlingComparison10.Pval,ModelORt.handlingComparison10.Tstat,ModelORt.handlingComparison10.Stats] = ranksum(ModelOR.CognitiveHandlingOR(:,2),ModelOR.WaitHandlingOR(:,2));
[ModelORt.handlingComparison14.Pval,ModelORt.handlingComparison14.Tstat,ModelORt.handlingComparison14.Stats] = ranksum(ModelOR.CognitiveHandlingOR(:,3),ModelOR.WaitHandlingOR(:,3));

if prompt == 'y'
   figure
   x = [(mean(ModelOR.CognitiveHandlingOR(:,1))) (mean(ModelOR.WaitHandlingOR(:,1))) 2.49;...
       (mean(ModelOR.CognitiveHandlingOR(:,2))) (mean(ModelOR.WaitHandlingOR(:,2))) 0.51;...
       (mean(ModelOR.CognitiveHandlingOR(:,3))) (mean(ModelOR.WaitHandlingOR(:,3))) 0.72];
   e = [(std(ModelOR.CognitiveHandlingOR(:,1))/sqrt(zC)) (std(ModelOR.WaitHandlingOR(:,1))/sqrt(zW)) 0;
        (std(ModelOR.CognitiveHandlingOR(:,2))/sqrt(zC)) (std(ModelOR.WaitHandlingOR(:,2))/sqrt(zW)) 0;
        (std(ModelOR.CognitiveHandlingOR(:,3))/sqrt(zC)) (std(ModelOR.WaitHandlingOR(:,3))/sqrt(zW)) 0];
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

%% TEST VERSIONS

% get per-subject results in structs
subjWLog = struct('Summary',{},'nullDev',{});
subjCLog = struct('Summary',{},'nullDev',{});
% 3D matrix with all the data
wLogMatrix = [];
cLogMatrix = [];

[~,~,wZ] = size(wMatrix);
[~,~,cZ] = size(cMatrix);

for i = 1:wZ
   [subjWLog(i),wLogMatrix(1:7,1:5,i)] = customLogistic(wMatrix(:,:,i));
end

clear i;

for i = 1:cZ
   [subjCLog(i),cLogMatrix(1:7,1:5,i)] = customLogistic(cMatrix(:,:,i));
end


%%%%%%%
% extra
% plot per subject
% tomorrow: get the mean probabilities for each group, not mean coefficients

matrix = wLogMatrix; % wLogMatrix stores the log regression data for w and c
rwds = [-10:1:20];
probMatrixW = []; % column order: 2s, 10s, 14s
probMatrixC = [];
meanProbW = [];
meanProbC = [];

% calculate the probabilities for each handling time per subject
% remember that the intercepts are interpretable since the predictors were
% centered at the lowest values (i.e. handling = 2s). That's why the
% handling coefficients are multiplied by the handling times - 2s.
for i = 1:wZ
    probMatrixW(:,1,i) = 1./(1+exp(-(matrix(3,1,i) + (matrix(4,2,i).*rwds))));
    probMatrixW(:,2,i) = 1./(1+exp(-(matrix(3,1,i) + (matrix(4,2,i).*rwds) + (matrix(3,2,i).*8))));
    probMatrixW(:,3,i) = 1./(1+exp(-(matrix(3,1,i) + (matrix(4,2,i).*rwds) + (matrix(3,2,i).*12))));

    figure
    hold on
    plot(probMatrixW(:,1,i))
    plot(probMatrixW(:,2,i))
    plot(probMatrixW(:,3,i))
    ylabel('Probability of completing a trial')
    ylim([0 1.1]);
    xlabel('Rewards'); set(gca,'XTick', [11 16 31]); 
    set(gca,'XTickLabels',[5 10 25]);
    legend('Handling = 2s','Handling = 10s','Handling = 14s');
    
end

matrix = cLogMatrix;

for i = 1:cZ
    if isnan(matrix(1,1,i))
        probMatrixC(1:length(rwds),1:3,i) = ones(length(rwds),3);
    else
        probMatrixC(:,1,i) = 1./(1+exp(-(matrix(3,1,i) + (matrix(4,2,i).*rwds))));
        probMatrixC(:,2,i) = 1./(1+exp(-(matrix(3,1,i) + (matrix(4,2,i).*rwds) + (matrix(3,2,i).*8))));
        probMatrixC(:,3,i) = 1./(1+exp(-(matrix(3,1,i) + (matrix(4,2,i).*rwds) + (matrix(3,2,i).*12))));
    end

%     figure
%     hold on
%     plot(x)
%     plot(y)
%     plot(z)
%     ylabel('Probability of completing a trial')
%     ylim([0 1.1]);
%     xlabel('Rewards'); set(gca,'XTick', [11 16 31]); 
%     set(gca,'XTickLabels',[5 10 25]);
%     legend('Handling = 2s','Handling = 10s','Handling = 14s');
    
end

% two(:,:) = probMatrixW(:,1,:);
% ten(:,:) = probMatrixW(:,2,:);
% fourt(:,:) = probMatrixW(:,3,:);
% meanProbW(:,1) = mean(two,2);
% meanProbW(:,2) = mean(ten,2);
% meanProbW(:,3) = mean(fourt,2);
% 
% two(:,:) = probMatrixC(:,1,:);
% ten(:,:) = probMatrixC(:,2,:);
% fourt(:,:) = probMatrixC(:,3,:);
% meanProbC(:,1) = mean(two,2,'omitnan');
% meanProbC(:,2) = mean(ten,2,'omitnan');
% meanProbC(:,3) = mean(fourt,2,'omitnan');

clear wZ cZ i two ten fourt rwds






% %% model OR overall (test version)
% 
% wModelOR = [];
% wModelPredicted = [];
% cModelOR = [];
% cModelPredicted = [];
% 
% % structs containing each subject's model results
% SubjectCOR = struct('percentNow',{},'percentDelayed',{},'percentMissed',{},...
%     'beta',{},'scale',{},'LL',{},...
%     'LL0',{},'r2',{},'R',{},'RR',{},'OC',{},'prob',...
%     {},'predictedChoice',{},'percentPredicted',{});
% 
% SubjectWOR = struct('percentNow',{},'percentDelayed',{},'percentMissed',{},...
%     'beta',{},'scale',{},'LL',{},...
%     'LL0',{},'r2',{},'R',{},'RR',{},'OC',{},'prob',...
%     {},'predictedChoice',{},'percentPredicted',{});
% 
% % figure
% % hold on
% % title('Probability of completion for cognitive, unspecified');
% % ylabel('Probability of completing trial')
% 
% for i = 1:zC
%     SubjectCOR(i) = foragingTest(cMatrix(:,3,i),cMatrix(:,6,i),cMatrix(:,2,i),cMatrix(:,1,i),0);
%     cModelOR(i) = SubjectCOR(i).beta;
%     cModelPredicted(i) = SubjectCOR(i).percentPredicted;
% 
% %     plot(unique(SubjectCOR(i).prob));
% end   
% 
% hold off
% clear i 
% 
% % figure
% % hold on
% % title('Probability of completion for wait, unspecified');
% % ylabel('Probability of completing trial')
% 
% for i = 1:zW
%     SubjectWOR(i) = foragingTest(wMatrix(:,3,i),wMatrix(:,6,i),wMatrix(:,2,i),wMatrix(:,1,i),0);
%     wModelOR(i) = SubjectWOR(i).beta;
%     wModelPredicted(i) = SubjectWOR(i).percentPredicted;
% 
% %     plot(unique(SubjectWOR(i).prob));    
% end    
% 
% cModelOR(isnan(cModelOR)) = [];
% wModelOR(isnan(wModelOR)) = [];
% cModelPredicted(cModelPredicted==0) = [];
% wModelPredicted(wModelPredicted==0) = [];
% 
% ModelOR.CognitiveAll = [cModelOR;cModelPredicted]';
% ModelOR.WaitAll = [wModelOR;wModelPredicted]';
% 
% % T-test comparing estimated opportunity rate values
% [ModelORt.Pval,ModelORt.Tstat,ModelORt.Stats] = ranksum(ModelOR.CognitiveAll(:,1),ModelOR.WaitAll(:,1));
% 
% if prompt == 'y'
%     figure
%     x = [mean(ModelOR.CognitiveAll(:,1)); mean(ModelOR.WaitAll(:,1))];
%     e = [std(ModelOR.CognitiveAll(:,1)); std(ModelOR.WaitAll(:,1))];
%     b = bar(x,0.5);
%     b.FaceColor = [0,.45,.74];    
%     hold on
%     h = errorbar(x,e); set(h,'LineStyle','none'); set(h,'color','r');    
%     title('Average estimated opportunity rate','FontSize',24);
%     %ylim([0,1.5]); 
%     xlabel('Condition','FontSize',24); set(gca,'XTick',1:3); set(gca,'XTickLabels',unique(condition));set(gca,'FontSize',24);
%     ylabel('Mean opportunity cost','FontSize',24);
%     hold off
%     clear h x e b     
% end    
% 
% clear i cModelOR cModelPredicted wModelOR wModelPredicted
% 
% %% model OR per handling
% % this seems wrong: of course the OR will be different, because k will have
% % to be different between handling times. Better to z-score them.
% 
% wModelOR = [];
% wModelPredicted = [];
% cModelOR = [];
% cModelPredicted = [];
% 
% for i = 1:zC
%     for j = 1:3
%         index = find(cMatrix(:,1,i)==handling(j));
%         tempOutput = foragingTest(cMatrix(index,3,i),cMatrix(index,6,i),cMatrix(index,2,i),cMatrix(index,1,i),1);
%         cModelOR(i,j) = tempOutput.beta;
%         cModelPredicted(i,j) = tempOutput.percentPredicted;
%     end
% end   
% 
% clear i j
% 
% for i = 1:zW
%     for j = 1:3
%         index = find(wMatrix(:,1,i)==handling(j));
%         tempOutput = foragingTest(wMatrix(index,3,i),wMatrix(index,6,i),wMatrix(index,2,i),wMatrix(index,1,i),1);
%         wModelOR(i,j) = tempOutput.beta;
%         wModelPredicted(i,j) = tempOutput.percentPredicted;
%     end
% end    
% 
% ModelOR.CognitiveHandlingOR = cModelOR;
% ModelOR.WaitHandlingOR = wModelOR;
% ModelOR.CognitiveHandlingPR = cModelPredicted;
% ModelOR.WaitHandlingPR = wModelPredicted;
% 
% clear i cModelOR cModelPredicted wModelOR wModelPredicted tempOutput
% 
% % rmANOVA
% compMatrix = [ModelOR.CognitiveHandlingOR; ModelOR.WaitHandlingOR];
% rmORxHandling = struct('table',zeros(1,length(condition)));
% rmORxHandling.table = table(condition,compMatrix(:,1),compMatrix(:,2),compMatrix(:,3),...
% 'VariableNames',{'Condition','TwoSec','TenSec','FourteenSec'});
% Meas = dataset([1 2 3]','VarNames',{'Handling'});
% rmORxHandling.rm = fitrm(rmORxHandling.table,'TwoSec-FourteenSec~Condition','WithinDesign',Meas);
% rmORxHandling.summary = ranova(rmORxHandling.rm);
% rmORxHandling.TwovTen = ttest(compMatrix(:,1),compMatrix(:,2));
% rmORxHandling.TwovFourt = ttest(compMatrix(:,1),compMatrix(:,3));
% rmORxHandling.TenvFourt = ttest(compMatrix(:,2),compMatrix(:,3));
% 
% % T-Tests comparing ORs between groups per handling
% [ModelORt.handlingComparison2.Pval,ModelORt.handlingComparison2.Tstat,ModelORt.handlingComparison2.Stats] = ranksum(ModelOR.CognitiveHandlingOR(:,1),ModelOR.WaitHandlingOR(:,1));
% [ModelORt.handlingComparison10.Pval,ModelORt.handlingComparison10.Tstat,ModelORt.handlingComparison10.Stats] = ranksum(ModelOR.CognitiveHandlingOR(:,2),ModelOR.WaitHandlingOR(:,2));
% [ModelORt.handlingComparison14.Pval,ModelORt.handlingComparison14.Tstat,ModelORt.handlingComparison14.Stats] = ranksum(ModelOR.CognitiveHandlingOR(:,3),ModelOR.WaitHandlingOR(:,3));
% 
% if prompt == 'y'
%    figure
%    x = [(mean(ModelOR.CognitiveHandlingOR(:,1))) (mean(ModelOR.WaitHandlingOR(:,1))) 2.49;...
%        (mean(ModelOR.CognitiveHandlingOR(:,2))) (mean(ModelOR.WaitHandlingOR(:,2))) 0.51;...
%        (mean(ModelOR.CognitiveHandlingOR(:,3))) (mean(ModelOR.WaitHandlingOR(:,3))) 0.72];
%    e = [(std(ModelOR.CognitiveHandlingOR(:,1))) (std(ModelOR.WaitHandlingOR(:,1))) 0;
%         (std(ModelOR.CognitiveHandlingOR(:,2))) (std(ModelOR.WaitHandlingOR(:,2))) 0;
%         (std(ModelOR.CognitiveHandlingOR(:,3))) (std(ModelOR.WaitHandlingOR(:,3))) 0];
%    b = bar(x);
%    hold on
%    h1 = errorbar(x(:,1),e(:,1));
%    h2 = errorbar(x(:,2),e(:,2));
%    h3 = errorbar(x(:,3),e(:,3));
%    set(h1,'LineStyle','none'); set(h1,'color','r'); set(h1,'XData',[0.77,1.77,2.77]);
%    set(h2,'LineStyle','none'); set(h2,'color','r'); set(h2,'XData',[1,2,3]);
%    set(h3,'LineStyle','none'); set(h3,'color','r'); set(h3,'XData',[1.23,2.23,3.23]);
%    title({'Mean subjective-ORs for each handling time','Cognitive vs Wait'},'FontSize',24);
%    legend('Cognitive','Wait','Smallest Opt.');set(gca,'FontSize',24);
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
%
% %% NEW VERSION WITHOUT 25 PTS (BETTER, BUT NO CIGAR)
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
%
%%%%%%%%%%%%%%%
% 
% When I tried to emulate a hyperbolic discounting and OC model similar to
% Fawcett's OC 1-choice version (minus alpha, since outcome here was
% certain).
% 
% wModelORscale = [];
% wModelORk = [];
% wModelORgamma = [];
% wModelPredicted = [];
% cModelORscale = [];
% cModelORk = [];
% cModelORgamma = [];
% cModelPredicted = [];
% 
% % structs containing each subject's model results
% SubjectCHYP = struct('percentNow',{},'percentDelayed',{},'percentMissed',{},...
%     'gamma',{},'k',{},'scale',{},'LL',{},...
%     'LL0',{},'r2',{},'SVdelayed',{},'prob',...
%     {},'predictedChoice',{},'percentPredicted',{});
% 
% SubjectWHYP = struct('percentNow',{},'percentDelayed',{},'percentMissed',{},...
%     'gamma',{},'k',{},'scale',{},'LL',{},...
%     'LL0',{},'r2',{},'SVdelayed',{},'prob',...
%     {},'predictedChoice',{},'percentPredicted',{});
% 
% % figure
% % hold on
% % title('Probability of completion for cognitive, unspecified');
% % ylabel('Probability of completing trial')
% 
% for i = 1:11
%     SubjectCHYP(i) = foragingTest(cMatrix(:,3,i),cMatrix(:,6,i),cMatrix(:,2,i),cMatrix(:,1,i),0);
%     cModelORscale(i) = SubjectCHYP(i).scale;
%     cModelORk(i) = SubjectCHYP(i).k;
%     cModelORgamma(i) = SubjectCHYP(i).gamma;
%     cModelPredicted(i) = SubjectCOR(i).percentPredicted;
% 
% %     plot(unique(SubjectCOR(i).prob));
% end   
% 
% 
% clear i 
% 
% % figure
% % hold on
% % title('Probability of completion for wait, unspecified');
% % ylabel('Probability of completing trial')
% 
% for i = 1:11
%     SubjectWHYP(i) = foragingTest(wMatrix(:,3,i),wMatrix(:,6,i),wMatrix(:,2,i),wMatrix(:,1,i),0);
%     wModelORscale(i) = SubjectWHYP(i).scale;
%     wModelORk(i) = SubjectWHYP(i).k;
%     wModelORgamma(i) = SubjectWHYP(i).gamma;
%     wModelPredicted(i) = SubjectWHYP(i).percentPredicted;
% 
% %     plot(unique(SubjectWOR(i).prob));    
% end    
% 
% cModelORscale(isnan(cModelORscale)) = 1; % since the Beta scale is having no effect
% cModelORk(isnan(cModelORk)) = [];
% cModelORgamma(isnan(cModelORgamma)) = [];
% wModelORscale(isnan(wModelORscale)) = 1;
% wModelORk(isnan(wModelORk)) = [];
% wModelORgamma(isnan(wModelORgamma)) = [];
% cModelPredicted(cModelPredicted==0) = [];
% wModelPredicted(wModelPredicted==0) = [];
% 
% ModelHYP.CognitiveAll = [cModelORscale;cModelORk;cModelORgamma;cModelPredicted]';
% ModelHYP.WaitAll = [wModelORscale;wModelORk;wModelORgamma;wModelPredicted]';
%
%%%%%%%%%%%%%%%
% How I created the 3d matrices
% Rows are rewards and columns handling times
% Tip for errors: std(wCompletion(1,1,:))./sqrt(11)
%combinedMatrixAll = [optimal(:,1) cog(:,1) wait(:,1) optimal(:,2) cog(:,2) wait(:,2) optimal(:,3) cog(:,3) wait(:,3)]
%errorMatrixAll = [errorMatrixO(:,1) errorMatrixC(:,1) errorMatrixW(:,1)  errorMatrixO(:,2) errorMatrixC(:,2) errorMatrixW(:,2) errorMatrixO(:,3) errorMatrixC(:,3) errorMatrixW(:,3)]
% 
% bar([[[1 0.91 0.6] [0 0.35 0.46] [0 0.28 0.02]];[[1 1 0.95] [1 0.8 0.53] [0 0.51 0.14]];[[1 1 0.99] [1 1 0.99] [1 0.99 0.93]]])
% x2 = ([[[combinedMatrixAll(:,3)] [combinedMatrixAll(:,2)] [combinedMatrixAll(:,1)]];...
%     [[combinedMatrixAll(:,6)] [combinedMatrixAll(:,5)] [combinedMatrixAll(:,4)]];...
%     [[combinedMatrixAll(:,9)] [combinedMatrixAll(:,8)] [combinedMatrixAll(:,7)]]]);
% 
% e2 = ([[[errorMatrixAll(:,3)] [errorMatrixAll(:,2)] [errorMatrixAll(:,1)]];...
%     [[errorMatrixAll(:,6)] [errorMatrixAll(:,5)] [errorMatrixAll(:,4)]];...
%     [[errorMatrixAll(:,9)] [errorMatrixAll(:,8)] [errorMatrixAll(:,7)]]]);
% 
% bar(x2)
% hold on
% h1 = errorbar(x2(:,1),e2(:,1));
% h2 = errorbar(x2(:,2),e2(:,2));
% h3 = errorbar(x2(:,3),e2(:,3));
% set(h1,'LineStyle','none'); set(h1,'color','r'); %set(h1,'XData',[0.77,1.77,2.77]);
% set(h2,'LineStyle','none'); set(h2,'color','r'); %set(h2,'XData',[1,2,3]);
% set(h3,'LineStyle','none'); set(h3,'color','r'); %set(h3,'XData',[1.23,2.23,3.23]);
% title({'Proportion completed for each handling time','Cognitive vs Wait'},'FontSize',24);
% ylim([0,1.2])
%
% put little bars where the optimal decision lies (for bar graph above
% figure
% xlim([0,10])
% ylim([0,1.2])
% hold on
% for i = 1:9
%     vector = [(i-0.2) (i+0.2)];
%     yes = [1 1];
%     no = [0 0];
%     if ismember(i,[4 7 8])
%        plot(vector,no,'Color',[0 0.45 0.74],'LineWidth',2.5)
%     else
%        plot(vector,yes,'Color',[0 0.45 0.74],'LineWidth',2.5)
%     end
% end