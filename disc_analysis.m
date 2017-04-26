% Getting ideas for plotting discounting curves for different participants.
% Hopefully this will turn into an analysis script that can be combined
% with logread.m

mtrxSize = size(Matrix); % size of the matrix containing every subject's data
numSubj = mtrxSize(1,3); % number of subjects
numColmns = mtrxSize(1,2); % number of columns (usually 5)
% final proportions for everything, for all subjects
finalSubj = zeros(3,4); % final array with all the discounting rates
for i = 1:numSubj % iterate for each participant
    
    mtrxSubj = Matrix(:,:,i); % extract the matrix for the first subject
    mtrxSubj = sortrows(mtrxSubj,1); % sort the matrix by reward condition
    numTrials = length(mtrxSubj); % number of trial
    % final proportion values for each reward amount
    finalFive = [];
    finalFift = [];
    finalTwnt = [];
    finalAll = []; % overall discounting rate
    % reward amount arrays
    fiveCents = []; 
    fiftCents = []; 
    twntCents = [];
    
    % divide ratio blocks into arrays, and assign to variables above
    for k = 1:numTrials 
        if mtrxSubj(k,2) == 0.05
            fiveCents(end+1,1:numColmns) = mtrxSubj(k,1:numColmns);
        elseif mtrxSubj(k,2) == 0.15
            fiftCents(end+1,1:numColmns) = mtrxSubj(k,1:numColmns);
        elseif mtrxSubj(k,2) == 0.25
            twntCents(end+1,1:numColmns) = mtrxSubj(k,1:numColmns);
        end        
        k = k + 1;
    end
   
    % calculating the proportion for each reward amount over each ratio
    ratios = [13,10,5,2]; 
    for j = 1:length(ratios)
        range = find(fiveCents(:,1) == ratios(j)); % where each travel/handling ratio block is
        finalFive(j) = sum(fiveCents(range(1):range(end),3)==1)./length(range); % proportion complete for the block
        
        range = find(fiftCents(:,1) == ratios(j)); % where each travel/handling ratio block is
        finalFift(j) = sum(fiftCents(range(1):range(end),3)==1)./length(range); % proportion complete for the block
        
        range = find(twntCents(:,1) == ratios(j)); % where each travel/handling ratio block is
        finalTwnt(j) = sum(twntCents(range(1):range(end),3)==1)./length(range); % proportion complete for the block   
        
        range = find(mtrxSubj(:,1) == ratios(j)); % where each travel/handling ratio block is
        finalAll(j) = sum(mtrxSubj(range(1):range(end),3)==1)./length(range); % proportion complete for the block 
        
        j = j + 1;
    end
    
    % finally, group everything into 1 array for the subject
    % the order of the rows is: 13_2,10_5,5_10,2_13
    finalSubj(1:length(finalAll),1:4,i) = [finalAll', finalFive', finalFift', finalTwnt'];
    %plot(finalSubj) % good for visualizing data
    
    i = i + 1;
    
end    