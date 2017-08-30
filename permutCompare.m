function [resultsTable, ROIs, alpha, pval] = permutCompare(nullDist,condOne,condTwo,oneLength,twoLength,labels,type)
    % type refers to prop comparisons ('prop') or chi-square ('chi2')
    % for chi square, the vectors are the raw numbers, not proportions
    
    alpha = prctile(nullDist,95);
    
    if type == 'prop'
        tempCompare = abs(condOne - condTwo);
        thresh = tempCompare > alpha;
        ROIs = labels(thresh);
        pval = length(ROIs)/length(nullDist);
        resultsTable = [labels num2cell(tempCompare) num2cell(thresh)];
    elseif type == 'chi2'
        %oneLength = input('Number of observations for the first condition?');
        %twoLength = input('Number of observations for the second condition?');
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
    histfit(nullDist)
    % title({'Null distribution of ?????','5000 iterations'})
end
