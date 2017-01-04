
clear all;
close all;

data_path = '/Users/toryz8/Desktop/Current_Projects/Darren/MRI/CONN analysis all subjects/controls/';
cd(data_path); clear data_path;

dirlist  = dir;
subject = {dirlist([dirlist.isdir]).name};
subject(ismember(subject,{'.','..'}))=[];
clear dirlist;



for i=1:length(subject);
    
    cd(subject{i})
    
    nrun = 1; % enter the number of runs here
    
    subject(i)
    
    if exist('./nMR/verbs/swverbs.nii') == 0
       cd ..;
       continue
    end 
    
    jobfile = {'/Volumes/PNRC-8/KadisDarren/Coordinator_Files/Scripts/Final/vg_model_spec_job.m'};
    jobs = repmat(jobfile, 1, nrun);
    inputs = cell(0, nrun);
    
    for crun = 1:nrun
    end
    
    spm('defaults', 'FMRI');
    spm_jobman('run', jobs, inputs{:});
    
    cd ..;
    
end

