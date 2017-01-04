%%% This script transforms the CONN adjacency matrices for each subject
%%% into individual matrices that can then be used in NBS. It extracts the
%%% matrices for everyone, as well as name and coordinates.

cd '/Users/toryz8/Desktop/Current_Projects/Darren/MRI/CONN_122015/Graph/Subject_matrices';

%% extract matrices, coords, and labels from CONN adjacency matrices

files = dir('*.mat');
mkdir('matrices');

for i = 1:length(files)
    
    matfile = load(files(i).name);
    id = strtok(files(i).name, 'C');
    matrix = matfile.Z;
    labels = matfile.names;
    coords = cellarray2vector(matfile.xyz);
    
    if i == 1            
       save('coords.mat', 'coords');
       save('labels.mat', 'labels');
    end    
    
    if length(coords) > length(labels)
        coords = coords(1:length(labels), :);
    end    
    
    if isequal(length(labels), length(matrix))    % checks if matrices are square
        continue
    else                                             % if they aren't, use only source ROIs as targets to ensure symmetry
        matrix = matrix(:,1:length(labels));
    end    
    
    matrix(1:length(matrix)+1:end)=0;                % Ensures that the diagonal is zero'd

    save(['./matrices/' id 'matrix.mat'], 'matrix');
    
end    


%% threshold every subject's matrix at 0.20 using BCT

cd ./matrices/
d=dir('*.mat');  % get the list of files
for j=1:length(d)           
a = load(d(j).name);
[threshmat] = threshold_proportional(matrix, 0.20);
save(strcat('thresh_', d(j).name), 'threshmat')
end

%% generates a 3d array with every subject's matrix

d=dir('thresh_*.mat');  % get the list of files
x=[];            % start w/ an empty array
for i=1:length(d)  
y = load(d(i).name); 
z = threshmat;
x=cat(3,x,z);   % read/concatenate into x
end

save('3d_matrix.mat','x')


















