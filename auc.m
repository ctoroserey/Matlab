function AUC = auc(Subject_matrix)
% based on Myerson et al., 2001
% this assumes that the y-axis uses a proportion, thus making normalization unnecessary. 
% In futurue implementations add a row that normalizes values just like it
% was done with ratios.

    mainMtrx = Subject_matrix;
    mainSize = size(mainMtrx); % to use as reference
    numSubj = mainSize(1,3); % number of subjects
    for i = 1%:numSubj
        
        subjMtrx = mainMtrx(:,:,i); % retrieve the subject's data
        ratio = [13/2, 10/5, 5/10, 2/13]; % '0' added for because the equation demands it
        maxPos = max(ratio); % the maximum ratio possible, used to normalize delay values
        ratio = [((13/2)/maxPos),((10/5)/maxPos),((5/10)/maxPos),((2/13)/maxPos)]; % normalize it according to paper
        curveAll = subjMtrx(:,1)';
        plot(curveAll(2:end));
        equation = 0;
        for k = 1:length(ratio)-1
            equation = equation + ((ratio(k) - ratio(k+1)).*((curveAll(k)+curveAll(k+1))/2));
            k = k + 1;
        end    
        
        i = i + 1;
        
    end    
    AUC = equation;
end
