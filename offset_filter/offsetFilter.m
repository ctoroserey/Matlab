function[imOF, varargout] = offsetFilter(im, varargin) 
% offsetFilter Nonlocal (offset) filter of Fischl & Schwartz.
%
% Implements offset filter of Bruce Fischl & Eric Schwartz (1999)
% "Adaptive non-local filtering: A fast alter,native to anisotropic
% diffusion for image segmentation." PAMI 22(1):42-48.
%
% Usage:
%
% [IMOFFSETFILTERED] = offsetFilter(IM)
%
% takes an image IM and returns the offset-filtered image
% IMOFFSETFILTERED.  The function can also be called with the following
% optional arguments:
%
% [IMOFFSETFILTERED, <IMOFFSETLOCI>] = offsetFilter(IM, <FILTERTYPE>,
% <FILTERSIGMA>, <SMOOTHSIGMA>, <DIRWINSZ>, <MAXSTEPS>)
%
%-----------------
% Input arguments:
%
%  IM  -->  Input image.  Only grey-scale images supported.
%
%  FILTERTYPE  -->  Optional. Specifies filter to apply to image.
%  'gaussian' (default) or 'median' are supported.
%
%  FILTERSIGMA  -->  Optional.  If FILTERTYPE == 'gaussian', specifies
%  sigma of the Gaussian used (default = 2).  If FILTERTYPE == 'median',
%  specifies size of one size of the median filter (default = 3).
%
%  SMOOTHSIGMA  -->  Optional.  Sigma of the Gaussian used to smooth the
%  image before calculating the offset vector field. (default = 2).
%
%  DIRWINSZ  -->  Optional.  Size of one side of the square window used to
%  calculate the initial offset direction vector field. (default = 5).
%
%  MAXSTEPS  -->  Optional.  Maximum number of pixel steps to take in
%  calculating an offset vector. (default = 50)
%  
%------------------
% Output arguments:
%
%  IMOF  -->  Offset-filtered image.
%
%  IMOL  -->  Optional.  Image of offset point loci.  Each pixel value is
%  an incidence count of the number of pixels whose offset landed at that
%  pixel.  

%--------------------------------------------------------------------------
%
%    Copyright (C) 2003 Neil Bomberger
%
%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%    USA 
% 
%  ------------
%  Contact info:
%   email:   neil.bomberger@ieee.org
%   address: Neil Bomberger, Dept of CNS, Boston University, 
%            677 Beacon St, Boston MA, 02215 
%
%---------------------------------------------------------------------------

% $Id: offsetFilter.m,v 1.5 2003/02/26 18:44:06 nbomberg Exp $

%keyboard;
[filterType, filterSigma, smoothSigma, dirWinSz, maxSteps, dirTh, ...
 ifDirLtThresh] = setOffsetFilterParameters(nargin, varargin);


sSize = 4*(ceil(smoothSigma)) + 1;
sg = fspecial('gaussian', sSize, smoothSigma);
smoothIm = filterOF(im, sg, 'reflect1');

%keyboard;
if strcmp(filterType, 'gaussian')
  fSize= 4*(ceil(filterSigma)) + 1;
  fg = fspecial('gaussian', fSize, filterSigma);
  filteredIm = filterOF(im, fg, 'reflect1');
elseif strcmp(filterType, 'median')
  fSize = filterSigma;
  filteredIm = medfilt2(im, [fSize fSize]);
end  

% Find orientation images for offset vector field calculation.
[imOX, imOY, imGradMag] = offsetFilterOrientation(smoothIm);

% Calculate initial direction of vector offset field
[imDirX, imDirY] = offsetFilterDirection(imOX, imOY, dirWinSz, dirTh, ...
					 ifDirLtThresh); 

% Calculate offset vector field
[imOffsetX, imOffsetY] = offsetFilterMagnitude(imDirX, imDirY, maxSteps); 

% Apply offsets as lookup table to filtered image to generate
% offset-filtered image
[imOF, lookupX, lookupY] = offsetFilterApplyOffset(filteredIm, ...
					      imOffsetX, imOffsetY) ;     

if (nargout > 1)
  % Generate image of offset loci
  imOffsetLoci = offsetFilterOffsetLoci(lookupX, lookupY);
  varargout{1} = imOffsetLoci;
end

%------------------------------------------------------------------------
function[filterType, filterSigma, smoothSigma, dirWinSz, maxSteps, ...
	 dirTh, ifDirLtThresh] = setOffsetFilterParameters(nargin, varargin)

% Extract cell array
varargin = varargin{1};

% Set Optional input arguments
if (nargin > 1)
  filterType = varargin{1};
%  keyboard;
else
  filterType = 'gaussian';
end
if (nargin > 2)
  filterSigma = varargin{2};
else
  if filterType == 'gaussian'
    filterSigma = 2;
  elseif filterType == 'median'
    filterSigma = 3;
  end
end
if (nargin > 3)
  smoothSigma = varargin{3};
else
  smoothSigma = 2;
end
if (nargin > 4)
  dirWinSz = varargin{4};
else
  dirWinSz = 5;
end
if (nargin > 5)
  maxSteps = varargin{5};
else
  maxSteps = 50;
end

% Parameters
dirTh = 0;
ifDirLtThresh = 0;
