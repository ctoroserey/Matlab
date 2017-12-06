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
nEccentricity = 20;
nAzimuth = 11; % has to be an odd number because the HM is shared in the visual field

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
    
    polarplot(theta2,k,'ro');
    hold on 
    polarplot(theta3,k,'go');
    
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
    plot(real(map),imag(map),'g'); xlim([-10 160]);

    % plot a point from the lower hemifield
    map = K.*log(dipole(k,theta3,alpha)./dipole(k,theta3,beta)) - K.*xShift;
    plot(real(map),imag(map),'r')    
    
end

% plot by polar angle
for j = theta2
    
    map = K.*log(dipole(eccentricity,j,alpha)./dipole(eccentricity,j,beta)) - K.*xShift;
    plot(real(map),imag(map),'g')  
    
end

for j = theta3
    
    map = K.*log(dipole(eccentricity,j,alpha)./dipole(eccentricity,j,beta)) - K.*xShift;
    plot(real(map),imag(map),'r')    
    
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

clear k

% plot full hemifield
% IMPORTANT: A.' TRANSPOSES WITHOUT CONJUGATION (SIGN REVERSAL OF THE IMAGINARY PART)
% THIS MEANS THAT ALL THE INFORMATION ABOUT THE QUARTER HEMIFIELD CAN BE
% CONTAINED IN A SINGLE MAP
plot(wdgdMapV1 + 80,'k');
plot(wdgdMapV1.' + 80,'k');
title('Mapped Wedged V1 image')
clear j k

% plot partial hemifields
figure;
hold on
plot(wdgdMapV1lower- xShift,'g'); plot(wdgdMapV1lower.'- xShift,'g')
plot(wdgdMapV1upper- xShift,'r'); plot(wdgdMapV1upper.'- xShift,'r')
title('Mapped Wedged Partial V1 image')

% -----V2
% resulting map for V2
% Notes:
% - Technically, the shear should be applied before the dipole is computed, working as a physical limitation of the angular space
% this somewhat mantains the iso-eccentricity contours intact
wdgdMapV2lower = areaTransform(wdgdMapV1lower, shearV2,1);

% plot partial hemifield
plot(wdgdMapV2lower - xShift,'Color',[1,0,0])
plot(wdgdMapV2lower.' - xShift,'b')


% -----V3
% resulting map for V3
wdgdMapV3lower = areaTransform(wdgdMapV2lower, shearV3,2);

% plot partial hemifield
plot(wdgdMapV3lower.' - xShift,'b')
plot(wdgdMapV3lower - xShift,'b')

clear ecc K radius nAzimuth indx




%% To do
% - Use the wedged map arrays as input for V2
%   (10.*(wdgdMap+5.2)) gives an approx

% %% Examples
% 
% % to plot a single polar vector based on the lower V1 map
% % This could be turned into a function with parameters:
% % 
% %     - Angle of interest (2 in example)
% %     - V1 wdgdMap (lower in this case)
% %     - Shear for V2
% %         
% % Let it output rPartV2 and iPartV2 (see how to combine into one complex number)
% 
% 
% % angle of interest
% j = 2;
% 
% % isolate the real and imaginary parts
% rPart = real(wdgdMapV1lower(j,:));
% iPart = imag(wdgdMapV1lower(j,:));
% 
% % get the difference in eccentricity and the angle by which to expand onto V2
% eccDiff = rPart(end) - rPart(1); 
% polSum = abs(min(iPart));
% 
% % resulting vector, ready to plot
% rPartV2 = rPart - eccDiff;
% iPartV2 = iPart.*shearV2 - polSum;
% 
% figure
% hold on
% plot(wdgdMapV1lower)
% plot(wdgdMapV1lower.')
% plot(rPart, iPart,'ro')
% plot(rPart, iPart.*shearV2,'bo') % with shearV2
% plot(rPartV2, iPartV2,'go')






