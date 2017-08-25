function [dist,roiTable] = chisqPermute(condOne,condTwo,labels,perms)

    oneLength = length(condOne);
    twoLength = length(condTwo);
    totalLength = oneLength + twoLength;
    studyList(1:oneLength) = condOne;
    studyList((1 + oneLength):totalLength) = condTwo;

    lbls = string(labels);
    dist = zeros(perms,1);
    roi = [];
    roiTable = [];
    
    for i = 1:perms
        randPerm = randperm(totalLength);
        randOne = [];
        randTwo = [];
        countOne = zeros(length(lbls),1);
        countTwo = zeros(length(lbls),1);
        chistats = zeros(length(lbls),1);
        
        for j = randPerm(1:oneLength)
           randOne = [randOne ; studyList(j).labels];
        end
        for k = randPerm((oneLength + 1):totalLength)
           randTwo = [randTwo ; studyList(k).labels]; 
        end
        randOne = string(randOne);
        randTwo = string(randTwo);
        for l = 1:length(lbls)
           countOne(l) = sum(randOne == lbls(l)); 
           countTwo(l) = sum(randTwo == lbls(l));
           [~,~,chistats(l),~] = prop_test([countOne(l) countTwo(l)],[oneLength twoLength],false);
        end
        
        indx = find(chistats == max(chistats));
        roi = [roi ; lbls(indx)];
        dist(i) = max(chistats);
        %mtrx(i).table = table(countOne',countTwo','VariableNames',{'countOne','countTwo'},'RowNames',labels);
        
    end
    
    for k = 1:length(lbls)
        roiTable(k) = sum(roi == lbls(k));
    end
    
    roiTable = [labels num2cell(roiTable)'];
    roiTable = sortrows(roiTable,2);
end


