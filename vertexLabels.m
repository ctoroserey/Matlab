function [labels, labelIndex, labelVertices] = vertexLabels(inputFile,fileName)
%% Associate a label to the corresponding vertex from the annotation file.
% Outputs file with a vector of labels.

[fileVertices, fileLabel, fileTable] = read_annotation(inputFile);

% get vertices just in case
labelVertices = fileVertices;

% label matching for visual checks
labels = num2cell(fileTable.table(:,5));
labelIndex = [fileTable.struct_names labels];

for i = 1:length(fileLabel)
    vertex = fileLabel(i);
    if vertex == 16777215
    else    
        index = find(fileTable.table(:,5)==vertex);
        finalLabels(i) = labelIndex(index,1); % labeling all vertices
    end    
end

labels = finalLabels';
% cell2csv(strcat(fileName,'.csv'),finalLabels');

fileID = fopen(strcat(fileName,'.csv'),'w');
formatSpec = '%s\n';
for row = 1:length(labels)
    fprintf(fileID,formatSpec,labels{row,:});
end
fclose(fileID);

end