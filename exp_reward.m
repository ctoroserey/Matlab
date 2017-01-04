function ER = exp_reward(prob_mass_func, large_reward, small_reward, GuT)
    
    prob_mass_func = prob_mass_func./sum(prob_mass_func);
    cum_dis_func = cumsum(prob_mass_func);

    ER = (cum_dis_func.*large_reward) + ((1-cum_dis_func).*small_reward);
    
    plot(GuT,ER);  
    hold on
    xlabel('Giving up time'); ylabel('Expected Reward');
    legend(strcat('LargeR:',' ',num2str(large_reward),', SmallR:',' ',num2str(small_reward)));
end
