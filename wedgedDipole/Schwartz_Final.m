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

% model parameters
alpha = 0.5;
beta = 80;
shearV1 = 0.90;
shearV2 = 0.33;
shearV3 = 0.4;
K = 15; % global scale parameter
xShift = log(alpha/beta); % to bring the map origin to 0 instead of -X

% total observations
nEccentricity = 80;
nAzimuth = 31; % has to be an odd number because the HM is shared in the visual field

% rho (equivalent to x)
% create 'r' exponentially spaced in [0, 'ecc']
ecc = 90;   % extent of visual field eccentricity
radius = linspace(log(alpha), log(ecc+alpha), nEccentricity);
eccentricity = ( exp(radius) - alpha );

% theta is y in radiants
theta = linspace(-pi/2,pi/2,nAzimuth);
center = round(nAzimuth/2);
theta2 = theta(1:center); % low right hemifield
theta3 = theta(center:nAzimuth);


%-------------- this plots the original figure that gets mapped
%subplot(1,2,1)
for k = eccentricity
    
    polarplot(theta2,k,'o','Color',orange);
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
    wdgdMapV1(indx,1:nAzimuth) = mapAll; 
    wdgdMapV1lower(indx,1:center) = mapUpper;
    wdgdMapV1upper(indx,1:center) = mapLower;

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

clear ecc K radius nAzimuth indx



% for later: upper hemifield
wdgdMapV2upper = areaTransform(wdgdMapV1upper, shearV2,1,1);
wdgdMapV3upper = areaTransform(wdgdMapV2upper, shearV3,2,1);

plot(wdgdMapV2upper - xShift,'Color',blue)
plot(wdgdMapV2upper.' - xShift,'Color',blue)
plot(wdgdMapV3upper - xShift,'Color',yellow)
plot(wdgdMapV3upper.' - xShift,'Color',yellow)


