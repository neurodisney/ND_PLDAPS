function p = cleanUpandSave(p)
%pds.reward.cleanUpandSave(p)    clean up after a trial
% Store any necessary data from the different reward modules. This is 
% mostly a wrapper to the other modules. But also removes any unused fields
% of p.trial.reward.timeReward
    
%nothing to do for other reward modes
p.trial.reward.timeReward(isnan(p.trial.reward.timeReward)) = [];
