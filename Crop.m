%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Active (350-750ms) and Baseline (-400-0ms) crops.
%%%%%%%%%%%% Make sure to define the baseline and active folders and labels
%%%%%%%%%%%% before running the script





%% Active time crop

cd /Users/toryz8/Documents/MATLAB/spm8/MEG_paeds_vg_devt_traj/_spm/Original/Active_crop/          % directory with extracted sources
filename = dir('Network_*.mat');                                                                                   % creates list of file names starting with 's_' withing the dir
filename = {filename(~[filename.isdir]).name}; 

for i = 1:length(filename);
    spm('defaults', 'eeg');
    
    S = [];
    S.D = (strcat('/Users/toryz8/Documents/MATLAB/spm8/MEG_paeds_vg_devt_traj/_spm/Original/Active_crop/', filename{i}));
    S.timewin = [350
        750];
    S.channels = {
        'LBA44'
        'LBA21'
        'LBA8'
        'RBA21'
        'RBA13'}';
    D = spm_eeg_crop(S);
    
end

%% SPM to Fieldtrip file conversion (Optional)

filename = dir('pNetwork*.mat');                                                                                   % no 'cd' required as long as original dir remains the same throughout the analysis
filename = {filename(~[filename.isdir]).name};

for f= 1:length(filename);                                                                                         % the loop should batch convert to FT format and save 
    
    fname = filename{f}; 
    D = spm_eeg_load(fname);                                                                                       % loads the m/eeg file
    ft_LR_ifg_vg = D.ftraw;                                                                                        % reads the SPM data as FT format
    
    save (strcat('ft_', filename{f}))   
end