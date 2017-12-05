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
nEccentricity = 20;
nAzimuth = 15;

% rho (equivalent to x)
eccentricity = 0:nEccentricity;

% theta is y in radiants
theta = linspace(-pi/2,pi/2,nAzimuth);
theta2 = theta(1:8); % low left hemifield
theta3 = theta(8:15);

% alpha prevents the log to go to infinite once r and theta get super small
% beta allows the end of the map to close down again for large values of
% r,theta. So, beta discounts a lot at higher values of the parameters.
% Plotting using either alpha or beta, without taking their difference,
% gives a monopole map.

alpha = 0.9;
beta = 170;
shear = 0.70;

%-------------- this plots the original figure that gets mapped
subplot(1,2,1)
for k = eccentricity
    polarplot(theta2,k,'ro');
    %p1.Color = [1./(k+1) 0 0];
    %p1.LineWidth = 2;
    hold on 
    polarplot(theta3,k,'go');
end

% colr = 1;
% for j = theta2
%     p2 = polarplot(j,eccentricity,'ro');
%     colr = colr + 1;
% end
title('Original image')
clear j k

%-------------- this plots the topographic comformal map
subplot(1,2,2)
hold on
for k = eccentricity
    map = log(myfunc(k,theta2,alpha)./myfunc(k,theta2,beta));
    plot(real(map),imag(map),'g')
 
    map = log(myfunc(k,theta3,alpha)./myfunc(k,theta3,beta));
    plot(real(map),imag(map),'r')    
end

for j = theta2
    map = log(myfunc(eccentricity,j,alpha)./myfunc(eccentricity,j,beta));
    plot(real(map),imag(map),'g')    
end

for j = theta3
    map = log(myfunc(eccentricity,j,alpha)./myfunc(eccentricity,j,beta));
    plot(real(map),imag(map),'r')    
end
title('Mapped V1 image')
clear j k

%------------- wedged dipole section------------------
% this will produce isoeccentricity and isopolar wedged maps
% using these for V2 input is an idea
% note: the output matrix of both wedge maps is the same, just transposed

wdgdMapV1 = [];
wdgdMapV1lower = [];
wdgdMapV1upper = [];

for k = eccentricity
    map = log(wdgdDipole(k,theta,alpha,shear)./wdgdDipole(k,theta,beta,shear));
    wdgdMapV1(k+1,1:nAzimuth) = map;
end

figure;
hold on
plot(wdgdMapV1,'b');
plot(wdgdMapV1','b');
title('Mapped Wedged V1 image')
clear j k

% V2?
shearV2 = 0.33;
wdgdEccV2 = real(wdgdMapV1); % input from V1
wdgdPolV2 = imag(wdgdMapV1);

wdgdMapV2 = wdgdDipole(wdgdEcc,wdgdPol,alpha,shearV2) ./ wdgdDipole(wdgdEcc,wdgdPol,beta,shearV2);

% figure;
% hold on
plot(wdgdMapV2.*100,'g');
plot(wdgdMapV2'.*100,'g');
title('Mapped Wedged V2 image')















%% To do
% - Use the wedged map arrays as input for V2
%   (10.*(wdgdMap+5.2)) gives an approx
