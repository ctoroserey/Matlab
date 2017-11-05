function[imDirX, imDirY] = offsetFilterDirection(imGradX, imGradY, wSize, ...
					     dirThresh, ifDirLtThresh)
% offsetFilterDirection Calculates direction of offset vector field for
%   an image.  
%
%   [IMDX, IMDY] = offsetFilterDirection(IMOX, IMOY, WSIZE, DIRTHRESH,
%   IFDIRLTTHRESH)  
%
%   For each pixel, this function uses the gradient vector field in a
%   surrounding neighborhood to determine whether the gradient
%   direction is pointing toward or away from a local edge.  It does this
%   by comparing the gradient vector at a pixel with the gradient vectors
%   at pixels in the surrounding neighborhood.  (If the gradient is viewed
%   as the first derivative of the image, this calculation can be thought
%   of as a second derivative of the image).  If determined that the
%   gradient vector is pointing toward an edge, the offset vector is given
%   the direction opposite the gradient vector.  If the gradient vector is
%   pointing away from an edge, the offset vector is given the same
%   direction as the gradient vector.
%
%   DIRTHRESH is a threshold on the direction calculation at each pixel.
%   If the magnitude of the direction calculation is small, it means the
%   direction is somewhat ambiguous.  If the magnitude is less than
%   DIRTHRESH, the direction is set to 0 (when IFDIRLTTHRESH = 
%   0), set to same direction as (imOrientX, imOrientY) (when
%   IFDIRTLTHRESh = 1), or randomized (when IFDIRLTTHRESH = 2).
%
%   The calculation is done according to Eq. (4.3) of Fischl and Schwartz
%   (1999) Adaptive Nonlocal Filtering... , IEEE PAMI.
%

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

% $Id: offsetFilterDirection.m,v 1.5 2003/03/22 23:01:39 nbomberg Exp $

% Construct mean filter
meanfilter = fspecial('average');

% Calculate orientation images by averaging x- and y- smooth gradient
% images over 3x3 neighborhoods.
imOrientX = filterOF(imGradX, meanfilter, 'reflect1');
imOrientY = filterOF(imGradY, meanfilter, 'reflect1');
  
s = size(imGradX) ;
whalf = floor((wSize-1)/2);   

% Initialize size of imDirX and imDirY so that doesn't cause error
% with -i option for mcc
imDirX = zeros(s);
imDirY = zeros(s);

%count = 0;  % Initialize counter for pixels with dir < dirThresh;

for y0 = 1:s(1)

  for x0 = 1:s(2)
%    sprintf('The current pixel is x0 = %d, y0 = %d\n', x0, y0)
    
    dir = 0;
    for y = -whalf:whalf
      % skip over pixels outside the boundary.
       yc = y0 + y ;
       skip = 0;
       if ((yc < 1) | (yc > s(1)))
	 skip = 1;
       end
       if ~skip
         for x = -whalf:whalf
	   xc = x0 + x ;
           skip = 0;
	   if ((xc < 1) | (xc > s(2)))
	     skip = 1;
           end
           if ~skip
             dot = imGradX(yc, xc) * imOrientX(y0, x0) + ...
		   imGradY(yc,xc) * imOrientY(y0,x0); 
	     if dot < 0
	       dot = 0;
	     end
             dir = dir + (x*imOrientX(y0,x0) + y*imOrientY(y0,x0))*dot ;
	   end
         end  
       end
     end
     
    if (abs(dir) < dirThresh)  % Handling of responses below threshold...
       if (ifDirLtThresh == 0)         % Set to zero...
         imDirX(y0, x0) = 0;
         imDirY(y0, x0) = 0;
       elseif (ifDirLtThresh == 1) % Continue in same direction as gradient...
	 imDirX(y0, x0) = imOrientX(y0, x0);
         imDirY(y0, x0) = imOrientY(y0, x0); 
	 
       elseif (ifDirLtThresh == 2) % This randomizes directions for pixels
				   % with abs(dir) < dirThresh.
         angle = 2*pi*rand;
         imDirX(y0, x0) = 1*cos(angle);
         imDirY(y0, x0) = 1*sin(angle);
	 %disp(sprintf('Randomizing angle.\n'));
       end
    elseif (dir > 0)   % Flip by 180 degrees 
      imDirX(y0, x0) = -imOrientX(y0, x0);
      imDirY(y0, x0) = -imOrientY(y0, x0);
    else
      imDirX(y0, x0) = imOrientX(y0, x0);
      imDirY(y0, x0) = imOrientY(y0, x0);
    end
    %    count = count + 1; 
  end
end

%numLessThanThresh = count;














