%% gaussian function

function r2 = mygauss(params, data, x)

mu = params(1); % mean of the distributiom
sigma = params(2); % spread
A = params(3); % amplitude - scaling
% b = params(4); % baseline shift
b = 0;

output_hat = b + A*exp(-(x-mu).^2/(sigma^2));


r2=1-((sum(((output_hat)-(data)).^2))/ (sum(((data)-mean((data))).^2)));
r2=-r2;

