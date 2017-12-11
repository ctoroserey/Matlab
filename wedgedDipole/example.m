
% example on what I did to map V1 -> V2 -> V3 visually

inMap = maps.V2v;
j = 2;
inType = 2;
shearOut = 0.33;

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

figure
hold on
plot(inMap,'k')
plot(inMap.','k')
plot(rPart, iPart,'ro')
plot(rPart, iPart.*shearOut,'bo') % with shearV2
plot(rPartV2, iPartV2,'go')
        
