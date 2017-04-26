

sub1=Matrix(:,:,1);

delay = sub1(1:end-1,1);
choice = sub1(1:end-1,3);
choice(choice==2)=0;
damt = sub1(1:end-1,2);
% optimal reward rates for different thresholds
rateTwo = rwd_sec([0.05,0.15,0.25],13,2);
rateFive = rwd_sec([0.05,0.15,0.25],10,5);
rateTen = rwd_sec([0.05,0.15,0.25],5,10);
rateThirt = rwd_sec([0.05,0.15,0.25],2,13);
% optimal rate
optRate = delay;
optRate(optRate==2)= max(rateTwo);
optRate(optRate==5)= max(rateFive);
optRate(optRate==10)= max(rateTen);
optRate(optRate==13)= max(rateThirt);
% opportunity cost
optCost = delay.*optRate;