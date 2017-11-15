%% Plotting the dipole topographic map of V1 
% This was NE780's second HW. The idea was to create map of a semi-circle
% that would map using the log model: log(z + alpha)/log(z + beta). The
% resulting map corresponds to V1's structure.
% the coordinates of the complex number (x + i.*y) were changed to polar
% coordinates (check function).

% function applying the polar coordinate-based log mapping model
% myfunc = @(r,theta,alpha) log(r.*exp(i.*theta) + alpha);
myfunc = @(r,theta,alpha) r.*exp(1i.*theta) + alpha;

% wedged version
% param is the control of extremes
% shear is the theta-modulating shear
phi = @(theta,shear) shear.*theta;
wdgdDipole = @(r,theta,param,shear) r.*exp(1i.*phi(theta,shear)) + param;

% total observations
nEccentricity = 80;
nAzimuth = 25;

% rho (equivalent to x)
eccentricity = 0:nEccentricity;

% theta is y in radiants
theta = linspace(-pi/2,pi/2,nAzimuth);
center = round(nAzimuth/2);
theta2 = theta(1:center); % low right hemifield
theta3 = theta(center:nAzimuth);

% alpha prevents the log to go to infinite once r and theta get super small
% beta allows the end of the map to close down again for large values of
% r,theta. So, beta discounts a lot at higher values of the parameters.
% Plotting using either alpha or beta, without taking their difference,
% gives a monopole map.

alpha = 0.9;
beta = 170;
shearV1 = 0.90;
K = 15; % global scale parameter
xShift = log(alpha/beta); % to bring the map origin to 0 instead of -X

%-------------- this plots the original figure that gets mapped
subplot(1,2,1)
for k = eccentricity
    polarplot(theta2,k,'ro');
    %p1.Color = [1./(k+1) 0 0];
    %p1.LineWidth = 2;
    hold on 
    polarplot(theta3,k,'go');
end

title('Original image')
clear j k

%-------------- this plots the topographic comformal map
subplot(1,2,2)
hold on
for k = eccentricity
    map = K.*log(myfunc(k,theta2,alpha)./myfunc(k,theta2,beta)) - K.*xShift; % the last subtraction puts the map at 0
    plot(real(map),imag(map),'g')
 
    map = K.*log(myfunc(k,theta3,alpha)./myfunc(k,theta3,beta)) - K.*xShift;
    plot(real(map),imag(map),'r')    
end

for j = theta2
    map = K.*log(myfunc(eccentricity,j,alpha)./myfunc(eccentricity,j,beta)) - K.*xShift;
    plot(real(map),imag(map),'g')    
end

for j = theta3
    map = K.*log(myfunc(eccentricity,j,alpha)./myfunc(eccentricity,j,beta)) - K.*xShift;
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

for k = eccentricity
    
    % create coordinate
    mapAll = K.*log(wdgdDipole(k,theta,alpha,shearV1)./wdgdDipole(k,theta,beta,shearV1)) - K.*xShift; 
    mapUpper = log(wdgdDipole(k,theta2,alpha,shearV1)./wdgdDipole(k,theta2,beta,shearV1)); % - log(alpha/beta);
    mapLower = log(wdgdDipole(k,theta3,alpha,shearV1)./wdgdDipole(k,theta3,beta,shearV1)); % + log(alpha/beta);
    
    % store in map
    wdgdMapV1(k+1,1:nAzimuth) = mapAll; 
    wdgdMapV1lower(k+1,1:center) = mapUpper;
    wdgdMapV1upper(k+1,1:center) = mapLower;

end

clear k

% plot full hemifield
% IMPORTANT: A.' TRANSPOSES WITHOUT CONJUGATION (SIGN REVERSAL OF THE IMAGINARY PART)
% THIS MEANS THAT ALL THE INFORMATION ABOUT THE QUARTER HEMIFIELD CAN BE
% CONTAINED IN A SINGLE MAP

plot(wdgdMapV1,'b');
plot(wdgdMapV1.','b');
title('Mapped Wedged V1 image')
clear j k

% plot partial hemifields
figure;
hold on
plot(wdgdMapV1lower- xShift,'g'); plot(wdgdMapV1lower.'- xShift,'g')
plot(wdgdMapV1upper- xShift,'r'); plot(wdgdMapV1upper.'- xShift,'r')
title('Mapped Wedged Partial V1 image')

% -----V2? From now on, focus on the top right hemifield / low-left hemisphere
% Notes:
% - Technically, the shear should be applied before the dipole is computed, working as a physical limitation of the angular space

shearV2 = 0.33;
%alpha = 0.010;
%beta = 50;
 
% Note: vertical meridian for the lower is wdgdMapV1lower(1:end,1)
V1InputLower = wdgdMapV1lower'; % input from V1
VMV1Lower = wdgdMapV1lower(1:end,1); % vertical meridian for the V1/V2 junction
wdgdEccV2 = real(V1InputLower); % eccentricity of wedged V1 map
wdgdPolV2 = flip(imag(V1InputLower)); % polar angle of wedged V1 map

wdgdMapV2 = wdgdDipole(wdgdEccV2,wdgdPolV2,alpha,shearV2) ./ wdgdDipole(wdgdEccV2,wdgdPolV2,beta,shearV2);

% figure;
% hold on
% plot(wdgdMapV2.*100-2.6,'b'); % the minus shifts the figure around the x-axis
% plot((wdgdMapV2.').*100-2.6,'b');
% title('Mapped Wedged V2 image')

% unlike above, this mantains the iso-eccentricity contours intact, which
% makes sense. But is it biologically apt?
plot(real(V1InputLower)- xShift,(imag(wdgdMapV2).*100)+imag(VMV1Lower)','b') % just adding the imaginary (polar) part of the vertical meridian to angle V2
plot(real(V1InputLower.')- xShift,(imag(wdgdMapV2.').*100)+imag(VMV1Lower),'b')













%% To do
% - Use the wedged map arrays as input for V2
%   (10.*(wdgdMap+5.2)) gives an approx
