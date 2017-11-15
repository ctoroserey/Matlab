% logmapSimple(parameters)
% Version 2.0 for R14SP3 and later
% Replaces deprecated isgray, isind, isrgb and 
% logmapSimple constructs a logmap and its inverse image using
% the monopole log(z+a) or dipole log(z+a)/log(z + b) mappings.
%
%  Parameters (as a MATLAB structure) are OPTIONAL
%
%		fname   - Image to warp
%		k       - Global map scale parameter (pixels)
%		maxEcc  - Max Eccentricity (degrees)
%   a       - The a map parameter of the monopole (degrees) 
%   b       - Dipole map parameter (degrees) 
%   F   	  - Frame Length of dimension of interest        
%             (e.g. 35mm film has frame size of 24mm x 36mm)
%   f		    - Focal length (e.g. 50mm lens)                
%
%   showOrig - 0 if you don't want the origional displayed
% 
%   Version 2.0 Modified by ELS on 6-17-2008 to fix problem with deprecated isgray and
%   isind functions. Using imfinfo instead
%
%
%  References:
%  ===========
%
% [1] Alan S. Rojer and Eric L. Schwartz. Design considerations for a 
% 	  space-variant visual sensor with complex-logarithmic geometry. 
% 	  In Proceedings. 10th International Conference on Pattern Recognition, 
% 	  volume 2 of International Conference on Pattern Recognition, 
% 	  pages 278-285, Atlantic City, NJ, June 16-21 1990. Int. Assoc. 
% 	  Pattern Recognition, IEEE Comput. Soc. Press.
%

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

function logmapSimple(p)

	if (nargin == 0 || ~isfield(p,'fname'))
		p.fname = 'eslab0018.jpg';
	end

	[p.a, p.k, p.maxEcc] = checkParameters(p);

	% Check for existence of image
	[fid1, message] = fopen(p.fname, 'r');
	if (fid1 == -1)
		error(sprintf('Erorr reading file <%s>: %s', p.fname, message));
	end
	fclose(fid1);
    
        %ELS 6-17-08 use imfinfo to findout image type
        % info.ColorType is 'indexed' or 'grayscale' or truecolor
        %% ELS FIX
        info = imfinfo(p.fname);
        INDEXED   = strmatch(info.ColorType, 'indexed');
        GRAYSCALE = strmatch(info.ColorType, 'grayscale');
        TRUECOLOR = strmatch(info.ColorType, 'truecolor');
        %
    	% Read in image and convert to type double
	img = im2double(imread(p.fname));
	
	% Convert indexed image to non-indexed image
	%if (isind(img) & isrgb(img))
	  if (INDEXED & TRUECOLOR)
       img = ind2rgb(img);
	  end
	%if (isind(img) & isgray(img))
	  if (INDEXED & GRAYSCALE)
       img = ind2gray(img);
	  end

	if (~isfield(p,'showOrig') | p.showOrig == 1)	
		figure('Name', 'Original Image');
		imagesc(img);
		if (GRAYSCALE)
			colormap gray
		end
		axis equal;
		axis tight;
	end;
	
	[p.nImageRows, p.nImageCols, depth] = size(img); 
	
	% Compute Max Eccentricity based on min image dimension
	p.maxR = min([p.nImageCols, p.nImageRows])/2 - 1;
	fprintf('Image %s is %dx%d\n', p.fname, p.nImageCols, p.nImageRows);
	tic;
	
	[logmapPoints, invLogmapPoints, k, FOV] = constructLogmap(p);
	fprintf('Elapsed Time to create map: %f seconds\n', toc);

	tic;	
	fprintf('Mapping Logmap Image and Its Inverse...\n');
	[logmapImage, invLogmapImage] = mapImage(img, logmapPoints, invLogmapPoints);
	figure('Name', 'Logmap Image');
	imagesc(logmapImage);
	fprintf('Elapsed Time to warp logmap and its inverse: %f seconds\n', toc);

	if (FOV == -1)	
		if (~isfield(p,'b'))
			strTitle = sprintf('Monopole (k = %5.2f, a = %5.2f)', p.k, p.a);
		else
			strTitle = sprintf('Dipole (k = %5.2f, a = %5.2f, b = %5.2f)', p.k, p.a, p.b);
		end;
	else
		if (~isfield(p,'b'))
			strTitle = sprintf('Monopole (k = %5.2f, a = %5.2f, FOV = %d^\\circ)', k, p.a, FOV);
		else
			strTitle = sprintf('Dipole (k = %5.2f, a = %5.2f, b = %f.2f, FOV = %d^\\circ)', k, p.a, p.b, FOV);
		end;
	end;

	title(strTitle);
	if (GRAYSCALE)
		colormap gray
	end
	axis equal;
	axis tight;
	
	figure('Name', 'Inverse Logmap Image');
	imagesc(invLogmapImage);

	if (FOV == -1)	
		if (~isfield(p,'b'))
			strTitle = sprintf('Inverse Monopole (k = %5.2f, a = %5.2f)', p.k, p.a);
		else
			strTitle = sprintf('Inverse Dipole (k = %5.2f, a = %5.2f, b = %5.2f)', p.k, p.a, p.b);
		end;
	else
		if (~isfield(p,'b'))
			strTitle = sprintf('Inverse Monopole (k = %5.2f, a = %5.2f, FOV = %d^\\circ)', k, p.a, FOV);
		else
			strTitle = sprintf('Inverse Dipole (k = %5.2f, a = %5.2f, b = %f.2f, FOV = %d^\\circ)', k, p.a, p.b, FOV);
		end;
	end;
	title(strTitle);
	if (GRAYSCALE)
		colormap gray
	end
	axis equal;
	axis tight;

return;

function [a, k, maxEcc] = checkParameters(p)

	if (~isfield(p,'a'))
		a = 0.5;	 
	else
		a = p.a;
	end;

	if (~isfield(p,'k'))
		k = 15;
	else
		k = p.k;
	end;

	if (~isfield(p,'maxEcc'))
		maxEcc = 100;
	else
		maxEcc = p.maxEcc;
	end;

return;

