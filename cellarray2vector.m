function [vec] = cellarray2vector(cellarray)
    %%% This function applies only to coordinate systems. It assumes the
    %%% cell array will have in each cell a single xyz coordinate that will
    %%% then be assigned to matrix 'x'.
    
    y = size(cellarray{1}); % gets the size of the first element on the list
    a = y(1,1); % determines the number of rows in each cell. Added for future reference so cells with >1 rows can be taken
    b = y(1,2); % determines the number of columns in each cell
    x = [a, b]; % creates a matrix with dimensions equal to the size of each cell
    
    for i = 1:length(cellarray)
        x(i,1:b) = cellarray{i};
        i = i + 1;
    end
    
    vec = x;
    