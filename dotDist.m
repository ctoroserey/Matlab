function [dotPlot] = dotDist(Matrix,labels)
% Matrix should contain the distributions of interest organized by column.
% example: dotDist(trying,{'Effort Handling','Wait Handling','Effort Reward','Wait Reward'})

    [~,nCols] = size(Matrix);
    dotPlot = figure;
    hold on
    xlim([0,(nCols+1)]);
    set(gca,'XTick', 1:nCols); set(gca,'XTickLabels',labels)
    hline = refline(0,0);
    hline.LineStyle = '--';
    hline.Color = [0 0 0];
    
    for i = 1:nCols
        index = ~isnan(Matrix(:,i));
        col = sort(Matrix(index,i));
        nObs = length(col);
        jitter = randperm(nObs)./100; % to jitter the placement of the dots around each integer
        scatter(((ones(1,nObs).*i)+jitter)',col); 
    end
end