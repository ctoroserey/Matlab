function [resultsTable, ROIs, alpha, pval] = permutCompare(nullDist, condOne, condTwo,labels)
    alpha = prctile(nullDist,95);
    tempCompare = abs(condOne - condTwo);
    thresh = tempCompare > alpha;
    ROIs = labels(thresh);
    pval = length(ROIs)/length(nullDist);
    resultsTable = [labels num2cell(tempCompare) num2cell(thresh)];
    
    figure
    histfit(nullDist)
    % title({'Null distribution of ?????','5000 iterations'})
end