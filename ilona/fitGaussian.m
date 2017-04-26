
% Fit a gaussian to data using fminsearch


startValues = [0.1, 0.1, 10]; % mean, sigma, amplitude
options = optimset('MaxFunEvals', 10000, 'MaxIter', 10000);
y_data = [0 0 5 26 10 5 0 1 0 0]; % created using hist to count number of observations per bin..
x_data = linspace(0,1,10);

[param_estimates, r2] = fminsearch('mygauss', startValues, options, y_data, x_data);

x_fit = linspace(0,1,100);
y_est = param_estimates(3)*exp(-(x_fit-param_estimates(1)).^2/(param_estimates(2)^2));

% plot
figure('Color', [1 1 1]),
plot(x_data, y_data, 'ok');
hold on,
plot(x_fit, y_est, 'r');
xlabel('Contrast (%)'); ylabel('# Estimates'); box off; legend({'Data' 'Best line fit'})
title(['R2 = ' num2str(-r2)])


function r2 = mygauss(params, data, x)

mu = params(1); % mean of the distributiom
sigma = params(2); % spread
A = params(3); % amplitude - scaling
% b = params(4); % baseline shift
b = 0;

output_hat = b + A*exp(-(x-mu).^2/(sigma^2));


r2=1-((sum(((output_hat)-(data)).^2))/ (sum(((data)-mean((data))).^2)));
r2=-r2;
end