function ETime = exp_remain_time(time, prob_mass_func, ITI)

    prob_mass_func = prob_mass_func./sum(prob_mass_func);
    prob_mass_func = cumsum(prob_mass_func);
    x = cumsum(time)./(1:length(time));
    
    ETime = (prob_mass_func.*(cumsum(time)./(1:length(time)))) + ((1-prob_mass_func).*time) + ITI;
    
    plot(time,ETime);  
    xlabel('Time'); ylabel('Expected Time Remaining');
end
