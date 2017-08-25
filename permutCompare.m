function [resultsTable, ROIs, alpha, pval] = permutCompare(nullDist,condOne,condTwo,labels,type)
    % type refers to prop comparisons ('prop') or chi-square ('chis')
    % for chi square, the vectors are the raw numbers, not proportions
    
    alpha = prctile(nullDist,95);
    
    if type == 'prop'
        tempCompare = abs(condOne - condTwo);
        thresh = tempCompare > alpha;
        ROIs = labels(thresh);
        pval = length(ROIs)/length(nullDist);
        resultsTable = [labels num2cell(tempCompare) num2cell(thresh)];
    elseif type == 'chis'
        oneLength = input('Number of observations for the first condition?');
        twoLength = input('Number of observations for the second condition?');
        chistats = zeros(length(labels),1);
        pval = zeros(length(labels),1);
        for l = 1:length(labels)
           [~,~,chistats(l),~] = prop_test([condOne(l) condTwo(l)],[oneLength twoLength],false);
           pval(l) = sum(nullDist<chistats(l))/length(nullDist);
        end    
        thresh = chistats > alpha;
        ROIs = labels(thresh);
        resultsTable = [labels num2cell(chistats) num2cell(thresh) num2cell(pval)];
    else
        disp('ERROR: unspecified type...')
    end
    
    figure
    histfit(nullDist)
    % title({'Null distribution of ?????','5000 iterations'})
end