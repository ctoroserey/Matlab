function [imMagX , imMagY] = offsetFilterMagnitude(imDirX, imDirY, maxSteps) 
% offsetFilterMagnitude  Does line search in direction of initial vector
% field, to find point where vector field goes to zero, or turns by >= 90 deg
% relative to starting point.
%
% [IMAGX, IMAGY] = offsetFilterMagnitude(IDIRX, IDIRY, MAXSTEPS,
% STOPSHORT) returns images IMAGX and IMAGY which contain x-components
% and y-components of final offset vector field, using initial offset
% vector field images IDIRX and IDIRY.  MAXSTEPS is the maximum number of
% pixels over which to search for the offset point. 
%
% The function implements Eq. (4.5) of Fischl and Schwartz (1999) Adaptive
% Nonlocal Filtering... , IEEE PAMI. 

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

% $Id: offsetFilterMagnitude.m,v 1.4 2003/03/06 00:54:23 nbomberg Exp $

FSCALE = 1000;

% Calculate number of rows and columns in the offset field images.
rows = size(imDirX, 1) ;  cols = size(imDirX, 2);

% Initialize imMagX  and imMagY to zero.
imMagX  = zeros(rows, cols);
imMagY = zeros(rows, cols);

for yc = 1:rows
  for xc = 1:cols
%    sprintf('The current pixel is xc = %d, yc = %d\n', xc, yc)
    % Do a Bresenham algorithm to find the offset line at this point
    dx = imDirX(yc, xc);
    dy = imDirY(yc, xc);    
    % Initialize xOld and yOld to zeros.
    %% - xOld = zeros(1, numOld); yOld = zeros(1, numOld);
    xOld = xc;  yOld = yc;
    xOffset = xc;  xNew = xc;
    yOffset = yc;  yNew = xc;
    ax = (abs(round(dx*FSCALE)))*2 ;
    sx = sign(round(dx*FSCALE));
    ay = (abs(round(dy*FSCALE)))*2 ;
    sy = sign(round(dy*FSCALE));

    if (sqrt(dx.^2 + dy.^2) > 0)  % Don't search if initial vector is zero.
      if (ax > ay) % x dominant
		 %      sprintf('x is dominant\n')
        d = ay - (ax/2);
	for (steps = 1:maxSteps)
	
	  if (d >= 0)    % move in y direction
	    yNew = yOld(1) + sy;
	    if ((yNew < 1) | (yNew > rows))  % Stop if new point is off image.
	      break;
	    end
	    xNew = xOld(1);
	    d = d - ax;
	  else          % move in x direction
	    xNew = xOld(1) + sx;
	    if (xNew < 1 | (xNew > cols))    % Stop if new point is off image.
	      break;
	    end
	    yNew = yOld(1);
	    d = d + ay;
	  end
	  xOffset = xNew;
	  yOffset = yNew;
	  
	  % Vector at new point.
          odx = imDirX(yNew, xNew);
	  ody = imDirY(yNew, xNew);
          % Take dot product of vector at new point with vector at
          % starting point. 
	  dot = odx*dx + ody*dy ;   

	  if (dot <= 0)         % Stop search if found point where vector
                                % field reverses 
	    xOffset = xOld;     % from starting point.
	    yOffset = yOld;
	    break;
	  end	  
	  xOld= xNew;
	  yOld= yNew;
	end
        
      else    % y dominant
	      %      sprintf('y is dominant')
	d = ax - (ay/2);
	for (steps = 1:maxSteps)

	  if (d >= 0)    % move in x direction 
	    xNew = xOld(1) + sx;
	    if ((xNew < 1) | (xNew > cols))    % Stop if new point is off
                                               % image. 
	      break;
	    end
	    yNew = yOld(1);
	    d = d - ay;
	  else          % move in x direction
	    yNew = yOld(1) + sy;
	    if (yNew < 1 | (yNew > rows))    % Stop if new point is off image.
	      break;
	    end
	    xNew = xOld(1);
	    d = d + ax;
	  end
	  
	  xOffset = xNew;
	  yOffset = yNew;

	  % Vector at new point
          odx = imDirX(yNew, xNew);
	  ody = imDirY(yNew, xNew);  	  
	  dot = odx*dx + ody*dy ;

	  if (dot <= 0)       % Stop search if found point where vector field
	    %xOffset = xOld;   % reverses from starting point.
	    %yOffset = yOld; 	    
	    break;
	  end  
	  xOld= xNew;
	  yOld= yNew;
	end 
      end
    end
    % Set the x- and y-components of the offset vector at (xc, yc).  
    imMagX(yc, xc) = (xOffset - xc);
    imMagY(yc, xc) = (yOffset - yc);
    
  end
end 
