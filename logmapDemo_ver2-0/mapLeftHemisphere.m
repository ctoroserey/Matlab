% version 2.0 removed mbint() for compatability with R14sp3 and above
% [leftLogmapPoints, leftInvLogmapPoints] = mapLeftHemisphere(p);
%
% mapLeftHemisphere constructs a LUT in the form of two output vectors for either a monopole or 
% dipole mapping of the left visual field.
% 
% Parameter:
%		nImageRows - Height of original image (pixels)
%		nImageCols - Width of original image (pixels)
%		maxR       - Max Radius (pixels)
%		maxEcc     - Max Eccentricity (degrees)
%		k          - Global map scale parameter (pixels)
%   a          - Monopole/Dipole map parameter (degrees)
%   b          - Dipole map parameter (degrees)  [Optional]
%
%  Note: No error checking of needed parameters are done in this function 
%
% Output:
%		leftLogmapPoints    - a vector of integer-spaced points belonging to the left 
%                         hemifield "cortical map"
%		leftInvLogmapPoints - a vector of integer-space points belonging to the left 
%                         hemifield "retinal map" 
%
% Note: There is a one-to-one mapping in the resulting LUT 
%       (i.e. length(leftLogmapPoints) = length(leftInvPoints))
%
% Copyright (C) 2002, 2003 Robert Wagner <wagner@cns.bu.edu>
% Copyright (C) 2004       George Kierstein <wisp@cns.bu.edu>
%
%   Computer Vision and Computational Neuroscience Lab
%   Department of Cognitive and Neural Systems
%   Boston University
%   Boston, MA  02215


% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

% Date - $Id: mapLeftHemisphere.m,v 1.1.1.1 2008/06/17 19:43:47 eric Exp $
%========================================================================%

function [leftLogmapPoints, leftInvLogmapPoints] = mapLeftHemisphere(p)

	% Compute the Boundry of the Logmap given the scale, radius, and map 
	% parameter a
	%

	% Compute ratio of pixels to degrees
	pixelsPerDegree = p.maxR/p.maxEcc;

	% Convert parameter a to pixels
	a_pixels = p.a*pixelsPerDegree;

	% Set up half arc
	thetaBorder = linspace(pi/2, 3*pi/2, 20);
	halfarc = p.maxR*exp(1i*thetaBorder);
	radius = linspace(log(a_pixels), log(p.maxR+a_pixels), p.k*20)';
	
	% Set vertical meridian
	r = exp(radius) - a_pixels;
	topVert = r*exp(1i*pi/2);
	bottomVert = flipud(r)*exp(1i*3*pi/2);

	% Reorganize the border points such that it is convex
	border = [halfarc(:); bottomVert(:); topVert(:)]; 

    %%%%%%%%%%%%%%%%%%%%%
	if (~isfield(p, 'b'))
		% Calculate left hemifield monopole border
		leftLogmapBorder = p.k * -conj(log(-conj(border) + a_pixels) - log(a_pixels));
	else
		% Convert parameter b to pixels
		b_pixels = p.b*pixelsPerDegree;

		% Calculate left hemifield dipole border
		leftLogmapBorder = -p.k * (log(border - a_pixels) - ...
                        log(border - b_pixels) - log(a_pixels/b_pixels));
    end
    %%%%%%%%%%%%%%%%%%%%%
    
	% Create the grid using the logmap border and find 
	% the points inside the range.
	%

	% Lay down cartesian grid using discretized logmap border
	intLeftLogmapBorder = unique(round(leftLogmapBorder));
	leftLogmapExtent = [min(min(real(intLeftLogmapBorder))) ...
                      max(max(real(intLeftLogmapBorder))) ...
						          min(min(imag(intLeftLogmapBorder))) ...
                      max(max(imag(intLeftLogmapBorder)))];

	[x, y] = meshgrid(leftLogmapExtent(1):leftLogmapExtent(2), ...
		  		  	      leftLogmapExtent(3):leftLogmapExtent(4));

	% Find points inside logmap border
	in = inpolygon(x, y, real(leftLogmapBorder), imag(leftLogmapBorder));

	% Construct the domain of inverse image points
	%

	% Setup mesh grid defining sensor (image) points
	[X, Y] = meshgrid(-p.maxR:0, -p.maxR:p.maxR);
	leftZ = X + i*Y;

	% Define virtual inverse points contained in image
	mag = abs(leftZ);
	I = find(mag <= p.maxR); % Claudio: if maxR is the maximum radius, this just defines the points within the radius of interest
	leftZ = round(leftZ(I));

	% Map the domain to logmap space
	%
	if (~isfield(p, 'b'))
		% Map the image points to monopole space
		leftW = p.k * -conj(log(-conj(leftZ) + a_pixels) - log(a_pixels));
	else
		% Map the image points to dipole space
		leftW = -p.k * (log(leftZ - a_pixels) - log(leftZ - b_pixels) - log(a_pixels/b_pixels));
	end

	% Domain points moved onto an integer grid
	gridPointsW = round(leftW);


	% The inverse mapping
	%

	% W contains all points within discrete logmap along w/the border itself
	W = [complex(x(in), y(in)); intLeftLogmapBorder];

	% Find the one to many relationship between logmap and image points
	[missingW, I] = setdiff(W, gridPointsW);
	missingW = round(missingW);

	if (~isfield(p,'b'))
		% Calculate inverse (image) points for those not already mapped to the monopole 
		missingZ = -conj(a_pixels*(exp(-conj(missingW/p.k)) - 1));
	else
		% Calculate inverse (image) points for those not already mapped to the dipole
		missingZ = (a_pixels*b_pixels*(exp(-missingW/p.k) - 1))./(a_pixels*exp(-missingW/p.k) - b_pixels);
	end
	missingZ = round(missingZ);

	% Collect and translate to one-based matrix coods
	%
	
	% Translate to one-based matrix coords
	logmapOrigin = round(-leftLogmapExtent(1) + 1) - round(leftLogmapExtent(3) - 1)*i;
	gridPointsW = gridPointsW + logmapOrigin;
	leftLogmapPoints = [gridPointsW; missingW + logmapOrigin];
	
	imageOrigin = round(p.nImageCols/2) + (round(p.nImageRows/2))*i;
	leftZ = leftZ + imageOrigin;
	leftInvLogmapPoints = [leftZ; missingZ + imageOrigin];

	(real(leftLogmapPoints));
	(imag(leftLogmapPoints));

	(real(leftInvLogmapPoints));
	(imag(leftInvLogmapPoints));

return;
