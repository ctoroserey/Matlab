function [totalRwd] = totalEarned(Matrix)
    totalRwd = sum(Matrix((find(Matrix(:,3)==1)),2));
end