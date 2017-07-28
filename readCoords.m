function [coords,nSubjects] = readCoords(coordfile)
% read an ALE-formatted file listing coordinates of activation peaks
% Input:
%   coordfile is the path to the input text file
% Output:
% 	coords: a cell array, where each entry corresponds to a study and in 
%       turn contains a cell array of coordinate triples.
%   nSubjects: a vector holding the number of subjects in each study

coords = {};
nSubjects = [];
fid = fopen(coordfile);
fdata = textscan(fid,'%s','Delimiter','\n');
% b{1} is a cell array with an entry for each line in the text file
studyNum = 0;
coordNum = 0;
readingCoords = false;
nLines = length(fdata{1});
for fl = 1:nLines % for each line
    % each new study begins with the number of subjects
    if ~readingCoords && ~isempty(strfind(fdata{1}{fl},'Subjects='))
        studyNum = studyNum+1;
        coordNum = 0;
        strBegin = strfind(fdata{1}{fl},'Subjects=');
        % the number itself begins 9 characters in
        nSubjects(studyNum) = str2double(fdata{1}{fl}(strBegin+9:end));
        readingCoords = true;
    elseif readingCoords
        if isempty(fdata{1}{fl}) || strcmp(fdata{1}{fl}(1:2),'//')
            % blank line (or double slash) marks the end of a study
            readingCoords = false;
        else
            % this cell contains coordinates
            coordNum = coordNum+1;
            coords{studyNum}{coordNum,1}(1,1:3) = str2num(fdata{1}{fl}); %#ok<ST2NM>
        end
    end
end
fclose(fid);


