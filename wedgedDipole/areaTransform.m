%function [out] = foragingOCModel(inMap,shearOut)

    % temp inputs for V2
    inMap = wdgdMapV1lower;
    shearOut = 0.33; 
    
    % dimensions of the input map
    [r,~] = size(inMap); % r is the number of eccentricities

    % vector of eccentricities 
    %ecc = 1:r; %j = 18;

    % for every eccentricity, get the polar vector
    for j = 1:r

        % isolate the real and imaginary parts
        rPart = real(wdgdMapV1lower(j,:));
        iPart = imag(wdgdMapV1lower(j,:));

        % get the difference in eccentricity and the angle by which to expand onto V2
        eccDiff = rPart(end) - rPart(1); 
        polSum = abs(min(iPart));

        % resulting vector, ready to plot
        rPartV2 = rPart - eccDiff;
        iPartV2 = iPart.*shearV2 - polSum;

        % plot
        figure
        hold on
        plot(wdgdMapV1lower)
        plot(wdgdMapV1lower.')
        plot(rPart, iPart,'ro')
        plot(rPart, iPart.*shearV2,'bo') % with shearV2
        plot(rPartV2, iPartV2,'go')

    end
    
%end