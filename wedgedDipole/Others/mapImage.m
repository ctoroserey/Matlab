% [logmapImage, invLogmapImage] = mapImage(img, logmapPoints, invLogmapPoints)
%
% Purpose: Map image (img) using the LUT provided by [logmapImage, invLogmapImage]
% 
% Input:
%	  img             - input image (must be NON-INDEXED)
%		logmapPoints    - vector of integer-spaced points belonging to the "cortical map"
%		invLogmapPoints - vector of integer-space points belonging to the "retinal map"
%
% Note: The last two arguments are the result of running constructLogmap.  Type
%		    <help constructLogmap> for details.
%
% Output:
%		logmapImage    - image produced by forward mapping
%		invLogmapImage -  image produced by inverse mapping
%
% Note: The resulting images are the same type as the input image.

% Copyright (C) 2002, 2003 Robert Wagner <wagner@cns.bu.edu>
% Copyright (C) 2004 			 George Kierstein <wisp@cns.bu.edu>
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

function [logmapImage, invLogmapImage] = mapImage(img, logmapPoints, invLogmapPoints)

	% Get image dimensions
	%
	% Note: Operating on grey image's non-existent singleton dimension 
	%       since MATLAB doesn't seem to give a way to explicitly encode
	%       then and doesn't mind operating as if they are there.
	%
	[nImageRows, nImageCols, depth] = size(img);

	% Compute # Rings and Rays
	numRings = abs(max(max(real(logmapPoints))) - min(min(real(logmapPoints)))) + 1;
	numRays = abs(max(max(imag(logmapPoints))) - min(min(imag(logmapPoints)))) + 1;

    disp(numRings)
    disp(numRays)
    
	% Init logmap image, mask and accumulator arrays
	logmapImage = zeros(numRays, numRings);
	invLogmapImage = zeros(nImageRows, nImageCols, depth);

	logmapMask = zeros(numRays, numRings);
	logmapCount = zeros(numRays, numRings);
	logmapAccum = zeros(numRays, numRings, depth);

	% Run over the many to many relationship between logmapPoints and invLogmapPoints
	% to construct forward and inverse logmapped images
	nPoints = length(logmapPoints);

	% Forward Map
	%
	for n = 1:nPoints

		r = imag(logmapPoints(n));
		c = real(logmapPoints(n));
		x = real(invLogmapPoints(n));
		y = imag(invLogmapPoints(n));

		logmapMask(r,c) = 1;
		logmapCount(r,c) = logmapCount(r,c) + 1;

		logmapAccum(r,c,1) = logmapAccum(r,c,1) + img(y, x, 1);

		if (depth == 3)
			logmapAccum(r,c,2) = logmapAccum(r,c,2) + img(y, x, 2);
			logmapAccum(r,c,3) = logmapAccum(r,c,3) + img(y, x, 3);
		end

	end

	% Mean value 
	index = find(logmapMask);

	R = logmapAccum(:,:,1);
	R(index) = R(index)./logmapCount(index);
	logmapImage(:,:,1) = R;

	if (depth == 3)

		G = logmapAccum(:,:,2);
		G(index) = G(index)./logmapCount(index);
		logmapImage(:,:,2) = G;

		B = logmapAccum(:,:,3);
		B(index) = B(index)./logmapCount(index);
		logmapImage(:,:,3) = B;
	end;

	% Create inverse image by mapping log points back to image domain
	%

	[uniqueInvLogmapPoints, I, J] = unique(invLogmapPoints);
	nUniquePoints = length(uniqueInvLogmapPoints);

	for n = 1:nUniquePoints

		x = real(uniqueInvLogmapPoints(n));
		y = imag(uniqueInvLogmapPoints(n));
		c = real(logmapPoints(I(n)));
		r = imag(logmapPoints(I(n)));
		invLogmapImage(y,x,:) = logmapImage(r,c,:);
	end

return;
