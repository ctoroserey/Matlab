function [resultsTable, ROIs, alpha,pval] = permutCompare(nullDist,condOne,condTwo,labels,type)
% Type refers to prop comparisons ('prop') or chi-square ('chi2')
% For chi square, the vectors are the raw numbers (e.g. countDEC), not proportions
   
    alpha = prctile(nullDist,95);
    
    if type == 'prop'
        tempCompare = abs(condOne - condTwo);
        thresh = tempCompare > alpha;
        ROIs = labels(thresh);
        pval = length(ROIs)/length(nullDist);
        resultsTable = [labels num2cell(tempCompare) num2cell(thresh)];
    elseif type == 'chi2'
        oneLength = input('Number of observations for the first condition?'); % e.g. how many studies are included in this condition?
        twoLength = input('Number of observations for the second condition?');
        chistats = zeros(length(labels),1);
        pval = zeros(length(labels),1);
        for l = 1:length(labels)
           [~,~,chistats(l),~] = prop_test([condOne(l) condTwo(l)],[oneLength twoLength],false);
           pval(l) = 1 - (sum(nullDist<chistats(l))/length(nullDist));
           if ((condOne(l)/oneLength) - (condTwo(l)/twoLength)) < 0
               chistats(l) = -1 .* chistats(l);
           end
        end    
        thresh = pval <= 0.05;
        ROIs = labels(thresh);
        resultsTable = [labels num2cell(chistats) num2cell(pval) num2cell(thresh)];
    else
        disp('ERROR: unspecified type...')
    end
    
    figure
    hold on
    histogram(nullDist)
    plot(ones(1,100).*alpha,1:200)
    figure
    plot(ksdensity(nullDist))
    
    
%     Notes:
%     To look at the uncorrected values, use the uncorrected null dist (_unc), plus the following
%     X = [resultsTable(:,1:2) prctile(nullDist_unc,95,2)];
%     X(:,4) = X(:,2) >= X(:,3);
% 
%     To reduce the sample space to DMN rois, I used the following (example):
%     index = ismember(Glasser,DMN_labels);
%     countNEG_dmnlbls = countNEG(index);
%     countPOS_dmnlbls = countPOS(index);
%     ...
end
