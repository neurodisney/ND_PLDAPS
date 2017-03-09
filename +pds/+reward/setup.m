function p = setup(p)
%pds.reward.setup(p)    setup reward systems before the experiment
% This is mostly a wrapper to the other reward modules.

    % allocate memory in case reward is given during pause
    p.trial.reward.iReward     = 1; % counter for reward times
    p.trial.reward.timeReward  = nan(2,15);