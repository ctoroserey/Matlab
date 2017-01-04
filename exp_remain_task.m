function ETask = exp_remain_task(task, prob_mass_func) % add ITI? They are estimating task remaining, not time

    prob_mass_func = prob_mass_func./sum(prob_mass_func);
    prob_mass_func = cumsum(prob_mass_func);
    x = task(end);
    
    ETask = (prob_mass_func.*(cumsum(task)./(1:length(task)))) + ((1-prob_mass_func).*task); % + ITI;
    
    plot(task,ETask);  
    xlabel('Task'); ylabel('Expected Tasks Remaining');
end
