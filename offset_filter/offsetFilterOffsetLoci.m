function [imOffsetLoci] = offsetFilterOffsetLoci(lookupx, lookupy) ;

% offsetFilterOffsetLoci Takes images of pixel locations of offsets, and
% returns image containing loci of offset points.
%
% Usage: IMOFFSETLOCI = offsetFilterOffsetLoci(LOOKUPX, LOOKUPY)

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

% $Id: offsetFilterOffsetLoci.m,v 1.3 2003/02/26 18:44:06 nbomberg Exp $

row = size(lookupx, 1); col = size(lookupx, 2);

imOffsetLoci = zeros(row, col);

index = (lookupx - 1)*row + lookupy;

for m = 1:row
  for n = 1:col
    imOffsetLoci(index(m, n)) = imOffsetLoci(index(m, n)) + 1;
  end
end
