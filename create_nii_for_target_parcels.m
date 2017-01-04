% INITIATE SPM5/8/12

clear all;
close all;

cd /Users/toryz8/OneDrive - cchmc/Current_Projects/Darren/42816/bp_stories.nii;


roi_by_parcel=spm_vol('resized_comp_bin.nii');    % read the nifti header into Matlab
matrix_vals = spm_read_vols(roi_by_parcel);     % read the volume data (intensity values) as a matrix
unique_vals = unique(matrix_vals);              % create array of unique values in the matrix
parcels = round(unique_vals);                   % integers  of all values in unique_vals; omit value 0 for subsequent analyses
parcels = unique(parcels);

length(parcels)


for z = 2:length(parcels);
    
    Vi = 'resized_comp_bin.nii'               % load the original parcellation file, for parcel extraction
    
    roi_label = parcels(z);
    
    Vo = strcat(num2str(roi_label), '.nii');
    f = strcat('i1>(', num2str(roi_label), '-0.1) & i1<(', num2str(roi_label), '+0.1)')
    
    Vo = spm_imcalc(Vi, Vo, f)
    
    clear Vo; clear f;
    
end

