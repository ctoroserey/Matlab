
% add error bars to a bar3 plot
% this version will need to be modified in the future to be flexible
% you would basically create matrix inputs to replace combinedMatrixAll and
% errorMatrixAll.

for col = 1:9
   for row = 1:3  
        centerZ = combinedMatrixAll(row,col);
        lowSE = centerZ - errorMatrixAll(row,col);
        highSE = centerZ + errorMatrixAll(row,col);
        p = plot3([col, col, col], [row, row, row], [lowSE, centerZ, highSE]);
        p.LineWidth = 3.0;
        p.Color = [0.35 0.35 0.35];
   end
end

