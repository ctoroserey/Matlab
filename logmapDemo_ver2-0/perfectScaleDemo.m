
% This script illustrates the use of constructLogmap and mapImage to 
% achieve perfect scale.  Type <help constructLogmap> or <help 
% mapImage> to see more detailed information.  Examples of both 
% the monopole and the dipole mapping are shown.

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

function perfectScaleDemo()

	p.fname = 'eslab0018.jpg';
	p.a = 0.5;	 
	p.F = 36;	 % Frame length (35mm frame size = 24mm x 36mm)
	p.f = 28;  % Focal Length (mm)
	logmapSimple(p);

return;

