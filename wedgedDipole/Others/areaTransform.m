function [compOut] = areaTransform(inMap,shearOut,inType,field)
    
    % inType is 1 for V1, 2 for V2
    % field = upper (1) or lower (-1) V1
    
    % dimensions of the input map
    [r,~] = size(inMap); % r is the number of eccentricities

    % vector of eccentricities 
    %ecc = 1:r; %j = 18;

    % matrix to store complex map
    compOut = NaN(size(inMap));
    
    % for every eccentricity, get the polar vector
    % for lower V1
    if field == -1
        
        for j = 1:r

            % isolate the real and imaginary parts
            rPart = flip(real(inMap(j,:))); % new 
            iPart = flip(imag(inMap(j,:)));

            % get the difference in eccentricity and the angle by which to expand onto V2
            eccDiff = rPart(end) - rPart(1); 
            polSum = abs(min(iPart));

            % resulting vector, ready to plot
            if inType == 1
                
                rPartV2 = rPart + eccDiff;
                
            else
                
                rPartV2 = rPart - eccDiff;
                
            end
            
            % compute the resulting vector
            iPartV2 = (iPart .* shearOut);
            iPartV2 = iPartV2 - polSum + abs(max(iPartV2));

            % store complex vector
            compOut(j,:) = complex(rPartV2,iPartV2);

        end
    
    % for upper V1
    elseif field == 1
        
        for j = 1:r

            % isolate the real and imaginary parts
            rPart = flip(real(inMap(j,:))); % new 
            iPart = flip(imag(inMap(j,:)));

            % get the difference in eccentricity and the angle by which to expand onto V2
            eccDiff = rPart(end) - rPart(1); 
            polSum = abs(max(iPart));

            % resulting vector, ready to plot
            if inType == 1
                
                rPartV2 = rPart - eccDiff;
                
            else
                
                rPartV2 = rPart + eccDiff;
                
            end
            
            % compute the resulting vector
            iPartV2 = (iPart .* shearOut);
            iPartV2 = iPartV2 + polSum - abs(min(iPartV2));

            % store complex vector
            compOut(j,:) = complex(rPartV2,iPartV2);

        end
        
    end
    
end