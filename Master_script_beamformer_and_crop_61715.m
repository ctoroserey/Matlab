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
datfilename = dir('s_*.dat');
datfilename = {datfilename(~[datfilename.isdir]).name};

for i = 1:length(filename);                                                                            % the loop should apply the beemformer on each file and save in original dir
    spm('defaults', 'eeg');
    
    S = [];
    S.D = (strcat(defaultdir, filename{i}));                                                           % loads each file based on its filename
    S.sources.pos = [61.4	-34.3	-7.39
36.7	-65.1	43.6
-43.7	29	26
49.6	-67.9	7.29
-42.3	-66.9	38.6
58.3	5.12	21.7
29.1	-54.2	59.3
-56.9	-10.9	8.69
-54.4	7.66	17.4
-49.1	0.329	-16.9
-47	-71	13.6
53.5	-53.8	22.1
47.4	28.8	24.3
39.6	-18.2	13.3
54.4	-32	45.9
-46.4	-33.5	14.1
-51.5	-3.35	-30
30.6	-0.8	-36.2
-62.7	-21.7	-0.667
44.2	-12.8	-5.62
-56.8	-52.1	6.06
59.9	-18.2	-18.5
-50.1	-52.9	-15.3
53	11.2	1.83
63.6	-39.2	10.7
-50.1	5.17	-0.854
44.6	-71.8	25.9
-28.7	-58.9	55.7
-60.7	-29.1	14.1
-41.4	44.9	10.4
-33.9	20	1.81
46.4	-2.38	9.19
-53.1	-27.9	41.3
-30.4	-3.06	-35.6
42.2	50.4	-5.53
39.7	-11.2	-27.5
-58	-40.5	27.9
32.7	-32.7	61
-32.6	-82.4	24.7
-57.8	-15.8	-15.9
-39.1	-12.8	-3.55
-45.3	8.4	31.5
27.4	-77.4	34
51.6	-51.7	43.8
43.8	9.56	-36.1
36.2	18.5	2.81
60	-34.7	29.7
-58.8	-34.8	-5.64
-31.5	0.759	5.48
-40.8	10.1	-35.6
-29	-35.3	62.7
-51.1	-49.6	44.1
55.3	-0.112	-20.7
61.7	-13.2	-0.109
40.1	47.3	14.3
57.7	-53.3	-3.18
38.3	-40.5	46
50.2	-33	12.4
61.2	-17.2	19.8
-51	-57.8	23.6
50.3	32.9	6.12
-37.2	-44.4	46.9
-49.4	25.5	7.56];                                                                         % regional coordinates defined in rows, followed by their labeling in corresponding order.
    S.sources.label = {
'103'
'104'
'109'
'114'
'116'
'117'
'124'
'126'
'127'
'13'
'135'
'137'
'138'
'141'
'142'
'145'
'146'
'15'
'151'
'154'
'155'
'159'
'16'
'160'
'163'
'164'
'165'
'167'
'177'
'188'
'191'
'193'
'195'
'20'
'22'
'26'
'28'
'29'
'32'
'34'
'35'
'43'
'45'
'46'
'47'
'48'
'56'
'59'
'6'
'62'
'65'
'66'
'68'
'7'
'71'
'73'
'82'
'9'
'91'
'92'
'94'
'96'
'98'
        }';
    S.voi.radius = 5;                                                                                  % Radius defined in milimeters
    S.voi.resolution = 2;                                                                              % Voxel resolution
    S.lambda = '0.01%';
    S.outfile = (strcat(defaultdir,'Network_', filename{i}));                                          % save output file within the original dir as 'Network_s_XX_vg.mat'
    S.conditions = {'Undefined'};
    S.appendchannels = {};                                                                             % no channels appended; list can be found in GUI
    D = spm_eeg_ft_beamformer_source(S);
    
    copyfile(strcat('Network_', filename{i}), strcat(defaultdir,'Baseline_crop/'));                    % this will copy the output files to the baseline and active folders
    copyfile(strcat('Network_', filename{i}), strcat(defaultdir,'Active_crop/')); 
    copyfile(strcat('Network_', datfilename{i}), strcat(defaultdir,'Baseline_crop/'));
    copyfile(strcat('Network_', datfilename{i}), strcat(defaultdir,'Active_crop/'));
end




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
    %%
    S.channels = {
'103'
'104'
'109'
'114'
'116'
'117'
'124'
'126'
'127'
'13'
'135'
'137'
'138'
'141'
'142'
'145'
'146'
'15'
'151'
'154'
'155'
'159'
'16'
'160'
'163'
'164'
'165'
'167'
'177'
'188'
'191'
'193'
'195'
'20'
'22'
'26'
'28'
'29'
'32'
'34'
'35'
'43'
'45'
'46'
'47'
'48'
'56'
'59'
'6'
'62'
'65'
'66'
'68'
'7'
'71'
'73'
'82'
'9'
'91'
'92'
'94'
'96'
'98'
        }';
    %%
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



%% Baseline time crop 

cd /Users/toryz8/Documents/MATLAB/spm8/MEG_paeds_vg_devt_traj/_spm/Original/Baseline_crop/                         % directory with extracted sources
filename = dir('Network_*.mat');                                                                                   % creates list of file names starting with 's_' withing the dir
filename = {filename(~[filename.isdir]).name}; 

for i = 1:length(filename);
    spm('defaults', 'eeg');
    
    S = [];
    S.D = (strcat('/Users/toryz8/Documents/MATLAB/spm8/MEG_paeds_vg_devt_traj/_spm/Original/Baseline_crop/', filename{i}));
    S.timewin = [-400
        0];
    %%
    S.channels = {
'103'
'104'
'109'
'114'
'116'
'117'
'124'
'126'
'127'
'13'
'135'
'137'
'138'
'141'
'142'
'145'
'146'
'15'
'151'
'154'
'155'
'159'
'16'
'160'
'163'
'164'
'165'
'167'
'177'
'188'
'191'
'193'
'195'
'20'
'22'
'26'
'28'
'29'
'32'
'34'
'35'
'43'
'45'
'46'
'47'
'48'
'56'
'59'
'6'
'62'
'65'
'66'
'68'
'7'
'71'
'73'
'82'
'9'
'91'
'92'
'94'
'96'
'98'
        }';
    %%
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