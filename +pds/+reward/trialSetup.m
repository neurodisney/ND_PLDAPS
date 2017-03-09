function p = trialSetup(p)
%pds.reward.trialSetup(p)    allocate memory for use during the trial
    p.trial.reward.iReward     = 1; % counter for reward times
    p.trial.reward.timeReward  = nan(2,p.trial.pldaps.maxTrialLength*2); %preallocate for a reward up to every 0.5 s