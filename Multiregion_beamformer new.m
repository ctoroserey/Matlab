%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% This script performs a fieldtrip beamformer source extraction on all
%%%% files within the defined directory bilaterally for the inferior frontal
%%%% gyrus. Analysed files are then converted to a fieldtrip format.


%% Add SPM8 path
restoredefaultpath;
cd /Users/toryz8/Documents/MATLAB/spm8;                                                
genpath('/Users/toryz8/Documents/MATLAB/spm8');
addpath(pwd)


%% Fieldtrip beamformer source extraction

cd /Users/toryz8/Documents/MATLAB/spm8/MEG_paeds_vg_devt_traj/_spm/Original                            % directory with extracted sources
filename = dir('s_*.mat');                                                                             % creates list of file names starting with 's_' withing the dir
filename = {filename(~[filename.isdir]).name};
defaultdir = '/Users/toryz8/Documents/MATLAB/spm8/MEG_paeds_vg_devt_traj/_spm/Original/';     
mkdir('Baseline_crop');
mkdir('Active_crop');

for i = 1:length(filename);                                                                            % the loop should apply the beemformer on each file and save in original dir
    spm('defaults', 'eeg');
    
    S = [];
    S.D = (strcat(defaultdir, filename{i}));                                                           % loads each file based on its filename
    S.sources.pos = [-50 12 28
                     -54 -36 -6
                     -4 18 46
                     50 -34 -6
                     40 20 -8];                                                                        % regional coordinates defined in rows, followed by their labeling in corresponding order.
    S.sources.label = {
        'LBA44'
        'LBA21'
        'LBA8'
        'RBA21'
        'RBA13'
        }';
    S.voi.radius = 7.5;                                                                                  % Radius defined in milimeters
    S.voi.resolution = 2;                                                                              % Voxel resolution
    S.lambda = '0.01%';
    S.outfile = (strcat(defaultdir,'Network_', filename{i}));                                          % save output file within the original dir as 'Network_s_XX_vg.mat'
    S.conditions = {'Undefined'};
    S.appendchannels = {};                                                                             % no channels appended; list can be found in GUI
    D = spm_eeg_ft_beamformer_source(S);
    
    copyfile(strcat('Network_', filename{i}), strcat(defaultdir,'Baseline_crop/'));                    % this will copy the output files to the baseline and active folders
    copyfile(strcat('Network_', filename{i}), strcat(defaultdir,'Active_crop/')); 
end

%% SPM to Fieldtrip file conversion

filename = dir('Network*.mat');                                                                        % no 'cd' required as long as original dir remains the same throughout the analysis
filename = {filename(~[filename.isdir]).name};

for f= 1:length(filename);                                                                             % the loop should batch convert to FT format and save 
    
    fname = filename{f}; 
    D = spm_eeg_load(fname);                                                                           % loads the m/eeg file
    ft_LR_ifg_vg = D.ftraw;                                                                            % reads the SPM data as FT format
    
    save (strcat('ft_', filename{f}))   
end