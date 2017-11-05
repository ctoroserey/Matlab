function image_out = padborderOF(image_in, n, format, varargin)
%padborderOF  Pads image to avoid border effects when filtering.
%
%  IMAGE_OUT = padborderOF(IMAGE_IN, N, FORMAT) 
%
%  Adds a border of thickness N to IMAGE_IN to produce IMAGE_OUT.  
%
%  FORMAT is a string determining boundary handling:
%    'repeat'   -  Repeat the edge pixels
%    'reflect1' -  Reflect about the edge pixels
%    'reflect2' -  Reflect, doubling the edge pixels
%    'reflect'  -  Same as 'reflect2'
%    'zeros'    -  Pad with zeros.
%    'remove'   -  Removes a border of thickness N around the image.
%
%    If FORMAT is a numeric value instead of a string, the image will be
%    padded with that value.
%
%  Note: N must be smaller than the smallest dimension of IMAGE_IN.
%
%---------------------------------------------------------------------------
%  Testing:
%  
%  IMAGE_OUT = padborderOF([], [], [], 'test') 
%
%  Performs a test of the function.

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

% $Id: padborderOF.m,v 1.2 2003/02/26 19:14:55 nbomberg Exp $

if nargin > 3
  test = varargin{1};
else
  test = 'notest';
end

switch lower(test)
  % Test padborderOF
 case 'test'
  privateTest;
  
  % Run padborderOF   
 otherwise
  % Get size of input image.
  s = size(image_in);   
  % Make sure third dimension is specified as 1 if image_in is only 2-D.
  if length(s) < 3
    s(3) = 1;
  end

  if isa(format, 'numeric')
    % initialize padded image
    image_out = format*ones(s(1) + 2*n, s(2) + 2*n, s(3));
    % Put input image in center of output image.
    image_out(n+1:s(1)+n, n+1:s(2)+n, :) = image_in;
    
  elseif strcmp(format, 'repeat')
    
    % Put input image in center of output image.
    image_out(n+1:s(1)+n, n+1:s(2)+n) = image_in;
    % Repeat border pixels on left...
    image_out(n+1:s(1)+n, 1:n) = image_in(:, 1)*ones(1, n);
    % right...
    image_out(n+1:s(1)+n, s(2)+n+1:s(2)+2*n) = image_in(:, end)*ones(1,n); 
    % top...
    image_out(1:n, n+1:s(2)+n) = ones(n, 1)*image_in(1, :);
    % bottom
    image_out(s(1)+n+1:s(1)+2*n, n+1:s(2)+n) = ones(n,1)*image_in(end, :);
    % top-left...
    image_out(1:n, 1:n) = image_in(1);
    % top-right...
    image_out(1:n, n+s(2)+1:s(2)+2*n) = image_in(1, s(2));
    % bottom-left...
    image_out(s(1)+n+1:s(1)+2*n, 1:n) = image_in(s(1), 1);
    % bottom-right...
    image_out(s(1)+n+1:s(1)+2*n, s(2)+n+1:s(2)+2*n) = image_in(s(1), s(2));

  elseif (strcmp(format, 'reflect')) | (strcmp(format, 'reflect2'))
    
    % Put input image in center of output image.
    image_out(n+1:s(1)+n, n+1:s(2)+n) = image_in;
    % Reflect image on left...
    image_out(n+1:s(1)+n, 1:n) = image_in(:, n:-1:1);
    % right...
    image_out(n+1:s(1)+n, s(2)+n+1:s(2)+2*n) = image_in(:, s(2):-1:s(2)-(n-1)); 
    % top...
    image_out(1:n, n+1:s(2)+n) = image_in(n:-1:1, :);
    % bottom
    image_out(s(1)+n+1:s(1)+2*n, n+1:s(2)+n) = image_in(s(1):-1:s(1)-(n-1), :);
    % top-left...
    image_out(1:n, 1:n) = image_in(n:-1:1, n:-1:1);
    % top-right...
    image_out(1:n, n+s(2)+1:s(2)+2*n) = image_in(n:-1:1, s(2):-1:s(2)-(n-1));
    % bottom-left...
    image_out(s(1)+n+1:s(1)+2*n, 1:n) = image_in(s(1):-1:s(1)-(n-1), n:-1:1);
    % bottom-right...
    image_out(s(1)+n+1:s(1)+2*n, s(2)+n+1:s(2)+2*n) = ...
	image_in(s(1):-1:s(1)-(n-1), s(2):-1:s(2)-(n-1));

  elseif strcmp(format, 'reflect1')
    
    % Put input image in center of output image.
    image_out(n+1:s(1)+n, n+1:s(2)+n) = image_in;
    % Reflect image on left...
    image_out(n+1:s(1)+n, 1:n) = image_in(:, n+1:-1:2);
    % right...
    image_out(n+1:s(1)+n, s(2)+n+1:s(2)+2*n) = image_in(:, (s(2)-1):-1:s(2)-n);
    % top...
    image_out(1:n, n+1:s(2)+n) = image_in(n+1:-1:2, :);
    % bottom
    image_out(s(1)+n+1:s(1)+2*n, n+1:s(2)+n) = image_in((s(1)-1):-1:s(1)-n, :);
    % top-left...
    image_out(1:n, 1:n) = image_in(n+1:-1:2, n+1:-1:2);
    % top-right...
    image_out(1:n, n+s(2)+1:s(2)+2*n) = image_in(n+1:-1:2, (s(2)-1):-1:s(2)-n);
    % bottom-left...
    image_out(s(1)+n+1:s(1)+2*n, 1:n) = image_in((s(1)-1):-1:s(1)-n, n+1:-1:2);
    % bottom-right...
    image_out(s(1)+n+1:s(1)+2*n, s(2)+n+1:s(2)+2*n) = ...
	image_in((s(1)-1):-1:s(1)-n, (s(2)-1):-1:s(2)-n);
    
  elseif strcmp(format, 'zeros')
    % initialize zeros

    image_out = zeros(s(1) + 2*n, s(2) + 2*n, s(3));
    % Put input image in center of output image.
    image_out(n+1:s(1)+n, n+1:s(2)+n, :) = image_in;
    
  elseif strcmp(format, 'remove') 
    image_out = image_in(n+1:s(1)-n, n+1:s(2)-n, :);
  else
    disp('You did not enter a valid format.')

  end

end 

%----------------------------------------------------------------------------
function[] = privateTest()
%privateTest

rand('state', 50);
im = rand(100, 100);
imPad = padborderOF(im, 50, 'reflect1');
imPad = padborderOF(im, 99, 'reflect1');
imPad = padborderOF(im, 99, 'reflect2');
imPad = padborderOF(im, 99, 'zeros');
imPad = padborderOF(im, 99, 'repeat');
imUnPad = padborderOF(imPad, 99, 'remove');
disp(sprintf('\nTests passed\n'));

 
  
