%% This script is meant to open the .csv logs from the effort tasks.
% It will put every subject datas into a 3D matrix, where the z coordinate
% denotes subject number (in the order displayed in the resulting "files"
% cell element.
%
% The order of the columns from the csv files should be (except for cog): 
% Handling time, Expected Reward, Choice, RT, Total Time
%
% IMPORTANT: if the data comes from the cognitive task, it will transform
% the log into a matrix just like the waiting task one. This is because the
% cognitive version logs the per-trial performance as well.

% current path: /Users/ctoro/git_clones/lab_tasks/Claudio/SONA/cog/data

%% ask for the type of data, and where it is (default in SONA folder)

prompt = input('Is this wait (w) or cognitive (c) data?','s');
pathq = input('Do you want to enter a new path? (y/n)','s');

if pathq == 'y'
    newpath = input('Paste full path here:','s');
    cd(newpath)
else 
    cd '/Users/Claudio/GitHub/Psychopy/effort_paradigms/SONA/wait/data/'; % set current directory to the log folder
end

%% matrix with all subjects from csv logs

if prompt == 'w'
    
    files = dir('*.csv');
    wfiles = {files(~[files.isdir]).name}'
    Matrix = [];

    for i = 1:length(wfiles)

        fileArray = load(wfiles{i});
        fileArray(fileArray(:,1)==0,:) = []; % remove the break row, otherwise it conflicts with NaN replacement below
        sze = size(fileArray);
        rows = sze(1);
        columns = sze(2);
        Matrix(1:rows,1:columns,i) = fileArray;

    end

elseif prompt == 'c'
    %cd '/Users/Claudio/GitHub/Psychopy/effort_paradigms/SONA/cog/data/'; % set current directory to the log folder 
    files = dir('*.csv');
    cfiles = {files(~[files.isdir]).name}'
    Matrix = [];

    for i = 1:length(cfiles)

        fileArray = readtable(cfiles{i});
        fileArray = table2array(fileArray(:,1:6));
        index = find(fileArray(:,4)==0);
        fileArray = fileArray(index,:);
        fileArray = [fileArray(:,1:3) fileArray(:,5:6)];
        sze = size(fileArray);
        rows = sze(1);
        columns = sze(2);
        Matrix(1:rows,1:columns,i) = fileArray;

    end
end

%% convert extra rows (currently = 0) to NaN
% the problem was that quit = 0 from psychopy, so I needed a way to convert
% the zeros patching extra rows without affecting real values

width = size(Matrix);

if length(width) < 3 
    col = Matrix(:,1);
        
    if col(end)==0
        extras = find(col==0); % get indexes for extras
        Matrix(extras(1):extras(end),:) = NaN; % convert to NaN
    end    

else      
    for j = 1:width(3)

        col = Matrix(:,1,j); % grab the delay column for subject j

        if col(end)==0
            extras = find(col==0); % get indexes for extras
            Matrix(extras(1):extras(end),:,j) = NaN; % convert to NaN
        end
    end    
end

%% add prefix 'c' for cog and 'w' for waiting

if prompt == 'c'
    cMatrix = Matrix;
    clearvars -except wfiles cfiles cMatrix wMatrix
else
    wMatrix = Matrix;
    clearvars -except wfiles cfiles wMatrix cMatrix
end






