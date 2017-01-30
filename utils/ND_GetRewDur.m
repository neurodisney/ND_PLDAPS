function p = ND_GetRewDur(p) 
%
%
% wolf zinke, Jan. 2017

if(~p.trial.task.Reward.IncrConsecutive)
% increase rewards after a defined number of trials was achieved
    cNumHit = p.trial.NHits;
else
% increase reward for consecutive correct trials
    cNumHit = p.trial.LastHits;
end

s = find(~(p.trial.task.Reward.Step>cNumHit),1,'last');

if(isempty(s))
    s = 1;
end

p.trial.task.Reward.Curr = p.trial.task.Reward.Dur(s);

