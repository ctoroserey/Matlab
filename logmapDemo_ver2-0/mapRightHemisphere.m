% version 2.0 6-17-08 removed mbint() for R14sp3 and above (ELS)
% [rightLogmapPoints, rightInvLogmapPoints] = mapRightHemisphere(p);
%
% mapRightHemisphere constructs a LUT in the form of two output vectors for either a 
% monopole or dipole mapping of the right visual field.
% 
% Parameters:
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
%		rightLogmapPoints    - a vector of integer-spaced points belonging to the right 
%                         hemifield "cortical map"
%		rightInvLogmapPoints - a vector of integer-space points belonging to the right 
%                         hemifield "retinal map" 
%
% Note: There is a one-to-one mapping in the resulting LUT 
%       (i.e. length(rightLogmapPoints) = length(rightInvPoints))
%
  
% Copyright (C) 2002, 2003 Robert Wagner <wagner@cns.bu.edu>
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

% Date - $Id: mapRightHemisphere.m,v 1.1.1.1 2008/06/17 19:43:47 eric Exp $
%========================================================================%

function [rightLogmapPoints, rightInvLogmapPoints] = mapRightHemisphere(p);

	% Compute the Boundry of the Logmap given the scale, radius, and map 
	% parameter a
	%

	% Compute ratio of pixels to degrees
	pixelsPerDegree = p.maxR/p.maxEcc;

	% Convert parameter a to pixels
	a_pixels = p.a*pixelsPerDegree;

	% Compute ratio of pixels to degrees
	pixelsPerDegree = p.maxR/p.maxEcc;

	% Set up half arc
	thetaBorder = linspace(-pi/2, pi/2, 20);
	halfarc = p.maxR*exp(i*thetaBorder);
	radius = linspace(log(a_pixels), log(p.maxR+a_pixels), p.k*20)';

	% Set vertical meridian
	r = exp(radius) - a_pixels;
	topVert = flipud(r)*exp(i*pi/2);
	bottomVert = r*exp(i*-pi/2);

	% Reorganize border such that it is convex
	border = [halfarc(:); topVert(:); bottomVert(:)];

	if (~isfield(p,'b'))
		% Calculate right hemifield monopole border
		rightLogmapBorder = p.k * (log(border + a_pixels) - log(a_pixels));
	else

		% Convert parameter b to pixels
		b_pixels = p.b*pixelsPerDegree;

		% Calculate right hemifield dipole border
		rightLogmapBorder = p.k * (log(border + a_pixels) ...
                        - log(border + b_pixels) - log(a_pixels/b_pixels));
	end

	% Create the grid using the logmap border and find 
	% the points inside the range.
	%

	% Lay down cartesian grid using discretized logmap border
	intLogmapBorder = unique(round(rightLogmapBorder));

	rightLogmapExtent = [min(min(real(intLogmapBorder))) ...
                       max(max(real(intLogmapBorder))) ...
					 	           min(min(imag(intLogmapBorder))) ...
                       max(max(imag(intLogmapBorder)))];
	
	[x, y] = meshgrid(rightLogmapExtent(1):rightLogmapExtent(2), ...
		  		  	      rightLogmapExtent(3):rightLogmapExtent(4));
	
	% Find points inside logmap border
	in = inpolygon(x, y, real(rightLogmapBorder), imag(rightLogmapBorder));
	
	% Construct the range of the log mapping 
	%

	% Setup mesh grid defining sensor (image) points
	[X, Y] = meshgrid(0:p.maxR, -p.maxR:p.maxR);
	rightZ = X + i*Y;
	
	% Define virtual inverse points contained in image
	mag = abs(rightZ);
	index = find(mag <= p.maxR);
	rightZ = round(rightZ(index));

	if (~isfield(p, 'b'))
		% Map the image points to monopole space
		rightW = p.k * (log(rightZ + a_pixels) - log(a_pixels));
	else
		% Map the image points to dipole space
		rightW = p.k * (log(rightZ + a_pixels) - log(rightZ + b_pixels) - log(a_pixels/b_pixels));
	end
	
	% Move the image points onto integer grid
	gridPointsW = round(rightW);

	% Construct the domain of the mapping
	%

	% W contains all points within discrete logmap along w/the border itself
	W = [complex(x(in), y(in)); intLogmapBorder];
	
	% Find the one to many relationship between logmap and image points
	[missingW, I] = setdiff(W, gridPointsW);
	missingW = round(missingW);
	
	if (~isfield(p, 'b'))
		% Calculate inverse (image) points for those not already mapped to the monopole
		missingZ = a_pixels*(exp(missingW/p.k) - 1);
	else
		% Calculate inverse (image) points for those not already mapped to the dipole
		missingZ = a_pixels*b_pixels*(1 - exp(missingW/p.k))./(a_pixels*exp(missingW/p.k) - b_pixels);
	end
	missingZ = round(missingZ);

	% Collect and translate to one-based matrix coods
	%
	
	% Translate to one-based matrix coords.
	logmapOrigin = round(-rightLogmapExtent(1) + 1) - (round(rightLogmapExtent(3) - 1))*i;
	gridPointsW = gridPointsW + logmapOrigin;
	rightLogmapPoints = [gridPointsW; missingW + logmapOrigin];

	% Translate virtual image points to one-based matrix coords.
	imageOrigin = (round(p.nImageCols/2)) + (round(p.nImageRows/2))*i;
	rightZ = rightZ + imageOrigin;
	rightInvLogmapPoints = [rightZ; missingZ + imageOrigin];

	(real(rightLogmapPoints));
	(imag(rightLogmapPoints));

	(real(rightInvLogmapPoints));
	(imag(rightInvLogmapPoints));

return;
