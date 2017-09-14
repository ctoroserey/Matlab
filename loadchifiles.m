

files = dir('*.csv');
struc = [];
allLabels = [];
counts = [];

for i = 1:length(files)
   fid = fopen(files(i).name); 
   temp = textscan(fid,'%s');
   struc(i).labels = temp{1}; 
   allLabels = [allLabels ; temp{1}];
   fclose(fid);
end

for l = 1:length(Glasser)
   counts(l) = sum(allLabels == Glasser(l)); 
end

POS = struc;
countPOS = counts';

clear temp i l ans fid files struc counts allLabels