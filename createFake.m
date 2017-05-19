rangeMatrix = [linspace(1,8,4);linspace(0.4,2.5,4);linspace(0.35,1.8,4)];
fakeMatrix = [];
temp = wMatrix(:,:,1);
demo = [];
handling = [2 10 14];

for k = 1:5
    demo(:,k) = temp(~isnan(temp(:,1)),k);
end

clear k

for i = 1:4 % subjects
    fakeMatrix(:,1:5,i) = demo;
    for j = 1:3 % k per handling
        index = find(fakeMatrix(:,1,i)==handling(j));
        fakeMatrix(index,6,i) = rangeMatrix(j,i); % remove once it works
        for k = index
            if fakeMatrix(k,1,i).*rangeMatrix(j,i) >= fakeMatrix(k,2,i)
                fakeMatrix(k,3,i) = 0;
            else
                fakeMatrix(k,3,i) = 1;
            end    
        end    
    end
end


% version with a single k per subject
% for i = 1:length(unique(rangeMatrix))
%     for j = 1:length(demo)
%         if (demo(j,,i) .* demo(j,3,i)) == 
%         end    
%     end
% end      