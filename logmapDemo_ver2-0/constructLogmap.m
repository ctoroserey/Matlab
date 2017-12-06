
%	[logmapPoints, invLogmapPoints, k, FOV] = constructLogmap(parameterStruct)
%
% This method constructs a LUT in the form of two output vectors for either a 
% monopole or dipole mapping of the full visual field.  This function uses
% two mapping functions (mapLeftHemisphere and mapRightHemisphere)
% 
% Parameters:
%
%		nImageRows - Height of original image (pixels)
%		nImageCols - Width of original image (pixels)
%		maxR       - Max Radius (pixels)
%		maxEcc     - Max Eccentricity (degrees)
%		k          - Global map scale parameter (pixels)
%   a          - Monopole/Dipole map parameter (degrees)
%   b          - Dipole map parameter (degrees) [Optional]
%   F   	     - Frame Length of dimension of interest        [Optional]
%                (e.g. 35mm film has frame size of 24mm x 36mm)
%   f		       - Focal length (e.g. 50mm lens)                [Optional]
%
% Note: If the frame length and focal length are specified, the scale parameter k is computed to 
% 		  create a "perfect scale" - meaning that one pixel at the origin of the image maps
%       to one pixel in the corresponding cortical region.
%
% Output:
%
%		logmapPoints    -  vector of integer-spaced points belonging to the "cortical map"
%		invLogmapPoints - vector of integer-space points belonging to the "retinal map"
%   k               - "perfect scale" global map parameter
%   FOV             - field of view computed from F and f
%
% Note: There is a one-to-one mapping in the resulting LUT 
%        (i.e. length(leftLogmapPoints) = length(leftInvPoints))
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
% Copyright (C) 2002, 2003 Robert Wagner <wagner@cns.bu.edu>
% Copyright (C) 2004       George Kierstein <wisp@cns.bu.edu>
%
%   Computer Vision and Computational Neuroscience Lab
%   Department of Cognitive and Neural Systems
%   Boston University
%   Boston, MA  02215
%

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

function varargout = constructLogmap(p)


	% Required parameters
	%
	if (~isfield(p, 'nImageRows') | ...
      ~isfield(p, 'nImageCols') | ...
      ~isfield(p, 'maxR') | ...
	    ~isfield(p, 'a'))

		fieldnames(p)
		error(sprintf('constructLogmap> Incorrect number of input arguments.\n'));
	end;

	if (~ismember(nargout, [2, 4]))
		error(sprintf('constructLogmap> Incorrect number of ouput arguments. Found %d, expecting %s.\n',  nargout, '2 or 4'));
	end 

	% Check maxR based on min. image dimension
	maxRadius = round(min([p.nImageCols, p.nImageRows])/2) - 1;
	if (p.maxR > maxRadius) 
		strError = 'maxR greater than min image dimension'; 
		error(sprintf('constructLogmap> %s\n', strError));
	end 

	% The Frame length is specified - Compute parameter k and override maxEcc
	%
	if (isfield(p, 'F')) 

		% Focal length and Field length come in pairs
		if (~isfield(p,'f'))
			strError = 'Focal Length required when Field Length is specified';
			error(sprintf('constructLogmap> %s\n', strError));
		end;

		if (~isNumericScalar(p.F) | ~isNumericScalar(p.f))
			strError = 'Field Length and Focal Length must be numeric scalar values.';
			error(sprintf('constructLogmap> %s\n', strError));
		end;

		[FOV, maxEcc, k] = calculateFOV(p);
		p.maxEcc = maxEcc;
		p.k = k;

	else

		FOV = -1;
		f = -1;
        
	end;

    
	if (~isNumericScalar(p.a) | ~isfield(p, 'k') | ~isNumericScalar(p.k))
			
		error(sprintf('constructLogmap> k and a must have numeric scalar values.\n'));
        
	end;

	%% Create the Hemifield Maps
	%
	disp('Creating Left Hemifield Map...');
	[leftLogmapPoints, leftInvLogmapPoints] = mapLeftHemisphere(p); % Claudio: this outputs 2 single complex vectors, not matrices..

    %%%%%%%%% Claudio: not interesting right now
	disp('Creating Right Hemifield Map...');
	[rightLogmapPoints, rightInvLogmapPoints] = mapRightHemisphere(p);

	% Translate right logmap points to create a butterfly image
	nLeftRings = abs(max(max(real(leftLogmapPoints))) - min(min(real(leftLogmapPoints)))) + 1;
	Tx = nLeftRings;
    
	% Merge the two hemifields
	logmapPoints = [leftLogmapPoints; (rightLogmapPoints + Tx)];
	invLogmapPoints = [leftInvLogmapPoints; rightInvLogmapPoints];

    %%%%%%%%%
	% Return the many to many relationship between the forward and inverse mappings in two vectors.
	if (nargout > 0) 

		varargout{1} = logmapPoints;
		varargout{2} = invLogmapPoints;

		% If k is derived return it along with the FOV
		if (nargout == 4)

			if (isfield(p,'F'))
				varargout{3} = k;
				varargout{4} = FOV;
			else
				varargout{3} = p.k;
				varargout{4} = -1;
			end;
		end
	end

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate Field of View (FOV) using frame length along desired dimension 
% on film or sensor array and the focal length and 
% Calculate the Global Map Scale Parameter required for "perfect scale"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [FOV, maxEcc, k] = calculateFOV(param)  

		% FOV Calculation
		%
		FOV = round(2*atan(param.F/(2*param.f))*180/pi); % FOV calculation (rounded to nearest degree)

		% Half field of view - "Optics" (degrees)
		R = FOV/2;	
		maxEcc = R;

		% Radius of disk in pixels
		p = param.maxR;	

		% Calculate ratio of degrees to pixels
		L = R/p; 

		if (isfield(param, 'b'))

			if (~isNumericScalar(param.b))
				strError = 'Dipole parameter b must be a numeric scalar.';
				error(sprintf('constructLogmap> %s\n', strError));
			end;

			dipole = 1;
		else
			dipole = 0;
		end;

		if (dipole)
			k = 1/(log((L + param.a)/(L + param.b)) - log(param.a/param.b));
		else 
			k = 1/(log((L + param.a)/param.a));
		end

return;


function bool = isNumericScalar(num)

	if (~isnumeric(num) | prod(size(num))~=1 | isempty(num) | ~isfinite(num))
		bool = 0;
	else
		bool = 1; 
	end;

return;
