function [out, summary] = crossValidate(Matrix)

[~,~,nSubs] = size(Matrix);

MatrixB = [];
MatrixA = [];

for i = 1:nSubs
    
    % find the break
    index = find(Matrix(:,1,i)==99);
    
    % get the before-break data
    tempMatrix = Matrix(1:(index-1),:,i);
    [rows,columns] = size(tempMatrix);
    MatrixB(1:rows,1:columns,i) = tempMatrix;
    
    % get the post-break data
    tempMatrix = Matrix((index+1):end,:,i);
    [rows,columns] = size(tempMatrix);
    MatrixA(1:rows,1:columns,i) = tempMatrix;
    
end

for i = 1:nSubs
    
    col = MatrixB(:,1,i); % grab the delay column for subject j

    if col(end) == 0
        extras = find(col==0); % get indexes for extras
        MatrixB(extras,:,i) = NaN; % convert to NaN
    end
end      

% set up the matrix for optimization
MatrixB = setAll(MatrixB);

%% model OR overall (updated with physical)

ModelOR = [];
ModelPredicted = [];

% structs containing each subject's model results
SubjectOR = struct('percentNow',{},'percentDelayed',{},'percentMissed',{},...
    'beta',{},'scale',{},'LL',{},...
    'LL0',{},'r2',{},'SOC',{},'prob',...
    {},'predictedChoice',{},'percentPredicted',{});


% estimate the OC per subject
for i = 1:nSubs
    
    SubjectOR(i) = foragingOCModel(MatrixB(:,3,i),MatrixB(:,6,i),MatrixB(:,2,i),MatrixB(:,1,i),0);
    ModelOR(i) = SubjectOR(i).beta;
    ModelPredicted(i) = SubjectOR(i).percentPredicted;

end   

clear i 

% eliminate NaN instances
ModelOR(isnan(ModelOR)) = [];
ModelPredicted(ModelPredicted==0) = [];

% Plot the OCs (requires the function dotDist)
%OCfig = dotDist([ModelOR.WaitAll(:,1), ModelOR.CognitiveAll(:,1), ModelOR.PhysicalAll(:,1)],{'Wait','Cognitive','Physical'});

%% Cross validate?

ModelPredicted = [];
negLL = [];
R2 = [];

for i = 1:nSubs
    
    Choice = MatrixA(:,3,i);
    miss = Choice ~= 0 & Choice ~= 1;
    choice = Choice(~miss); % choice data for valid trials
    Reward = MatrixA(:,2,i);
    Rwd = Reward(~miss); % reward for valid trials
    Handling = MatrixA(:,1,i);
    Handle = Handling(~miss); % handle time for valid trials

    out(i).scale = SubjectOR(i).scale;
    out(i).SOC = SubjectOR(i).beta.*Handle; % subjective opportunity cost (weighted)
    out(i).prob = 1 ./ (1 + exp(-(out(i).scale.*(Rwd - out(i).SOC))));
    out(i).prob(out(i).prob==1) = 1 - eps;
    out(i).prob(out(i).prob==0) = eps;
    out(i).predictedChoice = Rwd > out(i).SOC; % 1 if delayed option is greater
    out(i).percentPredicted = sum(out(i).predictedChoice == choice) / length(choice) * 100;
    out(i).negLL = -sum((choice==1).*log(out(i).prob) + (choice==0).*log(1-out(i).prob));
    
    out(i).negLL0 = log(0.5)*length(choice);
    out(i).r2 = 1 - (-out(i).negLL)/out(i).negLL0;
    
    ModelPredicted(i) = out(i).percentPredicted;
    negLL(i) = out(i).negLL;
    R2(i) = out(i).r2;
    
end


summary = [ModelOR; ModelPredicted; negLL; R2]';

end