function [SVlater,predictedChoice,out] = foraging_hyp(choseDelayed,ImmedAmt,DelAmt,Delay)
% choseDelayed = 1 if delayed option is chosen, 0 if immediate option is chosen. Others are no choices
% All inputs must be column vectors. 2016-Jun-07, Arthur.
% This version has been modified to act as a null-test, using just noise
% and the opportunity cost of time (oportRate.*delay)to estimate optimal
% discounting.

out.percentNow = (sum(choseDelayed == 0) / length(choseDelayed)) * 100;
out.percentDelayed = (sum(choseDelayed == 1) / length(choseDelayed)) * 100;
miss = choseDelayed ~= 0 & choseDelayed ~= 1;
out.percentMissed = (sum(miss)/length(choseDelayed)) * 100;
choice = choseDelayed(~miss);
IA = ImmedAmt(~miss); % opportunitycost
DA = DelAmt(~miss);
D = Delay(~miss);

if (sum(choice) == length(choice)) || (sum(choice) == 0) % if choices are one-sided
    if sum(choice) == length(choice)
        out.k=exp(min(IA./D));
    else
        out.k=exp(max(IA./D));
    end
    out.noise = nan;
    out.LL = 0;
else
    b = [-1, 1]; % replaces the noise parameter
    info.negLL = inf;
    for i = 1:length(b)
        % tried using fminsearch per Ilona's recommendation. Could work
        %[new.b,new.negLL] = fminsearch(@negLL,b(i),optimset('Algorithm','interior-point','Display','off'),choice,IA,DA,D);
        [new.b,new.negLL] = fmincon(@negLL,b(i),[],[],[],[],[log(eps)],[-log(eps)],[],optimset('Algorithm','interior-point','Display','off'),choice,IA,DA); %,D);
        if new.negLL < info.negLL
            info = new;
        end
    end
    out.noise = exp(info.b);
    out.LL = -info.negLL;
    % add plotting options
end
out.LL0 = log(0.5)*length(choice);
out.r2 = 1 - out.LL/out.LL0;
SVlater = DA ./(1+IA);
predictedChoice = SVlater > IA; % 1 if delayed option is greater
out.percentPredicted = sum(predictedChoice == choice) / length(choice) * 100;
end

function negLL = negLL(beta,choice,IA,DA) % ,D)
p = probcalc(beta,IA,DA); % ,D);
negLL = -sum((choice==1).*log(p) + (choice==0).*log(1-p));
end

function p = probcalc(beta,IA,DA) % ",D)" removed because IA currently means opportCost 
SVdelayed = DA-IA; % why exp(k)? because mink and maxk are expressed as logs, they need to be converted back
reg = exp(beta).*(SVdelayed); % logodds. Exponentiated because of the same reason as 'k'
p = 1 ./ (1 + exp(-reg)); % probability 
p(p == 1) = 1-eps;
p(p == 0) = eps;
end

