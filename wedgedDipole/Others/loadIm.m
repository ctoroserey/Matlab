%% main function
function [p] = loadIm(p)

    % just general temporary setup
    beta = 80;
    
    %% from logmapSimple.m
    if (nargin == 0 || ~isfield(p,'fname'))
		p.fname = 'steve.png';
	end

	[p.alpha, p.k, p.maxEcc] = checkParameters(p);

	% Check for existence of image
	[fid1, message] = fopen(p.fname, 'r');
	if (fid1 == -1)
		error(sprintf('Erorr reading file <%s>: %s', p.fname, message));
	end
	fclose(fid1);
    
        %ELS 6-17-08 use imfinfo to findout image type
        % info.ColorType is 'indexed' or 'grayscale' or truecolor
        % ELS FIX
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

	if (~isfield(p,'showOrig') || p.showOrig == 1)	
		figure('Name', 'Original Image');
		imagesc(img);
		if (GRAYSCALE)
			colormap gray
		end
		axis equal;
		axis tight;
	end;
	
	[p.nImageRows, p.nImageCols, p.depth] = size(img); 
    
    p.maxR = min([p.nImageCols, p.nImageRows])/2 - 1;
    p.pixPerDegree = p.maxR/p.maxEcc;
    p.b = beta;
    p.a_pixs = p.alpha*p.pixPerDegree;
    p.b_pixs = p.b*p.pixPerDegree;
    
    %% from constructLogmap.m
    % Required parameters
	%
	if (~isfield(p, 'nImageRows') | ...
      ~isfield(p, 'nImageCols') | ...
      ~isfield(p, 'maxR') | ...
	    ~isfield(p, 'alpha'))

		fieldnames(p)
		error(sprintf('constructLogmap> Incorrect number of input arguments.\n'));
	end;

	if (~ismember(nargout, [1, 2, 4]))
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

	    [p.FOV, maxEcc, k] = calculateFOV(p);
		p.maxEcc = maxEcc;
		p.k = k;

	else

		p.FOV = -1;
		p.f = -1;
        
	end;

    
	if (~isNumericScalar(p.alpha) | ~isfield(p, 'k') | ~isNumericScalar(p.k))
			
		error(sprintf('constructLogmap> k and a must have numeric scalar values.\n'));
        
	end;
    
return;



%% other necessary functions
function [a, k, maxEcc] = checkParameters(p)

if (~isfield(p,'alpha'))
    a = 0.5;	 
else
    a = p.alpha;
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
			k = 1/(log((L + param.alpha)/(L + param.b)) - log(param.alpha/param.b));
		else 
			k = 1/(log((L + param.alpha)/param.alpha));
		end

return;


function bool = isNumericScalar(num)

	if (~isnumeric(num) | prod(size(num))~=1 | isempty(num) | ~isfinite(num))
		bool = 0;
	else
		bool = 1; 
	end;

return;