function p = Task_Correct(p)
% default actions when a tasks ends correctly
%
%
% wolf zinke, March 2017

%ND_CtrlMsg(p, 'Correct Response');
pds.datapixx.strobe(p.trial.event.RESP_CORR);

p.trial.outcome.CurrOutcome = p.trial.outcome.Correct;

p.trial.Timer.Wait   = p.trial.CurTime + p.trial.reward.Lag;
p.trial.Timer.Reward = p.trial.Timer.Wait;

p.trial.CurrEpoch    = p.trial.epoch.WaitReward;
