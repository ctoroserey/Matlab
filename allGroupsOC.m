%% This script only runs the portion of foragingAnalyses.m dedicated to the estimation 
% of the opportunity cost of time (for delay and both effort types). It
% just requires the data to be loaded (using logread.m).

%% Basic setups
cMatrix = setAll(cMatrix); % for model fit script
wMatrix = setAll(wMatrix);
pMatrix = setAll(pMatrix);

format short g
[~,~,zC] = size(cMatrix);
[~,~,zW] = size(wMatrix);
[~,~,zP] = size(pMatrix);

%% model OR overall (updated with physical)

wModelOR = [];
wModelPredicted = [];
cModelOR = [];
cModelPredicted = [];
pModelOR = [];
pModelPredicted = [];

% structs containing each subject's model results
SubjectCOR = struct('percentNow',{},'percentDelayed',{},'percentMissed',{},...
    'beta',{},'scale',{},'LL',{},...
    'LL0',{},'r2',{},'SOC',{},'prob',...
    {},'predictedChoice',{},'percentPredicted',{});

SubjectWOR = struct('percentNow',{},'percentDelayed',{},'percentMissed',{},...
    'beta',{},'scale',{},'LL',{},...
    'LL0',{},'r2',{},'SOC',{},'prob',...
    {},'predictedChoice',{},'percentPredicted',{});

SubjectPOR = struct('percentNow',{},'percentDelayed',{},'percentMissed',{},...
    'beta',{},'scale',{},'LL',{},...
    'LL0',{},'r2',{},'SOC',{},'prob',...
    {},'predictedChoice',{},'percentPredicted',{});

% estimate the OC per subject
for i = 1:zC
    
    SubjectCOR(i) = foragingOCModel(cMatrix(:,3,i),cMatrix(:,6,i),cMatrix(:,2,i),cMatrix(:,1,i),0);
    cModelOR(i) = SubjectCOR(i).beta;
    cModelPredicted(i) = SubjectCOR(i).percentPredicted;

end   

clear i 

for i = 1:zW
    
    SubjectWOR(i) = foragingOCModel(wMatrix(:,3,i),wMatrix(:,6,i),wMatrix(:,2,i),wMatrix(:,1,i),0);
    wModelOR(i) = SubjectWOR(i).beta;
    wModelPredicted(i) = SubjectWOR(i).percentPredicted;

end    

clear i

for i = 1:zP
    
    SubjectPOR(i) = foragingOCModel(pMatrix(:,3,i),pMatrix(:,6,i),pMatrix(:,2,i),pMatrix(:,1,i),0);
    pModelOR(i) = SubjectPOR(i).beta;
    pModelPredicted(i) = SubjectPOR(i).percentPredicted;

end   

clear i 

% eliminate NaN instances
cModelOR(isnan(cModelOR)) = [];
wModelOR(isnan(wModelOR)) = [];
pModelOR(isnan(pModelOR)) = [];
cModelPredicted(cModelPredicted==0) = [];
wModelPredicted(wModelPredicted==0) = [];
pModelPredicted(pModelPredicted==0) = [];

% store in structs
ModelOR.CognitiveAll = [cModelOR; cModelPredicted]';
ModelOR.WaitAll = [wModelOR; wModelPredicted]';
ModelOR.PhysicalAll = [pModelOR; pModelPredicted]';

% Plot the OCs (requires the function dotDist)
OCfig = dotDist([ModelOR.WaitAll(:,1), ModelOR.CognitiveAll(:,1), ModelOR.PhysicalAll(:,1)],{'Wait','Cognitive','Physical'});


clear i cModelOR cModelPredicted wModelOR wModelPredicted zC zW zP