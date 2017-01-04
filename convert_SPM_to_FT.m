%% cd to datadirectory with extracted sources; then run following once

filename = dir('LR*.mat');
filename = {filename(~[filename.isdir]).name}'

%% the loop should batch convert to FT format and save

for f= 1:length(filename);
    
    fname = filename{f}
    
    D = spm_eeg_load(filename);     % loads the m/eeg file
    ft_LR_ifg_vg = D.ftraw;         % reads the SPM data as FT format
    
    save (strcat('.\ft_', filename{f}), 'ft_LR_ifg_vg')
    
end
