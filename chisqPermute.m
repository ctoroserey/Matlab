function [dist,uncorrected,roiTable] = chisqPermute(condOne,condTwo,labels,perms)
%% Performs a permutation analysis of chi-squared tests for each label
% between conditions. 
%
%   - dist: the final null distribution
%
%   - uncorrected: individual null distributions for each label
%
%   - roiTable: in case you want to check what areas had the largest statistic per permutation.
%
% Use permutCompare() to use the computed null distribution for the
% per-label chi-squared test of the real data.
%
% Example input: [null_DMNvsPOS_dmnlbls,null_DMNvsPOS_dmnlbls_unc,roiTable.DMNvsPOS_dmnlbls] = chisqPermute(DMN,POS,DMN_labels,5000);
%
% Claudio Aug-2017

%% Code
    oneLength = length(condOne);
    twoLength = length(condTwo);
    totalLength = oneLength + twoLength;
    studyList(1:oneLength) = condOne;
    studyList((1 + oneLength):totalLength) = condTwo;

    lbls = string(labels);
    dist = zeros(perms,1);
    roi = [];
    roiTable = [];
    uncorrected = [];
    
    for i = 1:perms
        
        randPerm = randperm(totalLength);
        randOne = [];
        randTwo = [];
        countOne = zeros(length(lbls),1);
        countTwo = zeros(length(lbls),1);
        chistats = zeros(length(lbls),1);
        
        % resample each group
        for j = randPerm(1:oneLength)
           randOne = [randOne ; studyList(j).labels];
        end
        for k = randPerm((oneLength + 1):totalLength)
           randTwo = [randTwo ; studyList(k).labels]; 
        end
        
        randOne = string(randOne);
        randTwo = string(randTwo);
        
        % actual permutation
        for l = 1:length(lbls)
           countOne(l) = sum(randOne == lbls(l)); 
           countTwo(l) = sum(randTwo == lbls(l));
           [~,~,chistats(l),~] = prop_test([countOne(l) countTwo(l)],[oneLength twoLength],false);
        end
        
        indx = find(chistats == max(chistats));
        roi = [roi ; lbls(indx)];
        uncorrected(1:length(lbls),i) = chistats;
        dist(i) = max(chistats);
        
    end
    
    for k = 1:length(lbls)
        roiTable(k) = sum(roi == lbls(k));
    end
    
    roiTable = [labels num2cell(roiTable)'];
    roiTable = sortrows(roiTable,2);
    
    beep
    
end


