function p = Task_Reward(p)
% default actions when the task starts
%
%
% wolf zinke, March 2017
if(p.trial.CurTime > p.trial.Timer.Reward)
    p.trial.EV.Reward = p.trial.CurTime - p.trial.EV.TaskStart;

    pds.reward.give(p, p.trial.reward.Curr);

    p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
end
