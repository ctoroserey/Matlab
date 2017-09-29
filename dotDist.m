function [dotPlot] = dotDist(Matrix,labels)
% Matrix should contain the distributions of interest organized by column.
% example: dotDist(trying,{'Effort Handling','Wait Handling','Effort Reward','Wait Reward'})

    [~,nCols] = size(Matrix);
    dotPlot = figure;
    hold on
    xlim([0,(nCols+1)]);
    set(gca,'XTick', 1:nCols); set(gca,'XTickLabels',labels)
    allMeans = [];
    
    for i = 1:nCols
        index = ~isnan(Matrix(:,i));
        col = sort(Matrix(index,i));
        allMeans(i) = mean(col);
        nObs = length(col);
        jitter = [0 (randperm(nObs-2)./100) 0]; % to jitter the placement of the dots around each integer
        scatter(((ones(1,nObs).*i)+jitter)',col); 
    end
    %hline = refline(0,round(mean(allMeans)));
    %hline.LineStyle = '--';
    %hline.Color = [0 0 0];    
end