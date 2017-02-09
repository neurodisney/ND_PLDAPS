function [cRew, p] = ND_GetRewDur(p) 
% Select current reward amount depending on a scheme that increases reward
% at defined total correct trial numbers, or within blocks of subsequent
% correct trials.
%
% wolf zinke, Jan. 2017

if(p.trial.task.Reward.IncrConsecutive)
% increase reward for consecutive correct trials
    cNumHit = p.trial.LastHits;
else
% increase rewards after a defined number of trials was achieved
    cNumHit = p.trial.NHits;
end

if(isempty(cNumHit) || cNumHit < 0)
    cNumHit = 1;
end

s = find(~(p.trial.task.Reward.Step >= cNumHit), 1, 'last');

if(isempty(s))
    s = 1;
end

cRew = p.trial.task.Reward.Dur(s);

p.trial.task.Reward.Curr = cRew;

ND_CtrlMsg(p, ['Correct Trials: ',int2str(cNumHit),' ;  Reward: ', num2str(cRew, '%.3f'), ' s']); 



