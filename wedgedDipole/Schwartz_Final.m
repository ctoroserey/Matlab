%% Plotting the dipole topographic map of V1 
% This was NE780's second HW. The idea was to create map of a semi-circle
% that would map using the log model: log(z + alpha)/log(z + beta). The
% resulting map corresponds to V1's structure (a simply connected surface).
% the coordinates of the complex number (x + i.*y) were changed to polar
% coordinates (check function).

% alpha prevents the log to go to infinite once r and theta get super small
% beta allows the end of the map to close down again for large values of
% r,theta. So, beta discounts a lot at higher values of the parameters.
% Plotting using either alpha or beta, without taking their difference,
% gives a monopole map.

% general aesthetic parameters
green = [.13,.93,.12];
orange = [.85 .3 .1];
blue = [.13,.65,.93];
yellow = [.93 .69 .13];

% function applying the polar coordinate-based log mapping model
% myfunc = @(r,theta,alpha) log(r.*exp(i.*theta) + alpha);
dipole = @(r,theta,alpha) r.*exp(1i.*theta) + alpha;

% wedged version
% param is the control of extremes
% shear is the theta-modulating shear
% Note: eccentricity is vital for the curvature calculations
phi = @(theta,shear) shear.*theta;
wdgdDipole = @(r,theta,param,shear) r.*exp(1i.*phi(theta,shear)) + param;

%%%%%%%%%%%
% load image
p = loadIm();
img = im2double(imread(p.fname));

% get the V1 map (just dipole)
[leftLogmapPoints, leftInvLogmapPoints] = mapRightHemisphere2(p);

% this one matches V1 topology
HM = imag(leftLogmapPoints);
lowHemV1 = leftLogmapPoints(HM < mean(HM));
upperHemV1 = leftLogmapPoints(HM > mean(HM));
HMinv = imag(leftInvLogmapPoints);
lowHeminvV1 = leftInvLogmapPoints(HM < mean(HM));

lowHemV2 = complex(real(lowHemV1), imag(lowHemV1) .* 0.5);
% 
% % map the image
% [logImgV1, ~] = mapImage(img,lowHemV1,lowHeminvV1);
% [logImgV2, ~] = mapImage(img,lowHemV2,lowHeminvV1); % problem is that the sheared image has no integer values to map to
%%%%%%%%%%%


% model parameters
alpha = 0.5;
beta = 80;
shearV1 = 0.90;
shearV2 = 0.33;
shearV3 = 0.4;
K = 15; % global scale parameter
xShift = log(alpha/beta); % to bring the map origin to 0 instead of -X
[azimuth,nEcc,depth] = size(img);

% total observations
nEccentricity = nEcc/2;
nAzimuth = round(azimuth/2); % has to be an odd number because the HM is shared in the visual field

% rho (equivalent to x)
% create 'r' exponentially spaced in [0, 'ecc']
ecc = 90;   % extent of visual field eccentricity
radius = linspace(log(alpha), log(ecc+alpha), nEccentricity);
eccentricity = ( exp(radius) - alpha );

% theta is y in radiants
theta = linspace(-pi/2,pi/2,azimuth);
theta2 = theta(1:nAzimuth); % low right hemifield
theta3 = theta((nAzimuth):azimuth);

% image cut in half (for the hemifield)
img2 = img(:,(nEccentricity+1):nEcc,:);
img2upper = img2(1:nAzimuth,:,:);
img2lower = img2(nAzimuth:azimuth,:,:);

%-------------- this plots the original figure that gets mapped
%subplot(1,2,1)
for k = eccentricity
    
    polarplot(theta2,k,'o','Color',orange); % single vecto polarplot(theta2(3),eccentricity,'o')
    hold on 
    polarplot(theta3,k,'o', 'Color',green);
    
end

title('Original image')
clear j k

%-------------- this plots the topographic comformal map
%subplot(1,2,2)
figure
hold on
% plot by eccentricity
for k = eccentricity
    
    % plot a point from the upper hemifield
    map = K.*log(dipole(k,theta2,alpha)./dipole(k,theta2,beta)) - K.*xShift; % the last subtraction puts the map at 0
    plot(real(map),imag(map),'Color',green); xlim([-10 160]);

    % plot a point from the lower hemifield
    map = K.*log(dipole(k,theta3,alpha)./dipole(k,theta3,beta)) - K.*xShift;
    plot(real(map),imag(map),'Color',orange)    
    
end

% plot by polar angle
for j = theta2
    
    map = K.*log(dipole(eccentricity,j,alpha)./dipole(eccentricity,j,beta)) - K.*xShift;
    plot(real(map),imag(map),'Color',green)  
    
end

for j = theta3
    
    map = K.*log(dipole(eccentricity,j,alpha)./dipole(eccentricity,j,beta)) - K.*xShift;
    plot(real(map),imag(map),'Color',orange)    
    
end

title('Mapped V1 image')
clear j k

%------------- wedged dipole section------------------
% this will produce isoeccentricity and isopolar wedged maps
% using these for V2 input is an idea
% note: the output matrix of both wedge maps is the same, just transposed

%REMINDER: Green is upper visual hemifield, lower V1

% -----V1
% full and partial hemifield maps
wdgdMapV1 = [];
wdgdMapV1lower = [];
wdgdMapV1upper = [];

indx = 1;

for k = eccentricity
    
    % create coordinate
    mapAll = K.*log(wdgdDipole(k,theta,alpha,shearV1)./wdgdDipole(k,theta,beta,shearV1)) - K.*xShift; 
    mapUpper = log(wdgdDipole(k,theta2,alpha,shearV1)./wdgdDipole(k,theta2,beta,shearV1)); % - log(alpha/beta);
    mapLower = log(wdgdDipole(k,theta3,alpha,shearV1)./wdgdDipole(k,theta3,beta,shearV1)); % + log(alpha/beta);
    
    % store in map
    wdgdMapV1(indx,1:azimuth) = mapAll; 
    wdgdMapV1lower(indx,1:nAzimuth) = mapUpper;
    wdgdMapV1upper(indx,1:nAzimuth) = mapLower;

    indx = indx + 1;
    
end

% plot full hemifield
% IMPORTANT: A.' TRANSPOSES WITHOUT CONJUGATION (SIGN REVERSAL OF THE IMAGINARY PART)
% THIS MEANS THAT ALL THE INFORMATION ABOUT THE QUARTER HEMIFIELD CAN BE
% CONTAINED IN A SINGLE MAP
plot(wdgdMapV1 + 80,'Color',blue);
plot(wdgdMapV1.' + 80,'Color',blue);
title('Mapped Wedged V1 image')


% plot partial hemifields
figure;
hold on
plot(wdgdMapV1lower - xShift,'Color',green); plot(wdgdMapV1lower.'- xShift,'Color',green)
plot(wdgdMapV1upper - xShift,'Color',orange); plot(wdgdMapV1upper.'- xShift,'Color',orange)
title('Mapped Wedged V1 -> V2 -> V3 image')

% -----V2
% resulting map for V2
% Notes:
% - Technically, the shear should be applied before the dipole is computed, working as a physical limitation of the angular space
% this somewhat mantains the iso-eccentricity contours intact
wdgdMapV2lower = areaTransform(wdgdMapV1lower, shearV2,1,-1);

% plot partial hemifield
plot(wdgdMapV2lower - xShift,'Color',blue)
plot(wdgdMapV2lower.' - xShift,'Color',blue)


% -----V3
% resulting map for V3
wdgdMapV3lower = areaTransform(wdgdMapV2lower, shearV3,2,-1);

% plot partial hemifield
plot(wdgdMapV3lower.' - xShift,'Color',yellow)
plot(wdgdMapV3lower - xShift,'Color',yellow)

%clear ecc K radius nAzimuth indx



% for later: upper hemifield
wdgdMapV2upper = areaTransform(wdgdMapV1upper, shearV2,1,1);
wdgdMapV3upper = areaTransform(wdgdMapV2upper, shearV3,2,1);

plot(wdgdMapV2upper - xShift,'Color',blue)
plot(wdgdMapV2upper.' - xShift,'Color',blue)
plot(wdgdMapV3upper - xShift,'Color',yellow)
plot(wdgdMapV3upper.' - xShift,'Color',yellow)


%% Notes
% 
% - Might have to use mapLeftHemisphere independently from constructLogMap.m it works with input p from loadIm (see below).
% - Just make sure that you understand the role of each complex vector: the inverse seems more V1-y. Both can be cut by the HM (see notes in mapLeft..m)

%-------- super important plotting onto polar plane of original image
% [rhoTest, thetaTest] = meshgrid(abs(radius),theta3);
% [X Y] = pol2cart(thetaTest,rhoTest);
% S = surf(X,Y,ones(size(X))); 
% set(S,'FaceColor','Texturemap','CData',img2upper);
% view(2);
% 
% % not quite
% T = surf(real(wdgdMapV1lower), imag(wdgdMapV1lower),ones(size(wdgdMapV1lower)));
% set(T,'FaceColor','Texturemap','CData',flip(img2lower));
% view(2);
%--------

%-------- CODE FROM SCHWARTZ
% % load image 
% test = loadIm();
% img = im2double(imread(test.fname));
% 
% % Create the Hemifield Maps
% % Claudio: (right/left inverted..fix) this outputs 2 single complex vectors, not matrices..
% [leftLogmapPoints, leftInvLogmapPoints] = mapRightHemisphere(test); 
% 
% % to get the inverse lower hemifield (can be plotted): 
% % inverted logmap plots on the polar plot
% 
% % this one matches V1 topology
% HM = imag(leftLogmapPoints);
% lowHem = leftLogmapPoints(HM < mean(HM));
% upperHem = leftLogmapPoints(HM > mean(HM));
% 
% % polar plot
% HMinv = imag(leftInvLogmapPoints);
% lowHeminv = leftInvLogmapPoints(HMinv < mean(HMinv));
% upperHeminv = leftInvLogmapPoints(HMinv > mean(HMinv));
%     
% % full image mapping
% [logImg, invlogImg] = mapImage(img,leftLogmapPoints,leftInvLogmapPoints);
% 
% % partial image mapping 
% [logImg, invlogImg] = mapImage(img,lowHem,lowHeminv);
% 
% % plot to check
% figure
% plot(lowHem,'o');
% 
% figure
% imagesc(logImg)
% 
% figure 
% imagesc(invlogImg)
%-----------

