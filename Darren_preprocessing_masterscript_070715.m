clear all; close all;
%% DESIGNATE THE CTF-FORMAT MEG DATASET HERE
% this should be the only thing we need to change per run
dataset = 'CTL02_R-kadis-storiesER_20150403_01.ds'
 
%% epoch, line noise correct, and remove jump artifacts in FT
% Initialize FieldTrip
restoredefaultpath;
addpath('c:\Users\kado3i\fieldtrip-20141001');
clear ft_defaults;
ft_defaults;
 
% define the trial epochs (full trial), build into cfg
cfg=[];
cfg.trialdef.prestim = 0.5;
cfg.trialdef.poststim = 2.5;
cfg.trialdef.eventtype = 'story';
cfg.dataset = dataset;
cfg = ft_definetrial(cfg);          % creates cfg.trl, indicates start, end, offset in sample numbers
% line noise correct, bandpass,
cfg.channel = {'MEG', '-MLC12'};    % keep all MEG channels except MLC12
cfg.dftfilter = 'yes';              % remove line noise with discrete fourier transform
cfg.dftfreq = [60 120 180];         % N. Amer line freq (60Hz) plus harmonics
cfg.lpfilter = 'yes';               % low pass filter
cfg.lpfreq = 256;                   % LP at 100 Hz ** helps eliminate muscle artifact **
cfg.hpfilter = 'yes';
cfg.hpfreq = 0.5;
cfg.demean = 'yes';
cfg.baselinewindow = [-0.5 0];
cfg.continuous = 'yes';
data = ft_preprocessing(cfg);
% correct for jump artificats
[cfg, artifact] = ft_artifact_jump(cfg);    % id jumps
data = ft_rejectartifact(cfg, data);        % remove jumps
save ft_stories data;
 
%% save an SPM8 version of the processed data
% initialize spm8
restoredefaultpath;
addpath('c:\Users\kado3i\spm8');
addpath(genpath('c:\Users\kado3i\\spm8\'));
load ft_stories;
spm('defaults','eeg');
spm_eeg_ft2spm(data, 'spm_stories');
 
%% my version of spm_eeg_copygrad.m
spmfile = 'spm_stories.mat';
ctffile = dataset;
hdr = ft_read_header(ctffile);
D = spm_eeg_load(spmfile);
D = sensors(D, 'MEG', ft_convert_units(hdr.grad, 'mm'));
D = fiducials(D, ft_convert_units(ft_read_headshape(ctffile), 'mm'));
% Create 2D positions for MEG (when there are no EEG sensors)
% by projecting the 3D positions to 2D
if ~isempty(strmatch('MEG', D.chantype, 'exact')) &&...
    ~isempty(D.sensors('MEG')) && isempty(D.sensors('EEG'))
    S = [];
    S.task = 'project3D';
   S.modality = 'MEG';
    S.updatehistory = 1;
    S.D = D;
   
    D = spm_eeg_prep(S);
end
save(D);
 
%% extract virtual sensors
clear all;
close all;
filename = 'spm_stories.mat';
spm('defaults', 'eeg');
S = [];
S.D = filename;
S.sources.pos = [
    61.4    -34.3   -7.39
    36.7    -65.1   43.6
    -43.7   29  26
    49.6    -67.9   7.29
    -42.3   -66.9   38.6
    58.3    5.12    21.7
    29.1    -54.2   59.3
    -56.9   -10.9   8.69
    -54.4   7.66    17.4
    -49.1   0.329   -16.9
    -47 -71 13.6
    53.5    -53.8   22.1
    47.4    28.8    24.3
    39.6    -18.2   13.3
    54.4    -32 45.9
    -46.4   -33.5   14.1
    -51.5   -3.35   -30
    30.6    -0.8    -36.2
    -62.7   -21.7   -0.667
    44.2    -12.8   -5.62
    -56.8   -52.1   6.06
    59.9    -18.2   -18.5
    -50.1   -52.9   -15.3
    53  11.2    1.83
    63.6    -39.2   10.7
    -50.1   5.17    -0.854
    44.6    -71.8   25.9
    -28.7   -58.9   55.7
    -60.7   -29.1   14.1
    -41.4   44.9    10.4
    -33.9   20  1.81
    46.4    -2.38   9.19
    -53.1   -27.9   41.3
    -30.4   -3.06   -35.6
    42.2    50.4    -5.53
    39.7    -11.2   -27.5
    -58 -40.5   27.9
    32.7    -32.7   61
    -32.6   -82.4   24.7
    -57.8   -15.8   -15.9
    -39.1   -12.8   -3.55
    -45.3   8.4 31.5
    27.4    -77.4   34
    51.6    -51.7   43.8
    43.8    9.56    -36.1
    36.2    18.5    2.81
    60  -34.7   29.7
    -58.8   -34.8   -5.64
    -31.5   0.759   5.48
    -40.8   10.1    -35.6
    -29 -35.3   62.7
    -51.1   -49.6   44.1
    55.3    -0.112  -20.7
    61.7    -13.2   -0.109
    40.1    47.3    14.3
    57.7    -53.3   -3.18
    38.3    -40.5   46
    50.2    -33 12.4
    61.2    -17.2   19.8
    -51 -57.8   23.6
    50.3    32.9    6.12
    -37.2   -44.4   46.9
    -49.4   25.5    7.56];
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
S.voi.radius = 5;                       % Radius defined in milimeters
S.voi.resolution = 2;                   % Voxel resolution
S.lambda = '0.01%';
S.outfile = (strcat('vs_', filename));
S.conditions = {'Undefined'};
S.appendchannels = {};
D = spm_eeg_ft_beamformer_source(S);
 
%% crop to the first 1500 ms of each trial
spm('defaults', 'eeg');
S = [];
S.D = 'vs_spm_stories.mat';
S.timewin = [0
             1500];
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
D = spm_eeg_crop(S);