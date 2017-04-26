function p = probcalc(beta,IA,DA,D)
SVdelayed = DA./(1+IA); % why exp(k)? because mink and maxk are expressed as logs, they need to be converted back
reg = exp(beta).*(SVdelayed-IA); % logodds. Exponentiated because of the same reason as 'k'
p = 1 ./ (1 + exp(-(SVdelayed-IA))); % probability 
%p(p == 1) = 1-eps;
%p(p == 0) = eps;
end
