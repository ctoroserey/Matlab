function [compOut] = areaTransform(inMap,shearOut)

    % temp inputs for V2
    %inMap = wdgdMapV1lower;
    %shearOut = 0.33; 
    
    % dimensions of the input map
    [r,~] = size(inMap); % r is the number of eccentricities

    % vector of eccentricities 
    %ecc = 1:r; %j = 18;

    % matrix to store complex map
    compOut = NaN(size(inMap));
    
    % for every eccentricity, get the polar vector
    for j = 1:r

        % isolate the real and imaginary parts
        rPart = flip(real(inMap(j,:))); % original real(inMap(j,:))
        iPart = flip(imag(inMap(j,:))); % original imag(inMap(j,:))

        % get the difference in eccentricity and the angle by which to expand onto V2
        eccDiff = rPart(end) - rPart(1); 
        polSum = abs(min(iPart));

        % resulting vector, ready to plot
        rPartV2 = rPart + eccDiff; % original is a minus
        iPartV2 = (iPart .* shearOut);
        iPartV2 = iPartV2 - polSum + abs(max(iPartV2));

        % plot
%         figure
%         hold on
%         plot(inMap)
%         plot(inMap.')
%         plot(rPart, iPart,'ro')
%         plot(rPart, iPart.*shearOut,'bo') % with shearV2
%         plot(rPartV2, iPartV2,'go')
        
        % store complex vector
        compOut(j,:) = complex(rPartV2,iPartV2);

    end
    
end