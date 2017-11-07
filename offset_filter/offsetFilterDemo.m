% offsetFilterDemo.m
% Type 'offsetFilterDemo' to run.

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

% $Id: offsetFilterDemo.m,v 1.2 2003/02/26 18:44:06 nbomberg Exp $

im = imread('pig.jpg');
im = im(:,:,1);
imn1 = imnoise(im, 'gaussian', 0, 0.1);
imn5 = imnoise(im, 'gaussian', 0, 0.5);

imOF = offsetFilter(im);
imn1OF = offsetFilter(imn1);
imn5OF = offsetFilter(imn5);

figure;
set(gcf, 'Position', [100 100 1400 800]);
subplot(2, 3, 1);
imagesc(im);
colormap(gray(256));
axis image; axis off;
title('Original image', 'FontSize', 16);

subplot(2, 3, 2);
imagesc(imn1);
colormap(gray(256));
axis image; axis off;
ttext = sprintf('Image w/Gaussian noise\n(0 mean, 0.001 variance)');
title(ttext, 'FontSize', 16);

subplot(2, 3, 3);
imagesc(imn5);
colormap(gray(256));
axis image; axis off;
ttext = sprintf('Image w/Gaussian noise\n(0 mean, 0.005 variance)');
title(ttext, 'FontSize', 16);

subplot(2, 3, 4);
imagesc(imOF);
colormap(gray(256));
axis image; axis off;
title('Offset filtered original image', 'FontSize', 16);

subplot(2, 3, 5);
imagesc(imn1OF);
colormap(gray(256));
axis image; axis off;
title('Offset filtered noisy image', 'FontSize', 16);

subplot(2, 3, 6);
imagesc(imn5OF);
colormap(gray(256));
axis image; axis off;
title('Offset filtered noisy image', 'FontSize', 16);

