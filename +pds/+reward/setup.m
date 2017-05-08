function p = setup(p)
%pds.reward.setup(p)    setup reward systems before the experiment
% This is mostly a wrapper to the other reward modules.

    % allocate memory in case reward is given during pause
    p.trial.reward.iReward     = 0; % counter for reward times
    totalRewards = sum(p.trial.reward.nRewards) + 1; % total number of rewards at each interval + 1 jackpot 
    p.trial.reward.timeReward  = nan(2,totalRewards);