function p = Task_CorrectReward(p)
% default actions when a tasks ends correctly
%
%
% wolf zinke, March 2017

p.trial.outcome.CurrOutcome = p.trial.outcome.Correct;
p.trial.task.Good = 1;

pds.reward.give(p, p.trial.reward.Dur);
pds.audio.playDP(p, 'reward', 'left');

% Record main reward time
p.trial.EV.Reward = p.trial.CurTime;

ND_SwitchEpoch(p, 'WaitEnd');

