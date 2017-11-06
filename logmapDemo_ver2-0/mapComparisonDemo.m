% This script illustrates the diference between the monopole and the dipole.  
% In this demo, the monopole is defined with a max eccentricity of 20 degrees, 
% while the dipole is set to the full visual field of 100 degrees of 
% eccentricity.  As you will see, both maps are equivalent up to 20 degrees of
% eccentricity.  To find out more about the underlying functions used to 
% contruct the maps, type <help constructLogmap> or <help mapImage> to 
% see detailed information.

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

function mapComparisonDemo()

	pm.fname = 'eslab0060.jpg';
	pm.a = 0.5;
	pm.k = 15;
	pm.maxEcc = 100;
	logmapSimple(pm);
	
	pd.fname = 'eslab0060.jpg';
	pd.a = 0.5;
	pd.b = 80;
	pd.k = 15;
	pd.maxEcc = 100;
	pd.showOrig = 0;
	logmapSimple(pd);

return;
