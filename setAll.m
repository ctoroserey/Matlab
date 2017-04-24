function [newMatrix] = setAll(allMatrix)
%% load the subject matrix (post 'logread') to have all its subjects go through 
% subsetup.m
matrix = allMatrix;
sze = size(allMatrix);
newMatrix = NaN(sze(1),sze(2)+2,sze(3));
size(newMatrix);
    for i = 1:sze(3)
        tempMatrix = subsetup(matrix(:,:,i));
        tempsize = size(tempMatrix);
        newMatrix(1:tempsize(1),:,i) = tempMatrix;
    end
end