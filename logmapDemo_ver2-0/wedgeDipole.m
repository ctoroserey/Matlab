%%% global params
k = 15.0;   % global map scale parameter 'k'

a = 0.5;    % global map parameter 'a'
b = 80.0;   % global map parameter 'b'

alpha1 = 1.000; % azimuthal shear in V1
alpha2 = 0.333; % azimuthal shear in V2
alpha3 = 0.250; % azimuthal shear in V3

ecc = 90;   % extent of visual field eccentricity
Necc = 20;  % number of steps in eccentricity
Npol = 22;  % number of steps in polar angle

%%% compute derived shear parameters
phi1 = (pi/2) * ( 1 - alpha1 );
phi2 = (pi/2) * ( 1 - alpha2 );
phi3 = (pi/2) * ( 1 - alpha3 );

%%% build real 'r' and 'theta' coordinate vectors
% create 'r' exponentially spaced in [0, 'ecc']
radius = linspace(log(a), log(ecc+a), Necc)';
r = ( exp(radius) - a );

% build vectors of polar angles relabeled by shearing
theta = [linspace(-pi/2, -eps*1e5, Npol/2),...
        linspace(+eps*1e5, +pi/2, Npol/2)];
    
thetaV1 = (alpha1*theta);
thetaV2 = (alpha2*theta) + ...
          (sign(theta)*(phi2+phi1));
thetaV3 = (alpha3*theta) + ...
          (sign(theta)*(pi-phi1-phi2));
      
%%% compute complex coordinates and mappings
% visual field
z = r*exp(1i*theta);

% wedge mapping
zV1 = r*exp(1i*thetaV1);
zV2 = -conj(r*exp(1i*thetaV2));
zV3 = r*exp(1i*thetaV3);

% dipole mapping
wV1 = k*log( (zV1+a)./(zV1+b) ) - k*log(a/b);
wV2 = k*log( (zV2+a)./(zV2+b) ) - k*log(a/b);
wV3 = k*log( (zV3+a)./(zV3+b) ) - k*log(a/b);

% plot
figure;
subplot(1,2,1);
hold on
plot(zV1,'r');
plot(zV2,'g');
plot(zV3,'b');
axis image; axis off;
title('Wedged hemifield');

subplot(1,2,2);
hold on
plot(wV1,'r');
plot(wV2,'g');
plot(wV3,'b');
axis image; axis off;
title('Topographic mapping onto V1, V2, and V3');