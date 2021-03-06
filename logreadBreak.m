%% This script is meant to open the .csv logs from the effort tasks.
% It will put every subject's data into a 3D matrix, where the z coordinate
% denotes subject number (in the order displayed in the resulting "files"
% cell element.
%
% The order of the columns from the csv files should be (except for cog): 
% Handling time, Expected Reward, Choice, RT, Total Time
%
% IMPORTANT: if the data comes from the cognitive task, it will transform
% the log into a matrix just like the waiting task one. This is because the
% cognitive version logs the per-trial performance as well.

% work path: /Users/ctoro/git_clones/lab_tasks/Claudio/SONA/cog/data
% personal path: /Users/Claudio/GitHub/lab_tasks/Claudio/SONA/cog/data


%% ask for the type of data, and where it is (default in SONA folder)

prompt = input('Is this wait (w), physical (p), or cognitive (c) data?','s');
pathq = input('Are you at work (w), on the go (p), or want a different path(y)?','s');
% pathq = input('Do you want to enter a new path? (y/n)','s');

if pathq == 'y'
    newpath = input('Paste full path here:','s');
    cd(newpath)
elseif pathq == 'w'
    if prompt == 'w'
        cd '/Users/ctoro/git_clones/lab_tasks/Claudio/SONA/wait/data'
    elseif prompt == 'c'
        cd '/Users/ctoro/git_clones/lab_tasks/Claudio/SONA/cog/data'
    else
        cd '/Users/ctoro/git_clones/lab_tasks/Claudio/SONA/phys/data'
    end
elseif pathq == 'p'
    if prompt == 'w'
        cd '/Users/Claudio/GitHub/lab_tasks/Claudio/SONA/wait/data'
    elseif prompt == 'c'
        cd '/Users/Claudio/GitHub/lab_tasks/Claudio/SONA/cog/data'
    else
        cd '/Users/Claudio/GitHub/lab_tasks/Claudio/SONA/phys/data'
    end    
end

%% matrix with all subjects from csv logs

if prompt == 'w'
    
    files = dir('*.csv');
    wfiles = {files(~[files.isdir]).name}'
    Matrix = [];

    for i = 1:length(wfiles)

        fileArray = load(wfiles{i});
        fileArray(fileArray(:,1)==0,:) = 99; % remove the break row, otherwise it conflicts with NaN replacement below
        [rows,columns] = size(fileArray);
        Matrix(1:rows,1:columns,i) = fileArray;

    end

elseif prompt == 'p'
    
    files = dir('cost*7_log.csv');
    pfiles = {files(~[files.isdir]).name}'
    Matrix = [];

    for i = 1:length(pfiles)

        fileArray = load(pfiles{i});
        fileArray(fileArray(:,1)==0,:) = 99; % remove the break row, otherwise it conflicts with NaN replacement below
        [rows,columns] = size(fileArray);
        Matrix(1:rows,1:columns,i) = fileArray;

    end
    
elseif prompt == 'c'
    
    files = dir('*.csv');
    cfiles = {files(~[files.isdir]).name}'
    Matrix = [];

    for i = 1:length(cfiles)

        fileArray = readtable(cfiles{i});
        fileArray = table2array(fileArray(:,1:6));
        fileArray(fileArray(:,4)==99,:) = 0;
        index = find(fileArray(:,4)==0);
        fileArray = fileArray(index,:);
        fileArray = [fileArray(:,1:3) fileArray(:,5:6)];
        fileArray(fileArray(:,1)==0,:) = 99;
        [rows, columns] = size(fileArray);
        Matrix(1:rows,1:columns,i) = fileArray;

    end
end

%% convert extra rows (currently = 0) to NaN
% the problem was that quit = 0 from psychopy, so I needed a way to convert
% the zeros patching extra rows without affecting real values

width = size(Matrix);

if length(width) < 3 
    col = Matrix(:,1);
        
    if col(end) == 0
        extras = find(col==0); % get indexes for extras
        Matrix(extras,:) = NaN; % convert to NaN
    end    

else      
    for j = 1:width(3)

        col = Matrix(:,1,j); % grab the delay column for subject j

        if col(end) == 0
            extras = find(col==0); % get indexes for extras
            Matrix(extras,:,j) = NaN; % convert to NaN
        end
    end    
end

%% add prefix 'c' for cog and 'w' for waiting

if prompt == 'c'
    cMatrix = Matrix;
    %clearvars -except wfiles cfiles pfiles cMatrix wMatrix pMatrix
elseif prompt == 'p'
    pMatrix = Matrix;
    %clearvars -except wfiles cfiles pfiles cMatrix wMatrix pMatrix
else
    wMatrix = Matrix;
    %clearvars -except wfiles cfiles pfiles wMatrix cMatrix pMatrix
end






