

files = dir('*.csv');
struc = [];
for i = 1:length(files)
   fid = fopen(files(i).name); 
   temp = textscan(fid,'%s');
   struc(i).labels = temp{1}; 
   fclose(fid);
end

NEG = struc;
clear temp i fid files struc