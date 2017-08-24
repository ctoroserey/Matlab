function [null] = imdumb(neg,pos)
    x = abs(neg)>=pos;
    y = abs(neg)<pos;
    z = zeros(5000,1);
    z(x) = neg(x);
    z(y) = pos(y);
    null = abs(z);
    %nullRaw = z;
end